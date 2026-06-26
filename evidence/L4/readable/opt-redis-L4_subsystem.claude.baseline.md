# transcript: You are exploring the Redis source at /home/bench/repos/redis. I need a complete, precise, line-numbered walkthrough of the key expiration subsystem covering...


💬 I'll spawn an Explore agent to do a thorough structural walkthrough of the expiration subsystem across all relevant files.
  ▸ Agent(Redis expiration subsystem deep dive)
  ▸ Bash(find /home/bench/repos/redis -name "*.c" -o -name "*.h" | grep -E "(expire|server|db|string)" | head -20)
  ▸ Bash(ls -la /home/bench/repos/redis/src/ | grep -E "(expire|server|db|string)")
  ▸ Read(/home/bench/repos/redis/src)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Bash(grep -n "typedef struct redisDb" /home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/t_string.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)

💬 Let me spot-check a few key line numbers from the agent's findings before presenting them.
  ▸ Bash(grep -n "void expireCommand\|void expireatCommand\|void pexpireCommand\|void pexpireatCommand\|void persistCommand\|expireGenericCommand\|void activeExpireCy...)
  ▸ Bash(grep -n "kvobj \*lookupKeyRead\|kvobj \*lookupKeyWrite\|kvobj \*lookupKeyReadWithFlags\|kvobj \*lookupKeyWriteWithFlags\|kvobj \*lookupKey\b\|keyStatus expir...)
  ▸ Bash(grep -n "redisDb {" /home/bench/repos/redis/src/server.h; grep -n "kvstore \*keys\|kvstore \*expires\|estore \*sub\|expires_cursor\|avg_ttl" /home/bench/repo...)
  ▸ Bash(grep -n "void expireCommand\|void expireatCommand\|void pexpireCommand\|void pexpireatCommand\|void persistCommand\|expireGenericCommand\|void activeExpireCy...)
  ▸ Bash(grep -n "lookupKeyRead\b\|lookupKeyWrite\b\|lookupKeyReadWithFlags\|lookupKeyWriteWithFlags\|expireIfNeeded\|keyIsExpired\|deleteExpiredKeyAndPropagate\|prop...)
  ▸ Bash(grep -n "redisDb {" /home/bench/repos/redis/src/server.h; grep -n "kvstore \*keys\|kvstore \*expires\|estore \*sub\|expires_cursor\|avg_ttl" /home/bench/repo...)

💬 Let me read the files directly instead.
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/expire.c)

💬 Now I have everything I need. Here is the complete, verified picture:  ---  ## Redis Key Expiration Subsystem — Complete Reference  ### Data Structures  ``` ...

──────── RESULT (success, 355972ms, 23 turns) ────────
Now I have everything I need. Here is the complete, verified picture:

---

## Redis Key Expiration Subsystem — Complete Reference

### Data Structures

```
server.h:1207  typedef struct redisDb {
server.h:1208      kvstore *keys;            // main keyspace (all keys)
server.h:1209      kvstore *expires;         // shadow dict: same kvobj entries, indexed for expiry lookup
server.h:1210      estore *subexpires;       // hash-field (HFE) expiry, stored in ebuckets
server.h:1220      long long avg_ttl;        // exponential moving average, stats only
server.h:1221      unsigned long expires_cursor; // persistent cursor for active-expiry scan
               } redisDb;
```

`db->expires` is a `kvstore` (slot-sharded hash table). It holds pointers to the **same `kvobj` objects** as `db->keys`; the expiry deadline is embedded directly in the `kvobj` via `kvobjGetExpire`/`kvobjSetExpire`. There is no separate value stored — if a kvobj has an expire, it appears in both stores.

---

### Path 1 — Setting a TTL (EXPIRE family)

```
EXPIRE / PEXPIRE / EXPIREAT / PEXPIREAT
  └─ expireCommand        expire.c:846   calls expireGenericCommand(c, commandTimeSnapshot(), UNIT_SECONDS)
  └─ pexpireCommand       expire.c:856   calls expireGenericCommand(c, commandTimeSnapshot(), UNIT_MILLISECONDS)
  └─ expireatCommand      expire.c:851   calls expireGenericCommand(c, 0, UNIT_SECONDS)
  └─ pexpireatCommand     expire.c:861   calls expireGenericCommand(c, 0, UNIT_MILLISECONDS)

expireGenericCommand    expire.c:726
  ├─ parseExtendedExpireArgumentsOrReply  expire.c:675  (NX/XX/GT/LT flag parsing)
  ├─ lookupKeyWrite       db.c:370        (triggers lazy expiry check on the key itself)
  ├─ [flag checks: NX, XX, GT, LT]       expire.c:763-805
  ├─ checkAlreadyExpired  expire.c:652    (when <= now && not loading && not replica)
  │    ├── YES (TTL already elapsed, master only):
  │    │   └─ dbGenericDelete  db.c:844  (async if lazyfree_lazy_expire, flag=DB_FLAG_KEY_EXPIRED)
  │    │       replicated as explicit DEL/UNLINK via rewriteClientCommandVector
  │    └── NO (future TTL):
  │        └─ setExpire   db.c:2706
  │            └─ setExpireByLink  db.c:2711
  │                ├─ kvstoreDictFindLink(db->keys, slot, key)     find kvobj
  │                ├─ kvobjGetExpire(kv)                           read old expire
  │                ├─ [if old expire != -1] kvobjSetExpire(kv, when)   update in-place (no realloc)
  │                └─ [if no old expire]
  │                    ├─ estoreRemove(db->subexpires, slot, kv)   unhook HFE if hash
  │                    ├─ kvobjSetExpire(kv, when)                 embed deadline; may realloc
  │                    ├─ [if reallocated] kvstoreDictSetAtLink(db->keys, ...)  update main dict ptr
  │                    ├─ kvstoreDictAddRaw(db->expires, slot, kv) register in expires dict
  │                    └─ [if HFE] estoreAdd(db->subexpires, slot, kv, subexpiry)  re-register
  │                    └─ [writable replica] rememberSlaveKeyWithExpire  expire.c:601
  └─ rewriteClientCommandArgument → PEXPIREAT <abs-ms>   (for AOF/replication)
     notifyKeyspaceEvent("expire")

PERSIST
  └─ persistCommand       expire.c:911
      ├─ lookupKeyWrite   db.c:370
      └─ removeExpire     db.c:2685
          ├─ kvstoreDictTwoPhaseUnlinkFind(db->expires, slot, key)  find entry
          ├─ kvobjSetExpire(kv, -1)                                  clear deadline in kvobj
          └─ kvstoreDictTwoPhaseUnlinkFree(db->expires, ...)         remove from expires dict

SET with EX/PX/EXAT/PXAT (t_string.c)
  └─ setGenericCommand    t_string.c:87
      ├─ lookupKeyWriteWithLink  db.c:380
      ├─ setKeyByLink     db.c:754          (inserts/replaces value)
      └─ setExpireByLink  db.c:2711         (same function as above)
```

**Key invariant:** the expiry deadline lives inside the `kvobj` itself. `db->expires` is an index that lets the active-expiry scanner enumerate only keys that have a TTL, without scanning all of `db->keys`.

---

### Path 2 — Lazy Expiry (on key access)

Every read or write command goes through `lookupKey`. Expiry is checked synchronously on the access thread before the command sees the value.

```
GET (or any command doing a key lookup)
  └─ lookupKeyRead        db.c:356
      └─ lookupKeyReadWithFlags  db.c:349
          └─ lookupKey    db.c:279
              ├─ dbFindByLink(db, key->ptr, link)   find kvobj in db->keys
              ├─ [if found] build expire_flags:
              │   EXPIRE_FORCE_DELETE_EXPIRED   if LOOKUP_WRITE && not read-only replica  db.c:294
              │   EXPIRE_AVOID_DELETE_EXPIRED   if LOOKUP_NOEXPIRE                         db.c:296
              │   EXPIRE_ALLOW_ACCESS_EXPIRED   if LOOKUP_ACCESS_EXPIRED                   db.c:298
              └─ expireIfNeeded(db, key, val, expire_flags)  db.c:2935   ← core gate

expireIfNeeded          db.c:2935   returns KEY_VALID | KEY_EXPIRED | KEY_DELETED | KEY_TRIMMED
  ├─ asmIsKeyInTrimJob(key_name)       db.c:2942   (cluster slot migration guard)
  ├─ EXPIRE_ALLOW_ACCESS_EXPIRED set?  db.c:2952   → KEY_VALID (caller wants the expired value)
  ├─ keyIsExpired(db, key, kv)         db.c:2877
  │   ├─ server.loading || allow_access_expired → 0 (never expire during load)
  │   ├─ getExpire(db, key, kv)        db.c:2762   → kvobjGetExpire(kv) (or lookup in db->expires)
  │   └─ return commandTimeSnapshot() > when
  ├─ [not expired] → KEY_VALID
  ├─ [replica, no FORCE flag] → KEY_EXPIRED (report expired but do not delete; wait for master DEL)
  ├─ confAllowsExpireDel()             db.c:2889   (nested-cmd / arbitrary-keys guard)
  ├─ EXPIRE_AVOID_DELETE_EXPIRED set?  → KEY_EXPIRED
  ├─ isPausedActionsWithUpdate(PAUSE_ACTION_EXPIRE) → KEY_EXPIRED
  └─ [master, delete allowed]
      └─ deleteExpiredKeyAndPropagate(db, key)  db.c:2826
          └─ deleteKeyAndPropagate(db, key, NOTIFY_EXPIRED, NULL)  db.c:2775
              ├─ lazy_flag = server.lazyfree_lazy_expire
              ├─ dbGenericDelete(db, key, lazy_flag, DB_FLAG_KEY_EXPIRED)  db.c:844
              │   ├─ kvstoreDictTwoPhaseUnlinkFind(db->keys, slot, key)     unlink from main dict
              │   ├─ [OBJ_HASH] estoreRemove(db->subexpires, slot, kv)      unhook HFE
              │   ├─ kvobjGetExpire(kv) != -1 →
              │   │   kvstoreDictDelete(db->expires, slot, key)              remove from expires dict
              │   ├─ [async] freeObjAsync(key, kv, db->id)                  lazy-free via BIO thread
              │   └─ kvstoreDictTwoPhaseUnlinkFree(db->keys, ...)            complete removal
              ├─ notifyKeyspaceEvent(NOTIFY_EXPIRED, "expired", ...)
              ├─ keyModified(NULL, db, key, NULL, 1)                         CSC invalidation
              ├─ propagateDeletion(db, key, lazy_flag)  db.c:2854
              │   └─ alsoPropagate(db->id, [DEL|UNLINK, key], 2,
              │                    PROPAGATE_AOF|PROPAGATE_REPL)             db.c:2866
              └─ server.stat_expiredkeys++
      return KEY_DELETED
```

Back in `lookupKey` (db.c:302–306): if `expireIfNeeded` returns anything other than `KEY_VALID`, `val` is set to `NULL` and the lookup returns `NULL`. The command then sees a missing key.

---

### Path 3 — Active Expiry (background, server cron)

Two call sites in the event loop:
- **Slow cycle**: `serverCron` → `activeExpireCycle(ACTIVE_EXPIRE_CYCLE_SLOW)` — runs at `server.hz` (default 10 Hz), may use up to `slow_time_perc`% of one CPU cycle
- **Fast cycle**: `beforeSleep` → `activeExpireCycle(ACTIVE_EXPIRE_CYCLE_FAST)` — short bursts capped to `config_cycle_fast_duration` µs, skipped if the previous slow cycle did not hit the time limit

```
activeExpireCycle(type)    expire.c:287
  ├─ isPausedActionsWithUpdate(PAUSE_ACTION_EXPIRE)  → return immediately
  ├─ [FAST cycle guards]     expire.c:318-331  (skip if not needed, or too recent)
  ├─ timelimit = slow_time_perc*1000000/server.hz/100   (µs budget per call)
  └─ for each DB (up to dbs_per_call, respecting timelimit):
      ├─ activeSubexpiresCycle(type)    expire.c:228    ← hash-field (HFE) expiry
      │   └─ activeSubexpires(db, slot, maxFieldsToExpire)  expire.c:208
      │       └─ estoreActiveExpire(db->subexpires, slot, &info)
      │           └─ [for each expired field] activeSubexpiresCb  expire.c:170
      │               └─ hashTypeExpire(db, kv, &quota, 0, 1)
      │
      └─ do { ... } while (expired/sampled > acceptable_stale && !timelimit_exit)
          ├─ data.now = mstime()                         expire.c:405  (snapshot for the scan batch)
          └─ kvstoreScan(db->expires, db->expires_cursor, -1,
                         expireScanCallback,
                         expirySamplingShouldSkipDict,
                         &data)                          expire.c:431
              │  cursor saved in db->expires_cursor — scan resumes across calls
              │
              ├─ expirySamplingShouldSkipDict  expire.c:130
              │   ├─ skip if dict is <1% full (avoid sparse scans)
              │   └─ skip if clusterCanAccessKeysInSlot() == 0 (slot migration)
              │
              └─ expireScanCallback(privdata, de, plink)  expire.c:114
                  ├─ kv = dictGetKV(de)
                  ├─ ttl = kvobjGetExpire(kv) - data.now
                  └─ activeExpireCycleTryExpire(data->db, kv, data->now)  expire.c:40
                      ├─ now < kvobjGetExpire(kv) → return 0  (not yet expired)
                      └─ [expired]:
                          ├─ enterExecutionUnit(1, 0)
                          ├─ keyobj = createStringObject(kvobjGetKey(kv), ...)
                          ├─ deleteExpiredKeyAndPropagate(db, keyobj)   db.c:2826
                          │   └─ [identical to lazy path above]
                          ├─ server.stat_expiredkeys_active++
                          ├─ exitExecutionUnit()
                          └─ postExecutionUnitOperations()   ← flushes also_propagate queue
                                                              (AOF write + replication send)
```

**Why `postExecutionUnitOperations` matters here:** lazy expiry fires inside `call()`, which handles propagation itself. Active expiry fires outside `call()`, so each batch of deletions needs an explicit flush of the `also_propagate` queue. The `serverAssert(server.also_propagate.numops == 0)` at expire.c:361 checks the slate is clean at entry.

---

### Replica and Writable-Slave Details

| Scenario | `expireIfNeeded` behaviour |
|---|---|
| Read-only replica, no `FORCE` flag | Returns `KEY_EXPIRED` (lies to caller), does **not** delete. Waits for `DEL`/`UNLINK` from master via replication stream. |
| Client is `CLIENT_MASTER` (replication feed) | Returns `KEY_VALID` — never expire keys the master just sent. |
| Writable replica | `EXPIRE_FORCE_DELETE_EXPIRED` is set on write-path lookups; deletion + propagation proceeds normally. Key is also tracked in `slaveKeysWithExpire` (expire.c:544) so `expireSlaveKeys` (expire.c:548) can sweep them periodically. |

`propagateDeletion` (db.c:2854) always forces `server.replication_allowed = 1` before calling `alsoPropagate`, so expiry-driven `DEL`/`UNLINK` are propagated even inside module contexts that disabled replication.

---

### Unified Call Graph

```
┌─────────────────────── PATH 1: SET TTL ────────────────────────────────┐
│  expireCommand (expire.c:846)                                           │
│  pexpireCommand (expire.c:856)      ──►  expireGenericCommand           │
│  expireatCommand (expire.c:851)           (expire.c:726)                │
│  pexpireatCommand (expire.c:861)            │                           │
│                                             ├─ parseExtendedExpire      │
│  setGenericCommand (t_string.c:87) ─────►   │   ArgumentsOrReply       │
│                                             │   (expire.c:675)         │
│                                             ├─ lookupKeyWrite (db.c:370)│
│                                             │   └─ lookupKey (db.c:279) │
│                                             │       └─ expireIfNeeded ──┼──► PATH 2
│                                             ├─ checkAlreadyExpired      │
│                                             │   (expire.c:652)          │
│                                             ├─ [already expired]        │
│                                             │   └─ dbGenericDelete ─────┼──► DELETION
│                                             └─ [future expire]          │
│                                                 └─ setExpire (db.c:2706)│
│                                                     └─ setExpireByLink  │
│                                                         (db.c:2711)     │
│                                                 ┌──────────────────┐    │
│                                                 │ kvobjSetExpire   │    │
│                                                 │ kvstoreDictAddRaw│    │
│                                                 │  (db->expires)   │    │
│                                                 └──────────────────┘    │
└────────────────────────────────────────────────────────────────────────┘

┌─────────────────────── PATH 2: LAZY EXPIRY ────────────────────────────┐
│  GET / any command                                                      │
│   └─ lookupKeyRead (db.c:356)                                           │
│       └─ lookupKeyReadWithFlags (db.c:349)          ─┐                  │
│   └─ lookupKeyWrite (db.c:370)                        │                 │
│       └─ lookupKeyWriteWithFlags (db.c:366)           │                 │
│                                                       ▼                 │
│                                              lookupKey (db.c:279)       │
│                                               └─ dbFindByLink           │
│                                               └─ expireIfNeeded         │
│                                                   (db.c:2935)           │
│                                                   ├─ keyIsExpired       │
│                                                   │   (db.c:2877)       │
│                                                   │   ├─ getExpire      │
│                                                   │   │  (db.c:2762)    │
│                                                   │   │  kvobjGetExpire │
│                                                   │   └─ commandTime    │
│                                                   │      Snapshot()     │
│                                                   ├─ confAllowsExpireDel│
│                                                   │   (db.c:2889)       │
│                                                   └─ deleteExpiredKey   │
│                                                      AndPropagate ──────┼──► DELETION
│                                                      (db.c:2826)        │
└────────────────────────────────────────────────────────────────────────┘

┌─────────────────────── PATH 3: ACTIVE EXPIRY ──────────────────────────┐
│  serverCron → activeExpireCycle(SLOW)   expire.c:287                   │
│  beforeSleep → activeExpireCycle(FAST)                                 │
│                  └─ [per db, per batch]                                 │
│                      ├─ activeSubexpiresCycle (expire.c:228) ─► HFE    │
│                      └─ kvstoreScan(db->expires, cursor,               │
│                                     expireScanCallback)   expire.c:431 │
│                             └─ expireScanCallback (expire.c:114)        │
│                                 └─ activeExpireCycleTryExpire           │
│                                     (expire.c:40)                       │
│                                     └─ deleteExpiredKeyAndPropagate ────┼──► DELETION
│                                         (db.c:2826)                     │
│                                     └─ postExecutionUnitOperations()    │
│                                         (flush AOF + replication)       │
└────────────────────────────────────────────────────────────────────────┘

┌─────────────────────── SHARED DELETION SPINE ──────────────────────────┐
│  deleteExpiredKeyAndPropagate (db.c:2826)                               │
│   └─ deleteKeyAndPropagate (db.c:2775)                                  │
│       ├─ dbGenericDelete (db.c:844)                                     │
│       │   ├─ kvstoreDictTwoPhaseUnlinkFind(db->keys)                    │
│       │   ├─ estoreRemove(db->subexpires)        if OBJ_HASH            │
│       │   ├─ kvstoreDictDelete(db->expires)      if expire != -1        │
│       │   ├─ [async] freeObjAsync()              if lazyfree_lazy_expire│
│       │   └─ kvstoreDictTwoPhaseUnlinkFree(db->keys)                    │
│       ├─ notifyKeyspaceEvent("expired")                                 │
│       ├─ keyModified()                           CSC/tracking           │
│       ├─ propagateDeletion (db.c:2854)                                  │
│       │   └─ alsoPropagate([DEL|UNLINK, key],                           │
│       │                    PROPAGATE_AOF|PROPAGATE_REPL)  db.c:2866     │
│       └─ server.stat_expiredkeys++                                      │
└────────────────────────────────────────────────────────────────────────┘
```

### Summary of every named function with file:line

| Function | File:line | Role |
|---|---|---|
| `expireCommand` | expire.c:846 | `EXPIRE key seconds` |
| `pexpireCommand` | expire.c:856 | `PEXPIRE key ms` |
| `expireatCommand` | expire.c:851 | `EXPIREAT key unix-s` |
| `pexpireatCommand` | expire.c:861 | `PEXPIREAT key unix-ms` |
| `persistCommand` | expire.c:911 | `PERSIST key` — removes TTL |
| `ttlCommand` / `pttlCommand` | expire.c:891/896 | Read TTL (via `ttlGenericCommand`) |
| `expiretimeCommand` / `pexpiretimeCommand` | expire.c:901/906 | Read absolute deadline |
| `checkAlreadyExpired` | expire.c:652 | Gate: is the requested TTL already in the past? |
| `parseExtendedExpireArgumentsOrReply` | expire.c:675 | NX/XX/GT/LT flag parsing |
| `expireGenericCommand` | expire.c:726 | Core implementation of all EXPIRE variants |
| `setExpire` | db.c:2706 | Thin wrapper → `setExpireByLink` |
| `setExpireByLink` | db.c:2711 | Embed deadline in kvobj; add to `db->expires` |
| `removeExpire` | db.c:2685 | Clear deadline; remove from `db->expires` |
| `getExpire` | db.c:2762 | Read deadline from kvobj / `db->expires` |
| `lookupKey` | db.c:279 | Core lookup; calls `expireIfNeeded` |
| `lookupKeyRead` | db.c:356 | Read-path entry point |
| `lookupKeyReadWithFlags` | db.c:349 | Read-path with flags |
| `lookupKeyWrite` | db.c:370 | Write-path entry point |
| `lookupKeyWriteWithFlags` | db.c:366 | Write-path with flags |
| `lookupKeyWriteWithLink` | db.c:380 | Write-path + link out-param |
| `keyIsExpired` | db.c:2877 | Boolean: `now > deadline` (with loading/access guards) |
| `confAllowsExpireDel` | db.c:2889 | Guard: nested-cmd / arbitrary-keys config check |
| `expireIfNeeded` | db.c:2935 | Lazy expiry gate; returns `KEY_VALID/EXPIRED/DELETED/TRIMMED` |
| `deleteExpiredKeyAndPropagate` | db.c:2826 | Public entry: expire a key + propagate |
| `deleteKeyAndPropagate` (static) | db.c:2775 | Shared logic for expiry and eviction |
| `propagateDeletion` | db.c:2854 | Queue `DEL`/`UNLINK` to AOF + replicas |
| `dbGenericDelete` | db.c:844 | Remove from `db->keys`, `db->expires`, `db->subexpires` |
| `dbSyncDelete` | db.c:903 | Synchronous delete (calls `dbGenericDelete` async=0) |
| `dbAsyncDelete` | db.c:909 | Async/lazy-free delete (async=1) |
| `dbDelete` | db.c:915 | Respects `lazyfree_lazy_server_del` config |
| `dbFindExpires` | db.c:3076 | Lookup kvobj in `db->expires` by key name |
| `activeExpireCycle` | expire.c:287 | Background scan; called by cron (slow) and beforeSleep (fast) |
| `expireScanCallback` | expire.c:114 | Per-entry callback from `kvstoreScan` |
| `expirySamplingShouldSkipDict` | expire.c:130 | Skip sparse or migrating slot dicts |
| `activeExpireCycleTryExpire` | expire.c:40 | Check one kvobj; delete if expired |
| `activeSubexpiresCycle` | expire.c:228 | Hash-field (HFE) active expiry driver |
| `activeSubexpires` | expire.c:208 | Per-slot HFE expiry via `estoreActiveExpire` |
| `activeSubexpiresCb` | expire.c:170 | Callback: expire fields, return ACT_UPDATE/REMOVE |
| `expireSlaveKeys` | expire.c:548 | Periodic scan of writable-replica keys with TTL |
| `rememberSlaveKeyWithExpire` | expire.c:601 | Track key in `slaveKeysWithExpire` on writable replica |
