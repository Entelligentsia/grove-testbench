# transcript: Give a complete architectural walkthrough of how Redis propagates a write command from a master to its replicas — the cross-cutting replication pipeline. Spa...


💬 I'll load the grove tools and then do a systematic walk through the replication pipeline.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now I'll fan out parallel grove queries across the key subsystems — command execution, propagation, the backlog, networking, and the replica side.
  ▸ mcp__grove__outline({"file":"src/replication.c","detail":0})
  ▸ mcp__grove__outline({"file":"src/server.c","kind":"function","detail":0})
  ▸ mcp__grove__outline({"file":"src/networking.c","kind":"function","detail":0})
  ▸ mcp__grove__outline({"file":"src/server.h","kind":"struct","detail":1})

💬 Good — now I'll fetch the key function bodies and structs in parallel batches.
  ▸ mcp__grove__source({"id":"c:src/server.c#call@3949"})
  ▸ mcp__grove__source({"id":"c:src/server.c#shouldPropagate@3673"})
  ▸ mcp__grove__source({"id":"c:src/server.c#propagateNow@3704"})
  ▸ mcp__grove__source({"id":"c:src/server.c#alsoPropagate@3732"})
  ▸ mcp__grove__source({"id":"c:src/server.h#replBacklog@1399"})
  ▸ mcp__grove__source({"id":"c:src/server.h#replBufBlock@1195"})
  ▸ mcp__grove__source({"id":"c:src/server.h#client@1476"})
  ▸ mcp__grove__source({"id":"c:src/server.h#redisOp@1802"})
  ▸ mcp__grove__source({"id":"c:src/server.h#redisOpArray@1813"})
  ▸ mcp__grove__source({"id":"c:src/server.c#propagatePendingCommands@3811"})
  ▸ mcp__grove__source({"id":"c:src/server.c#postExecutionUnitOperations@3867"})
  ▸ mcp__grove__source({"id":"c:src/server.h#redisServer@2005"})

💬 Now I'll pull the core replication functions — the buffer writer, feed path, and replica-side stream receiver.
  ▸ mcp__grove__source({"id":"c:src/replication.c#replicationFeedSlaves@631"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#feedReplicationBuffer@618"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#prepareReplicasToWrite@363"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replBufWriterBegin@466"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replBufWriterEnd@565"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replicationFeedStreamFromMasterStream@766"})

💬 Now I need the write-side (sending to replicas) and the replica receive/apply side.
  ▸ mcp__grove__source({"id":"c:src/networking.c#_writeToClientSlave@2734"})
  ▸ mcp__grove__source({"id":"c:src/networking.c#handleClientsWithPendingWrites@2897"})
  ▸ mcp__grove__source({"id":"c:src/networking.c#_clientHasPendingRepliesSlave@1540"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replicaPutOnline@1637"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replicaStartCommandStream@1674"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#createReplicationBacklog@244"})

💬 Now the replica-receive side: the `master` client input processing and ACK mechanism.
  ▸ mcp__grove__source({"id":"c:src/networking.c#processInputBuffer@3626"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replicationSendAck@4475"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#syncWithMaster@3071"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#incrementalTrimReplicationBacklog@384"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#addReplyReplicationBacklog@833"})
  ▸ mcp__grove__source({"id":"c:src/server.c#beforeSleep@1935"})

💬 Let me grab the remaining pieces: PSYNC master handler, post-RDB activation, and ACK dispatch.
  ▸ mcp__grove__source({"id":"c:src/replication.c#masterTryPartialResynchronization@986"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#updateSlavesWaitingBgsave@1961"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#canFeedReplicaReplBuffer@329"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replicationCreateMasterClient@2168"})
  ▸ mcp__grove__source({"id":"c:src/server.c#sendGetackToReplicas@1911"})
  ▸ mcp__grove__source({"id":"c:src/replication.c#replBufWriterAppend@533"})

💬 I now have everything needed to write the complete walkthrough. Let me compose it.  ---  # Redis Replication Pipeline — Complete Architectural Walkthrough  -...

──────── RESULT (success, 397635ms, 42 turns) ────────
I now have everything needed to write the complete walkthrough. Let me compose it.

---

# Redis Replication Pipeline — Complete Architectural Walkthrough

---

## Key Data Structures

Before following the code, understand what moves through it.

### `redisOp` / `redisOpArray` — `server.h:1802, 1813`
```c
struct redisOp    { robj **argv; int argc, dbid, target; }
struct redisOpArray { redisOp *ops; int numops; int capacity; }
```
`server.also_propagate` (type `redisOpArray`) is the **staging area** where commands accumulate during a `call()` invocation before being flushed to the wire. Written by `alsoPropagate`, drained by `propagatePendingCommands`.

### `replBufBlock` — `server.h:1195`
```c
struct replBufBlock {
    int refcount;           // # of replicas + backlog holding this block
    long long id;
    long long repl_offset;  // offset of buf[0] in the global stream
    size_t size, used;
    char buf[];             // flexible-array payload
}
```
The fundamental unit of the replication buffer. Every replica and the backlog cursor into the **same** list of blocks — no per-replica copies.

### `replBacklog` — `server.h:1399`
```c
struct replBacklog {
    listNode *ref_repl_buf_node; // oldest block owned by the backlog
    size_t unindexed_count;
    rax *blocks_index;           // encoded_offset → listNode, for fast PSYNC seeks
    long long histlen;           // bytes currently in window
    long long offset;            // global offset of the first byte in window
}
```
Not a separate ring buffer — it is a sliding **window into `server.repl_buffer_blocks`**, sharing blocks with replica clients via `refcount`.

### `client` — replica-specific fields — `server.h:1476`
```
replstate              // SLAVE_STATE_{WAIT_BGSAVE_START, WAIT_BGSAVE_END, SEND_BULK, ONLINE, …}
ref_repl_buf_node      // listNode* of current replBufBlock being consumed
ref_block_pos          // byte cursor within that block
repl_ack_off           // last offset this replica ACK'd to the master
repl_start_cmd_stream_on_ack  // 1 = activate stream on first REPLCONF ACK (diskless)
woff                   // master_repl_offset at time of last write by this client
read_reploff / reploff // (master client on replica) parsed/applied stream offsets
```

### `redisServer` — master replication fields — `server.h:2005`
```
master_repl_offset   // monotone byte count of the replication stream
repl_backlog         // replBacklog*
repl_buffer_blocks   // list<replBufBlock> — the actual storage
repl_buffer_mem      // byte total across all blocks
also_propagate       // redisOpArray staging
slaves               // list<client*> of connected replica clients
slaveseldb           // last SELECT DB sent to replicas
get_ack_from_slaves  // flag: inject GETACK before sleeping
```

---

## Phase 1 — Command Execution and Propagation Decision

### `processCommand` → `call` — `server.c:4412, 3949`

After `readQueryFromClient` + `processInputBuffer` parse a complete command, `processCommand` runs ACL/cluster/maxmemory checks and calls:

```c
call(c, CMD_CALL_FULL);
```

Inside `call`:

1. **Save dirty baseline**: `dirty = server.dirty`
2. **Execute**: `c->cmd->proc(c)` — dispatches to e.g. `setCommand`, `lpushCommand`. The implementation may call `forceCommandPropagation(c, PROPAGATE_REPL)` to force replication even with zero dirty-count (e.g. `EXPIRE` that found no key).
3. **Measure delta**: `dirty = server.dirty - dirty`
4. **Determine propagation flags**:
   - `dirty > 0` → `PROPAGATE_AOF | PROPAGATE_REPL`
   - `CLIENT_FORCE_REPL` on client → add `PROPAGATE_REPL`
   - `CLIENT_PREVENT_REPL_PROP` or `CLIENT_MODULE_PREVENT_REPL_PROP` → clear `PROPAGATE_REPL`
5. **Stage**: calls `alsoPropagate(c->db->id, c->argv, c->argc, propagate_flags)`
6. **Update write offset**: `if (old_master_repl_offset != server.master_repl_offset) c->woff = server.master_repl_offset`
7. **Tail**: `afterCommand(c)` → `exitExecutionUnit` → if nesting depth returns to 0, fires `postExecutionUnitOperations`

### `shouldPropagate` — `server.c:3673`
```c
static int shouldPropagate(int target) {
    if (!server.replication_allowed || target == PROPAGATE_NONE || server.loading) return 0;
    if (target & PROPAGATE_REPL)
        if (server.masterhost == NULL &&
            (server.repl_backlog || listLength(server.slaves) != 0))
            return 1;
    ...
}
```
Gates: only the **top-level master** propagates (not a replica that received the command from upstream).

### `alsoPropagate` — `server.c:3732`
```c
void alsoPropagate(int dbid, robj **argv, int argc, int target) {
    // ref-counted argv copy
    redisOpArrayAppend(&server.also_propagate, dbid, argvcopy, argc, target);
}
```
Appends a `redisOp` to `server.also_propagate`. Multiple side-effect commands from one invocation (e.g., a Lua script calling SET + EXPIRE) accumulate here together.

### `postExecutionUnitOperations` → `propagatePendingCommands` — `server.c:3867, 3811`

```c
void postExecutionUnitOperations(void) {
    if (server.execution_nesting) return;  // not at top level yet
    propagatePendingCommands();
    modulePostExecutionUnitOperations();
}
```

`propagatePendingCommands`:
- If `also_propagate.numops > 1`: prepends `propagateNow(-1, &shared.multi, 1, ...)` and appends `propagateNow(-1, &shared.exec, 1, ...)` so the replica applies everything atomically
- Loops calling `propagateNow(rop->dbid, rop->argv, rop->argc, rop->target)` for each staged op
- Calls `redisOpArrayFree(&server.also_propagate)`

### `propagateNow` — `server.c:3704`
```c
static void propagateNow(int dbid, robj **argv, int argc, int target) {
    if (target & PROPAGATE_AOF)  feedAppendOnlyFile(dbid, argv, argc);
    if (target & PROPAGATE_REPL) replicationFeedSlaves(server.slaves, dbid, argv, argc);
}
```
The **fork point**: AOF and replication diverge here.

---

## Phase 2 — Serializing into the Shared Replication Buffer

### `replicationFeedSlaves` — `replication.c:631`

Single entry-point for writing to the replication stream:

1. **Guard — skip if replica**: `if (server.masterhost != NULL) return` — a replica that received this command from its master will proxy the raw bytes instead (Phase 5).
2. **Guard — skip if no consumers**: returns if no slaves and no backlog.
3. **`prepareReplicasToWrite()`** (replication.c:363): walks `server.slaves`; for each where `canFeedReplicaReplBuffer(slave)` is true, calls `prepareClientToWrite(slave)` — this enqueues the replica into `server.clients_pending_write` and installs a writable event handler.
4. **SELECT injection**: if `dictid != server.slaveseldb`, serializes `SELECT <db>` via `feedReplicationBuffer` and updates `server.slaveseldb`.
5. **RESP multi-bulk serialization** via `replBufWriter`:
   ```c
   replBufWriterBegin(&wr);
   replBufWriterAppendBulkLen(&wr, '*', argc);
   for j in 0..argc:
       replBufWriterAppendBulkLen(&wr, '$', objlen);
       replBufWriterAppend(&wr, argv[j]->ptr, objlen);
       replBufWriterAppend(&wr, "\r\n", 2);
   replBufWriterEnd(&wr);
   ```

### `canFeedReplicaReplBuffer` — `replication.c:329`
Returns false for:
- `CLIENT_REPL_RDBONLY` — snapshot-only replicas
- `SLAVE_STATE_WAIT_BGSAVE_START` or `SLAVE_STATE_WAIT_RDB_CHANNEL` — full-sync pending
- `CLIENT_CLOSE_ASAP`

These replicas cannot accumulate the stream yet; they will catch up once the full sync RDB is delivered.

### `replBufWriter` internals

**`replBufWriterBegin`** — `replication.c:466`  
Snapshots the current state:
- If the tail block has free space: records `wr->start_node = listLast(server.repl_buffer_blocks)`, `wr->start_pos = tail->used`
- Otherwise: `wr->start_node = NULL` (first append will allocate a new block)

**`replBufWriterAppend`** — `replication.c:533`  
Fast path:
```c
if (avail >= len) {
    memcpy(wr->tail->buf + wr->tail->used, buf, len);
    wr->tail->used += len;
    wr->total_len += len;
}
```
Slow path (`replBufWriterAppendSlow` → `replBufWriterAllocBlock`): `zmalloc` a new `replBufBlock`, set `repl_offset`, append to `server.repl_buffer_blocks`, `server.repl_buffer_mem += size`.

**`replBufWriterEnd`** — `replication.c:565`  
The commit that makes data visible:
1. `server.master_repl_offset += wr->total_len`
2. `server.repl_backlog->histlen += wr->total_len`
3. For each eligible replica in `server.slaves`:
   - If `slave->ref_repl_buf_node == NULL` (first write since coming online): set it to `wr->start_node`, `ref_block_pos = wr->start_pos`, `refcount++` on that block
   - If new blocks were allocated: check `closeClientOnOutputBufferLimitReached`
4. Set `server.repl_backlog->ref_repl_buf_node` similarly if the backlog had no head yet
5. If new blocks added: `incrementalTrimReplicationBacklog(REPL_BACKLOG_TRIM_BLOCKS_PER_CALL)`

### `incrementalTrimReplicationBacklog` — `replication.c:384`

Trims from the **head** of `server.repl_buffer_blocks` when `histlen > repl_backlog_size`. A block is only freed when:
- Its `refcount == 1` (only the backlog holds it — no replica cursor)
- Dropping it won't make `histlen` fall below `repl_backlog_size`

Advances `repl_backlog->ref_repl_buf_node` to the next block, removes the old offset from `repl_backlog->blocks_index` (the rax), and updates `repl_backlog->offset`. A slow replica holding `refcount > 1` on the head block **implicitly enlarges the backlog** — it is the main pressure valve preventing memory OOM vs PSYNC.

---

## Phase 3 — Network Write: Draining Blocks to Replicas

### `beforeSleep` → `handleClientsWithPendingWrites` — `server.c:1935, networking.c:2897`

At the end of every event-loop iteration, before `aeApiPoll` sleeps, `beforeSleep` runs:
```c
handleClientsWithPendingWrites();
putReplicasInPendingClientsToIOThreads();
sendPendingClientsToIOThreads();
// also: incremental backlog trim (10× normal rate)
```

`handleClientsWithPendingWrites` drains `server.clients_pending_write`. For each replica not delegated to an IO thread, it calls `writeToClient(c, 0)` → `_writeToClientSlave`.

### `_writeToClientSlave` — `networking.c:2734`

Zero-copy drain from the shared block list:
```c
replBufBlock *o = listNodeValue(c->ref_repl_buf_node);
nwritten = connWrite(c->conn, o->buf + c->ref_block_pos,
                              o->used - c->ref_block_pos);
c->ref_block_pos += nwritten;

// advance to next block when current is exhausted:
listNode *next = listNextNode(c->ref_repl_buf_node);
if (next && c->ref_block_pos == o->used) {
    o->refcount--;
    ((replBufBlock*)listNodeValue(next))->refcount++;
    c->ref_repl_buf_node = next;
    c->ref_block_pos = 0;
    incrementalTrimReplicationBacklog(...);  // may free old blocks
}
```

**There is no per-replica copy of replication data.** Each replica is a `(ref_repl_buf_node, ref_block_pos)` cursor in the shared `server.repl_buffer_blocks` list. `refcount` is the only memory ownership primitive.

`_clientHasPendingRepliesSlave` (networking.c:1540) reports pending data by comparing the replica's cursor to the list tail — a replica's "output buffer" is entirely virtual.

If a write is partial, `installClientWriteHandler` registers a writable file event; the next poll will call `sendReplyToClient` → `writeToClient` again.

---

## Phase 4 — Initial Sync: Full Resync and PSYNC

### Replica: `connectWithMaster` → `syncWithMaster` state machine — `replication.c:3433, 3071`

`replicationCron` (every 100 ms from `serverCron`) detects `repl_state == REPL_STATE_CONNECT` and calls `connectWithMaster`. A non-blocking TCP connect fires `syncWithMaster` as the read/write handler. It is a **resumable state machine**:

```
REPL_STATE_CONNECTING
  → sends PING
REPL_STATE_RECEIVE_PING_REPLY
  → waits for +PONG
REPL_STATE_SEND_HANDSHAKE
  → sends AUTH (if configured)
  → sends REPLCONF listening-port <port>
  → sends REPLCONF ip-address <ip>    (optional)
  → sends REPLCONF capa eof psync2    (capabilities negotiation)
REPL_STATE_RECEIVE_AUTH/PORT/IP/CAPA_REPLY
  → validates each; non-fatal errors tolerated for older masters
REPL_STATE_SEND_PSYNC
  → slaveTryPartialResynchronization(conn, 0)
     → sends: PSYNC <replid|?> <offset|-1>
REPL_STATE_RECEIVE_PSYNC_REPLY
  → slaveTryPartialResynchronization(conn, 1) reads reply
```

### Master: `syncCommand` / `masterTryPartialResynchronization` — `replication.c:1188, 986`

`syncCommand` receives the PSYNC. It calls `masterTryPartialResynchronization(c, psync_offset)`:

**Partial resync path** (happy path):
1. Validate `master_replid` matches `server.replid` (or `server.replid2` within `second_replid_offset`)
2. Check `psync_offset` is in `[repl_backlog->offset, repl_backlog->offset + histlen]`
3. Mark client: `CLIENT_SLAVE`, `replstate = SLAVE_STATE_ONLINE`, add to `server.slaves`
4. Write `+CONTINUE <replid>\r\n` directly via `connWrite`
5. `addReplyReplicationBacklog(c, psync_offset)` (replication.c:833):
   - Uses `repl_backlog->blocks_index` (rax keyed by big-endian offset) to binary-search the starting block
   - Sets `c->ref_repl_buf_node` + `c->ref_block_pos` and increments block `refcount`
   - Returns `histlen - skip` (bytes to replay)

**Full resync path**: `masterTryPartialResynchronization` returns `C_ERR`. The master:
1. Sends `+FULLRESYNC <replid> <offset>`; replica saves these in `server.master_replid` and `server.master_initial_offset`
2. `startBgsaveForReplication` (replication.c:1103): `redisFork` → child runs `rdbSave` (disk) or `rdbSaveToSlavesSockets` (diskless)
3. Replica state set to `SLAVE_STATE_WAIT_BGSAVE_END`

**While BGSAVE runs**, incoming write commands feed `server.repl_buffer_blocks` normally. Replicas in `SLAVE_STATE_WAIT_BGSAVE_END` pass `canFeedReplicaReplBuffer()` once they transition past `WAIT_BGSAVE_START`, so new writes **accumulate in the shared buffer** without delivery — they wait for the replica to come online.

**After BGSAVE**: `checkChildrenDone` → `updateSlavesWaitingBgsave` (replication.c:1961):
- **Disk**: `slave->replstate = SLAVE_STATE_SEND_BULK`, installs `sendBulkToSlave` write handler → streams the RDB file byte-by-byte (`read` from `repldbfd`, `connWrite` to socket) → on completion, `replicaPutOnline`
- **Diskless (socket)**: `replicaPutOnline(slave)` immediately; sets `slave->repl_start_cmd_stream_on_ack = 1` — the command stream is not yet activated to avoid mixing with the RDB EOF sentinel

### `replicaPutOnline` / `replicaStartCommandStream` — `replication.c:1637, 1674`

```c
int replicaPutOnline(client *slave) {
    slave->replstate = SLAVE_STATE_ONLINE;
    slave->repl_ack_time = server.unixtime;
    refreshGoodSlavesCount();
    // fires REDISMODULE_EVENT_REPLICA_CHANGE
}

void replicaStartCommandStream(client *slave) {
    slave->repl_start_cmd_stream_on_ack = 0;
    putClientInPendingWriteQueue(slave);  // → clients_pending_write
}
```

Once `putClientInPendingWriteQueue` runs, the next `beforeSleep` → `handleClientsWithPendingWrites` will start draining the accumulated `replBufBlock` chain to the replica.

---

## Phase 5 — Replica Receives and Re-executes the Stream

### `replicationCreateMasterClient` — `replication.c:2168`

After PSYNC succeeds (partial or full), the replica calls:
```c
server.master = createClient(conn);
connSetReadHandler(server.master->conn, readQueryFromClient);
server.master->flags |= CLIENT_MASTER;
server.master->querybuf = sdsempty();   // private buf (preserved for sub-replica proxying)
server.master->reploff = server.master_initial_offset;
server.master->read_reploff = server.master->reploff;
```
The master connection becomes an ordinary `client` but flagged `CLIENT_MASTER`. It has a **private** (non-shared) `querybuf` because the raw bytes must be preserved after parsing for forwarding to sub-replicas.

### Receiving and re-executing commands

Data arrives on `server.master->conn`. The standard I/O path runs:

```
readQueryFromClient (networking.c:3830)
  appends to server.master->querybuf; advances read_reploff
  → processInputBuffer (networking.c:3626)
      parse loop:
        processMultibulkBuffer / processInlineBuffer
          → sets c->argc, c->argv, c->reploff_next
        processCommandAndResetClient
          → processCommand
              → call(c, CMD_CALL_FULL)
                  c->cmd->proc(c)              // re-executes e.g. setCommand
                  alsoPropagate(...)            // if replica has sub-replicas
                  postExecutionUnitOperations
                    propagatePendingCommands
                      propagateNow
                        replicationFeedSlaves  // ← gated: skip if we have no slaves
                        (also) replicationFeedStreamFromMasterStream
```

Key difference for `CLIENT_MASTER` in `processInputBuffer`: the querybuf is trimmed to `c->repl_applied` (not `qb_pos`) — only the bytes **fully processed and proxied** are released. This preserves the raw stream for the proxy step.

`c->reploff` is updated to `c->reploff_next` inside `commandProcessed` after each successful command, tracking the applied offset precisely.

### `replicationFeedStreamFromMasterStream` — `replication.c:766`

When this replica itself has downstream replicas, instead of re-serializing the command from `argv` (which would change the byte layout and break replication ID sharing), it proxies the **raw bytes** from querybuf:

```c
void replicationFeedStreamFromMasterStream(char *buf, size_t buflen) {
    if (server.repl_backlog) {
        prepareReplicasToWrite();
        feedReplicationBuffer(buf, buflen);  // → replBufWriterBegin/Append/End
    }
}
```

This is called from `processInputBuffer` at the querybuf trim point, feeding the exact bytes received from the upstream master. The result: every replica in a replication chain has an **identical** `server.repl_buffer_blocks` content, identical `master_repl_offset` values, and can advertise the same `replid` — enabling cascading partial resync.

---

## Phase 6 — ACK / Offset Tracking / WAIT Unblocking

### `sendGetackToReplicas` — `server.c:1911`

In `beforeSleep`, when `server.get_ack_from_slaves` is set (set by `replicationRequestAckFromSlaves`, which is called when a WAIT/WAITAOF client blocks):
```c
argv = { shared.replconf, shared.getack, shared.special_asterick }
replicationFeedSlaves(server.slaves, -1, argv, 3);
```
Injects `REPLCONF GETACK *` into the replication stream for all replicas simultaneously.

### `replicationSendAck` — `replication.c:4475`

On the replica side, called by `replicationCron` (every `repl_ping_slave_period / 10` seconds) or upon receiving GETACK:
```c
addReplyArrayLen(c, 3);           // or 5 if FACK supported
addReplyBulkCString(c, "REPLCONF");
addReplyBulkCString(c, "ACK");
addReplyBulkLongLong(c, c->reploff);  // server.master->reploff
// optionally: "FACK" <fsynced_reploff>  for WAITAOF
```
Written to `server.master->conn` (upstream master connection).

### Master receives ACK: `replconfCommand` — `replication.c:1446`

The REPLCONF ACK arrives as an ordinary command on the replica's `client` struct on the master. The handler:
- `slave->repl_ack_off = offset` and `slave->repl_ack_time = server.unixtime`
- If `slave->repl_start_cmd_stream_on_ack`: calls `replicaStartCommandStream(slave)` — one-time activation for diskless sync that was deferred until first ACK
- `processClientsWaitingReplicas` (replication.c:4841): scans `server.clients_waiting_acks`; unblocks any WAIT client whose required offset and replica count are satisfied

---

## Every Function and Structure, in Pipeline Order

| # | Function / Structure | File | Line | Role |
|---|---------------------|------|------|------|
| 1 | `processCommand` | server.c | 4412 | Auth/ACL/cluster checks → `call` |
| 2 | `call` | server.c | 3949 | Execute cmd, measure dirty, stage propagation |
| 3 | `shouldPropagate` | server.c | 3673 | Gate: enabled? master? backlog/slaves exist? |
| 4 | `alsoPropagate` | server.c | 3732 | Append `redisOp` to `server.also_propagate` |
| 5 | `redisOp` / `redisOpArray` | server.h | 1802/1813 | Staging array for deferred propagation |
| 6 | `postExecutionUnitOperations` | server.c | 3867 | Top-nesting guard before flushing |
| 7 | `propagatePendingCommands` | server.c | 3811 | Drain staging; wrap in MULTI/EXEC if needed |
| 8 | `propagateNow` | server.c | 3704 | Fork to `feedAppendOnlyFile` + `replicationFeedSlaves` |
| 9 | `replicationFeedSlaves` | replication.c | 631 | SELECT injection + RESP serialize into repl buffer |
| 10 | `prepareReplicasToWrite` | replication.c | 363 | Install write handlers on eligible replicas |
| 11 | `canFeedReplicaReplBuffer` | replication.c | 329 | Filter WAIT_BGSAVE / RDBONLY replicas |
| 12 | `replBufWriter` (struct) | replication.c | 457 | Transactional cursor for block writes |
| 13 | `replBufWriterBegin` | replication.c | 466 | Snapshot tail block + start position |
| 14 | `replBufWriterAppend` | replication.c | 533 | `memcpy` into tail; `replBufWriterAllocBlock` if needed |
| 15 | `replBufWriterEnd` | replication.c | 565 | Commit: bump `master_repl_offset`; set replica cursors; trim |
| 16 | `replBufBlock` (struct) | server.h | 1195 | Ref-counted shared payload block |
| 17 | `server.repl_buffer_blocks` | server.h | ~2340 | `list<replBufBlock>` — the actual storage |
| 18 | `server.master_repl_offset` | server.h | ~2276 | Global stream byte counter |
| 19 | `replBacklog` (struct) | server.h | 1399 | Sliding window into `repl_buffer_blocks` |
| 20 | `incrementalTrimReplicationBacklog` | replication.c | 384 | Evict head blocks when `histlen > repl_backlog_size` |
| 21 | `beforeSleep` | server.c | 1935 | Event-loop pre-sleep orchestrator |
| 22 | `handleClientsWithPendingWrites` | networking.c | 2897 | Drain `clients_pending_write` queue |
| 23 | `_clientHasPendingRepliesSlave` | networking.c | 1540 | Check cursor vs tail (no private buffer) |
| 24 | `_writeToClientSlave` | networking.c | 2734 | Zero-copy `connWrite` from `replBufBlock` chain |
| 25 | `installClientWriteHandler` | networking.c | 263 | Register writable fd event for partial writes |
| 26 | `connectWithMaster` | replication.c | 3433 | Non-blocking TCP connect to master |
| 27 | `syncWithMaster` | replication.c | 3071 | Replica handshake state machine |
| 28 | `slaveTryPartialResynchronization` | replication.c | 2880 | Send PSYNC; read +CONTINUE / +FULLRESYNC |
| 29 | `syncCommand` | replication.c | 1188 | Master PSYNC/SYNC command handler |
| 30 | `masterTryPartialResynchronization` | replication.c | 986 | Validate replid + backlog coverage → send +CONTINUE |
| 31 | `addReplyReplicationBacklog` | replication.c | 833 | Set replica cursor via rax index; bump `refcount` |
| 32 | `startBgsaveForReplication` | replication.c | 1103 | Fork RDB snapshot for full resync |
| 33 | `updateSlavesWaitingBgsave` | replication.c | 1961 | Post-BGSAVE: `sendBulkToSlave` (disk) or `replicaPutOnline` (diskless) |
| 34 | `sendBulkToSlave` | replication.c | 1751 | Stream RDB file to replica (disk-based sync) |
| 35 | `replicaPutOnline` | replication.c | 1637 | `replstate = SLAVE_STATE_ONLINE`; refresh slave count |
| 36 | `replicaStartCommandStream` | replication.c | 1674 | Enqueue into `clients_pending_write` |
| 37 | `replicationCreateMasterClient` | replication.c | 2168 | Create `server.master` client; install `readQueryFromClient` |
| 38 | `readQueryFromClient` | networking.c | 3830 | Read bytes from master conn into `querybuf` |
| 39 | `processInputBuffer` | networking.c | 3626 | Parse RESP; trim to `repl_applied` for master client |
| 40 | `processCommandAndResetClient` → `call` | networking.c/server.c | 3491/3949 | Re-execute command on replica dataset |
| 41 | `replicationFeedStreamFromMasterStream` | replication.c | 766 | Proxy raw querybuf bytes to sub-replicas verbatim |
| 42 | `feedReplicationBuffer` | replication.c | 618 | Thin wrapper: `replBufWriterBegin/Append/End` |
| 43 | `sendGetackToReplicas` | server.c | 1911 | Inject `REPLCONF GETACK *` into stream |
| 44 | `replicationSendAck` | replication.c | 4475 | Replica sends `REPLCONF ACK <reploff>` upstream |
| 45 | `replconfCommand` (ACK branch) | replication.c | 1446 | Master updates `slave->repl_ack_off`; activate stream |
| 46 | `processClientsWaitingReplicas` | replication.c | 4841 | Unblock WAIT / WAITAOF clients |

---

## Unified Architecture Diagram

```
MASTER PROCESS
══════════════════════════════════════════════════════════════════════════════

  Client connection
  ─────────────────
  readQueryFromClient (networking.c:3830)
    └─► processInputBuffer (networking.c:3626)
          └─► processCommandAndResetClient
                └─► processCommand (server.c:4412)
                      └─► call(c, CMD_CALL_FULL) (server.c:3949)
                            │
                            ├─ c->cmd->proc(c)          ← executes setCommand etc.
                            │    └─ server.dirty++
                            │
                            ├─ alsoPropagate()           ← server.c:3732
                            │    └─► redisOpArrayAppend(&server.also_propagate, …)
                            │
                            └─ afterCommand → exitExecutionUnit
                                 └─► postExecutionUnitOperations (server.c:3867)
                                       └─► propagatePendingCommands (server.c:3811)
                                             │  (wraps in MULTI/EXEC if numops > 1)
                                             └─► propagateNow (server.c:3704)
                                                   ├─► feedAppendOnlyFile          [AOF]
                                                   └─► replicationFeedSlaves       [REPL]
                                                         (replication.c:631)

  Replication Feed Path
  ─────────────────────
  replicationFeedSlaves
    ├─ prepareReplicasToWrite()      ← install write handlers on online replicas
    │    └─ canFeedReplicaReplBuffer() filters WAIT_BGSAVE / RDBONLY
    │
    ├─ feedReplicationBuffer(SELECT) ← if db changed
    │
    └─ replBufWriterBegin/Append/End (replication.c:466,533,565)
         │
         │  WRITES INTO:
         │  ┌─────────────────────────────────────────────────────┐
         │  │  server.repl_buffer_blocks  (list<replBufBlock>)    │
         │  │                                                     │
         │  │  [block0][block1][block2] ··· [blockN]  (tail)     │
         │  │     ▲         ▲                   ▲                │
         │  │  backlog   replica-A           replica-B           │
         │  │  .ref_node .ref_repl_buf_node  .ref_repl_buf_node  │
         │  │  refcount  refcount            refcount            │
         │  └─────────────────────────────────────────────────────┘
         │
         │  ON COMMIT (replBufWriterEnd):
         ├─ server.master_repl_offset += total_len
         ├─ server.repl_backlog->histlen += total_len
         ├─ set/update replica cursors (ref_repl_buf_node, ref_block_pos)
         └─ incrementalTrimReplicationBacklog()   ← evict head if histlen > limit
              (only if head refcount == 1, i.e., no replica holds it)

  Backlog Index (for PSYNC)
  ─────────────────────────
  server.repl_backlog->blocks_index  (rax)
    encoded_offset → listNode*
    used by addReplyReplicationBacklog() to O(log N) seek to PSYNC start point

  Network Write (beforeSleep)
  ──────────────────────────
  beforeSleep (server.c:1935)
    └─► handleClientsWithPendingWrites (networking.c:2897)
          └─► writeToClient → _writeToClientSlave (networking.c:2734)
                │
                │  for each replica:
                │    connWrite(conn, block->buf + ref_block_pos, available)
                │    ref_block_pos += nwritten
                │    if block exhausted → advance to next block, refcount--/++
                │    (no copy — zero-copy send from shared replBufBlock)
                │
                └─► installClientWriteHandler  ← if partial write

  ACK / WAIT
  ──────────
  beforeSleep
    └─► sendGetackToReplicas (server.c:1911)
          └─► replicationFeedSlaves([REPLCONF GETACK *])
                ↓ (arrives at replica, replica sends back ACK)
  replconfCommand ACK branch (replication.c:1446)
    ├─ slave->repl_ack_off = offset
    └─► processClientsWaitingReplicas  ← unblock WAIT/WAITAOF clients


INITIAL SYNC PATH (first connection or stale replica)
══════════════════════════════════════════════════════════════════════════════

  REPLICA                              MASTER
  ───────                              ──────
  connectWithMaster
  syncWithMaster state machine:
    PING ──────────────────────────►
         ◄─────────────────────── +PONG
    AUTH ──────────────────────────►  (if configured)
    REPLCONF listening-port ───────►
    REPLCONF capa eof psync2 ──────►
         ◄────────────────────── +OK
    PSYNC <replid> <offset> ───────►
                                     masterTryPartialResynchronization
                                       (replication.c:986)

    ── PARTIAL RESYNC ──────────────────────────────────────────────────────
         ◄────────────── +CONTINUE <replid>
    addReplyReplicationBacklog sets replica cursor in shared buffer
    replica receives buffered data via normal _writeToClientSlave path

    ── FULL RESYNC ─────────────────────────────────────────────────────────
         ◄───────────── +FULLRESYNC <replid> <offset>
                                     startBgsaveForReplication
                                       redisFork → rdbSave (disk)
                                                or rdbSaveToSlavesSockets (diskless)
                                     [ new writes → repl_buffer_blocks, not yet sent ]

                                     BGSAVE done → updateSlavesWaitingBgsave
                                       disk:     sendBulkToSlave (RDB file → socket)
                                       diskless: replicaPutOnline immediately

    RDB received ──────────────────►  readSyncBulkPayload loads into dataset
    replicationCreateMasterClient     (server.master client created)
    connSetReadHandler → readQueryFromClient


REPLICA PROCESS (steady state)
══════════════════════════════════════════════════════════════════════════════

  Master connection (server.master, CLIENT_MASTER)
  ─────────────────
  readQueryFromClient (networking.c:3830)
    └─► processInputBuffer (networking.c:3626)
          │
          │  parse RESP from querybuf → pending commands
          │  c->read_reploff tracks bytes parsed
          │
          └─► processCommandAndResetClient → call()
                ├─ cmd->proc(c)          ← re-execute on local dataset
                │
                └─ if sub-replicas exist:
                     replicationFeedStreamFromMasterStream (replication.c:766)
                       └─► feedReplicationBuffer(querybuf_ptr, len)
                             (raw bytes, not re-serialized → identical stream)
                             → replBufWriterBegin/Append/End
                               → sub-replica repl_buffer_blocks

          querybuf trimmed to repl_applied (not qb_pos) — raw bytes held
          until fully proxied to sub-replicas

  ACK (replica → master)
  ──────────────────────
  replicationCron / GETACK received
    └─► replicationSendAck (replication.c:4475)
          REPLCONF ACK <server.master->reploff>
          (optionally FACK <fsynced_reploff> for WAITAOF)
```

---

## Summary of the Three Invariants That Hold Everything Together

**1. Single shared buffer, cursor-per-consumer.**  
`server.repl_buffer_blocks` is one linked list of `replBufBlock`s. The backlog and every replica hold a `(listNode*, offset)` cursor and a `refcount` share. No data is copied per-replica. Blocks are freed only when every cursor has passed them.

**2. `master_repl_offset` is the universal clock.**  
Every byte appended to the replication buffer advances `master_repl_offset`. Replicas report `reploff` (applied offset) via REPLCONF ACK. The delta `master_repl_offset - slave->repl_ack_off` is the replication lag. PSYNC partial resync is feasible exactly when the requested offset falls in `[repl_backlog->offset, repl_backlog->offset + histlen]`.

**3. Re-execution uses raw bytes, not re-serialization.**  
A replica with sub-replicas does not re-serialize commands via `replicationFeedSlaves`. It calls `replicationFeedStreamFromMasterStream` with the raw querybuf bytes — preserving the bit-identical stream so the entire chain shares one `replid` and one consistent offset space.
