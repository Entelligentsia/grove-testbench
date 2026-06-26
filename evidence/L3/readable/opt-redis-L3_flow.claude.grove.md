# transcript: Trace how a SET command is executed in Redis: name every function it passes through from the moment the command is dispatched to where the value is stored in...


💬 I'll use the grove MCP tools to trace the SET command execution path. Let me load those schemas first.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me find the SET command handler and trace it through the codebase.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"setCommand","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"processCommand","kind":"function"})

💬 Let me read `setCommand` and `processCommand` in parallel, and also find where command processing is first triggered.
  ▸ mcp__grove__source({"id":"c:src/t_string.c#setCommand@435"})
  ▸ mcp__grove__source({"id":"c:src/server.c#processCommand@4412"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"readQueryFromClient","kind":"function"})

💬 Now let me fetch `call`, `setGenericCommand`, and `readQueryFromClient` — plus find the keyspace storage function.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"call","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"setGenericCommand","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"processInputBuffer","kind":"function"})
  ▸ mcp__grove__source({"id":"c:src/t_string.c#setGenericCommand@87"})
  ▸ mcp__grove__source({"id":"c:src/server.c#call@3949"})
  ▸ mcp__grove__source({"id":"c:src/networking.c#processInputBuffer@3626"})
  ▸ mcp__grove__source({"id":"c:src/networking.c#readQueryFromClient@3830"})

💬 Now let me fetch the final two key functions: `processCommandAndResetClient` and `setKeyByLink`.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"processCommandAndResetClient","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"setKeyByLink","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"processMultibulkBuffer","kind":"function"})
  ▸ mcp__grove__source({"id":"c:src/networking.c#processCommandAndResetClient@3491"})
  ▸ mcp__grove__source({"id":"c:src/db.c#setKeyByLink@754"})

💬 One more level down — let me check `dbAddByLink` and `dbSetValue` to see the final dict write.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"dbAddByLink","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"dbSetValue","kind":"function"})
  ▸ mcp__grove__source({"id":"c:src/db.c#dbAddByLink@460"})
  ▸ mcp__grove__source({"id":"c:src/db.c#dbSetValue@575"})

💬 Let me get `dbAddInternal` to see the final dict insertion.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/redis","name":"dbAddInternal","kind":"function"})
  ▸ mcp__grove__source({"id":"c:src/db.c#dbAddInternal@416"})

💬 I have the complete trace. Here is every function in order, from socket read to keyspace write:  ---  ## SET command execution trace  ### 1. `readQueryFromCl...

──────── RESULT (success, 140899ms, 25 turns) ────────
I have the complete trace. Here is every function in order, from socket read to keyspace write:

---

## SET command execution trace

### 1. `readQueryFromClient` — `src/networking.c:3830`
The event loop fires this I/O callback when the client socket is readable. It calls `connRead` to fill `c->querybuf` with raw bytes, validates the query-buffer size limit, then calls `processInputBuffer`.

### 2. `processInputBuffer` — `src/networking.c:3626`
Loops over `c->querybuf`. Detects the protocol type (`*` → `PROTO_REQ_MULTIBULK`, else inline). For RESP format it calls…

### 3. `processMultibulkBuffer` — `src/networking.c:3214`
Parses `*3\r\n$3\r\nSET\r\n$3\r\nfoo\r\n$5\r\nvalue\r\n` into a `pendingCommand` with `argc`/`argv`. Runs `preprocessCommand` then marks the pending command ready. Back in `processInputBuffer`, the ready command's `argc`/`argv` are promoted to `c->argc`/`c->argv` and control falls to…

### 4. `processCommandAndResetClient` — `src/networking.c:3491`
Sets `server.current_client = c`, then calls `processCommand`. On return calls `commandProcessed` to clean up and advance replication offsets.

### 5. `processCommand` — `src/server.c:4412`
- Calls `lookupCommand(c->argv, c->argc)` → finds the `redisCommand` entry for `SET`, sets `c->cmd`.
- Runs all gate checks in order: command existence, arity, auth, ACL (`ACLCheckAllPerm`), cluster slot routing, OOM eviction, disk-error guards, replica-read-only, pub/sub restrictions, client-pause blocks.
- For a non-MULTI client: calls `call(c, CMD_CALL_FULL)`.

### 6. `call` — `src/server.c:3949`
Timestamps the call, then invokes **`c->cmd->proc(c)`** — i.e. the function pointer stored in the command table, which for SET is `setCommand`. After it returns, `call` records duration, updates command stats and the slowlog, feeds MONITOR clients, and conditionally propagates to AOF/replication via `alsoPropagate`.

### 7. `setCommand` — `src/t_string.c:435`
Parses extended options (EX, PX, EXAT, PXAT, NX, XX, GET, KEEPTTL, IFEQ, IFNE, …) with `parseExtendedStringArgumentsOrReply`. Calls `tryObjectEncoding(c->argv[2])` to choose the tightest in-memory encoding (int, embstr, or raw SDS). Then calls…

### 8. `setGenericCommand` — `src/t_string.c:87`
- Converts expiry argument to absolute milliseconds via `getExpireMillisecondsOrReply`.
- Handles `GET` flag by calling `getGenericCommand` first.
- Calls `lookupKeyWriteWithLink(c->db, key, &link)` to check existence and grab a `dictEntryLink` for zero-copy insert/update.
- Enforces NX/XX/IFEQ/IFNE/IFDEQ/IFDNE conditions; returns early with NIL if they fail.
- If the expiry is already elapsed: calls `dbDelete`, fires a `"del"` keyspace event, and returns OK.
- Otherwise calls **`setKeyByLink`**, then fires the `NOTIFY_STRING "set"` keyspace event and (if expiry) the `NOTIFY_GENERIC "expire"` event. Rewrites the command argv to canonical `PXAT` form for replication.

### 9. `setKeyByLink` — `src/db.c:754`
Decides between insert and update using the `SETKEY_ALREADY_EXIST` / `SETKEY_DOESNT_EXIST` flags already resolved above:
- **Key exists** → calls `dbSetValue` (update path)
- **Key is new** → calls `dbAddByLink` (insert path)

Then calls `keyModified` to signal client-side tracking invalidations and update the LRU/LFU timestamp.

### 10a. Insert path — `dbAddByLink` → `dbAddInternal` — `src/db.c:460 / 416`
`dbAddByLink` delegates straight to `dbAddInternal`, which:
- Calls `kvobjSet(key->ptr, val, metabits)` to allocate a `kvobj` embedding the value.
- Calls **`kvstoreDictSetAtLink(db->keys, slot, kv, link, 1)`** — this writes the `kvobj` into the per-slot hash table inside `db->keys`, the main keyspace dict. This is the moment the key/value becomes visible to all future lookups.
- Fires `NOTIFY_NEW "new"`, updates key-size histograms.

### 10b. Overwrite path — `dbSetValue` — `src/db.c:575`
For an existing key, either:
- **Fast swap** (refcount == 1, encoding compatible): swaps `type`, `encoding`, `ptr` fields in-place on the existing `kvobj`, avoiding a dict mutation entirely.
- **Full replace**: calls `kvobjSet` for a new `kvobj`, then **`kvstoreDictSetAtLink(db->keys, slot, kvNew, &link, 0)`** to replace the dict entry at the pre-resolved link. Also updates `db->expires` if a TTL is being kept.

---

### Summary

```
readQueryFromClient          networking.c   ← fills querybuf from socket
  └─ processInputBuffer      networking.c   ← protocol dispatch loop
       └─ processMultibulkBuffer            ← RESP parse → argc/argv
       └─ processCommandAndResetClient      networking.c
            └─ processCommand              server.c    ← lookup, gate checks
                 └─ call                   server.c    ← dispatch via cmd->proc()
                      └─ setCommand        t_string.c  ← option parsing, encoding
                           └─ setGenericCommand         t_string.c  ← NX/XX/TTL logic
                                └─ setKeyByLink         db.c        ← insert or update
                                     ├─ dbAddByLink → dbAddInternal
                                     │    └─ kvstoreDictSetAtLink(db->keys) ← NEW key stored
                                     └─ dbSetValue
                                          └─ kvstoreDictSetAtLink(db->keys) ← EXISTING key updated
```

The value finally lives in **`db->keys`** — a `kvstore` (array of per-slot `dict`s) on the `redisDb` struct — keyed by the SDS string and stored as a `kvobj` (a compact struct that inlines the `robj` header with the type/encoding/refcount/value).
