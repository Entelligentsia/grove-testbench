# transcript: Map every function and data structure involved in Redis write-command replication from master to replica. The codebase is at /home/bench/repos/redis/src/. I ...


💬 I'll spawn an Explore agent to do a thorough pinpoint search across the replication pipeline before synthesizing the walkthrough.
  ▸ Agent(Deep replication pipeline code map)
  ▸ Bash(find /home/bench/repos/redis/src -name "*.c" -o -name "*.h" | head -20)
  ▸ Bash(ls /home/bench/repos/redis/src/ | grep -E "\.(c|h)$")
  ▸ Read(/home/bench/repos/redis/src)
  ▸ Bash(grep -n "^int processCommand" /home/bench/repos/redis/src/server.c | head -5)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Bash(grep -n "^int processCommand\|^void call\|^void propagate\|^void alsoPropagate" /home/bench/repos/redis/src/server.c 2>&1 | head -20)
  ▸ Bash(grep -n "processCommand\|^void call" /home/bench/repos/redis/src/server.c 2>&1 | grep -E "processCommand|call\(" | head -20)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)

💬 Good foundation. Now let me read the key functions directly to get precise line numbers and fill in any gaps.
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)

💬 Now let me check the replica-side processing and the `syncWithMaster`/`readQueryFromClient` path.
  ▸ Bash(grep -n "syncWithMaster\|readSyncBulkPayload\|connectWithMaster\|replicationSetMaster\|masterTryPartialResynchronization\|replicaofCommand\|slaveofCommand\|p...)
  ▸ Bash(grep -n "waitCommand\|replicationCountAcksByOffset\|replconfCommand\|REPLCONF\|repl_ack_off\|numreplicas_acked\|replicationGetSlaveMaxLag" /home/bench/repos/...)
  ▸ Bash(grep -n "writeToClient\|sendReplyToClient\|handleClientsWithPendingWrites\|clientInstallWriteHandler\|putClientInPendingWriteQueue\|ref_repl_buf_node\|ref_bl...)
  ▸ Agent(Replica-side and networking line number lookup)
  ▸ Bash(grep -n "^syncWithMaster" /home/bench/repos/redis/src/replication.c | head -1)
  ▸ Bash(find /home/bench/repos/redis/src -name "replication.c" -o -name "networking.c" -o -name "server.c" -o -name "server.h")
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Bash(grep -n "^void syncWithMaster" /home/bench/repos/redis/src/replication.c)
  ▸ Bash(grep -n "^void readSyncBulkPayload" /home/bench/repos/redis/src/replication.c)
  ▸ Bash(grep -n "^void connectWithMaster" /home/bench/repos/redis/src/replication.c)
  ▸ Bash(grep -n "^void replicationSetMaster" /home/bench/repos/redis/src/replication.c)
  ▸ Bash(grep -n "^int masterTryPartialResynchronization" /home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)
  ▸ Read(/home/bench/repos/redis/src/server.h)

💬 Let me check a few more specific sections to complete the picture.
  ▸ Read(/home/bench/repos/redis/src/networking.c)
  ▸ Read(/home/bench/repos/redis/src/replication.c)
  ▸ Read(/home/bench/repos/redis/src/server.c)

💬 I have everything I need. Here is the complete architectural walkthrough.  ---  ## Redis Write-Command Replication: End-to-End Architecture  ---  ### Stage 0...

──────── RESULT (success, 459750ms, 18 turns) ────────
I have everything I need. Here is the complete architectural walkthrough.

---

## Redis Write-Command Replication: End-to-End Architecture

---

### Stage 0 — Setup: the `redisCommandTable` and Write Flag

Every command is registered in `redisCommandTable` (server.c, around line 300). Write commands carry the `CMD_WRITE` flag. `processCommand()` uses that flag for ACL enforcement and cluster checks, but **propagation is not driven by the flag** — it is driven by the `server.dirty` counter: if the command actually changed data, it gets propagated.

---

### Stage 1 — Command Dispatch: `processCommand` → `call`

**`processCommand()`** `server.c:4412`

The entry point for every client request. After ACL, cluster, quota, and MULTI/EXEC checks, it reaches:

```c
// server.c:4787-4788
int flags = CMD_CALL_FULL;
call(c, flags);
```

`CMD_CALL_FULL` includes `CMD_CALL_PROPAGATE_REPL | CMD_CALL_PROPAGATE_AOF`.

---

**`call()`** `server.c:3949`

The execution core. Key sequence:

```
server.c:3978   dirty = server.dirty;                   // snapshot dirty counter
server.c:3979   old_master_repl_offset = server.master_repl_offset;
server.c:4007   enterExecutionUnit(1, call_timer);      // track nesting depth
server.c:4015   c->cmd->proc(c);                        // ← RUN THE COMMAND
server.c:4017   exitExecutionUnit();
...
server.c:4032   dirty = server.dirty - dirty;           // did command mutate data?
...
// Propagation decision block (server.c:4122-4153):
if (flags & CMD_CALL_PROPAGATE
    && !(c->flags & CLIENT_PREVENT_PROP)
    && c->cmd->proc != execCommand
    && !(c->cmd->flags & CMD_MODULE))
{
    int propagate_flags = PROPAGATE_NONE;
    if (dirty) propagate_flags |= (PROPAGATE_AOF|PROPAGATE_REPL); // data changed
    if (c->flags & CLIENT_FORCE_REPL)  propagate_flags |= PROPAGATE_REPL;
    if (c->flags & CLIENT_FORCE_AOF)   propagate_flags |= PROPAGATE_AOF;
    // CLIENT_PREVENT_REPL_PROP strips PROPAGATE_REPL ...
    if (propagate_flags != PROPAGATE_NONE)
        alsoPropagate(c->db->id, c->argv, c->argc, propagate_flags); // server.c:4153
}
...
server.c:4189   afterCommand(c);
```

**Key data structures introduced here:**

| Item | Location | Description |
|------|----------|-------------|
| `client.flags` | `server.h:1478` | `CLIENT_FORCE_REPL`, `CLIENT_PREVENT_REPL_PROP`, etc. |
| `client.argv / argc` | `server.h:1492-1494` | The parsed command tokens |
| `server.dirty` | `server.h` | Global count of keyspace mutations |
| `server.master_repl_offset` | `server.h:2374` | Monotonically-increasing byte offset |

---

### Stage 2 — Propagation Queue: `alsoPropagate` → `redisOpArray`

**`alsoPropagate()`** `server.c:3732`

Does **not** propagate immediately. Copies `argv`, ref-counts each object, and appends an entry to `server.also_propagate`:

```c
redisOpArrayAppend(&server.also_propagate, dbid, argvcopy, argc, target);
// server.c:3744
```

**`redisOp` / `redisOpArray`** `server.h:1802-1817`

```c
typedef struct redisOp {
    robj **argv;
    int argc, dbid, target;   // target = PROPAGATE_REPL | PROPAGATE_AOF
} redisOp;

typedef struct redisOpArray {
    redisOp *ops;
    int numops;
    int capacity;
} redisOpArray;
```

`server.also_propagate` (`server.h:2354`) is the instance in `redisServer`.

---

**`afterCommand()`** called from `call()` at `server.c:4189`

Calls `postExecutionUnitOperations()`.

**`postExecutionUnitOperations()`** `server.c:3867`

```c
void postExecutionUnitOperations(void) {
    if (server.execution_nesting) return;   // only at top-level
    firePostExecutionUnitJobs();
    propagatePendingCommands();             // server.c:3875
    modulePostExecutionUnitOperations();
}
```

The `execution_nesting` guard means nested `call()` invocations (e.g., from Lua or MULTI/EXEC) accumulate into `also_propagate` without flushing; the flush happens only when the outermost `call()` unwinds.

---

**`propagatePendingCommands()`** `server.c:3811`

Flushes `also_propagate` to the wire. If more than one op is queued (e.g., a command that triggers side-effects via module hooks), wraps them in MULTI/EXEC on the replication stream:

```c
if (transaction) propagateNow(-1, &shared.multi, 1, PROPAGATE_AOF|PROPAGATE_REPL);
for (j = 0; j < server.also_propagate.numops; j++) {
    rop = &server.also_propagate.ops[j];
    propagateNow(rop->dbid, rop->argv, rop->argc, rop->target); // server.c:3842
}
if (transaction) propagateNow(-1, &shared.exec, 1, PROPAGATE_AOF|PROPAGATE_REPL);
redisOpArrayFree(&server.also_propagate);
```

---

**`propagateNow()`** `server.c:3704`

```c
static void propagateNow(int dbid, robj **argv, int argc, int target) {
    if (server.aof_state != AOF_OFF && target & PROPAGATE_AOF)
        feedAppendOnlyFile(dbid, argv, argc);       // AOF path
    if (target & PROPAGATE_REPL)
        replicationFeedSlaves(server.slaves, dbid, argv, argc); // server.c:3716
}
```

This is the fork point: AOF goes left, replication goes right.

---

### Stage 3 — Serialization and Backlog Write: `replicationFeedSlaves`

**`replicationFeedSlaves()`** `replication.c:631`

The function that writes the command into the shared replication buffer. Step by step:

```
replication.c:644  if (server.masterhost != NULL) return;  // not a top-level master
replication.c:649  if (current_client->flags & CLIENT_MASTER) return; // proxying only
replication.c:653  if (backlog==NULL && no slaves) { master_repl_offset++; return; }
replication.c:669  prepareReplicasToWrite();        // install write handlers on replicas
// SELECT if DB changed:
replication.c:688  feedReplicationBuffer(selectcmd->ptr, sdslen(...));
// Serialize the command as RESP:
replication.c:703  replBufWriterBegin(&wr);
replication.c:707  replBufWriterAppendBulkLen(&wr, '*', argc);  // *N\r\n
for each arg:
replication.c:712      replBufWriterAppendBulkLen(&wr, '$', objlen); // $L\r\n
replication.c:717/719  replBufWriterAppend(&wr, arg_bytes, objlen);  // data
replication.c:721      replBufWriterAppend(&wr, "\r\n", 2);
replication.c:724  replBufWriterEnd(&wr);           // commits to repl_buffer_blocks
```

**`feedReplicationBuffer()`** `replication.c:618`

```c
static void feedReplicationBuffer(const char *buf, size_t len) {
    replBufWriter wr;
    replBufWriterBegin(&wr);
    replBufWriterAppend(&wr, buf, len);
    replBufWriterEnd(&wr);     // updates server.master_repl_offset
}
```

`replBufWriterEnd()` also: anchors the backlog's `ref_repl_buf_node` on first write, and calls `incrementalTrimReplicationBacklog()` when a new block is allocated.

---

### Stage 4 — The Global Replication Buffer and Backlog

These two structures are the heart of the memory model:

**`replBufBlock`** `server.h:1195`

```c
typedef struct replBufBlock {
    int refcount;       // #replicas + (1 if backlog references it)
    long long id;
    long long repl_offset;  // byte offset of buf[0] in the stream
    size_t size;            // allocated capacity
    size_t used;            // bytes written
    char buf[];             // flexible array — the actual RESP bytes
} replBufBlock;
```

`server.repl_buffer_blocks` (`server.h:2404`) is a `list *` of these blocks. Every `replBufBlock` that any replica or the backlog currently references has `refcount > 0`. When `refcount` drops to zero the block is freed.

**`replBacklog`** `server.h:1399`

```c
typedef struct replBacklog {
    listNode *ref_repl_buf_node;  // oldest block owned by the backlog
    size_t unindexed_count;
    rax *blocks_index;    // sparse index: repl_offset → block, for fast PSYNC seeks
    long long histlen;    // bytes currently in the backlog window
    long long offset;     // repl_offset of the first backlog byte
} replBacklog;
```

`server.repl_backlog` (`server.h:2383`) points to this. It is not a separate copy of the data — it is just a **reference into `repl_buffer_blocks`** (a sliding window). When `histlen` would exceed `repl_backlog_size`, `incrementalTrimReplicationBacklog()` advances `ref_repl_buf_node` forward, decrementing `refcount` on released blocks.

**Offset accounting:**

- `server.master_repl_offset` — advances with every byte written to the buffer.
- `replBacklog.offset` — the repl_offset of the oldest byte still retained.
- `client.repl_ack_off` — the offset the replica last confirmed receiving.

---

### Stage 5 — Feeding the Replica Socket: `prepareReplicasToWrite` → `writeToClient`

**`prepareReplicasToWrite()`** `replication.c:363`

Called by `replicationFeedSlaves()` before writing to the buffer. For each slave in `server.slaves` that passes `canFeedReplicaReplBuffer()` (i.e., `replstate == SLAVE_STATE_ONLINE`), calls:

```c
prepareClientToWrite(slave);   // replication.c:372
```

**`prepareClientToWrite()` / `_prepareClientToWrite()`** `networking.c:363, 307`

```c
static inline int _prepareClientToWrite(client *c) {
    // ... early exits for script/module/CLOSE_ASAP ...
    if (likely(c->running_tid == IOTHREAD_MAIN_THREAD_ID) && !clientHasPendingReplies(c))
        putClientInPendingWriteQueue(c);   // networking.c:335
    return C_OK;
}
```

`putClientInPendingWriteQueue()` adds the replica `client` to `server.clients_pending_write`.

**Event loop drain — `handleClientsWithPendingWrites()`** `networking.c:2897`

Called from `beforeSleep()` each time the event loop awakens. For each client in `clients_pending_write`:

```c
writeToClient(c, 0);
// if still pending, install a write event handler:
connSetWriteHandlerWithBarrier(c->conn, sendReplyToClient, ...);
```

**`writeToClient()`** `networking.c:2786`

Dispatches on client type. For replica clients (`clientTypeIsSlave(c)`):

```c
while (_clientHasPendingRepliesSlave(c)) {
    _writeToClientSlave(c, &nwritten);
}
atomicIncr(server.stat_net_repl_output_bytes, totwritten);
```

**`_writeToClientSlave()`** `networking.c ~2757`

The actual copy-from-buffer-to-socket loop:

```c
replBufBlock *o = listNodeValue(c->ref_repl_buf_node);  // net.c:2757
connWrite(c->conn, o->buf + c->ref_block_pos,
          o->used - c->ref_block_pos);                  // net.c:2761
c->ref_block_pos += nwritten;
// When block is fully consumed, advance to next:
o->refcount--;
((replBufBlock*)listNodeValue(next))->refcount++;
c->ref_repl_buf_node = next;
c->ref_block_pos = 0;
incrementalTrimReplicationBacklog(...);                 // net.c:2773
```

**Key `client` fields for replicas** `server.h:1543-1576`

| Field | Description |
|-------|-------------|
| `client.replstate` | `SLAVE_STATE_ONLINE` (9) when streaming |
| `client.ref_repl_buf_node` | `listNode*` into `repl_buffer_blocks` — current block being drained |
| `client.ref_block_pos` | byte offset within that block |
| `client.repl_ack_off` | last ACKed offset (updated by REPLCONF ACK) |
| `client.repl_ack_time` | timestamp of last ACK |
| `client.reploff` | applied replication offset (if this client is a master conn on a replica) |

---

### Stage 6 — Replica Side: Initial Sync and Steady-State

#### 6a. Handshake State Machine

**`replicaofCommand()`** `replication.c:4350` — sets `server.masterhost / masterport`, triggers `connectWithMaster()`.

**`connectWithMaster()`** `replication.c:3433` — opens a non-blocking TCP connection and registers `syncWithMaster` as the read/write handler. Sets `server.repl_state = REPL_STATE_CONNECTING`.

**`syncWithMaster()`** `replication.c:3071` — a single function driven by `server.repl_state` (`repl_state` enum, `server.h:519`):

```
REPL_STATE_CONNECTING        → send PING
REPL_STATE_RECEIVE_PING_REPLY
REPL_STATE_SEND_HANDSHAKE    → REPLCONF listening-port / ip-address / capa psync2
REPL_STATE_RECEIVE_AUTH_REPLY
REPL_STATE_RECEIVE_PORT_REPLY / IP_REPLY / REQ_REPLY / CAPA_REPLY
REPL_STATE_SEND_PSYNC        → PSYNC <replid> <offset>
REPL_STATE_RECEIVE_PSYNC_REPLY
    +FULLRESYNC → REPL_STATE_TRANSFER
    +CONTINUE   → REPL_STATE_CONNECTED (partial resync)
```

**`masterTryPartialResynchronization()`** `replication.c:985` (master side) — checks if the replica's requested `<replid> <offset>` falls within the backlog window. Uses `replBacklog.blocks_index` (the rax tree) to seek to the right `replBufBlock` quickly, then streams from there.

#### 6b. Full Sync — RDB Transfer

`REPL_STATE_TRANSFER` triggers **`readSyncBulkPayload()`** `replication.c:2253`.

The master forks a child (`bgsaveCommand`/`rdbSaveBackground`), pipes the RDB to the replica over the connection. `readSyncBulkPayload()` writes it to a temp file, flushes the DB, loads the RDB, then transitions to `REPL_STATE_CONNECTED`.

Slave-side `client.replstate` on the **master**: `SLAVE_STATE_WAIT_BGSAVE_START → SLAVE_STATE_WAIT_BGSAVE_END → SLAVE_STATE_SEND_BULK → SLAVE_STATE_ONLINE`.

#### 6c. Materializing the Master Client

**`replicationCreateMasterClient()`** `replication.c:2168`

```c
server.master = createClient(conn);                          // line 2169
connSetReadHandler(server.master->conn, readQueryFromClient); // line 2171
server.master->flags |= CLIENT_MASTER;                       // line 2184
```

This is the pivot: the replica creates an internal `client` object (`server.master`) for the connection to its master, and attaches `readQueryFromClient` as the read handler. From this point, the replica and a normal Redis client share the **same read path**.

#### 6d. Steady-State Command Replay

Every time the TCP socket delivers bytes from the master:

```
readQueryFromClient()         networking.c
  └─ processInputBuffer()
       ├─ processMultibulkBuffer()   // parse RESP *N\r\n$L\r\n...
       └─ processCommand()           server.c:4412
            └─ call()               server.c:3949
                 └─ c->cmd->proc(c) // ← re-execute SET, LPUSH, etc.
```

Because `server.master->flags & CLIENT_MASTER`, several things differ:
- `call()` does **not** propagate the command via `alsoPropagate` (the `if (server.masterhost != NULL) return` guard in `replicationFeedSlaves` prevents double-propagation — unless the replica has its own sub-replicas, in which case `replicationFeedStreamFromMasterStream()` is used).
- `server.master->reploff` is advanced to track applied offset.

**`replicationFeedStreamFromMasterStream()`** `replication.c:766` — when a replica has its own downstream replicas, raw bytes from the master are fed directly into the replica's own `repl_buffer_blocks` without re-serialization. This preserves the identical byte stream (and thus the same replication ID).

---

### Stage 7 — ACK and WAIT

#### 7a. Periodic ACK from Replica

**`replicationCron()`** `replication.c:4937` runs every 100ms in `serverCron`. Calls `replicationSendAck()`, which sends:

```
REPLCONF ACK <server.master->reploff>
```

#### 7b. ACK Received on Master

**`replconfCommand()`** `replication.c:1446` handles REPLCONF on the master side. On "ACK":

```c
// replication.c:1494
c->repl_ack_off = offset;
c->repl_ack_time = server.unixtime;
```

The replica's `client` struct on the master is updated with the new confirmed offset.

#### 7c. WAIT Command

**`waitCommand()`** `replication.c:4754` — blocks the calling client until N replicas acknowledge at least `master_repl_offset` or a timeout expires.

**`replicationCountAcksByOffset()`** `replication.c:4720` — scans `server.slaves`, counting replicas where `slave->repl_ack_off >= offset`.

---

### Unified Architecture Diagram

```
CLIENT                   MASTER                                    REPLICA(S)
  │                        │                                           │
  │── SET foo bar ────────►│                                           │
  │                        │  processCommand()         server.c:4412  │
  │                        │    └─ call()              server.c:3949  │
  │                        │         │                                 │
  │                        │         ├─ c->cmd->proc(c)  [setCommand] │
  │                        │         │    └─ dbAdd() / dbOverwrite()  │
  │                        │         │       server.dirty++           │
  │                        │         │                                 │
  │                        │         ├─ alsoPropagate()  server.c:4153│
  │                        │         │    └─ redisOpArrayAppend()     │
  │                        │         │       → server.also_propagate  │
  │                        │         │                                 │
  │                        │         └─ afterCommand()  server.c:4189 │
  │                        │              └─ postExecutionUnitOps()   │
  │                        │                   └─ propagatePending()  │
  │                        │                        └─ propagateNow() │
  │                        │                             ├─ feedAOF() │
  │                        │                             └─ replication│
  │                        │                                FeedSlaves()
  │                        │                                replication.c:631
  │                        │                                           │
  │                        │  ┌─────────────────────────────────────┐ │
  │                        │  │  GLOBAL REPLICATION BUFFER           │ │
  │                        │  │  server.repl_buffer_blocks (list)   │ │
  │                        │  │  ┌──────────┐ ┌──────────┐ ┌──────┐│ │
  │                        │  │  │replBuf   │→│replBuf   │→│ ...  ││ │
  │                        │  │  │Block     │ │Block     │ │      ││ │
  │                        │  │  │refcount=2│ │refcount=1│ │      ││ │
  │                        │  │  │[*3\r\n   │ │$3\r\n    │ │      ││ │
  │                        │  │  │$3\r\nSET │ │foo\r\n   │ │      ││ │
  │                        │  │  │...]      │ │$3\r\nbar │ │      ││ │
  │                        │  │  └──────────┘ └──────────┘ └──────┘│ │
  │                        │  │       ▲              ▲              │ │
  │                        │  │  replBacklog    replica-A           │ │
  │                        │  │  .ref_node      .ref_repl_buf_node  │ │
  │                        │  │  (backlog        (current send pos) │ │
  │                        │  │   window)                           │ │
  │                        │  └─────────────────────────────────────┘ │
  │                        │                                           │
  │                        │  EVENT LOOP beforeSleep():               │
  │                        │  handleClientsWithPendingWrites()        │
  │                        │    └─ writeToClient(replica_client)      │
  │                        │         └─ _writeToClientSlave()         │
  │                        │              └─ connWrite(conn,          │
  │                        │                   block->buf+pos, len)──►│
  │                        │                                           │
  │                        │                    readQueryFromClient()  │
  │                        │                      processInputBuffer() │
  │                        │                        processMultibulk() │
  │                        │                          processCommand() │
  │                        │                            call()        │
  │                        │                             setCommand() │
  │                        │                            [key applied] │
  │                        │                                           │
  │                        │◄──── REPLCONF ACK <offset> ─────────────│
  │                        │  replconfCommand()                        │
  │                        │    c->repl_ack_off = offset              │
  │                        │                                           │
  │◄─ (unblocked) ─────────│  waitCommand() / replicationCount        │
  │                        │  AcksByOffset()                          │
```

---

### Function Reference Table (in pipeline order)

| # | Function | File:Line | Role |
|---|----------|-----------|------|
| 1 | `processCommand` | `server.c:4412` | Validate and dispatch; calls `call()` at :4788 |
| 2 | `call` | `server.c:3949` | Run `c->cmd->proc(c)` (:4015), build propagate_flags (:4122), call `alsoPropagate` (:4153) |
| 3 | `alsoPropagate` | `server.c:3732` | Copy argv, append `redisOp` to `server.also_propagate` |
| 4 | `afterCommand` | `server.c:4189` (call site) | Triggers `postExecutionUnitOperations` |
| 5 | `postExecutionUnitOperations` | `server.c:3867` | Top-level flush guard; calls `propagatePendingCommands` (:3875) |
| 6 | `propagatePendingCommands` | `server.c:3811` | Drains `server.also_propagate`; wraps in MULTI/EXEC if >1 op |
| 7 | `propagateNow` | `server.c:3704` | Forks to AOF (:3714) and `replicationFeedSlaves` (:3716) |
| 8 | `replicationFeedSlaves` | `replication.c:631` | Guard checks, `prepareReplicasToWrite`, serialize RESP into buffer |
| 9 | `prepareReplicasToWrite` | `replication.c:363` | For each `SLAVE_STATE_ONLINE` replica: `prepareClientToWrite` |
| 10 | `prepareClientToWrite` | `networking.c:363` | `putClientInPendingWriteQueue` → adds to `clients_pending_write` |
| 11 | `feedReplicationBuffer` | `replication.c:618` | Appends bytes to `repl_buffer_blocks`; updates `master_repl_offset` |
| 12 | `incrementalTrimReplicationBacklog` | `replication.c:384` | Trims oldest blocks when `histlen > repl_backlog_size` |
| 13 | `handleClientsWithPendingWrites` | `networking.c:2897` | Event loop drain; calls `writeToClient` per replica |
| 14 | `writeToClient` | `networking.c:2786` | Dispatch: slave path calls `_writeToClientSlave` in loop |
| 15 | `_writeToClientSlave` | `networking.c:~2757` | `connWrite` from `ref_repl_buf_node`; advances block pointer |
| 16 | `replicationCreateMasterClient` | `replication.c:2168` | On replica: `createClient`, `connSetReadHandler(…, readQueryFromClient)` |
| 17 | `readQueryFromClient` | `networking.c` | Replica receives bytes from master; feeds `processInputBuffer` |
| 18 | `processMultibulkBuffer` | `networking.c` | Parse RESP into `client.argv` |
| 19 | `processCommand` → `call` | `server.c:4412, 3949` | Replica re-executes the command in its own keyspace |
| 20 | `replicationFeedStreamFromMasterStream` | `replication.c:766` | Chained replicas: proxy raw bytes to own `repl_buffer_blocks` |
| 21 | `replconfCommand` | `replication.c:1446` | Master receives `REPLCONF ACK <offset>`; sets `c->repl_ack_off` (:1494) |
| 22 | `replicationCron` | `replication.c:4937` | Every 100ms: replica sends ACK; master checks timeouts, sends PING |
| 23 | `waitCommand` | `replication.c:4754` | Block client until N replicas ACK offset |
| 24 | `replicationCountAcksByOffset` | `replication.c:4720` | Count slaves where `repl_ack_off >= target_offset` |
| 25 | `masterTryPartialResynchronization` | `replication.c:985` | PSYNC: check backlog range, seek via `blocks_index` rax, stream |
| 26 | `syncWithMaster` | `replication.c:3071` | Replica handshake state machine (`REPL_STATE_*`) |
| 27 | `readSyncBulkPayload` | `replication.c:2253` | Receive and load RDB during full sync |
