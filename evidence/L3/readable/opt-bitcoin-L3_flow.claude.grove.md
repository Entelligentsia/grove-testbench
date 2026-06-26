# transcript: Trace how Bitcoin Core validates a new transaction received from a peer and accepts it into the mempool: name every function it passes through, in order, fro...


💬 I'll use the grove MCP tools as required by the project instructions. Let me load their schemas first, then trace the transaction validation path.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me trace the full path. I'll start with the P2P message handler and map the transaction validation chain in parallel.
  ▸ mcp__grove__symbols({"dir":"src","name":"ProcessMessage"})
  ▸ mcp__grove__symbols({"dir":"src","name":"AcceptToMemoryPool"})
  ▸ mcp__grove__source({"id":"cpp:src/net_processing.cpp#ProcessMessage@3603"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptToMemoryPool@1781"})

💬 Now let me trace into `ProcessTransaction` and `MemPoolAccept::AcceptSingleTransactionAndCleanup` in parallel.
  ▸ mcp__grove__symbols({"dir":"src","name":"ProcessTransaction"})
  ▸ mcp__grove__symbols({"dir":"src","name":"AcceptSingleTransactionAndCleanup"})
  ▸ mcp__grove__symbols({"dir":"src","name":"ReceivedTx"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ProcessTransaction@4455"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptSingleTransactionAndCleanup@591"})
  ▸ mcp__grove__source({"id":"cpp:src/node/txdownloadman_impl.cpp#ReceivedTx@505"})

💬 Good. `AcceptSingleTransactionAndCleanup` was truncated. Let me get the full body and the inner `AcceptSingleTransaction` function.
  ▸ mcp__grove__symbols({"dir":"src","name":"AcceptSingleTransaction"})
  ▸ mcp__grove__outline({"file":"src/validation.cpp","kind":"function","detail":0})

💬 Now let me get the core validation pipeline functions in parallel.
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptSingleTransactionInternal@597"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PreChecks@676"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PolicyScriptChecks@688"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ConsensusScriptChecks@694"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#FinalizeSubpackage@697"})

💬 The outline signatures are declarations — let me fetch the actual implementations using the other_candidates IDs.
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptSingleTransactionInternal@1323"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PreChecks@786"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PolicyScriptChecks@1139"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ConsensusScriptChecks@1162"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#FinalizeSubpackage@1195"})

💬 Now let me get `AcceptSingleTransactionAndCleanup` (the actual one at line 25847 range) and `ReplacementChecks`.
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ReplacementChecks@1139"})
  ▸ mcp__grove__symbols({"dir":"src","name":"ReplacementChecks"})
  ▸ mcp__grove__symbols({"dir":"src","name":"ProcessValidTx"})

💬 Let me read the `AcceptSingleTransactionAndCleanup` inline body directly and get `ProcessValidTx`.
  ▸ Read(/home/bench/repos/bitcoin/src/validation.cpp)
  ▸ mcp__grove__source({"id":"cpp:src/net_processing.cpp#ProcessValidTx@3177"})

💬 I now have the full picture. Here is the complete ordered call chain, every function from wire to mempool:  ---  ## Bitcoin Core: New Transaction → Mempool  ...

──────── RESULT (success, 380395ms, 29 turns) ────────
I now have the full picture. Here is the complete ordered call chain, every function from wire to mempool:

---

## Bitcoin Core: New Transaction → Mempool

### 1. `PeerManagerImpl::ProcessMessage` — `src/net_processing.cpp:3603`

Entry point for all P2P messages. When `msg_type == NetMsgType::TX`:
- Guards: rejects if `RejectIncomingTxs(pfrom)` (block-relay-only connection) or `IsInitialBlockDownload()`.
- Deserializes: `vRecv >> TX_WITH_WITNESS(ptx)`.
- Calls **`m_txdownloadman.ReceivedTx(pfrom.GetId(), ptx)`** → `{should_validate, package_to_validate}`.
- If `should_validate`, calls **`m_chainman.ProcessTransaction(ptx)`**.
- On `VALID` result, calls **`ProcessValidTx(...)`**.
- On `INVALID` result, calls `ProcessInvalidTx(...)` and potentially triggers package validation.

---

### 2. `TxDownloadManagerImpl::ReceivedTx` — `src/node/txdownloadman_impl.cpp:505`

Pre-validation dedup / early rejection:
- Marks request answered in `m_txrequest`.
- Calls `AlreadyHaveTx(wtxid, false)` — checks bloom reject filter, mempool, and confirmed set.
- If already seen: returns `{false, std::nullopt}` (skip validation).
- If in *reconsiderable* rejects: returns `{false, Find1P1CPackage(...)}` (try as 1-parent-1-child package instead).
- Otherwise: returns `{true, std::nullopt}` (proceed to validation).

---

### 3. `ChainstateManager::ProcessTransaction` — `src/validation.cpp:4455`

Thin wrapper under `cs_main`:
- Calls **`AcceptToMemoryPool(active_chainstate, tx, GetTime(), bypass_limits=false, test_accept=false)`**.
- After acceptance calls `m_mempool->check(...)` (a debug-only sanity assertion).

---

### 4. `AcceptToMemoryPool` — `src/validation.cpp:1781`

Sets up arguments and drives the `MemPoolAccept` object:
- Creates `MemPoolAccept::ATMPArgs` via `ATMPArgs::SingleAccept(...)`.
- Calls **`MemPoolAccept(pool, active_chainstate).AcceptSingleTransactionAndCleanup(tx, args)`**.
- On failure: uncaches any coins that were fetched into the cache (`CCoinsViewCache::Uncache` per output).
- Calls `FlushStateToDisk(PERIODIC)` to keep the coins cache within bounds.

---

### 5. `MemPoolAccept::AcceptSingleTransactionAndCleanup` — `src/validation.cpp:591` *(inline)*

- Acquires `m_pool.cs`.
- Calls **`AcceptSingleTransactionInternal(ptx, args)`**.
- On return (success or failure), calls `ClearSubPackageState()` to reset per-attempt state.

---

### 6. `MemPoolAccept::AcceptSingleTransactionInternal` — `src/validation.cpp:1323`

The orchestration function. Calls each validation stage in order, returning a `MempoolAcceptResult` at each failure point:

| Step | Call | Purpose |
|------|------|---------|
| a | **`PreChecks(args, ws)`** | All cheap checks (see §7) |
| b | **`ReplacementChecks(ws)`** | RBF rules (only if `m_subpackage.m_rbf`) |
| c | `m_changeset->CheckMemPoolPolicyLimits()` | Cluster size cap |
| d | `EntriesAndTxidsDisjoint(ancestors, ws.m_conflicts, ...)` | No tx can spend what it replaces |
| e | `CheckEphemeralSpends(...)` | Ephemeral anchor policy |
| f | **`PolicyScriptChecks(args, ws)`** | Script eval with standard policy flags |
| g | **`ConsensusScriptChecks(args, ws)`** | Script eval with current-block consensus flags + caches result |
| h | **`FinalizeSubpackage(args)`** | Commit to mempool (see §11) |
| i | `LimitMempoolSize(m_pool, ...)` | Evict low-fee txs if over limit |
| j | `signals->TransactionAddedToMempool(...)` | Fire validation interface signal |

---

### 7. `MemPoolAccept::PreChecks` — `src/validation.cpp:786`

In order, every cheap check before script execution:

1. **`CheckTransaction(tx, state)`** — structural: no duplicate inputs, output values in range, non-empty vin/vout.
2. Coinbase rejection (coinbase only valid in a block).
3. **`IsStandardTx(tx, ...)`** — policy: output script types, datacarrier size, bare multisig setting.
4. Minimum non-witness size ≥ 65 bytes (CVE-2017-12842 mitigation).
5. **`CheckFinalTxAtTip(..., tx)`** — `nLockTime` finality against current tip.
6. Exact-duplicate check: `m_pool.exists(wtxid)` and `m_pool.exists(txid)`.
7. Conflict scan: iterates `tx.vin`, calls `m_pool.GetConflictTx(txin.prevout)` — populates `ws.m_conflicts` for RBF.
8. Input existence: `m_view.HaveCoin(txin.prevout)` for every input (missing input → `TX_MISSING_INPUTS`).
9. **`CalculateLockPointsAtTip`** + **`CheckSequenceLocksAtTip`** — BIP68 relative lock-time.
10. **`Consensus::CheckTxInputs(tx, state, m_view, height+1, ws.m_base_fees)`** — input sum ≥ output sum, no overflow, coinbase maturity.
11. **`ValidateInputsStandardness(tx, m_view)`** — policy: input script types (pubkey encoding, etc.).
12. **`IsWitnessStandard(tx, m_view)`** — policy: witness stack limits.
13. **`GetTransactionSigOpCost(...)`** — sigop budget check (≤ `MAX_STANDARD_TX_SIGOPS_COST`).
14. **`m_changeset->StageAddition(...)`** — stages the entry; computes vsize, modified fee (after `PrioritiseTransaction` deltas).
15. **`PreCheckEphemeralTx`** — 0-fee required for dust (ephemeral anchor) transactions.
16. **`CheckFeeRate(ws.m_vsize, ws.m_modified_fees, state)`** — above mempool minimum feerate.
17. **`SingleTRUCChecks(m_pool, ws.m_ptx, ws.m_parents, ws.m_conflicts, ws.m_vsize)`** — TRUC (v3) topology and size policy.

---

### 8. `MemPoolAccept::ReplacementChecks` — `src/validation.cpp:988`

Only reached when `ws.m_conflicts` is non-empty (RBF candidate):
- Computes fees and sizes of to-be-replaced transactions.
- Enforces BIP125 / TRUC RBF rules: replacement must pay more fees, not add unconfirmed inputs, not evict too many descendants, and must improve absolute fee by at least the relay fee for its own vsize.

---

### 9. `MemPoolAccept::PolicyScriptChecks` — `src/validation.cpp:1139`

- Calls **`CheckInputScripts(tx, state, m_view, STANDARD_SCRIPT_VERIFY_FLAGS, /*cacheStore=*/true, /*fRecursiveScriptChecks=*/false, ws.m_precomputed_txdata, GetValidationCache())`**.
- Runs the script interpreter for every input using the stricter *standard* policy flags (e.g. `CLEANSTACK`, `MINIMALDATA`, low-S, `NULLFAIL`).
- Results cached in the script validation cache to avoid re-execution at block connect time.

---

### 10. `MemPoolAccept::ConsensusScriptChecks` — `src/validation.cpp:1162`

- Calls **`GetBlockScriptFlags(*m_active_chainstate.m_chain.Tip(), m_chainman)`** to get the *consensus* flag set for the next block.
- Calls **`CheckInputsFromMempoolAndCache(tx, state, m_view, m_pool, currentBlockScriptVerifyFlags, ws.m_precomputed_txdata, CoinsTip(), GetValidationCache())`** — re-runs script validation with consensus flags (catches soft-fork activations) and writes results to the script cache.

---

### 11. `MemPoolAccept::FinalizeSubpackage` — `src/validation.cpp:1195`

The actual mempool insertion:
- Iterates `m_changeset->GetRemovals()` — for each conflicting tx being replaced: logs the replacement, records it in `m_subpackage.m_replaced_transactions`.
- **`m_subpackage.m_changeset->Apply()`** — atomically applies the staged changeset: removes conflicting entries and inserts the new transaction into `CTxMemPool`'s internal data structures.
- Resets the changeset.

---

### 12. Back in `AcceptSingleTransactionInternal` (post-finalize)

- **`LimitMempoolSize(m_pool, m_active_chainstate.CoinsTip())`** — if the pool is over its byte/count limit, evicts the lowest-feerate transactions (the new tx itself may be evicted here, returning `TX_RECONSIDERABLE`).
- **`m_pool.m_opts.signals->TransactionAddedToMempool(tx_info, m_pool.GetAndIncrementSequence())`** — fires the validation interface notification (consumed by fee estimator, wallet, ZMQ, RPC subscribers).

---

### 13. `PeerManagerImpl::ProcessValidTx` — `src/net_processing.cpp:3177`

Called back in `ProcessMessage` after `ProcessTransaction` returns `VALID`:
- **`m_txdownloadman.MempoolAcceptedTx(tx)`** — updates the download manager: removes from orphan set, clears in-flight state.
- **`InitiateTxBroadcastToAll(tx->GetHash(), tx->GetWitnessHash())`** — schedules INV announcements to all connected peers for relay.
- Logs acceptance to `BCLog::MEMPOOL`.

---

## Summary call graph

```
ProcessMessage (net_processing.cpp)
  └─ TxDownloadManagerImpl::ReceivedTx          ← dedup / bloom filter gate
  └─ ChainstateManager::ProcessTransaction
       └─ AcceptToMemoryPool
            └─ MemPoolAccept::AcceptSingleTransactionAndCleanup
                 └─ AcceptSingleTransactionInternal
                      ├─ PreChecks
                      │    ├─ CheckTransaction           ← structural
                      │    ├─ IsStandardTx               ← policy
                      │    ├─ CheckFinalTxAtTip          ← locktime
                      │    ├─ m_view.HaveCoin            ← input existence
                      │    ├─ CalculateLockPointsAtTip / CheckSequenceLocksAtTip  ← BIP68
                      │    ├─ Consensus::CheckTxInputs   ← input values, maturity
                      │    ├─ m_changeset->StageAddition ← vsize / fee staging
                      │    ├─ CheckFeeRate               ← min relay fee
                      │    └─ SingleTRUCChecks           ← v3 policy
                      ├─ ReplacementChecks               ← BIP125 / TRUC RBF
                      ├─ PolicyScriptChecks
                      │    └─ CheckInputScripts (STANDARD flags)
                      ├─ ConsensusScriptChecks
                      │    └─ CheckInputsFromMempoolAndCache (consensus flags)
                      └─ FinalizeSubpackage
                           └─ m_changeset->Apply()       ← **tx enters mempool here**
  └─ ProcessValidTx
       ├─ TxDownloadManager::MempoolAcceptedTx
       └─ InitiateTxBroadcastToAll              ← relay to peers
```
