# transcript: Give the complete end-to-end picture of Bitcoin Core's mempool transaction-acceptance subsystem: from the acceptance entry point (AcceptToMemoryPool / MemPoo...


💬 I'll load the grove tools first, then systematically map the entire subsystem.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me fan out parallel grove queries across all the key files in this subsystem.
  ▸ mcp__grove__symbols({"dir":"src","name":"AcceptToMemoryPool"})
  ▸ mcp__grove__symbols({"dir":"src","name":"MemPoolAccept"})
  ▸ mcp__grove__outline({"file":"src/txmempool.h","detail":1})

💬 Now let me get the full MemPoolAccept class outline and AcceptToMemoryPool source in parallel.
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#MemPoolAccept@443"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptToMemoryPool@1781"})
  ▸ mcp__grove__outline({"file":"src/validation.cpp","detail":0,"kind":"function"})

💬 Now let me fetch the bodies of all the key methods in parallel.
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PreChecks@676"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptSingleTransactionInternal@597"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ReplacementChecks@679"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PolicyScriptChecks@688"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ConsensusScriptChecks@694"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#FinalizeSubpackage@697"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#SubmitPackage@702"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptPackage@629"})

💬 The grove tool returned only signatures — I need the implementation bodies at the correct line numbers.
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PreChecks@786"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptSingleTransactionInternal@1323"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ReplacementChecks@988"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PolicyScriptChecks@1139"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ConsensusScriptChecks@1162"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#FinalizeSubpackage@1195"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#SubmitPackage@1246"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptPackage@1628"})

💬 Now let me fetch the remaining key methods: `AcceptSubPackage`, `AcceptMultipleTransactionsInternal`, `LimitMempoolSize`, `CheckInputsFromMempoolAndCache`, a...
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptSubPackage@622"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptMultipleTransactionsInternal@610"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#LimitMempoolSize@272"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#CheckInputsFromMempoolAndCache@403"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PackageRBFChecks@681"})
  ▸ mcp__grove__outline({"file":"src/txmempool.cpp","detail":0,"kind":"function"})

💬 Need the implementations at the correct lines.
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptSubPackage@1602"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#AcceptMultipleTransactionsInternal@1438"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#CheckInputsFromMempoolAndCache@403"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#PackageRBFChecks@1041"})
  ▸ mcp__grove__symbols({"dir":"src","name":"Apply"})

💬 Now let me get the CTxMemPool insertion path, `LimitMempoolSize`, and `CheckInputsFromMempoolAndCache` implementations.
  ▸ mcp__grove__source({"id":"cpp:src/txmempool.cpp#Apply@206"})
  ▸ mcp__grove__source({"id":"c:src/txmempool.h#Apply@677"})
  ▸ mcp__grove__outline({"file":"src/txmempool.cpp","detail":1})
  ▸ mcp__grove__symbols({"dir":"src","name":"LimitMempoolSize"})
  ▸ mcp__grove__symbols({"dir":"src","name":"CheckInputScripts"})

💬 Now let me get the final pieces: `addNewTransaction`, `TrimToSize`, `LimitMempoolSize`, and the full `CheckInputScripts`.
  ▸ mcp__grove__source({"id":"cpp:src/txmempool.cpp#addNewTransaction@229"})
  ▸ mcp__grove__source({"id":"cpp:src/txmempool.cpp#TrimToSize@861"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#LimitMempoolSize@272"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#CheckInputScripts@2067"})
  ▸ mcp__grove__source({"id":"cpp:src/txmempool.cpp#removeUnchecked@263"})
  ▸ mcp__grove__source({"id":"cpp:src/txmempool.cpp#RemoveStaged@793"})

💬 Let me get `LimitMempoolSize` full body and a few key helper functions.
  ▸ Read(/home/bench/repos/bitcoin/src/validation.cpp)
  ▸ mcp__grove__symbols({"dir":"src","name":"ProcessNewPackage"})
  ▸ mcp__grove__symbols({"dir":"src","name":"GetEntriesForConflicts"})
  ▸ mcp__grove__symbols({"dir":"src","name":"PaysForRBF"})
  ▸ mcp__grove__symbols({"dir":"src","name":"ImprovesFeerateDiagram"})
  ▸ mcp__grove__symbols({"dir":"src","name":"StageAddition"})

💬 Now let me find `StageAddition`, `CheckTransaction`, and `Consensus::CheckTxInputs`.
  ▸ mcp__grove__symbols({"dir":"src","name":"CheckTransaction"})
  ▸ mcp__grove__symbols({"dir":"src","name":"CheckTxInputs"})
  ▸ mcp__grove__symbols({"dir":"src","nameContains":true,"name":"StageAddition"})
  ▸ mcp__grove__source({"id":"cpp:src/validation.cpp#ProcessNewPackage@1813"})

💬 Let me get the `ChangeSet` class details and `StageAddition` from txmempool.h.
  ▸ Read(/home/bench/repos/bitcoin/src/txmempool.h)
  ▸ mcp__grove__source({"id":"cpp:src/consensus/tx_check.cpp#CheckTransaction@11"})
  ▸ mcp__grove__source({"id":"cpp:src/consensus/tx_verify.cpp#CheckTxInputs@164"})

💬 I now have all the data I need. Let me write the complete picture.  ---  ## Bitcoin Core Mempool Transaction-Acceptance Subsystem  All code lives in `src/val...

──────── RESULT (success, 584441ms, 59 turns) ────────
I now have all the data I need. Let me write the complete picture.

---

## Bitcoin Core Mempool Transaction-Acceptance Subsystem

All code lives in `src/validation.cpp` (the `MemPoolAccept` machine) and `src/txmempool.cpp` / `src/txmempool.h` (the `CTxMemPool` data store). Consensus helpers are in `src/consensus/`. RBF helpers are in `src/policy/rbf.cpp`.

---

### 1. Public Entry Points

#### Single transaction — `AcceptToMemoryPool` (`validation.cpp:1781`)
```
AcceptToMemoryPool(Chainstate& active_chainstate, const CTransactionRef& tx,
                   int64_t accept_time, bool bypass_limits, bool test_accept)
```
Called by: net_processing (relay), wallet, and RPC `sendrawtransaction`.  
Requires: `cs_main` already held by caller.

1. Resolves `CTxMemPool& pool` from `active_chainstate`.
2. Builds `ATMPArgs::SingleAccept(chainparams, accept_time, bypass_limits, coins_to_uncache, test_accept)`.
3. Constructs a `MemPoolAccept` and calls `AcceptSingleTransactionAndCleanup(tx, args)`.
4. On rejection: calls `CoinsTip().Uncache` for any coins fetched during validation and fires `TRACEPOINT(mempool, rejected)`.
5. Calls `FlushStateToDisk(PERIODIC)` to keep the coins cache bounded.
6. Returns `MempoolAcceptResult`.

#### Package — `ProcessNewPackage` (`validation.cpp:1813`)
```
ProcessNewPackage(Chainstate&, CTxMemPool&, const Package&,
                  bool test_accept, const std::optional<CFeeRate>& client_maxfeerate)
```
Called by: net_processing (package relay).

- `test_accept=true` → `ATMPArgs::PackageTestAccept` → `AcceptMultipleTransactionsAndCleanup`
- `test_accept=false` → `ATMPArgs::PackageChildWithParents` → `AcceptPackage`

---

### 2. Key Classes

#### `MemPoolAccept` (`validation.cpp:443`)
A short-lived object constructed per acceptance call; owns the entire validation state machine.

| Member | Type | Role |
|--------|------|------|
| `m_pool` | `CTxMemPool&` | The live mempool |
| `m_view` | `CCoinsViewCache` | Working coin cache; backend swapped during PreChecks |
| `m_viewmempool` | `CCoinsViewMemPool` | Sees mempool + UTXO set; acts as m_view's backend for input lookup |
| `m_active_chainstate` | `Chainstate&` | Chain tip, height, coins tip |
| `m_subpackage` | `SubPackageState` | Per-subpackage: changeset, total fees/vsize, RBF flag, replaced-tx list |

**Inner structs:**

- **`ATMPArgs`** (`validation.cpp:456`) — immutable parameters for the acceptance run: `m_bypass_limits`, `m_test_accept`, `m_allow_replacement`, `m_allow_sibling_eviction`, `m_package_submission`, `m_package_feerates`, `m_client_maxfeerate`. Four named static constructors: `SingleAccept`, `PackageTestAccept`, `PackageChildWithParents`, `SingleInPackageAccept`.

- **`Workspace`** (`validation.cpp:635`) — mutable per-transaction state threaded through all check phases: `m_ptx`, `m_hash`, `m_state` (TxValidationState), `m_conflicts`, `m_iters_conflicting`, `m_parents`, `m_tx_handle` (the ChangeSet iterator), `m_vsize`, `m_base_fees`, `m_modified_fees`, `m_package_feerate`, `m_precomputed_txdata`, `m_sibling_eviction`.

- **`SubPackageState`** (`validation.cpp:~740`) — reset between sub-packages: `m_changeset` (unique_ptr<ChangeSet>), `m_rbf`, `m_replaced_transactions`, `m_total_modified_fees`, `m_total_vsize`, `m_conflicting_fees`, `m_conflicting_size`.

#### `CTxMemPool` (`txmempool.h`, implemented in `txmempool.cpp`)
The persistent mempool data store.

| Member | Role |
|--------|------|
| `mapTx` (`indexed_transaction_set`) | Multi-index boost container of `CTxMemPoolEntry` |
| `mapNextTx` | Maps `COutPoint → txiter` (what spends each output) |
| `txns_randomized` | Flat list for random-order iteration |
| `m_txgraph` | `TxGraph` — cluster-linearization engine; drives `GetWorstMainChunk` for eviction |
| `cs` | Pool-wide mutex |
| `m_opts` | `Options`: min_relay_feerate, max_size_bytes, expiry, require_standard, incremental_relay_feerate, signals |

#### `CTxMemPool::ChangeSet` (`txmempool.h:620`)
A write-ahead staging buffer opened for each sub-package. Holds `m_to_add`, `m_entry_vec`, `m_to_remove`, and a reference to `m_txgraph`'s staging layer (started in constructor, committed or aborted in `Apply`/destructor). Key methods: `StageAddition`, `StageRemoval`, `CheckMemPoolPolicyLimits`, `CalculateChunksForRBF`, `Apply`.

#### `CTxMemPoolEntry` (`txmempool.h`)
Wraps a `CTransactionRef`; stores fee, modified_fees, time, entry_height, sigops_cost, spends_coinbase, lock_points, vsize, `idx_randomized`. Inherits `TxGraph::Ref` so it participates in the cluster graph directly.

#### `CCoinsViewMemPool` (`txmempool.cpp:740`)
Layered coin view: looks up coins in the mempool first, then falls through to the UTXO set. `PackageAddTransaction` (`txmempool.cpp:765`) adds *temporary* coins during package validation so later transactions in the package can spend outputs of earlier ones.

---

### 3. Single-Transaction Acceptance Path (step by step)

```
AcceptToMemoryPool                    validation.cpp:1781
  └─ MemPoolAccept::AcceptSingleTransactionAndCleanup   :591
       ├─ LOCK(m_pool.cs)
       └─ AcceptSingleTransactionInternal               :1323
            ├─ PreChecks                                :786
            ├─ (if m_rbf) ReplacementChecks             :988
            ├─ ChangeSet::CheckMemPoolPolicyLimits
            ├─ (if !bypass_limits && require_standard)
            │     CheckEphemeralSpends
            ├─ PolicyScriptChecks                       :1139
            ├─ ConsensusScriptChecks                    :1162
            ├─ [if test_accept → return early]
            ├─ FinalizeSubpackage                       :1195
            └─ (if !package_submission && !bypass_limits)
                  LimitMempoolSize                      :272
```

---

### 4. `PreChecks` (`validation.cpp:786`) — Ordered Check Sequence

| # | Check | Helper | Location |
|---|-------|--------|----------|
| 1 | Basic structural validity | `CheckTransaction` | `consensus/tx_check.cpp:11` |
| 2 | Reject coinbase | — | — |
| 3 | Standardness (non-test nets) | `IsStandardTx` | `policy/policy.cpp` |
| 4 | Min nonwitness size ≥ 65 bytes (CVE-2017-12842) | `GetSerializeSize(TX_NO_WITNESS)` | — |
| 5 | `nLockTime` is final at next block | `CheckFinalTxAtTip` | `validation.cpp:155` |
| 6 | Not already in mempool (wtxid and txid) | `m_pool.exists` | — |
| 7 | Conflict detection vs mempool | `m_pool.GetConflictTx` per input | `txmempool.cpp:689` |
| 8 | Input existence: connect `m_view` → `m_viewmempool` backend, call `HaveCoin` per input; add missing outpoints to `coins_to_uncache` | `CCoinsViewMemPool::GetCoin` | `txmempool.cpp:742` |
| 9 | Detach `m_view` backend (freeze cache) | `m_view.SetBackend(CoinsViewEmpty)` | — |
| 10 | BIP68 sequence locks at tip | `CalculateLockPointsAtTip` → `CheckSequenceLocksAtTip` | `validation.cpp:209, 254` |
| 11 | Input amounts, coinbase maturity, fee calculation | `Consensus::CheckTxInputs` | `consensus/tx_verify.cpp:164` |
| 12 | Input script standardness | `ValidateInputsStandardness` | `policy/policy.cpp` |
| 13 | Witness standardness | `IsWitnessStandard` | `policy/policy.cpp` |
| 14 | Sigop cost ≤ `MAX_STANDARD_TX_SIGOPS_COST` | `GetTransactionSigOpCost` | `policy/policy.cpp` |
| 15 | Detect coinbase-spending inputs | — | — |
| 16 | **Stage the entry** | `ChangeSet::StageAddition` | `txmempool.h:634` |
|   | ↳ creates `CTxMemPoolEntry`, adds to `m_to_add`/`m_entry_vec`, calls `m_txgraph->AddTransaction` in staging | | |
| 17 | Ephemeral dust pre-check | `PreCheckEphemeralTx` | — |
| 18 | Per-tx fee rate ≥ mempool min + min relay (unless `bypass_limits` or `package_feerates`) | `CheckFeeRate` | `validation.cpp:707` |
| 19 | Resolve conflict iterators | `m_pool.GetIterSet(m_conflicts)` | — |
| 20 | Resolve mempool parents | `m_pool.GetParents(*m_tx_handle)` | — |
| 21 | TRUC/v3 topology checks | `SingleTRUCChecks` (or sibling eviction) | `policy/truc_policy.cpp` |
| 22 | Set `m_subpackage.m_rbf` flag if any conflicts | — | — |

---

### 5. `ReplacementChecks` (`validation.cpp:988`) — RBF Rules

Called only when `m_subpackage.m_rbf` is true (a conflict was found).

| Step | Rule | Helper | File |
|------|------|--------|------|
| 1 | Collect all transitive descendants of direct conflicts (≤ 100 total) — Rule #5 | `GetEntriesForConflicts` | `policy/rbf.cpp:58` |
| 2 | Accumulate `m_conflicting_fees` and `m_conflicting_size` | — | — |
| 3 | New tx pays enough to cover its own relay + exceeds replaced fees — Rules #3/#4 | `PaysForRBF` | `policy/rbf.cpp:100` |
| 4 | Stage all conflicts for removal | `ChangeSet::StageRemoval` per iter | `txmempool.h:636` |
| 5 | Cluster size limit still satisfied | `ChangeSet::CheckMemPoolPolicyLimits` | — |
| 6 | Feerate diagram strictly improves | `ImprovesFeerateDiagram` | `policy/rbf.cpp:127` |

`ImprovesFeerateDiagram` calls `ChangeSet::CalculateChunksForRBF` → `m_txgraph->GetChunksForRBF` to compare the old and new linearized cluster feerate diagrams.

---

### 6. `PolicyScriptChecks` (`validation.cpp:1139`)

```
PolicyScriptChecks(args, ws)
  └─ CheckInputScripts(tx, state, m_view,
                        STANDARD_SCRIPT_VERIFY_FLAGS,
                        cacheSigStore=true, cacheFullScriptStore=false,
                        ws.m_precomputed_txdata,
                        GetValidationCache())          validation.cpp:2067
       ├─ Check m_script_execution_cache (CuckooCache keyed on wtxid+flags)
       ├─ PrecomputedTransactionData::Init (load spent outputs)
       └─ Per-input: CScriptCheck(spent_output, tx, sig_cache, i, flags)
            └─ CScriptCheck::operator()() → VerifyScript
```

Uses policy flags (`STANDARD_SCRIPT_VERIFY_FLAGS`). Results not yet cached to the "full" script cache.

---

### 7. `ConsensusScriptChecks` (`validation.cpp:1162`)

```
ConsensusScriptChecks(args, ws)
  ├─ GetBlockScriptFlags(*chain.Tip(), m_chainman)     validation.cpp:2256
  └─ CheckInputsFromMempoolAndCache(tx, state, m_view,
                                     m_pool, blockScriptFlags,
                                     ws.m_precomputed_txdata,
                                     CoinsTip(), GetValidationCache())  validation.cpp:403
       └─ CheckInputScripts(... cacheFullScriptStore=true ...)
            └─ On success: inserts hashCacheEntry into
               m_script_execution_cache
```

Runs with *consensus* flags (potentially stricter than policy). Populates the script execution cache so a block that later includes this tx can skip re-verification.

---

### 8. `FinalizeSubpackage` → `CTxMemPool::Apply` — Actual Insertion (`validation.cpp:1195`, `txmempool.cpp:206`)

```
FinalizeSubpackage(args)                              validation.cpp:1195
  ├─ Log replacement info + TRACEPOINT(mempool, replaced) per conflict
  └─ ChangeSet::Apply()                               txmempool.h:677
       └─ CTxMemPool::Apply(changeset)                txmempool.cpp:206
            ├─ m_txgraph->CommitStaging()
            │    (promotes staging TxGraph to MAIN level)
            ├─ RemoveStaged(changeset->m_to_remove, REPLACED)  txmempool.cpp:793
            │    └─ removeUnchecked(it, REPLACED)              txmempool.cpp:263
            │         ├─ GetAndIncrementSequence()
            │         ├─ signals->TransactionRemovedFromMempool()
            │         ├─ TRACEPOINT(mempool, removed)
            │         ├─ mapNextTx.erase (per input)
            │         ├─ RemoveUnbroadcastTx
            │         ├─ txns_randomized: swap-with-back + pop
            │         ├─ totalTxSize -= , m_total_fee -=
            │         ├─ cachedInnerUsage -=
            │         └─ mapTx.erase(it)
            ├─ Per added tx: mapTx.insert(node_handle)
            │   then addNewTransaction(it)                      txmempool.cpp:229
            │        ├─ cachedInnerUsage += DynamicMemoryUsage
            │        ├─ mapNextTx.insert per input prevout
            │        ├─ nTransactionsUpdated++
            │        ├─ totalTxSize += , m_total_fee +=
            │        ├─ txns_randomized.emplace_back
            │        └─ TRACEPOINT(mempool, added)
            └─ m_txgraph->DoWork(POST_CHANGE_COST)
                 (re-linearize affected clusters)
```

After `FinalizeSubpackage` returns, `AcceptSingleTransactionInternal` fires `signals->TransactionAddedToMempool`.

---

### 9. Package Paths

#### `AcceptPackage` (`validation.cpp:1628`)
Top-level package orchestrator. Per transaction in the package:
- Already in mempool → record `MempoolTx` result, skip.
- Same-txid-diff-witness → record `MempoolTxDifferentWitness`, skip.
- Otherwise → `AcceptSubPackage({tx}, args)` (single-tx sub-package).
  - If `VALID`: done, in mempool.
  - If `TX_RECONSIDERABLE` or `TX_MISSING_INPUTS`: queue for multi-tx re-evaluation.
  - Otherwise: `quit_early = true`.

Then `AcceptSubPackage(txns_package_eval, args)` for all queued txns.  
Finally `ClearSubPackageState()` → `LimitMempoolSize`.

#### `AcceptSubPackage` (`validation.cpp:1602`)
```
AcceptSubPackage(subpackage, args)
  ├─ size == 1 → AcceptSingleTransactionInternal (with SingleInPackageAccept args)
  └─ size  > 1 → AcceptMultipleTransactionsInternal
```

#### `AcceptMultipleTransactionsInternal` (`validation.cpp:1438`)
```
AcceptMultipleTransactionsInternal(txns, args)
  ├─ IsWellFormedPackage()
  ├─ Per tx: PreChecks → m_viewmempool.PackageAddTransaction
  ├─ Per tx: PackageTRUCChecks
  ├─ (if package_feerates) CheckFeeRate on aggregate
  ├─ (if m_rbf) PackageRBFChecks                     validation.cpp:1041
  │    ├─ Only 1-parent-1-child, no mempool ancestors
  │    ├─ GetEntriesForConflicts
  │    ├─ ChangeSet::StageRemoval per conflict
  │    ├─ PaysForRBF (aggregate package fees)
  │    ├─ CheckMemPoolPolicyLimits
  │    └─ ImprovesFeerateDiagram
  ├─ CheckMemPoolPolicyLimits
  ├─ CheckEphemeralSpends
  ├─ Per tx: PolicyScriptChecks
  └─ SubmitPackage                                    validation.cpp:1246
       ├─ FinalizeSubpackage  (calls ChangeSet::Apply → CTxMemPool::Apply)
       └─ Per ws: ConsensusScriptChecks (adds to script cache)
            + signals->TransactionAddedToMempool
```

---

### 10. Eviction — `LimitMempoolSize` (`validation.cpp:272`)

Called after every successful single-tx commit (unless `bypass_limits` or `package_submission`) and after every package.

```
LimitMempoolSize(pool, coins_cache)               validation.cpp:272
  ├─ pool.Expire(now - expiry)                    txmempool.cpp:811
  │    └─ removeUnchecked(it, EXPIRY) per expired entry
  └─ pool.TrimToSize(max_size_bytes, &vNoSpends)  txmempool.cpp:861
       └─ while DynamicMemoryUsage() > sizelimit:
            ├─ m_txgraph->GetWorstMainChunk()
            │    (returns lowest feerate chunk from cluster linearization)
            ├─ removed += incremental_relay_feerate
            ├─ trackPackageRemoved(removed)       → updates rollingMinimumFeeRate
            └─ removeUnchecked(e, SIZELIMIT)      txmempool.cpp:263
                 (same as removal path above)
```

After `TrimToSize`, any outpoints that no longer have a spending tx in the mempool are `Uncache`d from the coins cache.

---

### 11. Unified Call Graph

```
═══════════════════════════════════════════════════════════════════════
ENTRY POINTS
═══════════════════════════════════════════════════════════════════════

AcceptToMemoryPool (validation.cpp:1781)
│   ┌─ ATMPArgs::SingleAccept
│   └─ MemPoolAccept::AcceptSingleTransactionAndCleanup (:591)
│        └─ [LOCK m_pool.cs]
│             AcceptSingleTransactionInternal (:1323)
│              │
│              ├─[1] PreChecks (:786)
│              │      ├─ CheckTransaction (consensus/tx_check.cpp:11)
│              │      ├─ IsStandardTx (policy/policy.cpp)
│              │      ├─ CheckFinalTxAtTip (:155)
│              │      ├─ m_pool.GetConflictTx (:689)
│              │      ├─ CCoinsViewMemPool::GetCoin / HaveCoin (:742)
│              │      ├─ CalculateLockPointsAtTip (:209)
│              │      │    └─ CheckSequenceLocksAtTip (:254)
│              │      ├─ Consensus::CheckTxInputs (tx_verify.cpp:164)
│              │      ├─ ValidateInputsStandardness
│              │      ├─ IsWitnessStandard
│              │      ├─ GetTransactionSigOpCost
│              │      ├─ ChangeSet::StageAddition (:634)
│              │      │    └─ m_txgraph->AddTransaction [staging]
│              │      ├─ CheckFeeRate (:707)
│              │      ├─ m_pool.GetParents
│              │      └─ SingleTRUCChecks (policy/truc_policy.cpp)
│              │
│              ├─[2] (if rbf) ReplacementChecks (:988)
│              │      ├─ GetEntriesForConflicts (policy/rbf.cpp:58)
│              │      ├─ PaysForRBF (:100)
│              │      ├─ ChangeSet::StageRemoval
│              │      ├─ ChangeSet::CheckMemPoolPolicyLimits
│              │      └─ ImprovesFeerateDiagram (:127)
│              │           └─ ChangeSet::CalculateChunksForRBF
│              │                └─ m_txgraph->GetChunksForRBF
│              │
│              ├─[3] ChangeSet::CheckMemPoolPolicyLimits
│              │
│              ├─[4] PolicyScriptChecks (:1139)
│              │      └─ CheckInputScripts (:2067) [STANDARD flags]
│              │           └─ Per input: CScriptCheck → VerifyScript
│              │
│              ├─[5] ConsensusScriptChecks (:1162)
│              │      ├─ GetBlockScriptFlags (:2256)
│              │      └─ CheckInputsFromMempoolAndCache (:403)
│              │           └─ CheckInputScripts (:2067) [consensus flags]
│              │                └─ m_script_execution_cache.insert
│              │
│              ├─[6] FinalizeSubpackage (:1195)
│              │      └─ ChangeSet::Apply → CTxMemPool::Apply (:206)
│              │           ├─ m_txgraph->CommitStaging
│              │           ├─ RemoveStaged (:793)
│              │           │    └─ removeUnchecked (:263)  [per replaced tx]
│              │           │         ├─ signals->TransactionRemovedFromMempool
│              │           │         ├─ TRACEPOINT(mempool, removed)
│              │           │         ├─ mapNextTx.erase
│              │           │         ├─ txns_randomized swap-pop
│              │           │         └─ mapTx.erase
│              │           ├─ mapTx.insert (splice from ChangeSet::m_to_add)
│              │           ├─ addNewTransaction (:229)
│              │           │    ├─ mapNextTx.insert
│              │           │    ├─ totalTxSize/m_total_fee/cachedInnerUsage +=
│              │           │    ├─ txns_randomized.emplace_back
│              │           │    └─ TRACEPOINT(mempool, added)
│              │           └─ m_txgraph->DoWork [post-change linearization]
│              │
│              ├─[7] signals->TransactionAddedToMempool
│              │
│              └─[8] (if !package_submission) LimitMempoolSize (:272)
│                     ├─ CTxMemPool::Expire (:811)
│                     │    └─ removeUnchecked (:263) per expired tx
│                     └─ CTxMemPool::TrimToSize (:861)
│                          └─ while over sizelimit:
│                               ├─ m_txgraph->GetWorstMainChunk
│                               ├─ trackPackageRemoved → rollingMinimumFeeRate
│                               └─ removeUnchecked (:263) per evicted tx
│                                    └─ signals->TransactionRemovedFromMempool

ProcessNewPackage (validation.cpp:1813)
│   ├─[test] ATMPArgs::PackageTestAccept
│   │         └─ AcceptMultipleTransactionsAndCleanup (:604)
│   └─[live] ATMPArgs::PackageChildWithParents
│             └─ AcceptPackage (:1628)
│                  ├─ IsWellFormedPackage / IsChildWithParents
│                  ├─ [LOCK m_pool.cs]
│                  ├─ Per tx: AcceptSubPackage({tx}, args) (:1602)
│                  │    └─ AcceptSingleTransactionInternal [SingleInPackageAccept]
│                  │         └─ ... [same path as above, steps 1–7,
│                  │                 but LimitMempoolSize deferred]
│                  ├─ AcceptSubPackage(txns_package_eval, args) (:1602)
│                  │    └─ AcceptMultipleTransactionsInternal (:1438)
│                  │         ├─ Per tx: PreChecks
│                  │         │    └─ m_viewmempool.PackageAddTransaction (:765)
│                  │         ├─ Per tx: PackageTRUCChecks
│                  │         ├─ CheckFeeRate [aggregate]
│                  │         ├─ (if rbf) PackageRBFChecks (:1041)
│                  │         │    ├─ GetEntriesForConflicts
│                  │         │    ├─ PaysForRBF [aggregate fees]
│                  │         │    ├─ ChangeSet::CheckMemPoolPolicyLimits
│                  │         │    └─ ImprovesFeerateDiagram
│                  │         ├─ ChangeSet::CheckMemPoolPolicyLimits
│                  │         ├─ CheckEphemeralSpends
│                  │         ├─ Per tx: PolicyScriptChecks
│                  │         └─ SubmitPackage (:1246)
│                  │              ├─ FinalizeSubpackage [→ CTxMemPool::Apply]
│                  │              └─ Per ws: ConsensusScriptChecks
│                  │                   + signals->TransactionAddedToMempool
│                  ├─ ClearSubPackageState (abort staging if not applied)
│                  └─ LimitMempoolSize (:272)
│                       └─ [Expire + TrimToSize as above]

═══════════════════════════════════════════════════════════════════════
```

---

### Key Invariants

- **`cs_main` + `m_pool.cs`** are both required for any `MemPoolAccept` method. `AcceptToMemoryPool` requires the caller to already hold `cs_main`; `m_pool.cs` is taken inside `AcceptSingleTransactionAndCleanup`.
- **The `ChangeSet`** is the atomic staging unit. Nothing is visible to the pool until `ChangeSet::Apply` → `CTxMemPool::Apply` commits the staging TxGraph and splices entries into `mapTx`.
- **`LimitMempoolSize` must not be called while a changeset is open** (`TrimToSize` asserts `!m_have_changeset`). This is why `AcceptMultipleTransactionsAndCleanup` and `AcceptPackage` clear the sub-package state *before* calling `LimitMempoolSize`.
- **`rollingMinimumFeeRate`** (the dynamic mempool min fee) is bumped by `trackPackageRemoved` whenever `TrimToSize` evicts a chunk, creating hysteresis so evicted-feerate txns cannot immediately re-enter.
- **Script execution cache** is populated in `ConsensusScriptChecks` (not `PolicyScriptChecks`) so the cache is keyed on consensus flags, matching what block validation will re-verify.
