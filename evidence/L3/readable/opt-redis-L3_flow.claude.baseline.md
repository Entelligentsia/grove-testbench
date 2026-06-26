# transcript: Trace the full execution path of the Redis SET command, from when the server reads and dispatches the command, to where the value is finally stored in the ke...


💬 Let me explore the Redis source to trace the SET command execution path.
  ▸ Bash(ls /home/bench/repos/redis/src/ | head -50)
  ▸ Bash(ls /home/bench/repos/redis/)
  ▸ Bash(ls /home/bench/repos/redis/)
  ▸ Read(/home/bench/repos/redis)
  ▸ Agent(Trace SET command execution in Redis source)
  ▸ Bash(find /home/bench/repos/redis -type f -name "*.c" | head -20)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Bash(grep -n "^void processInputBuffer\|^void processCommand\|^int processInlineBuffer\|^void readQueryFromClient" /home/bench/repos/redis/src/server.c /home/benc...)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Bash(find /home/bench/repos/redis/src -name "*.c" -type f)
  ▸ Read(/home/bench/repos/redis/src)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/t_string.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)

💬 Let me verify a few of the critical line numbers to make sure they're accurate.
  ▸ Read(/home/bench/repos/redis/src/t_string.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)

💬 Let me also verify `setCommand` and the `setKeyByLink` / `dbSetValue` functions.
  ▸ Read(/home/bench/repos/redis/src/t_string.c)
  ▸ Read(/home/bench/repos/redis/src/db.c)

💬 Good. Let me also check `dbSetValue` to confirm the overwrite path.
  ▸ Read(/home/bench/repos/redis/src/db.c)

💬 All the key line numbers are confirmed. Here is the complete, verified trace:  ---  ## Redis SET Command Execution Path  ### Phase 1 — Network I/O  **1. `rea...

──────── RESULT (success, 154178ms, 12 turns) ────────
All the key line numbers are confirmed. Here is the complete, verified trace:

---

## Redis SET Command Execution Path

### Phase 1 — Network I/O

**1. `readQueryFromClient`** (`src/networking.c:3830`)
Reads raw bytes from the client socket into `c->querybuf`, then calls `processInputBuffer(c)`.

---

### Phase 2 — RESP Parsing

**2. `processInputBuffer`** (`src/networking.c:3626`)
Main parsing loop. Detects whether the request is inline or RESP multibulk, calls the appropriate parser, then calls `processCommandAndResetClient()`.

**3. `processMultibulkBuffer`** (`src/networking.c:3214`) *(for RESP clients, the normal path)*
Parses `*3\r\n$3\r\nSET\r\n$3\r\nfoo\r\n$3\r\nbar\r\n` into `c->argv[]` as Redis objects.

**4. `processCommandAndResetClient`** → **`processCommand`** (`src/server.c:4412`)
Looks up the command in the command table, checks arity, runs ACL checks, checks cluster routing, memory limits, replication state. At line 4788, calls `call(c, CMD_CALL_FULL)`.

---

### Phase 3 — Dispatch

**5. `call`** (`src/server.c:3949`)
Bookkeeping (dirty counter snapshot, stats, slow log timer). At line 4015:
```c
c->cmd->proc(c);   // → setCommand(c)
```
Post-call handles propagation to AOF/replicas.

---

### Phase 4 — SET Command Handler

**6. `setCommand`** (`src/t_string.c:435`)
Parses optional flags (NX, XX, EX, PX, KEEPTTL, GET, IFEQ, …) via `parseExtendedStringArgumentsOrReply()`.  
Calls `tryObjectEncoding(c->argv[2])` to compact the value (e.g. integer encoding).  
Calls `setGenericCommand(c, flags, key, &argv[2], expire, unit, …)` at line 443.

---

### Phase 5 — Generic Set Logic

**7. `setGenericCommand`** (`src/t_string.c:87`)
- Line 95: validates expiry range.
- Line 104: `lookupKeyWriteWithLink(c->db, key, &link)` — checks whether the key already exists and captures a `dictEntryLink` (a pointer-to-bucket, avoids a second hash lookup).
- Lines 106–113: enforces NX/XX/IFEQ/IFNE conditions; returns early if unmet.
- Line 161: if the expiry is already in the past, calls `dbDelete()` and returns.
- **Line 181: `setKeyByLink(c, c->db, key, valref, setkey_flags, &link)`** — the actual store.
- Line 184: if an expiry was given, `setExpireByLink()` attaches it.
- Line 190: `server.dirty++` marks the change for AOF/replication.
- Line 191: fires `keyspace-notification` event `"set"`.

---

### Phase 6 — Key Storage

**8. `setKeyByLink`** (`src/db.c:754`)
Branches on whether the key exists:

| Path | Function called |
|------|----------------|
| Key **exists** (line 777) | `dbSetValue(db, key, valref, link, 1, 1, keepttl)` |
| Key **absent** (line 785) | `dbAddByLink(db, key, valref, link)` |

After either branch, calls `keyModified()` at line 789.

---

#### New-key path

**9a. `dbAddByLink`** (`src/db.c:460`)
Initialises an empty `KeyMetaSpec`, calls `dbAddInternal()`.

**10a. `dbAddInternal`** (`src/db.c:416`)
- Line 419: `getKeySlot(key->ptr)` — resolves the cluster hash slot (always `0` in standalone mode).
- Line 423: `kvobjSet(key->ptr, val, metabits)` — packs key + value into a single `kvobj` allocation.
- Line 424: `initObjectLRUOrLFU(kv)` — stamps eviction metadata.
- **Line 425: `kvstoreDictSetAtLink(db->keys, slot, kv, link, 1)`** — inserts the `kvobj` into the per-slot dictionary inside `db->keys` (a `kvstore`, which is an array of `dict`s, one per hash slot).
- Line 444: `signalKeyAsReady()` — unblocks any clients waiting on this key (e.g. BLPOP).
- Line 445: fires `"new"` keyspace notification.

---

#### Overwrite path

**9b. `dbSetValue`** (`src/db.c:575`)
- Line 585: fetches the old `kvobj` from the dict entry at `*link`.
- Lines 633–648 (fast path): if both old and new objects have `refcount == 1` and neither is `EMBSTR`, **swaps their `type`/`encoding`/`ptr` fields in-place** — the dict entry is not touched; only the object content changes.
- Lines 652–657 (slow path, e.g. embedded strings or shared objects): builds a fresh `kvobj` via `kvobjSet()`, then **Line 657: `kvstoreDictSetAtLink(db->keys, slot, kvNew, &link, 0)`** replaces the entry in the hash table.

---

### Phase 7 — Hash Table (inside `kvstore` / `dict`)

**`kvstoreDictSetAtLink`** → **`dictSetAtLink`** (`src/dict.c`)
Writes the `kvobj` pointer directly into the `dictEntry` bucket identified by `link`. For new keys this is a `dictAddRaw()` insertion that handles bucket allocation and collision chaining; for overwrites it's a pointer-swap at the pre-located entry. The final resting place is:

```
server.db[dbid].keys   // kvstore (array of dict, one per slot)
  └── dict[slot]       // standard open-addressing hash table
        └── dictEntry  // stores kvobj* (key SDS + value robj packed together)
```

---

### Condensed call chain

```
readQueryFromClient            networking.c:3830
  processInputBuffer           networking.c:3626
    processMultibulkBuffer     networking.c:3214
    processCommandAndResetClient
      processCommand           server.c:4412
        call                   server.c:3949
          c->cmd->proc(c)  ──► setCommand          t_string.c:435
                                 tryObjectEncoding
                                 setGenericCommand  t_string.c:87
                                   lookupKeyWriteWithLink
                                   setKeyByLink     db.c:754
                                     ├─[exists]─► dbSetValue      db.c:575
                                     │              kvstoreDictSetAtLink  ← value stored
                                     └─[new]────► dbAddByLink     db.c:460
                                                    dbAddInternal  db.c:416
                                                      kvobjSet
                                                      kvstoreDictSetAtLink  ← value stored
```

The value is definitively stored by **`kvstoreDictSetAtLink`** inside `dbAddInternal` (new key) or `dbSetValue` (overwrite), both operating on `server.db[N].keys`.
