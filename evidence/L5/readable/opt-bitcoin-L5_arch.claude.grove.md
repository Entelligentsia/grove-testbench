# transcript: Give a complete architectural walkthrough of how Bitcoin Core validates and connects a new block to the chain — the cross-cutting block-connection architectu...


💬 I'll use grove to navigate this systematically. Let me load the grove tools and then explore each subsystem in parallel.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now I'll fan out and explore all subsystems in parallel — net_processing, validation, coins/UTXO, and mempool.
  ▸ mcp__grove__outline({"file":"src/net_processing.cpp","detail":0})
  ▸ mcp__grove__outline({"file":"src/validation.cpp","detail":0})
  ▸ mcp__grove__outline({"file":"src/validation.h","detail":0})

💬 Good. Now I'll fetch the bodies of all key functions in parallel — the full pipeline from block receipt to mempool reconciliation.
  ▸ mcp__grove__source({"id":"cpp:src/net_processing.cpp#ProcessBlock@3455"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ProcessNewBlock@4405"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptBlock@4305"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ActivateBestChain@3330"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ActivateBestChainStep@3198"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ConnectTip@3019"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ConnectBlock@2301"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#UpdateCoins@2005"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#UpdateTip@2896"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#MaybeUpdateMempoolForReorg@302"})
  ▸ mcp__grove__source({"id":"cpp:src/net_processing.cpp#BlockConnected@2094"})

💬 Now I'll grab the remaining pieces — the P2P message handler, mempool `removeForBlock`, `AcceptBlockHeader`, `ReceivedBlockTransactions`, and the coins view ...
  ▸ mcp__grove__source({"file":"src/net_processing.cpp","name":"ProcessHeadersMessage"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptBlockHeader@4193"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ReceivedBlockTransactions@3772"})
  ▸ mcp__grove__symbols({"dir":"src/txmempool.cpp","name":"removeForBlock"})
  ▸ mcp__grove__outline({"file":"src/coins.h","detail":0})
  ▸ mcp__grove__outline({"file":"src/coins.cpp","detail":0})

💬 Now fetching `removeForBlock`, `DisconnectTip`, `CheckInputScripts`, and the `ProcessMessage` block/headers handler — the last pieces of the puzzle.
  ▸ mcp__grove__source({"id":"cpp:src/txmempool.cpp#removeForBlock@405"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#DisconnectTip@2943"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#CheckInputScripts@2067"})
  ▸ mcp__grove__source({"id":"cpp:src/net_processing.cpp#ProcessHeadersMessage@2989"})
  ▸ mcp__grove__source({"id":"cpp:src/net_processing.cpp#ProcessCompactBlockTxns@3472"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#FindMostWorkChain@3128"})

💬 I now have everything needed. Here is the complete architectural walkthrough.  ---  # Bitcoin Core: Block Connection Architecture  ## Overview of the pipelin...

──────── RESULT (success, 294366ms, 28 turns) ────────
I now have everything needed. Here is the complete architectural walkthrough.

---

# Bitcoin Core: Block Connection Architecture

## Overview of the pipeline

```
[P2P peer] → ProcessMessage → ProcessBlock
                                   │
                            ProcessNewBlock (ChainstateManager)
                                   ├─ CheckBlock
                                   ├─ AcceptBlock
                                   │     ├─ AcceptBlockHeader → AddToBlockIndex
                                   │     ├─ CheckBlock + ContextualCheckBlock
                                   │     ├─ WriteBlock (disk)
                                   │     └─ ReceivedBlockTransactions
                                   │
                            ActivateBestChain (Chainstate)
                                   └─ ActivateBestChainStep
                                         ├─ [reorg] DisconnectTip × N
                                         ├─ ConnectTip
                                         │     ├─ ConnectBlock
                                         │     │     ├─ CheckTxInputs (per tx)
                                         │     │     ├─ CheckInputScripts → CCheckQueue
                                         │     │     └─ UpdateCoins → SpendCoin / AddCoin
                                         │     ├─ view.Flush → CoinsTip
                                         │     ├─ removeForBlock (mempool)
                                         │     ├─ m_chain.SetTip
                                         │     └─ UpdateTip
                                         └─ MaybeUpdateMempoolForReorg
```

---

## Phase 1 — Block Receipt in P2P (`src/net_processing.cpp`)

### 1.1 Message dispatch

`PeerManagerImpl::ProcessMessages` (`net_processing.cpp:5141`) is called from the net thread for each peer. It dispatches to `ProcessMessage` (`net_processing.cpp:3603`), which switches on the P2P message type string.

**Headers path** (`headers` / compact block announcements):

`ProcessMessage` calls `ProcessHeadersMessage` (`net_processing.cpp:2989`). This function:
- Calls `CheckHeadersPoW` (`net_processing.cpp:2647`) — checks that each header has valid proof-of-work before doing anything else (anti-DoS).
- Optionally runs `TryLowWorkHeadersSync` (`net_processing.cpp:2795`) for chains with insufficient work.
- Calls `m_chainman.ProcessNewBlockHeaders(headers, min_pow_checked=true, ...)` — validates and indexes headers into the block index.
- Calls `UpdatePeerStateForReceivedHeaders` (`net_processing.cpp:2938`) — updates per-peer block availability tracking.
- Calls `HeadersDirectFetchBlocks` (`net_processing.cpp:2872`) — if the announced tip is new and we're close to the tip, immediately sends `GETDATA` for the full block.

**Compact block path** (`cmpctblock` + `blocktxn`):

After receiving a `cmpctblock` and filling missing transactions, `ProcessCompactBlockTxns` (`net_processing.cpp:3472`) reconstructs the full block via `PartiallyDownloadedBlock::FillBlock`, then calls `ProcessBlock` (`net_processing.cpp:3455`).

**Full block path** (`block` message):

`ProcessMessage` at the `block` message type calls `ProcessBlock` directly.

### 1.2 `PeerManagerImpl::ProcessBlock` — `net_processing.cpp:3455`

```cpp
void PeerManagerImpl::ProcessBlock(CNode& node,
    const std::shared_ptr<const CBlock>& block,
    bool force_processing, bool min_pow_checked)
```

This is the thin P2P→validation bridge. It calls `m_chainman.ProcessNewBlock(block, force_processing, min_pow_checked, &new_block)`. On success it updates `node.m_last_block_time` and clears the in-flight request tracking.

---

## Phase 2 — Block Storage (`src/validation.cpp`, `ChainstateManager`)

### 2.1 `ChainstateManager::ProcessNewBlock` — `validation.cpp:4405`

This is the single public entry point for any new block, whether from P2P, RPC, or internal. Under `cs_main`:

1. Calls `CheckBlock(*block, state, GetConsensus())` — lightweight structural validation: merkle root, witness malleation, size, sigop limits. This is done *before* `AcceptBlock` so malformed blocks never touch the block index (see the CVE-2012-2459 comment in the source).

2. On success, calls `AcceptBlock(block, state, &pindex, force_processing, nullptr, new_block, min_pow_checked)`.

Then outside `cs_main`:

3. Calls `NotifyHeaderTip()` — signals observers of new best header.
4. Calls `ActiveChainstate().ActivateBestChain(state, block)`.
5. If an assumeutxo background chainstate exists: also calls `bg_chain->ActivateBestChain(bg_state, block)`.

### 2.2 `ChainstateManager::AcceptBlock` — `validation.cpp:4305`

Requires `cs_main`. This function decides whether to actually store the block to disk.

**Step 1 — Index the header:**

Calls `AcceptBlockHeader(block, state, &pindex, min_pow_checked)` (`validation.cpp:4193`).

- Deduplicates via `m_blockman.m_block_index` (the `BlockMap`, an `std::unordered_map<uint256, CBlockIndex>`).
- Calls `CheckBlockHeader` (`validation.cpp:3835`) — validates PoW and block version.
- Walks back to `pindexPrev` and calls `ContextualCheckBlockHeader` (`validation.cpp:4087`) — enforces timestamp rules (Median Time Past), difficulty target, and version soft-fork thresholds.
- On a genuinely new header: calls `m_blockman.AddToBlockIndex(block, m_best_header)`, which allocates a `CBlockIndex` node and links it into the tree via `pprev`. Updates `m_best_header` if this has more work.

**Step 2 — Anti-DoS guards:**

Checks `fAlreadyHave` (data already on disk), `fHasMoreOrSameWork` (at least as much chain work as our tip), `fTooFarAhead` (more than `MIN_BLOCKS_TO_KEEP`=288 blocks ahead of tip). Unrequested blocks that fail these checks are dropped silently.

**Step 3 — Full contextual validation:**

Calls `CheckBlock` + `ContextualCheckBlock` (`validation.cpp:4136`). `ContextualCheckBlock` enforces BIP34 (height in coinbase), BIP65/68 (locktime/sequence), and witness commitment. If either fails, calls `InvalidBlockFound`.

**Step 4 — Write to disk:**

Calls `m_blockman.WriteBlock(block, pindex->nHeight)` → returns a `FlatFilePos` (file index + byte offset into `blk?????.dat`).

**Step 5 — Mark available:**

Calls `ReceivedBlockTransactions(block, pindex, blockPos)` (`validation.cpp:3772`):
- Sets `pindexNew->nTx`, `nFile`, `nDataPos`, `nStatus |= BLOCK_HAVE_DATA`.
- Sets `pindexNew->m_chain_tx_count` (cumulative tx count from genesis).
- Calls `pindex->RaiseValidity(BLOCK_VALID_TRANSACTIONS)`.
- Propagates `m_chain_tx_count` forward through any queued orphan blocks in `m_blocks_unlinked`.
- For each newly linkable block calls `c->TryAddBlockIndexCandidate(pindex)` — inserts into `setBlockIndexCandidates` (a `std::set<CBlockIndex*, CBlockIndexWorkComparator>`), which is the priority queue that `FindMostWorkChain` scans.

**Step 6:** Calls `ActiveChainstate().FlushStateToDisk(state, FlushStateMode::NONE)` — allows pruning stale block files but does not force a UTXO flush yet.

---

## Phase 3 — Chain Activation (`src/validation.cpp`, `Chainstate`)

### 3.1 `Chainstate::ActivateBestChain` — `validation.cpp:3330`

This function holds `m_chainstate_mutex` (its own per-chainstate mutex) for the entire duration, preventing concurrent re-entry. It then enters a `do { ... } while (pindexNewTip != pindexMostWork)` loop that releases and re-acquires `cs_main` between iterations, allowing other threads to run.

Inner loop (under both `cs_main` and `MempoolMutex()`):

1. Calls `FindMostWorkChain()` if `pindexMostWork == nullptr`.
2. Calls `ActivateBestChainStep(state, *pindexMostWork, pblock, fInvalidFound, connected_blocks)`.
3. Iterates `connected_blocks` and fires `signals->BlockConnected(chainstate_role, block, index)` for each.
4. Fires `signals->UpdatedBlockTip(pindexNewTip, pindexFork, still_in_ibd)` and `GetNotifications().blockTip(...)`.
5. Calls `signals->ActiveTipChange(*pindexNewTip, IsInitialBlockDownload())`.
6. Calls `FlushStateToDisk(PERIODIC)` — flushes UTXO cache to LevelDB if dirty and overdue.

### 3.2 `Chainstate::FindMostWorkChain` — `validation.cpp:3128`

Scans `setBlockIndexCandidates` from the highest-work end (reverse iterator). For each candidate it walks the ancestry back to the active chain, checking `BLOCK_FAILED_VALID` and `BLOCK_HAVE_DATA`. Invalid or data-missing ancestors cause the whole subtree to be ejected from candidates. Returns the first fully-valid, fully-available candidate.

### 3.3 `Chainstate::ActivateBestChainStep` — `validation.cpp:3198`

Requires `cs_main` and `m_mempool->cs`.

**Reorg — disconnecting old blocks:**

Finds the fork point: `pindexFork = m_chain.FindFork(index_most_work)`. While `m_chain.Tip() != pindexFork`, calls `DisconnectTip(state, &disconnectpool)` — see §3.4. Collects disconnected transactions into a `DisconnectedBlockTransactions disconnectpool`.

**Connecting new blocks:**

Builds `vpindexToConnect` (in batches of up to 32 to avoid iterating the full list). For each `pindexConnect` in forward height order: calls `ConnectTip(state, pindexConnect, pblock, connected_blocks, disconnectpool)` — see §4.

**After connecting:**

If any blocks were disconnected calls `MaybeUpdateMempoolForReorg(disconnectpool, true)` — see §6.2.
Calls `m_mempool->check(CoinsTip(), m_chain.Height()+1)` — integrity check in debug builds.
Calls `CheckForkWarningConditions()` — alerts if a competing chain has significant work.

### 3.4 `Chainstate::DisconnectTip` — `validation.cpp:2943` (reorg path)

Requires `cs_main` and `m_mempool->cs`. Reads the tip block from disk, then:

1. Creates a local `CCoinsViewCache view(&CoinsTip())`.
2. Calls `DisconnectBlock(block, pindexDelete, view)` (`validation.cpp:2185`) — applies the stored undo data (`CTxUndo`) in reverse: for each non-coinbase tx, calls `ApplyTxInUndo` to restore spent coins; for each output created in the block, calls `view.SpendCoin()`. Updates `view.SetBestBlock(pindexDelete->pprev->GetBlockHash())`.
3. `view.Flush()` — commits restored coins back to `CoinsTip()`.
4. Calls `disconnectpool.AddTransactionsFromBlock(block.vtx)` — queues block txs for re-submission to mempool.
5. Calls `m_chain.SetTip(*pindexDelete->pprev)` — retracts the chain pointer.
6. Calls `UpdateTip(pindexDelete->pprev)`.
7. Fires `signals->BlockDisconnected(pblock, pindexDelete)` — notifies wallets, indexes.

---

## Phase 4 — `ConnectTip` + `ConnectBlock` (`src/validation.cpp`)

### 4.1 `Chainstate::ConnectTip` — `validation.cpp:3019`

Requires `cs_main` and `m_mempool->cs`. This is the atomic "apply one block" operation.

1. **Load block:** If not passed in-memory (as `block_to_connect`), calls `m_blockman.ReadBlock(*pblockNew, *pindexNew)`.

2. **Apply to UTXO cache:** Gets `CCoinsViewCache& view = *m_coins_views->m_connect_block_view` (a single-block scratch cache layered on top of `m_catcherview`). Creates a reset guard. Calls `ConnectBlock(*block_to_connect, state, pindexNew, view)` — see §4.2.

3. Fires `signals->BlockChecked(block_to_connect, state)` — informs `PeerManagerImpl::BlockChecked` which handles banning/score updates.

4. **Flush the view:** Calls `view.Flush(reallocate_cache=false)` — writes all dirty coins from the scratch cache into `m_catcherview` (the main `CCoinsViewCache`). At this point the UTXO set in memory reflects the new tip.

5. **Persist chainstate:** Calls `FlushStateToDisk(state, FlushStateMode::IF_NEEDED)` — if the coins cache exceeds `nCoinCacheUsage`, writes dirty entries to LevelDB (`m_dbview`).

6. **Mempool eviction:** Calls `m_mempool->removeForBlock(block_to_connect->vtx, pindexNew->nHeight)` — see §6.1. Also calls `disconnectpool.removeForBlock(block_to_connect->vtx)` — prevents disconnected transactions that are now in this block from being re-added.

7. **Advance tip:** `m_chain.SetTip(*pindexNew)` — moves the `CChain` pointer (the canonical chain of `CBlockIndex*`).

8. **Update IBD status:** `m_chainman.UpdateIBDStatus()`.

9. **Notify state:** `UpdateTip(pindexNew)` — see §6.3.

10. **Snapshot validation:** `m_chainman.MaybeValidateSnapshot(*this, current_cs)` — if this is the background chainstate that just caught up to its target, hashes the UTXO set and validates it against the assumeutxo metadata.

11. Appends `{pindexNew, block}` to `connected_blocks` for the caller to fire `BlockConnected` signals.

### 4.2 `Chainstate::ConnectBlock` — `validation.cpp:2301`

This is the consensus-critical validation core. Requires `cs_main`. Operates on a `CCoinsViewCache& view` that is the scratch cache initialized to the previous block's UTXO state.

**Sanity re-check:**
Re-runs `CheckBlock(block, state, params.GetConsensus(), !fJustCheck, !fJustCheck)`. Asserts `view.GetBestBlock() == hashPrevBlock`.

**AssumeValid bypass logic:**
Computes `script_check_reason` — whether to run script checks at all. Script verification is skipped for blocks that are ancestors of the `assumevalid` block and are sufficiently buried (more than two weeks before the best header). This is the critical performance optimization for IBD.

**BIP30 check:**
If `fEnforceBIP30`: iterates every output of every tx and verifies no existing unspent coin at that `COutPoint` in the view.

**Script flags:** Calls `GetBlockScriptFlags(*pindex, m_chainman)` (`validation.cpp:2256`) — returns the set of `script_verify_flags` active at this height (P2SH, DERSIG, CHECKLOCKTIMEVERIFY, CSV, SEGWIT, TAPROOT, etc.) by walking the deployment state.

**Parallel script check setup:** If the thread pool has workers and scripts are being checked, creates `CCheckQueueControl<CScriptCheck> control(m_chainman.GetCheckQueue())`.

**Per-transaction loop** (over `block.vtx`):

For each non-coinbase transaction:
- `Consensus::CheckTxInputs(tx, tx_state, view, pindex->nHeight, txfee)` (`src/consensus/tx_verify.cpp`) — verifies all inputs exist in the view as unspent, no overflow, valid amounts. Accumulates `nFees`.
- BIP68: reads `prevheights[j] = view.AccessCoin(tx.vin[j].prevout).nHeight` for each input, then calls `SequenceLocks(tx, nLockTimeFlags, prevheights, *pindex)`.
- `GetTransactionSigOpCost(tx, view, flags)` — accumulates sigop cost, enforced against `MAX_BLOCK_SIGOPS_COST`.
- `CheckInputScripts(tx, tx_state, view, flags, fCacheResults, fCacheResults, txsdata[i], m_chainman.m_validation_cache, &vChecks)` (`validation.cpp:2067`) — see §4.3.
  - If parallel: appends `CScriptCheck` objects to `control` for async verification.
  - If serial: runs immediately.
- `UpdateCoins(tx, view, blockundo.vtxundo.back(), pindex->nHeight)` — see §5.

**Coinbase reward check:** Verifies `block.vtx[0]->GetValueOut() <= nFees + GetBlockSubsidy(pindex->nHeight, ...)`.

**Parallel script wait:** `control->Complete()` — blocks until all queued `CScriptCheck` tasks finish and collects any failure.

**Write undo data:** `m_blockman.WriteBlockUndo(blockundo, state, *pindex)` — serializes `CBlockUndo` (the per-tx undo vectors of spent coins) to `rev?????.dat`. This is what `DisconnectBlock` reads during reorgs.

**Finalize:** `view.SetBestBlock(pindex->GetBlockHash())` — marks the view as representing this block's post-state. `pindex->RaiseValidity(BLOCK_VALID_SCRIPTS)`.

### 4.3 `CheckInputScripts` — `validation.cpp:2067`

```cpp
bool CheckInputScripts(const CTransaction& tx, TxValidationState& state,
                       const CCoinsViewCache& inputs, script_verify_flags flags,
                       bool cacheSigStore, bool cacheFullScriptStore,
                       PrecomputedTransactionData& txdata,
                       ValidationCache& validation_cache,
                       std::vector<CScriptCheck>* pvChecks)
```

1. **Script execution cache:** Computes a SHA256 hash of `(tx.GetWitnessHash() ‖ flags)`. Checks `validation_cache.m_script_execution_cache` (a cuckoo cache). If the entry exists, the entire tx passes without re-running any scripts.

2. **Prepare sighash data:** Calls `txdata.Init(tx, spent_outputs)` — precomputes the sighash for SegWit inputs.

3. **Per-input verification:** For each input, creates `CScriptCheck(spent_output, tx, validation_cache.m_signature_cache, i, flags, cacheSigStore, &txdata)`. The `CScriptCheck::operator()()` calls `VerifyScript` → the script interpreter in `src/script/interpreter.cpp`.

4. If `pvChecks != nullptr` (parallel path): moves checks into the vector for `CCheckQueueControl::Add`. Otherwise runs immediately.

5. On full success with `cacheFullScriptStore`: inserts the hash into `m_script_execution_cache`.

---

## Phase 5 — UTXO / Coins Set Updates

### 5.1 Coins view layer hierarchy

```
CCoinsView (abstract, src/coins.h)
    └─ CCoinsViewDB            — LevelDB backend (src/txdb.cpp)
         └─ CCoinsViewErrorCatcher   — wraps DB read errors
              └─ CCoinsViewCache (m_catcherview)   — main in-memory cache
                   └─ CCoinsViewCache (m_connect_block_view)  — per-block scratch
```

`CoinsViews` (`src/validation.h:509`) bundles these together. `Chainstate::CoinsTip()` returns `m_catcherview`. `ConnectTip` uses `m_connect_block_view` as a single-block staging area.

Each `CCoinsViewCache` holds a `CCoinsMap` (an `std::unordered_map<COutPoint, CCoinsCacheEntry>`) of dirty coins. `CCoinsCacheEntry` carries a `Coin` (the `CTxOut` + `nHeight` + `fCoinBase` flag) plus dirty/fresh flags.

### 5.2 `UpdateCoins` — `validation.cpp:2005`

```cpp
void UpdateCoins(const CTransaction& tx, CCoinsViewCache& inputs,
                 CTxUndo& txundo, int nHeight)
```

For non-coinbase transactions:
- For each `txin`: calls `inputs.SpendCoin(txin.prevout, &txundo.vprevout.back())` (`coins.cpp:132`) — looks up the coin, copies it into the undo entry, then marks the cache entry dirty and removes the coin (sets it to `IsSpent()`).

Then for all transactions (including coinbase):
- Calls `AddCoins(inputs, tx, nHeight)` (`coins.cpp:121`) — iterates `tx.vout`, calling `inputs.AddCoin(COutPoint(tx.GetHash(), i), Coin(out, nHeight, tx.IsCoinBase()), ...)` for each non-OP_RETURN output.

`CCoinsViewCache::Flush` (`coins.cpp:260`) propagates all dirty `CCoinsCacheEntry` objects into the parent view via `BatchWrite`. When `m_connect_block_view.Flush()` is called in `ConnectTip`, the dirty coins flow into `m_catcherview`. When `FlushStateToDisk` triggers, `m_catcherview.Sync()` / `m_catcherview.Flush()` writes to `CCoinsViewDB::BatchWrite`, which serializes to LevelDB using `CDBBatch`.

---

## Phase 6 — Tip Update and Mempool Reconciliation

### 6.1 `CTxMemPool::removeForBlock` — `src/txmempool.cpp:405`

Called from `ConnectTip` while holding both `cs_main` and `m_mempool->cs`.

```cpp
void CTxMemPool::removeForBlock(
    const std::vector<CTransactionRef>& vtx, unsigned int nBlockHeight)
```

For each transaction in the block:
- Looks it up in `mapTx` by txid. If found: calls `removeUnchecked(it, MemPoolRemovalReason::BLOCK)` — removes the entry and all its package state from the mempool data structures (`mapTx`, `mapNextTx`, `mapLinks`, fee stats, etc.).
- Calls `removeConflicts(*tx)` — finds all transactions spending any of the same inputs via `mapNextTx`, and calls `removeRecursive` on them with `MemPoolRemovalReason::CONFLICT`.
- Calls `ClearPrioritisation(tx->GetHash())`.

After the loop:
- Fires `signals->MempoolTransactionsRemovedForBlock(txs_removed_for_block, nBlockHeight)`.
- Sets `blockSinceLastRollingFeeBump = true` — allows the rolling minimum fee to decay.
- Calls `m_txgraph->DoWork(POST_CHANGE_COST)` — re-runs cluster mempool's linearization algorithm on affected clusters.

### 6.2 `Chainstate::MaybeUpdateMempoolForReorg` — `validation.cpp:302`

Called from `ActivateBestChainStep` after any disconnect/connect cycle. On the reorg path (`fAddToMempool=true`):

- Iterates `disconnectpool.take()` in reverse chronological order (earliest disconnected tx first).
- For each tx (non-coinbase): calls `AcceptToMemoryPool(*this, *it, GetTime(), bypass_limits=true, test_accept=false)`. `bypass_limits=true` means fee rate and mempool size limits are relaxed.
- Coinbases and ATMP failures: calls `m_mempool->removeRecursive(**it, MemPoolRemovalReason::REORG)`.
- After re-adding: calls `m_mempool->UpdateTransactionsFromBlock(vHashUpdate)` — fixes descendant fee and size accounting for re-added transactions.
- Calls `m_mempool->removeForReorg(...)` — removes transactions that are no longer `CheckFinalTxAtTip` valid or that fail `CheckSequenceLocksAtTip` at the new tip, or whose coinbase input is immature.

### 6.3 `Chainstate::UpdateTip` — `validation.cpp:2896`

Called from both `ConnectTip` and `DisconnectTip`. For the active chainstate:
- Calls `m_mempool->AddTransactionsUpdated(1)` — bumps the mempool's sequence counter, invalidating any RPC iterators.
- Calls `m_chainman.m_versionbitscache.CheckUnknownActivations(pindexNew, GetParams())` — scans version bits for deployments not known to this software; fires `warningSet(UNKNOWN_NEW_RULES_ACTIVATED, ...)` if any threshold is crossed.
- Calls `UpdateTipLog(...)` — emits the standard "new best=" log line.

### 6.4 `PeerManagerImpl::BlockConnected` — `net_processing.cpp:2094`

Fired via the `ValidationInterface` signals bus once `ActivateBestChain` has confirmed the new tip:
- Updates `m_last_tip_update` — resets the stale-tip eviction timer.
- Decays `m_block_stalling_timeout` back toward the default (2s).
- For non-historical, non-IBD chainstates: calls `m_txdownloadman.BlockConnected(pblock)` — removes all transactions in the block from the tx download tracking structures (inv sets, orphan map, announced-from-peer sets).

---

## Key Classes and Their Roles

| Class | File | Role |
|---|---|---|
| `PeerManagerImpl` | `net_processing.cpp:501` | P2P message dispatch, block download orchestration |
| `CNode` | `net.h` | Per-peer connection state |
| `ChainstateManager` | `validation.h:902` | Owns all chainstates; `ProcessNewBlock`, `AcceptBlock`, `AcceptBlockHeader` |
| `Chainstate` | `validation.h:527` | Single chain's state: `ActivateBestChain`, `ConnectBlock`, `UpdateTip` |
| `CBlockIndex` | `chain.h` | Block index node: height, hash, work, status flags, pprev tree |
| `CChain` | `chain.h` | Active chain as a `std::vector<CBlockIndex*>` (height-indexed) |
| `BlockManager` | `node/blockstorage.h` | `blk?????.dat` / `rev?????.dat` I/O, `m_block_index` map |
| `CoinsViews` | `validation.h:509` | Owns DB + cache + scratch-cache view stack |
| `CCoinsViewCache` | `coins.h` | In-memory UTXO cache; `SpendCoin`, `AddCoin`, `Flush`, `BatchWrite` |
| `CCoinsViewDB` | `txdb.h` | LevelDB-backed UTXO persistence |
| `CTxMemPool` | `txmempool.h` | In-memory mempool; `removeForBlock`, `removeConflicts`, cluster graph |
| `DisconnectedBlockTransactions` | `txmempool.h` | Temporary buffer of txs from disconnected blocks pending re-admission |
| `ValidationCache` | `validation.h` | `m_script_execution_cache` (cuckoo) + `m_signature_cache` |
| `CCheckQueue` | `checkqueue.h` | Thread pool for parallel `CScriptCheck` execution |
| `CBlockUndo` / `CTxUndo` | `undo.h` | Undo data (spent coins) for each block; written to `rev?????.dat` |

---

## Locking Protocol

Three locks govern this pipeline:

```
cs_main          — global chainstate lock; held for AcceptBlock, ConnectBlock, header ops
m_chainstate_mutex — per-Chainstate; held for entire ActivateBestChain call; allows
                     cs_main to be released between step iterations
m_mempool->cs    — mempool lock; held jointly with cs_main inside ActivateBestChainStep;
                   both ConnectTip and MaybeUpdateMempoolForReorg require both
```

The deliberate `cs_main` release between `ActivateBestChainStep` iterations (in the `ActivateBestChain` loop) is the key design that prevents the validation engine from starving the RPC thread during large reorgs.

---

## Unified Architecture Diagram

```
                        ┌──────────────┐
                        │  P2P Thread  │  (net.cpp: CConnman, socket I/O)
                        └──────┬───────┘
                               │ message bytes
                        ┌──────▼───────┐
                        │ ProcessMessages│  net_processing.cpp:5141
                        │ ProcessMessage │  net_processing.cpp:3603
                        └──────┬───────┘
              ┌────────────────┼─────────────────────┐
     headers/cmpctblock        │ block            blocktxn
              │                │                     │
   ProcessHeadersMessage   ProcessBlock       ProcessCompactBlockTxns
   :2989                   :3455              :3472
     │ ProcessNewBlockHeaders  │                     │ FillBlock
     │ (→ AcceptBlockHeader    │                     │ (PartiallyDownloadedBlock)
     │    × each header)       └──────────┬──────────┘
     │ HeadersDirectFetchBlocks           │
     │  → GETDATA                         │
     └────────────────────────────────────┘
                                          │
                               ┌──────────▼──────────────────┐
                               │  ChainstateManager           │  validation.cpp
                               │  ::ProcessNewBlock :4405     │
                               │                              │
                               │  1. LOCK(cs_main)            │
                               │  2. CheckBlock()    :3925    │  ← merkle, size, sigops
                               │  3. AcceptBlock()   :4305    │
                               │     ├─AcceptBlockHeader :4193│  ← PoW, timestamp, index
                               │     │  ├─CheckBlockHeader    │
                               │     │  ├─ContextualCheckBlkHdr│
                               │     │  └─AddToBlockIndex     │  → BlockMap (CBlockIndex tree)
                               │     ├─CheckBlock+ContextualCheckBlock
                               │     ├─WriteBlock()           │  → blk?????.dat
                               │     └─ReceivedBlockTransactions :3772
                               │        └─TryAddBlockIndexCandidate
                               │           → setBlockIndexCandidates (priority set)
                               │  4. UNLOCK(cs_main)          │
                               │  5. NotifyHeaderTip()        │
                               └──────────┬──────────────────┘
                                          │
                               ┌──────────▼──────────────────────────────┐
                               │  Chainstate::ActivateBestChain :3330    │
                               │  LOCK(m_chainstate_mutex)               │
                               │                                         │
                               │  loop {                                 │
                               │    LOCK(cs_main) + LOCK(mempool->cs)    │
                               │    FindMostWorkChain() :3128            │
                               │      └─ scan setBlockIndexCandidates    │
                               │    ActivateBestChainStep() :3198        │
                               │    signals->BlockConnected()            │
                               │    signals->UpdatedBlockTip()           │
                               │    UNLOCK; FlushStateToDisk(PERIODIC)   │
                               │  }                                      │
                               └──────────┬──────────────────────────────┘
                                          │
                  ┌───────────────────────▼───────────────────────────────┐
                  │  Chainstate::ActivateBestChainStep :3198              │
                  │  (cs_main + mempool->cs held)                        │
                  │                                                       │
                  │  [REORG path: tip ≠ fork point]                      │
                  │  ┌─ DisconnectTip() :2943 ─────────────────────────┐ │
                  │  │  ReadBlock()                                     │ │
                  │  │  CCoinsViewCache view(&CoinsTip())               │ │
                  │  │  DisconnectBlock() :2185                         │ │
                  │  │    ApplyTxInUndo() ← CTxUndo from rev?????.dat  │ │
                  │  │    view.SpendCoin() [removes new outputs]        │ │
                  │  │    view.SetBestBlock(prev)                       │ │
                  │  │  view.Flush() → CoinsTip() updated               │ │
                  │  │  disconnectpool.AddTransactionsFromBlock()       │ │
                  │  │  m_chain.SetTip(*prev)                           │ │
                  │  │  signals->BlockDisconnected()                    │ │
                  │  └──────────────────────────────────────────────────┘ │
                  │                                                       │
                  │  [CONNECT path: for each new block]                  │
                  │  ┌─ ConnectTip() :3019 ──────────────────────────┐   │
                  │  │  ReadBlock() (or use cached block)             │   │
                  │  │                                                │   │
                  │  │  ┌─ ConnectBlock() :2301 ──────────────────┐  │   │
                  │  │  │  CheckBlock() re-run                    │  │   │
                  │  │  │  GetBlockScriptFlags()                  │  │   │
                  │  │  │  BIP30 duplicate-coinbase check         │  │   │
                  │  │  │  CCheckQueueControl control(CheckQueue) │  │   │
                  │  │  │                                         │  │   │
                  │  │  │  for each tx:                           │  │   │
                  │  │  │    CheckTxInputs() [inputs exist, fees] │  │   │
                  │  │  │    SequenceLocks() [BIP68]              │  │   │
                  │  │  │    GetTransactionSigOpCost()            │  │   │
                  │  │  │    CheckInputScripts() :2067            │  │   │
                  │  │  │      └─ script exec cache lookup        │  │   │
                  │  │  │      └─ CScriptCheck → control.Add()   │  │   │
                  │  │  │           (parallel, CCheckQueue)       │  │   │
                  │  │  │    UpdateCoins() :2005                  │  │   │
                  │  │  │      SpendCoin() [mark inputs spent]    │  │   │
                  │  │  │        → CTxUndo undo entries           │  │   │
                  │  │  │      AddCoin() [add new outputs]        │  │   │
                  │  │  │        → CCoinsViewCache dirty          │  │   │
                  │  │  │                                         │  │   │
                  │  │  │  control.Complete() [wait scripts]      │  │   │
                  │  │  │  coinbase reward check                  │  │   │
                  │  │  │  WriteBlockUndo() → rev?????.dat        │  │   │
                  │  │  │  view.SetBestBlock(pindex->hash)        │  │   │
                  │  │  └─────────────────────────────────────────┘  │   │
                  │  │                                                │   │
                  │  │  signals->BlockChecked()                       │   │
                  │  │  view.Flush() ──────────────────────────────►  │   │
                  │  │    CCoinsViewCache (m_connect_block_view)       │   │
                  │  │       └─ BatchWrite → m_catcherview (CoinsTip) │   │
                  │  │  FlushStateToDisk(IF_NEEDED) ────────────────► │   │
                  │  │    m_catcherview.Sync/Flush                    │   │
                  │  │       └─ CCoinsViewDB (LevelDB) coins.ldb      │   │
                  │  │                                                │   │
                  │  │  ┌─ Mempool reconciliation ─────────────────┐ │   │
                  │  │  │  removeForBlock() txmempool.cpp:405      │ │   │
                  │  │  │    removeUnchecked(BLOCK) per confirmed   │ │   │
                  │  │  │    removeConflicts() per doublespend      │ │   │
                  │  │  │    MempoolTransactionsRemovedForBlock()   │ │   │
                  │  │  │    m_txgraph->DoWork() [re-linearize]    │ │   │
                  │  │  │  disconnectpool.removeForBlock()          │ │   │
                  │  │  └──────────────────────────────────────────┘ │   │
                  │  │                                                │   │
                  │  │  m_chain.SetTip(*pindexNew)  ◄── TIP MOVES   │   │
                  │  │  UpdateIBDStatus()                            │   │
                  │  │  UpdateTip() :2896                            │   │
                  │  │    mempool->AddTransactionsUpdated(1)         │   │
                  │  │    versionbitscache.CheckUnknownActivations() │   │
                  │  │  MaybeValidateSnapshot()                      │   │
                  │  │  → connected_blocks.emplace_back(...)         │   │
                  │  └────────────────────────────────────────────────┘   │
                  │                                                       │
                  │  [after all connects/disconnects]                     │
                  │  MaybeUpdateMempoolForReorg() :302                    │
                  │    AcceptToMemoryPool(bypass_limits=true) per tx     │
                  │    removeRecursive(REORG) for invalids               │
                  │    UpdateTransactionsFromBlock()                      │
                  │    removeForReorg() [non-final, immature coinbase]   │
                  │  mempool->check(CoinsTip, height+1) [debug]          │
                  └───────────────────────────────────────────────────────┘
                                          │
                                          │  ValidationInterface signals
                               ┌──────────▼──────────────────────────────┐
                               │  PeerManagerImpl::BlockConnected :2094  │
                               │    m_last_tip_update = now              │
                               │    decay m_block_stalling_timeout       │
                               │    m_txdownloadman.BlockConnected()     │
                               │      └─ remove confirmed txs from       │
                               │         inv/orphan/announced tracking   │
                               └─────────────────────────────────────────┘
```

---

## Execution Summary: One Block, in Order

| # | Function | File:Line | What happens |
|---|---|---|---|
| 1 | `ProcessMessage` | `net_processing.cpp:3603` | Dispatch on `NetMsgType::BLOCK` |
| 2 | `ProcessBlock` | `net_processing.cpp:3455` | P2P → validation bridge |
| 3 | `ChainstateManager::ProcessNewBlock` | `validation.cpp:4405` | Entry point; acquires `cs_main` |
| 4 | `CheckBlock` | `validation.cpp:3925` | Merkle root, size, coinbase, sigops |
| 5 | `ChainstateManager::AcceptBlock` | `validation.cpp:4305` | Storage decision and disk write |
| 6 | `AcceptBlockHeader` | `validation.cpp:4193` | PoW, timestamp, add `CBlockIndex` to tree |
| 7 | `CheckBlockHeader` | `validation.cpp:3835` | nBits / version sanity |
| 8 | `ContextualCheckBlockHeader` | `validation.cpp:4087` | MTP, difficulty, version softforks |
| 9 | `m_blockman.AddToBlockIndex` | `blockstorage.cpp` | Inserts into `BlockMap` |
| 10 | `ContextualCheckBlock` | `validation.cpp:4136` | BIP34/65/68, witness commitment |
| 11 | `m_blockman.WriteBlock` | `blockstorage.cpp` | Serialize to `blk?????.dat` |
| 12 | `ReceivedBlockTransactions` | `validation.cpp:3772` | Mark `BLOCK_HAVE_DATA`, propagate tx count, add to `setBlockIndexCandidates` |
| 13 | `Chainstate::ActivateBestChain` | `validation.cpp:3330` | Acquire `m_chainstate_mutex`; main loop |
| 14 | `FindMostWorkChain` | `validation.cpp:3128` | Scan `setBlockIndexCandidates` for best valid candidate |
| 15 | `ActivateBestChainStep` | `validation.cpp:3198` | Reorg detection; disconnect/connect loop |
| 16 | `DisconnectTip` *(reorg only)* | `validation.cpp:2943` | Read block, `DisconnectBlock`, flush view, retract tip |
| 17 | `ConnectTip` | `validation.cpp:3019` | Read block, run `ConnectBlock`, flush, advance tip |
| 18 | `ConnectBlock` | `validation.cpp:2301` | Per-tx validation: inputs, scripts, amounts, sigops |
| 19 | `Consensus::CheckTxInputs` | `consensus/tx_verify.cpp` | UTXO existence, value overflow, fee |
| 20 | `CheckInputScripts` | `validation.cpp:2067` | Script execution cache + `CScriptCheck` per input |
| 21 | `CCheckQueue::Add / Complete` | `checkqueue.h` | Parallel script verification on worker threads |
| 22 | `UpdateCoins` | `validation.cpp:2005` | `SpendCoin` (undo entries) + `AddCoin` (new outputs) |
| 23 | `view.Flush` | `coins.cpp:260` | Dirty coins → `m_catcherview` |
| 24 | `FlushStateToDisk(IF_NEEDED)` | `validation.cpp:2707` | `m_catcherview` → LevelDB if cache full |
| 25 | `CTxMemPool::removeForBlock` | `txmempool.cpp:405` | Evict confirmed + conflicting txs |
| 26 | `m_chain.SetTip(*pindexNew)` | `chain.h` | **Canonical tip advances** |
| 27 | `UpdateTip` | `validation.cpp:2896` | Mempool sequence bump, version-bit warnings, log |
| 28 | `MaybeUpdateMempoolForReorg` | `validation.cpp:302` | Re-admit disconnected txs; evict newly invalid ones |
| 29 | `signals->BlockConnected` | `validationinterface.cpp` | Notify wallet, indexes, P2P |
| 30 | `PeerManagerImpl::BlockConnected` | `net_processing.cpp:2094` | Reset stall timer, clear tx download state |
| 31 | `signals->UpdatedBlockTip` | `net_processing.cpp:2187` | Trigger header announcements to peers |
