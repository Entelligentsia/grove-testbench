# transcript: I'm planning a change to how a write performed on a primary becomes visible on its replicas, so I need to understand the full journey of a write command's ef...


💬 Let me load the grove tools first, then map the replication subsystem.
  ▸ ToolSearch(select:mcp__grove__map,mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition)

💬 Now let me fan out concurrent grove lookups across the three stages: command dispatch, propagation queuing, and replication feed.
  ▸ mcp__grove__symbols({"dir":"src","name":"call","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"propagate","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"feedReplicationBuffer","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"alsoPropagate","kind":"function"})

💬 Let me fetch the `call` function body and hunt for the propagation machinery in parallel.
  ▸ mcp__grove__source({"id":"c:src/server.c#call@3949"})
  ▸ mcp__grove__symbols({"dir":"src","name":"propagateNow","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"replicationFeedSlaves","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"afterCommand","kind":"function"})

💬 Good. Now let me fetch the bodies of the remaining key functions in parallel.
  ▸ mcp__grove__source({"id":"c:src/server.c#propagateNow@3704"})
  ▸ mcp__grove__source({"id":"c:src/server.c#alsoPropagate@3732"})
  ▸ mcp__grove__source({"id":"c:src/server.c#afterCommand@4271"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replicationFeedSlaves@631"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#feedReplicationBuffer@618"})

💬 Now let me chase the remaining connective tissue: `postExecutionUnitOperations`, `propagatePendingCommands`, and the `replBufWriter` machinery.
  ▸ mcp__grove__symbols({"dir":"src","name":"postExecutionUnitOperations","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"propagatePendingCommands","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"replBufWriterEnd","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"prepareReplicasToWrite","kind":"function"})
  ▸ mcp__grove__source({"id":"c:src/server.c#postExecutionUnitOperations@3867"})
  ▸ mcp__grove__source({"id":"c:src/server.c#propagatePendingCommands@3811"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replBufWriterEnd@565"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#prepareReplicasToWrite@363"})

💬 Let me get the writer functions to complete the buffer picture.
  ▸ mcp__grove__symbols({"dir":"src","name":"replBufWriterBegin","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"replBufWriterAppend","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src","name":"shouldPropagate","kind":"function"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replBufWriterBegin@466"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replBufWriterAppend@533"})
  ▸ mcp__grove__source({"id":"c:src/server.c#shouldPropagate@3673"})

💬 I now have everything needed to give you the full picture. Here is the end-to-end walkthrough.  ---  ## Stage 1 — Command execution and dirty detection (`cal...

──────── RESULT (success, 132282ms, 29 turns) ────────
I now have everything needed to give you the full picture. Here is the end-to-end walkthrough.

---

## Stage 1 — Command execution and dirty detection (`call`, `server.c:3949`)

`call()` is the single choke-point through which every command passes. Before invoking the handler it snapshots two counters:

```c
dirty = server.dirty;
long long old_master_repl_offset = server.master_repl_offset;
```

Then it runs the handler:

```c
c->cmd->proc(c);
```

Any write operation (e.g. `setCommand`, `lpushCommand`, …) increments `server.dirty` as a side effect. After the handler returns, `call()` computes:

```c
dirty = server.dirty - dirty;
```

A non-zero delta is the canonical signal that data was actually modified. That drives the propagation flags:

```c
if (dirty) propagate_flags |= (PROPAGATE_AOF|PROPAGATE_REPL);
if (c->flags & CLIENT_FORCE_REPL) propagate_flags |= PROPAGATE_REPL;
// CLIENT_PREVENT_REPL_PROP clears the flag
```

If `propagate_flags != PROPAGATE_NONE`, `call()` calls:

```c
alsoPropagate(c->db->id, c->argv, c->argc, propagate_flags);
```

---

## Stage 2 — Queuing the operation (`alsoPropagate`, `server.c:3732`)

`alsoPropagate` does **not** propagate immediately. It copies the `argv` array (incrementing refcounts), then appends a `redisOp` entry to `server.also_propagate` (a `redisOpArray`):

```c
redisOpArrayAppend(&server.also_propagate, dbid, argvcopy, argc, target);
```

This deferral is what allows nested invocations (MULTI/EXEC, Lua, modules) to accumulate multiple writes before anything goes out.

---

## Stage 3 — Flushing pending commands (`afterCommand` → `postExecutionUnitOperations` → `propagatePendingCommands`)

At the tail of `call()`:

```c
afterCommand(c);   // server.c:4271
```

`afterCommand` calls `postExecutionUnitOperations()`, which has a nesting guard:

```c
if (server.execution_nesting) return;  // server.c:3867
```

So the flush only happens once the **outermost** `call()` returns — nested calls from scripts or MULTI/EXEC accumulate without flushing. Then:

```c
propagatePendingCommands();   // server.c:3811
```

`propagatePendingCommands` checks `server.also_propagate.numops`. If more than one command is queued (and the command doesn't touch arbitrary keys), it wraps them in MULTI/EXEC by prepending a `propagateNow(-1, &shared.multi, …)` and appending `propagateNow(-1, &shared.exec, …)`. Then it iterates every queued op and calls `propagateNow` on each, then frees `server.also_propagate`.

---

## Stage 4 — Dispatching to AOF and replication (`propagateNow`, `server.c:3704`)

```c
static void propagateNow(int dbid, robj **argv, int argc, int target) {
    if (!shouldPropagate(target)) return;
    if (server.aof_state != AOF_OFF && target & PROPAGATE_AOF)
        feedAppendOnlyFile(dbid, argv, argc);
    if (target & PROPAGATE_REPL) {
        replicationFeedSlaves(server.slaves, dbid, argv, argc);
    }
}
```

`shouldPropagate` (`server.c:3673`) enforces the gate conditions: replication must be allowed, server must not be loading, and for `PROPAGATE_REPL` specifically, `server.masterhost` must be NULL (i.e., this node is the top-level master, not a replica), and either a backlog exists or at least one slave is connected.

---

## Stage 5 — Serializing to RESP and staging in the shared buffer (`replicationFeedSlaves`, `replication.c:631`)

Before writing any bytes, `replicationFeedSlaves` calls:

```c
prepareReplicasToWrite();  // replication.c:363
```

This iterates `server.slaves` and calls `prepareClientToWrite(slave)` on each eligible replica, which installs a write handler on the event loop for that replica's socket. Nothing is sent yet — this just arms the socket.

Then the command is serialized into RESP:

1. If the target DB differs from `server.slaveseldb`, a `SELECT <id>` command is fed first via `feedReplicationBuffer()`.
2. A `replBufWriter wr` is initialized with `replBufWriterBegin(&wr)`.
3. The multi-bulk count (`*N\r\n`), then for each argument `$len\r\n<data>\r\n`, is appended via `replBufWriterAppend`.
4. `replBufWriterEnd(&wr)` finalizes everything.

---

## Stage 6 — The shared replication buffer (`replBufWriter` machinery, `replication.c`)

The replication buffer is a single **shared linked list** of `replBufBlock` nodes in `server.repl_buffer_blocks`. Every connected replica and the backlog share this same memory — there is no per-replica copy.

**`replBufWriterBegin`** (`replication.c:466`): snapshots the tail block's current write position — the `(node, offset)` pair where this command's bytes will start.

**`replBufWriterAppend`** (`replication.c:533`): `memcpy`s into the tail block's `buf[]`. If the tail is full, `replBufWriterAppendSlow` allocates a fresh `replBufBlock` and links it in.

**`replBufWriterEnd`** (`replication.c:565`) is where the critical accounting happens:

```c
server.master_repl_offset += wr->total_len;    // advance the global replication offset
server.repl_backlog->histlen += wr->total_len;
```

Then it iterates every connected slave. For each one where `canFeedReplicaReplBuffer` is true and `slave->ref_repl_buf_node == NULL` (not yet pinned), it sets:

```c
slave->ref_repl_buf_node = wr->start_node;
slave->ref_block_pos     = wr->start_pos;
((replBufBlock *)listNodeValue(wr->start_node))->refcount++;
```

This is the replica's **read pointer** into the shared buffer — the exact node and byte offset where this command's bytes begin. The same is done for the backlog's own `ref_repl_buf_node`. If new blocks were allocated, the oldest unreferenced blocks are trimmed to keep the backlog within `repl-backlog-size`.

The actual I/O is asynchronous: when the event loop fires the write handler for a replica's socket, it reads starting from `slave->ref_repl_buf_node` at `slave->ref_block_pos` and drains bytes to the network, advancing the pointer as it goes.

---

## The chain end-to-end

```
c->cmd->proc(c)               ← handler runs; server.dirty incremented
  └─ call() detects dirty delta
       └─ alsoPropagate()     ← copies argv, appends redisOp to server.also_propagate
            (deferred — nothing sent yet)

call() returns
  └─ afterCommand()
       └─ postExecutionUnitOperations()   ← no-op if execution_nesting > 0
            └─ propagatePendingCommands()
                 └─ propagateNow()        ← one call per queued op (wrapped in MULTI/EXEC if >1)
                      └─ replicationFeedSlaves()
                           ├─ prepareReplicasToWrite()  ← arms write handlers on sockets
                           └─ replBufWriter{Begin→Append→End}
                                ├─ serializes RESP into shared repl_buffer_blocks
                                ├─ advances master_repl_offset
                                └─ pins each slave's ref_repl_buf_node to the start position

[event loop, later]
  └─ write handler per replica
       └─ drains from slave->ref_repl_buf_node out to the TCP socket
```

The key design points to keep in mind for your change:
- **`alsoPropagate` is the queue-entry point**, not `propagateNow` — if you need to intercept or modify what gets replicated, that's one place to hook.
- **`propagatePendingCommands` owns the MULTI/EXEC wrapping** — if you add extra writes that arrive alongside an existing write, they'll get wrapped together.
- **`replBufWriterEnd` is where `master_repl_offset` advances and where each replica gets its read pointer** — anything that changes what bytes are staged or when they're committed needs to go through or around that finalizer.
- The shared buffer means a replica's view of a write is determined by its `ref_repl_buf_node` pointer, not a copy of the data — mutations to the buffer after `replBufWriterEnd` would affect all readers.
