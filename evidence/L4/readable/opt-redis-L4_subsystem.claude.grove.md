# transcript: Give the complete end-to-end picture of key expiration in Redis as a subsystem: the entry points for setting a TTL (the EXPIRE family), lazy expiry on key ac...


💬 Loading grove tools first, then mapping the expiration subsystem.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me fan out across all three expiry paths in parallel.
  ▸ mcp__grove__outline({"file":"src/expire.c"})
  ▸ mcp__grove__symbols({"dir":"src","name":"expireCommand"})
  ▸ mcp__grove__symbols({"dir":"src","name":"expireIfNeeded"})
  ▸ mcp__grove__symbols({"dir":"src","name":"activeExpireCycle"})

💬 Good. Now fetching all four key function bodies in parallel.
  ▸ mcp__grove__source({"id":"c:src/expire.c#expireGenericCommand@726"})
  ▸ mcp__grove__source({"id":"c:src/db.c#expireIfNeeded@2935"})
  ▸ mcp__grove__source({"id":"c:src/expire.c#activeExpireCycle@287"})
  ▸ mcp__grove__source({"id":"c:src/expire.c#activeExpireCycleTryExpire@40"})

💬 Now fetching the remaining key functions in parallel: `setExpire`, `deleteExpiredKeyAndPropagate`, `lookupKeyRead`, `lookupKeyWrite`, `keyIsExpired`, `expire...
  ▸ mcp__grove__symbols({"dir":"src","name":"setExpire"})
  ▸ mcp__grove__symbols({"dir":"src","name":"deleteExpiredKeyAndPropagate"})
  ▸ mcp__grove__symbols({"dir":"src","name":"keyIsExpired"})
  ▸ mcp__grove__symbols({"dir":"src","name":"lookupKeyRead"})
  ▸ mcp__grove__symbols({"dir":"src","name":"lookupKeyWrite"})
  ▸ mcp__grove__source({"id":"c:src/expire.c#expireScanCallback@114"})

💬 Fetching the remaining function bodies in parallel.
  ▸ mcp__grove__source({"id":"c:src/db.c#setExpire@2706"})
  ▸ mcp__grove__source({"id":"c:src/db.c#deleteExpiredKeyAndPropagate@2826"})
  ▸ mcp__grove__source({"id":"c:src/db.c#keyIsExpired@2877"})
  ▸ mcp__grove__source({"id":"c:src/db.c#lookupKeyRead@356"})
  ▸ mcp__grove__source({"id":"c:src/db.c#lookupKeyWrite@370"})
  ▸ mcp__grove__callers({"dir":"src","name":"activeExpireCycle"})

💬 Now fetching the lookup internals, `setExpireByLink`, `deleteKeyAndPropagate`, `getExpire`, and the `databasesCron`/`serverCron` call chain.
  ▸ mcp__grove__symbols({"dir":"src","name":"lookupKeyReadWithFlags"})
  ▸ mcp__grove__symbols({"dir":"src","name":"lookupKeyWriteWithFlags"})
  ▸ mcp__grove__symbols({"dir":"src","name":"setExpireByLink"})
  ▸ mcp__grove__symbols({"dir":"src","name":"deleteKeyAndPropagate"})
  ▸ mcp__grove__symbols({"dir":"src","name":"getExpire"})
  ▸ mcp__grove__symbols({"dir":"src","name":"databasesCron"})
  ▸ mcp__grove__source({"id":"c:src/db.c#lookupKeyReadWithFlags@349"})
  ▸ mcp__grove__source({"id":"c:src/db.c#lookupKeyWriteWithFlags@366"})
  ▸ mcp__grove__source({"id":"c:src/db.c#setExpireByLink@2711"})
  ▸ mcp__grove__source({"id":"c:src/db.c#deleteKeyAndPropagate@2775"})
  ▸ mcp__grove__source({"id":"c:src/db.c#getExpire@2762"})
  ▸ mcp__grove__source({"id":"c:src/server.c#databasesCron@1305"})

💬 Last set of pieces: the `lookupKey` core, `serverCron` connection, and the `redisDb` struct.
  ▸ mcp__grove__symbols({"dir":"src","name":"lookupKey","kind":"function"})
  ▸ mcp__grove__callers({"dir":"src","name":"databasesCron"})
  ▸ mcp__grove__symbols({"dir":"src","name":"redisDb"})
  ▸ mcp__grove__symbols({"dir":"src","name":"dbGenericDelete"})
  ▸ mcp__grove__source({"id":"c:src/db.c#lookupKey@279"})
  ▸ mcp__grove__source({"id":"c:src/server.h#redisDb@1207"})

💬 I now have everything needed for the complete picture. Here it is.  ---  ## Redis Key Expiration — End-to-End  ### Key Data Structures  ``` server.db[i]  (re...

──────── RESULT (success, 191415ms, 40 turns) ────────
I now have everything needed for the complete picture. Here it is.

---

## Redis Key Expiration — End-to-End

### Key Data Structures

```
server.db[i]  (redisDb, src/server.h:1207)
  ├── kvstore *keys          — the main keyspace (all keys)
  ├── kvstore *expires       — secondary index: only keys with a TTL set
  │                            each entry's value is the kvobj* from keys,
  │                            with the deadline (ms unix timestamp) embedded
  │                            inside the object via kvobjSetExpire/kvobjGetExpire
  ├── estore  *subexpires    — hash-field (HFE) sub-key expiry
  ├── long long  avg_ttl     — running average TTL (stats only)
  └── unsigned long expires_cursor  — scan position for active-expire
```

`kvstore` is a cluster-slot-sharded array of `dict`s (`src/kvstore.c`).  
The TTL is **embedded directly in the `kvobj`** (not in a separate value); `db->expires` holds a pointer to the same `kvobj` as `db->keys` for the same key, making the expire check a single field read.

---

## Path 1 — Setting a TTL (EXPIRE family)

### Entry points (`src/expire.c`)

| Command | Function | Line |
|---------|----------|------|
| `EXPIRE`    | `expireCommand`    | 846 |
| `EXPIREAT`  | `expireatCommand`  | 851 |
| `PEXPIRE`   | `pexpireCommand`   | 856 |
| `PEXPIREAT` | `pexpireatCommand` | 861 |

All four are one-liners that call the common implementation:

```
expireCommand(client *c)                           expire.c:846
  └─► expireGenericCommand(c, basetime=0, UNIT_SECONDS)  expire.c:726
        1. parseExtendedExpireArgumentsOrReply(c, &flag)  expire.c:675
              → parse NX / XX / GT / LT flags
        2. getLongLongFromObjectOrReply()  — parse the TTL argument
        3. convert to absolute ms timestamp (when += basetime)
        4. lookupKeyWrite(c->db, key)                     db.c:370
              └─► lookupKeyWriteWithFlags(db, key, LOOKUP_NONE)  db.c:366
                    └─► lookupKey(db, key, LOOKUP_WRITE, NULL)   db.c:279
                          └─► expireIfNeeded(...)  [lazy check, see Path 2]
           → returns NULL if key absent → reply 0
        5. kvobjGetExpire(kv)  — read old TTL for NX/XX/GT/LT guards
        6. checkAlreadyExpired(when)                      expire.c:652
              if (when <= mstime()) → already past:
              └─► dbGenericDelete(db, key, lazyfree_lazy_expire,
                                  DB_FLAG_KEY_EXPIRED)    db.c:844
                    → unlinks from db->keys and db->expires,
                      frees synchronously or hands to bio thread
        7. else → setExpire(c, db, key, when)             db.c:2706
              └─► setExpireByLink(c, db, key->ptr, when, NULL)  db.c:2711
                    a. kvstoreDictFindLink(db->keys, slot, key) — find entry
                    b. kvobjGetExpire(kv)
                       • if already had TTL:
                           kvobjSetExpire(kv, when)  — update in-place
                       • if no TTL yet:
                           kvobjSetExpire(kv, when)  — embed in kvobj
                           kvstoreDictAddRaw(db->expires, slot, kv, NULL)
                             → inserts into the expires index
                    c. if writable replica:
                           rememberSlaveKeyWithExpire(db, key)  expire.c:601
        8. notifyKeyspaceEvent(NOTIFY_GENERIC, "expire", ...)
        9. rewriteClientCommandArgument(…, shared.pexpireat)
              → normalize to PEXPIREAT for AOF + replication
```

---

## Path 2 — Lazy Expiry on Key Access

Every command that accesses a key goes through `lookupKeyRead` or `lookupKeyWrite`, both converging on `lookupKey`, which calls `expireIfNeeded` on every hit.

```
lookupKeyRead(db, key)                             db.c:356
  └─► lookupKeyReadWithFlags(db, key, LOOKUP_NONE) db.c:349
        └─► lookupKey(db, key, flags, link)        db.c:279

lookupKeyWrite(db, key)                            db.c:370
  └─► lookupKeyWriteWithFlags(db, key, LOOKUP_NONE) db.c:366
        └─► lookupKey(db, key, flags|LOOKUP_WRITE, link) db.c:279

lookupKey(db, key, flags, link)                    db.c:279
  1. dbFindByLink(db, key->ptr, link)
        → hash-table probe into db->keys; returns kvobj* or NULL
  2. if (val):
        build expire_flags from LOOKUP_* flags:
          LOOKUP_WRITE        → EXPIRE_FORCE_DELETE_EXPIRED
          LOOKUP_NOEXPIRE     → EXPIRE_AVOID_DELETE_EXPIRED
          LOOKUP_ACCESS_EXPIRED → EXPIRE_ALLOW_ACCESS_EXPIRED
        expireIfNeeded(db, key, val, expire_flags)   db.c:2935
          1. keyIsExpired(db, key->ptr, kv)          db.c:2877
                └─► getExpire(db, key, kv)           db.c:2762
                      └─► kvobjGetExpire(kv)  — read embedded ms timestamp
                    commandTimeSnapshot()  — current ms time (Lua-safe)
                    return now > when
          2. Guards (return KEY_EXPIRED without deleting if):
                • server.loading || server.allow_access_expired
                • replica and not EXPIRE_FORCE_DELETE_EXPIRED
                • confAllowsExpireDel() == false
                • EXPIRE_AVOID_DELETE_EXPIRED flag set
                • isPausedActionsWithUpdate(PAUSE_ACTION_EXPIRE)
          3. deleteExpiredKeyAndPropagate(db, key)   db.c:2826
                └─► deleteKeyAndPropagate(db, key,
                      NOTIFY_EXPIRED, NULL)           db.c:2775
                      a. dbGenericDelete(db, key,
                           lazyfree_lazy_expire,
                           DB_FLAG_KEY_EXPIRED)       db.c:844
                           → removes from db->keys AND db->expires
                           → frees object (sync or bio thread)
                      b. notifyKeyspaceEvent(NOTIFY_EXPIRED, "expired", ...)
                      c. keyModified(NULL, db, key, NULL, 1)
                      d. propagateDeletion(db, key, lazy_flag)
                           → writes DEL/UNLINK to AOF + replica buffers
                      e. server.stat_expiredkeys++
          returns KEY_DELETED → lookupKey sets val = NULL
  3. if (val): update LRU/LFU, hit stats
     else:     keymiss event, miss stats
  return val  (NULL if expired)
```

---

## Path 3 — Active Expiry (serverCron)

Two call sites trigger `activeExpireCycle` with different time budgets:

| Type | Call site | File:line | Budget |
|------|-----------|-----------|--------|
| Slow | `serverCron` → `databasesCron` | server.c:1680 / 1310 | `config_cycle_slow_time_perc`% of CPU (≈ 25 % by default) |
| Fast | `beforeSleep` | server.c:1992 | `ACTIVE_EXPIRE_CYCLE_FAST_DURATION` µs (~1 ms) |

```
serverCron()                                       server.c:~1600
  └─► databasesCron()                              server.c:1305
        if (server.active_expire_enabled && iAmMaster()):
          activeExpireCycle(ACTIVE_EXPIRE_CYCLE_SLOW)  expire.c:287
        else (replica):
          expireSlaveKeys()                        expire.c:548

beforeSleep()                                      server.c:1992
  └─► activeExpireCycle(ACTIVE_EXPIRE_CYCLE_FAST)  expire.c:287

activeExpireCycle(type)                            expire.c:287
  1. isPausedActionsWithUpdate(PAUSE_ACTION_EXPIRE) → return if paused
  2. Fast-cycle guard: skip if timelimit_exit==0 and stale% acceptable
  3. timelimit = (slow: cpu% / hz)  or  (fast: FAST_DURATION µs)
  4. for j in 0..dbs_per_call  (static current_db rotates across calls):
        db = server.db[current_db % server.dbnum]
        activeSubexpiresCycle(type)               expire.c:228
          → scans db->subexpires for hash field expiry
        if kvstoreSize(db->expires) == 0: skip
        do {
          num = min(kvstoreSize(db->expires), config_keys_per_loop)
          while (data.sampled < num && checked_buckets < max_buckets):
            db->expires_cursor =
              kvstoreScan(db->expires,            ← scans the expires kvstore
                          db->expires_cursor,
                          -1,
                          expireScanCallback,     expire.c:114
                          expirySamplingShouldSkipDict,
                          &data)
              if cursor wraps to 0: db fully scanned, break

          expireScanCallback(privdata, de, plink) expire.c:114
            kv = dictGetKV(de)
            ttl = kvobjGetExpire(kv) - data->now
            activeExpireCycleTryExpire(db, kv, now) expire.c:40
              if now < kvobjGetExpire(kv): return 0  ← not expired
              enterExecutionUnit(1, 0)
              deleteExpiredKeyAndPropagate(db, keyobj)  ← same as lazy path
              server.stat_expiredkeys_active++
              exitExecutionUnit()
              postExecutionUnitOperations()          ← flush propagation
              return 1
            if ttl > 0: accumulate for avg_ttl stats

          every 16 iterations: update db->avg_ttl, check ustime() > timelimit
          repeat = (expired/sampled > config_cycle_acceptable_stale)
                   && !db_done
        } while (repeat)
  5. update server.stat_expire_cycle_time_used
  6. update server.stat_expired_stale_perc (5% new / 95% old EWMA)
```

---

## Unified Call Graph

```
══════════════════════════════════════════════════════════════
PATH 1: EXPIRE / EXPIREAT / PEXPIRE / PEXPIREAT
══════════════════════════════════════════════════════════════

expireCommand            expire.c:846  ─┐
expireatCommand          expire.c:851   │
pexpireCommand           expire.c:856   ├──► expireGenericCommand   expire.c:726
pexpireatCommand         expire.c:861  ─┘      │
                                               ├─ parseExtendedExpireArgumentsOrReply  expire.c:675
                                               ├─ lookupKeyWrite          db.c:370
                                               │    └─ lookupKeyWriteWithFlags  db.c:366
                                               │         └─ lookupKey          db.c:279
                                               │              └─ expireIfNeeded (▼ PATH 2)
                                               ├─ checkAlreadyExpired          expire.c:652
                                               │    └─ [if past] dbGenericDelete  db.c:844
                                               └─ setExpire                    db.c:2706
                                                    └─ setExpireByLink          db.c:2711
                                                         ├─ kvobjSetExpire      (embed TTL in kvobj)
                                                         └─ kvstoreDictAddRaw(db->expires, ...)
                                                              (add to expires index if new)

══════════════════════════════════════════════════════════════
PATH 2: LAZY EXPIRY  (every key read or write)
══════════════════════════════════════════════════════════════

<any read cmd>
  └─ lookupKeyRead              db.c:356
       └─ lookupKeyReadWithFlags  db.c:349
            └─ lookupKey          db.c:279 ──────────────────────────────────┐
                                                                              │
<any write cmd>                                                               │
  └─ lookupKeyWrite             db.c:370                                      │
       └─ lookupKeyWriteWithFlags db.c:366                                    │
            └─ lookupKey          db.c:279 ──────────────────────────────────┘
                  │
                  ├─ dbFindByLink(db->keys, ...)   ← O(1) hash probe
                  └─ expireIfNeeded(db, key, kv, flags)   db.c:2935
                         │
                         ├─ keyIsExpired(db, key, kv)     db.c:2877
                         │    ├─ getExpire(db, key, kv)   db.c:2762
                         │    │    └─ kvobjGetExpire(kv)  ← read embedded TTL
                         │    └─ commandTimeSnapshot()    ← current ms time
                         │
                         ├─ [guards: replica, pause, config]
                         │
                         └─ deleteExpiredKeyAndPropagate(db, key)   db.c:2826
                                └─ deleteKeyAndPropagate(db, key, NOTIFY_EXPIRED, NULL)  db.c:2775
                                       ├─ dbGenericDelete(db, key, lazyfree, EXPIRED)   db.c:844
                                       │    ├─ unlink from db->keys
                                       │    └─ unlink from db->expires
                                       ├─ notifyKeyspaceEvent("expired")
                                       ├─ keyModified(...)
                                       ├─ propagateDeletion(...)   → AOF + replicas
                                       └─ server.stat_expiredkeys++

══════════════════════════════════════════════════════════════
PATH 3: ACTIVE EXPIRY  (timer + event loop)
══════════════════════════════════════════════════════════════

serverCron()                        server.c:~1680
  └─ databasesCron()                server.c:1305
       └─ activeExpireCycle(SLOW)   expire.c:287 ──────────────────────────┐
                                                                            │
beforeSleep()                       server.c:1992                          │
  └─ activeExpireCycle(FAST)        expire.c:287 ──────────────────────────┘
          │
          ├─ [pause / fast-cycle guards]
          ├─ activeSubexpiresCycle(type)         expire.c:228
          │    └─ activeSubexpires(db, slot, max)  expire.c:208
          │         └─ activeSubexpiresCb(...)     expire.c:170  (hash field expiry)
          │
          └─ [per-DB loop, rotating via static current_db]
               └─ [do-while: repeat while stale% > threshold]
                    └─ kvstoreScan(db->expires, db->expires_cursor, …,
                                   expireScanCallback, …)
                            │   ← incremental scan; cursor saved in db->expires_cursor
                            │
                            └─ expireScanCallback(privdata, de, plink)  expire.c:114
                                   ├─ kvobjGetExpire(kv)   ← read TTL
                                   └─ activeExpireCycleTryExpire(db, kv, now)  expire.c:40
                                          ├─ [if not expired: return 0]
                                          └─ deleteExpiredKeyAndPropagate(db, key)
                                                 └─ deleteKeyAndPropagate(...)  db.c:2775
                                                        (▲ identical to Path 2 leaf)
```

---

## Summary of responsibilities by file

| File | Responsibility in expiry |
|------|--------------------------|
| `src/expire.c` | All four EXPIRE commands; `expireGenericCommand`; `activeExpireCycle` and its scan loop; `activeExpireCycleTryExpire`; `expireScanCallback`; replica slave-key tracking |
| `src/db.c` | `lookupKey` (lazy-expiry trigger); `expireIfNeeded`; `keyIsExpired`; `getExpire`; `setExpire` / `setExpireByLink` (writes to `db->expires`); `deleteExpiredKeyAndPropagate` / `deleteKeyAndPropagate` / `dbGenericDelete` |
| `src/server.c` | `serverCron` → `databasesCron` (slow cycle); `beforeSleep` (fast cycle) |
| `src/server.h` | `redisDb` struct: `keys`, `expires`, `expires_cursor`, `avg_ttl` |
