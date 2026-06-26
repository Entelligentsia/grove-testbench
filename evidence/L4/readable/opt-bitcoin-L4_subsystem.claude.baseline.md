# transcript: I need a thorough, end-to-end mapping of Bitcoin Core's mempool transaction-acceptance subsystem. The working directory is /home/bench/repos/bitcoin. Search ...


💬 I'll spawn an Explore agent to map the mempool acceptance subsystem thoroughly across the relevant source files.
  ▸ Agent(Deep exploration of Bitcoin Core mempool acceptance subsystem)
  ▸ Read(/home/bench/repos/bitcoin/src/txmempool.h)
  ▸ Read(/home/bench/repos/bitcoin/src/validation.h)
  ▸ Read(/home/bench/repos/bitcoin/src/policy/fees.h)
  ▸ Read(/home/bench/repos/bitcoin/src/policy/policy.h)
  ▸ Read(/home/bench/repos/bitcoin/src/consensus/tx_verify.h)
  ▸ Read(/home/bench/repos/bitcoin/src/txmempool.cpp)
  ▸ Read(/home/bench/repos/bitcoin/src/validation.cpp)
  ▸ Read(/home/bench/repos/bitcoin/src/policy/policy.cpp)
  ▸ Read(/home/bench/repos/bitcoin/src/consensus/tx_verify.cpp)
  ▸ Bash(grep -n "^MempoolAcceptResult AcceptToMemoryPool\|^bool MemPoolAccept::\|^PackageMempoolAcceptResult ProcessNewPackage\|^bool MemPoolAccept::PreChecks\|^bool...)
  ▸ Read(/home/bench/repos/bitcoin/src/validation.cpp)
  ▸ Read(/home/bench/repos/bitcoin/src/validation.cpp)

💬 Here is the complete picture, organized from entry point to eviction, with file:line for every function.  ---  ## 1. Entry Points  ### `AcceptToMemoryPool` —...

──────── RESULT (success, 266204ms, 2 turns) ────────
Here is the complete picture, organized from entry point to eviction, with file:line for every function.

---

## 1. Entry Points

### `AcceptToMemoryPool` — `src/validation.cpp:1781`
Single-transaction public API. Creates an `ATMPArgs::SingleAccept` argument bundle, then delegates.

```
AcceptToMemoryPool(active_chainstate, tx, accept_time, bypass_limits, test_accept)
  → MemPoolAccept::AcceptSingleTransactionAndCleanup()          validation.cpp:591
```

### `ProcessNewPackage` — `src/validation.cpp:1813`
Package public API. Routes to test-accept or full submission.

```
ProcessNewPackage(active_chainstate, pool, package, test_accept, client_maxfeerate)
  → [test_accept] AcceptMultipleTransactionsAndCleanup()        validation.cpp:604
  → [submit]      AcceptPackage()                               validation.cpp:1628
```

---

## 2. `MemPoolAccept` — The Central Class (`src/validation.cpp:442`)

Defined entirely inside `src/validation.cpp` as a local class. Key inner types:

| Type | Lines | Purpose |
|---|---|---|
| `ATMPArgs` | 456–585 | Immutable flags per call (bypass_limits, test_accept, allow_replacement, package_feerates, client_maxfeerate). Four factory methods: `SingleAccept`, `PackageTestAccept`, `PackageChildWithParents`, `SingleInPackageAccept`. |
| `Workspace` | 634–670 | Per-transaction mutable state: conflicts, changeset handle, effective feerate, replaced txs. |
| `SubPackageState` | 753–772 | Aggregate state across a subpackage: total conflicts, combined vsize/fees. |

---

## 3. Single-Transaction Path

```
AcceptSingleTransactionAndCleanup()          validation.cpp:591
  acquires cs_main
  → AcceptSingleTransactionInternal()        validation.cpp:1323
       ├─1. PreChecks()                      validation.cpp:786
       ├─2. [if conflicts] ReplacementChecks() validation.cpp:988
       ├─3. PolicyScriptChecks()             validation.cpp:1139
       ├─4. ConsensusScriptChecks()          validation.cpp:1162
       ├─5. FinalizeSubpackage()             validation.cpp:1195
       └─6. LimitMempoolSize()               validation.cpp:272
  → ClearSubPackageState()
```

---

## 4. Package Path

```
AcceptPackage()                              validation.cpp:1628
  ├─ IsWellFormedPackage()                   src/policy/packages.cpp
  ├─ IsChildWithParents()                    src/policy/packages.cpp
  └─ for each tx in topological order:
       ├─ [already in mempool]  → MempoolTx() result
       ├─ [same-txid-diff-wit]  → MempoolTxDifferentWitness() result
       └─ [new tx] AcceptSubPackage()        validation.cpp:1602
            ├─ [size > 1] AcceptMultipleTransactionsInternal()  validation.cpp:1438
            └─ [size == 1] AcceptSingleTransactionInternal()    validation.cpp:1323
  → LimitMempoolSize()                       validation.cpp:272  (once, after all subpackages)
```

### `AcceptMultipleTransactionsInternal` — `validation.cpp:1438`
Used for multi-tx subpackages (child+unconfirmed-parents):

```
AcceptMultipleTransactionsInternal()
  ├─ for each tx: PreChecks()                validation.cpp:786
  ├─ PackageAddTransaction() on view         (make outputs visible to descendants)
  ├─ for each tx: PackageTRUCChecks()        validation.cpp (TRUC/v3 policy)
  ├─ CheckFeeRate() aggregate                (package feerate)
  ├─ [if conflicts] PackageRBFChecks()       validation.cpp:1041
  ├─ for each tx: PolicyScriptChecks()       validation.cpp:1139
  └─ SubmitPackage()                         validation.cpp:1246
       ├─ FinalizeSubpackage()               validation.cpp:1195
       └─ for each tx: ConsensusScriptChecks() validation.cpp:1162
```

---

## 5. Validation Check Details

### `PreChecks` — `validation.cpp:786`
The first and most comprehensive gate. In order:

| Step | Function Called | File:Line |
|---|---|---|
| Basic tx validity | `CheckTransaction()` | `src/primitives/transaction.cpp` |
| Standard policy | `IsStandardTx()` | `src/policy/policy.cpp:100` |
| Finality (nLockTime) | `CheckFinalTxAtTip()` | `validation.cpp:155` |
| Duplicate exact | lookup in `mapTx` | — |
| Duplicate witness-only | lookup in `mapTx` | — |
| Conflict detection | iterate `mapNextTx` | — |
| UTXO existence | `CCoinsViewMemPool::GetCoin()` | — |
| Sequence locks | `CalculateLockPointsAtTip()` → `CheckSequenceLocksAtTip()` | `validation.cpp:209, 254` |
| UTXO value math | `Consensus::CheckTxInputs()` | `src/consensus/tx_verify.cpp:164` |
| Input script types | `ValidateInputsStandardness()` | `src/policy/policy.cpp:214` |
| Witness format | `IsWitnessStandard()` | `src/policy/policy.cpp:265` |
| Sigop cost | `GetTransactionSigOpCost()` | `src/consensus/tx_verify.cpp:143` |
| Ephemeral anchor | internal checks | — |
| TRUC/v3 rules | `SingleTRUCChecks()` | — |
| Stage for changeset | `ChangeSet::StageAddition()` | `src/txmempool.h:634` |
| Min relay fee | `GetMinFee()` / `CheckFeeRate()` | — |

### `ReplacementChecks` — `validation.cpp:988` (single-tx RBF)

```
ReplacementChecks()
  ├─ GetEntriesForConflicts()          (collect all directly+transitively conflicting entries)
  ├─ PaysForRBF()                      (fee increment ≥ relay cost of replaced vbytes, BIP 125 rule 3/4)
  ├─ CheckMemPoolPolicyLimits()        (cluster size constraints on changeset)
  └─ ImprovesFeerateDiagram()          (new tx must strictly improve chunk feerate diagram)
```

### `PackageRBFChecks` — `validation.cpp:1041`
Stricter version for packages (must be size-2 child-with-parent, no in-mempool parents of conflicting txs):

```
PackageRBFChecks()
  ├─ GetEntriesForConflicts()
  ├─ PaysForRBF()                      (aggregate package fees)
  ├─ CheckMemPoolPolicyLimits()
  └─ ImprovesFeerateDiagram()
```

### `PolicyScriptChecks` — `validation.cpp:1139`
Expensive; uses `STANDARD_SCRIPT_VERIFY_FLAGS`:

```
PolicyScriptChecks()
  └─ CheckInputScripts()               validation.cpp  (EvalScript loop over all inputs)
```

### `ConsensusScriptChecks` — `validation.cpp:1162`
Runs after policy passes; caches results in `ValidationCache` for block validation:

```
ConsensusScriptChecks()
  └─ CheckInputsFromMempoolAndCache()  validation.cpp:403
       (flags from chain tip; populates script-sig cache)
```

### `FinalizeSubpackage` — `validation.cpp:1195`
Applies staged changes atomically:

```
FinalizeSubpackage()
  └─ CTxMemPool::ChangeSet::Apply()    txmempool.cpp:206
       ├─ m_txgraph->CommitStaging()   (TxGraph cluster accounting)
       ├─ RemoveStaged()               (evict RBF victims)
       ├─ addNewTransaction() per tx   txmempool.cpp:229
       └─ m_txgraph->DoWork()
```

---

## 6. `CTxMemPool` Internals (`src/txmempool.h:186`, `src/txmempool.cpp`)

### Insertion: `addNewTransaction` — `txmempool.cpp:229`
Updates every tracking structure after a tx enters:
- `cachedInnerUsage` (memory accounting)
- `mapNextTx` (outpoint → spending-tx index)
- `totalTxSize`, `m_total_fee`
- `txns_randomized` (for random iteration)
- `nTransactionsUpdated`

### Removal: `removeUnchecked` — `txmempool.cpp:263`
Tears down all the above for one entry; called by `RemoveStaged` and `removeRecursive`. Takes a `MemPoolRemovalReason` enum:
```
EXPIRY | SIZELIMIT | REORG | BLOCK | CONFLICT | REPLACED | EXTERNAL
```

### Block confirmation: `removeForBlock` — `txmempool.cpp:405`
Called from `ConnectBlock` when a block is connected:

```
removeForBlock(vtx, nBlockHeight)
  ├─ for each block tx: removeUnchecked(BLOCK)
  ├─ removeConflicts()                (remove mempool txs spending same outputs as block txs)
  └─ signal MempoolTransactionsRemovedForBlock
```

### Reorg removal: `removeForReorg` — `txmempool.cpp:360`
Called on disconnect; re-checks maturity and finality for remaining mempool txs.

---

## 7. Eviction: `LimitMempoolSize` — `validation.cpp:272`

```
LimitMempoolSize(pool, coins_cache)
  ├─ pool.Expire(now - expiry_hours)   txmempool.h:461
  │    (remove txs older than -mempoolexpiry, walking EXPIRY reason)
  └─ pool.TrimToSize(max_size_bytes)   txmempool.h:458
       (remove lowest-feerate-chunk txs until pool fits;
        uses TxGraph chunk feerate ordering;
        signals MemPoolRemovalReason::SIZELIMIT)
  └─ coins_cache.Uncache(removed_outpoints)
```

`TrimToSize` uses the `TxGraph` cluster/chunk structure to find the globally worst chunk by feerate and evict it (plus its descendants) atomically, so the mempool's feerate diagram is always convex after trimming.

---

## 8. Key Supporting Types

| Type | File:Line | Role |
|---|---|---|
| `MempoolAcceptResult` | `validation.h:131` | Single-tx outcome; ResultType: VALID / INVALID / MEMPOOL_ENTRY / DIFFERENT_WITNESS |
| `PackageMempoolAcceptResult` | `validation.h:236` | Map of `Wtxid → MempoolAcceptResult` + package-level `PackageValidationState` |
| `TxValidationState` | `src/consensus/validation.h` | Carries rejection reason/code through the call chain |
| `CTxMemPool::ChangeSet` | `txmempool.h:618` | Staging buffer; `StageAddition`, `StageRemoval`, `Apply`, `CheckMemPoolPolicyLimits`, `CalculateChunksForRBF` |
| `TxGraph` | `src/txgraph.h` | Cluster-mempool graph; tracks chunks and their feerates for eviction and RBF diagram checks |
| `CCoinsViewMemPool` | `txmempool.h` | `CCoinsView` that overlays the mempool over the UTXO set; used in `PreChecks` |

---

## 9. Unified Call Graph

```
┌────────────────────────────────────────────────────────────────────────────┐
│  PUBLIC ENTRY POINTS                                                        │
│                                                                             │
│  AcceptToMemoryPool()                    ProcessNewPackage()                │
│  validation.cpp:1781                     validation.cpp:1813                │
│        │                                       │                            │
│        │                          ┌────────────┴────────────┐               │
│        │                    test_accept?               submit?               │
│        │                          │                          │              │
│        ↓                          ↓                          ↓              │
│  AcceptSingleTransaction     AcceptMultipleTx         AcceptPackage()       │
│  AndCleanup()                AndCleanup()             :1628                 │
│  :591                        :604                          │                │
│        │                          │                  ┌─────┴──────┐        │
│        │                          │             per tx        per tx        │
│        ↓                          ↓                  │          │           │
│  AcceptSingleTransaction     AcceptMultipleTx   AcceptSubPackage()           │
│  Internal()                  Internal()         :1602                        │
│  :1323                       :1438                   │                       │
│        │                          │             size==1?     size>1?         │
└────────┼──────────────────────────┼──────────────────┼─────────────┘        │
         │                          │                  │             │
         │                          │                  ↓             ↓
         │         ┌────────────────┘     AcceptSingleTx   AcceptMultipleTx
         │         │                      Internal()        Internal()
         ↓         ↓
┌──────────────────────────────────────────────────────────────────────┐
│  SHARED VALIDATION PIPELINE                                           │
│                                                                       │
│  1. PreChecks()  :786                                                 │
│       ├─ CheckTransaction()                                           │
│       ├─ IsStandardTx()                    policy.cpp:100            │
│       ├─ CheckFinalTxAtTip()               validation.cpp:155        │
│       ├─ [dup / conflict detection]        mapTx / mapNextTx         │
│       ├─ CalculateLockPointsAtTip()        :209                      │
│       ├─ CheckSequenceLocksAtTip()         :254                      │
│       ├─ Consensus::CheckTxInputs()        tx_verify.cpp:164         │
│       ├─ ValidateInputsStandardness()      policy.cpp:214            │
│       ├─ IsWitnessStandard()              policy.cpp:265            │
│       ├─ GetTransactionSigOpCost()         tx_verify.cpp:143         │
│       ├─ SingleTRUCChecks() / PackageTRUCChecks()                   │
│       └─ ChangeSet::StageAddition()        txmempool.h:634           │
│                                                                       │
│  2. [conflicts?] ReplacementChecks()  :988  ─OR─                     │
│                  PackageRBFChecks()   :1041                           │
│       ├─ GetEntriesForConflicts()                                     │
│       ├─ PaysForRBF()                                                 │
│       ├─ CheckMemPoolPolicyLimits()    (TxGraph cluster limit)        │
│       └─ ImprovesFeerateDiagram()     (convexity check)              │
│                                                                       │
│  3. PolicyScriptChecks()  :1139                                       │
│       └─ CheckInputScripts(STANDARD_FLAGS)                            │
│                                                                       │
│  4. ConsensusScriptChecks()  :1162                                    │
│       └─ CheckInputsFromMempoolAndCache()  :403                       │
│             (consensus flags, populates ValidationCache)             │
│                                                                       │
│  5. FinalizeSubpackage()  :1195                                       │
│       └─ ChangeSet::Apply()           txmempool.cpp:206              │
│             ├─ TxGraph::CommitStaging()                               │
│             ├─ RemoveStaged()  → removeUnchecked(REPLACED)  :263     │
│             ├─ addNewTransaction()    txmempool.cpp:229               │
│             └─ TxGraph::DoWork()                                      │
│                                                                       │
│  6. LimitMempoolSize()  :272                                          │
│       ├─ CTxMemPool::Expire()         txmempool.h:461                 │
│       │     └─ removeUnchecked(EXPIRY)                               │
│       └─ CTxMemPool::TrimToSize()     txmempool.h:458                 │
│             (TxGraph chunk-feerate order → removeUnchecked(SIZELIMIT))│
└──────────────────────────────────────────────────────────────────────┘

OUT-OF-BAND REMOVAL PATHS:
  ConnectBlock() → removeForBlock()  txmempool.cpp:405
                      ├─ removeUnchecked(BLOCK) per confirmed tx
                      └─ removeConflicts() → removeUnchecked(CONFLICT)

  DisconnectBlock() → removeForReorg()  txmempool.cpp:360
                        (re-checks maturity/finality, removes violators)
```

---

### Key architectural notes

- **`ChangeSet` is the atomicity mechanism.** `PreChecks` stages adds; `ReplacementChecks`/`PackageRBFChecks` stage removes. Nothing hits the real `mapTx` until `ChangeSet::Apply()` is called inside `FinalizeSubpackage`. This means the validation can be aborted cleanly at any point before finalization.

- **Two-pass script checking is intentional.** `PolicyScriptChecks` uses stricter standard flags (e.g., `SCRIPT_VERIFY_NULLFAIL`) to reject non-standard scripts before the expensive `ConsensusScriptChecks`. The consensus pass then caches its result in `ValidationCache` keyed on `(txid, flags)`, so `ConnectBlock` can reuse it without re-executing.

- **`TxGraph` drives eviction order.** `TrimToSize` doesn't sort all mempool transactions; it asks `TxGraph` for the lowest-feerate *chunk* (a topologically connected set of txs that should be mined together) and evicts it atomically, keeping the feerate diagram strictly convex.

- **`bypass_limits`** (set during reorg re-acceptance) skips step 6 entirely, allowing temporarily over-limit pools during block disconnect/reconnect.
