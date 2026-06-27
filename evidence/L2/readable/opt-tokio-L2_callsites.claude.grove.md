# transcript: Where is `Runtime` defined, and list every place it is referenced or called across the source tree, with file and line.

  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__callers,mcp__grove__definition,mcp__grove__source)

💬 Now let me search for `Runtime` definitions and all references simultaneously.
  ▸ mcp__grove__definition({"name":"Runtime","dir":"/home/bench/repos/tokio"})
  ▸ mcp__grove__callers({"name":"Runtime","dir":"/home/bench/repos/tokio"})

💬 Here are the results, organized by category.  ---  ## Definitions (2)  | File | Line | Declaration | |------|------|-------------| | `tokio/src/runtime/runti...

──────── RESULT (success, 58715ms, 4 turns) ────────
Here are the results, organized by category.

---

## Definitions (2)

| File | Line | Declaration |
|------|------|-------------|
| `tokio/src/runtime/runtime.rs` | 97 | `pub struct Runtime { … }` — the canonical public type |
| `tokio/src/runtime/tests/task.rs` | 384 | `struct Runtime(Arc<Inner>)` — test-only local mock |

---

## Source / library (`tokio/src/`)

**`runtime/runtime.rs`** — primary `impl` block and all methods  
`131` `impl Runtime`  
`136/137` `Runtime::from_parts` constructor  
`174` `pub fn new() -> io::Result<Runtime>`  
`502` `impl Drop for Runtime`  
`521/523` `impl UnwindSafe / RefUnwindSafe for Runtime`

**`runtime/builder.rs`**  
`5` import  
`1062` `Builder::build() -> io::Result<Runtime>`  
`1636/1642` `build_current_thread_runtime()` returns / constructs `Runtime`  
`1854/1906` `build_threaded_runtime()` returns `Runtime`

**`runtime/mod.rs`**  
`617` `pub use runtime::{Runtime, RuntimeFlavor, is_rt_shutdown_err}`

**`runtime/handle.rs`**  
`7/9/28/31` doc-comments linking to `Runtime::handle` / `Runtime::enter`  
`56/58/71–74/114/116` doc examples using `Runtime::new()`  
`249/253/257–261/332–334` doc-comments cross-linking `Runtime::block_on`, `shutdown_*`

**`runtime/tests/task.rs`**  
`336` `struct SpawnOnDrop(Runtime)` (the local test type)  
`361` `fn with(f: impl FnOnce(Runtime))`  
`372` `let rt = Runtime(Arc::new(…))`  
`388/392/395/437/455` fields and impls on the test `Runtime`

**`runtime/tests/loom_blocking.rs`** `1/135` import + `mk_runtime() -> Runtime`  
**`runtime/tests/loom_current_thread.rs`** `6/14` import + `assert_at_most_num_polls(rt: Arc<Runtime>)`  
**`runtime/tests/loom_multi_thread.rs`** `12/350` import + `mk_pool() -> Runtime`  
**`runtime/tests/loom_multi_thread/yield_now.rs`** `3/32` import + `mk_runtime() -> Runtime`  
**`runtime/tests/loom_current_thread/yield_now.rs`** `2/28` import + `mk_runtime() -> Runtime`  
**`runtime/tests/task_combinations.rs`** `203` field `rt: crate::runtime::Runtime`  
**`runtime/time/tests/mod.rs`** `35` `fn rt(start_paused: bool) -> crate::runtime::Runtime`  
**`runtime/metrics/runtime.rs`** `16/18/45/71/272/305/598/610` doc-comments

**`signal/windows/sys.rs`** `122/227` import + `fn rt() -> Runtime`  
**`signal/registry.rs`** `169/259` import + `fn rt() -> Runtime`

**`process/unix/pidfd_reaper.rs`** `218/222` import + `fn create_runtime() -> Runtime`

**`task/local.rs`** `58/86/123/221/623/630/633/649/652/667/673` doc-comments + `LocalSet::block_on(rt: &crate::runtime::Runtime, …)`  
**`task/spawn.rs`** `18/21/33` doc-comments  
**`task/blocking.rs`** `38/167` doc-comments

**`io/bsd/poll_aio.rs`** `124/134` doc-comments (`Runtime::enter`)  
**`io/poll_evented.rs`** `86/106` doc-comments  

**`net/tcp/listener.rs`** `241`, **`net/tcp/stream.rs`** `208`, **`net/udp.rs`** `208`  
**`net/unix/pipe.rs`** `66/228/254/393/418/473/493/941/966/1021/1041`  
**`net/unix/listener.rs`** `74/106/154`, **`net/unix/stream.rs`** `80/115/851`  
**`net/unix/datagram/socket.rs`** `466`  
**`net/windows/named_pipe.rs`** `123/126/996/999/2258/2261/2289/2292/2471/2485`  
— all doc-comments pointing to `Runtime::enter`

**`sync/mpsc/bounded.rs`** `402/412/1026/1036` doc-examples  
**`lib.rs`** `169` top-level doc-comment  
**`time/mod.rs`** `20`, **`time/clock.rs`** `327`

---

## Tests (`tokio/tests/`)

| File | Lines |
|------|-------|
| `rt_common.rs` | 15, 30, 46, 60–63, 72, 1095 |
| `rt_basic.rs` | 4, 474 |
| `rt_threaded.rs` | 885–886 |
| `rt_handle.rs` | 5, 121 |
| `rt_handle_block_on.rs` | 11, 24, 38, 57, 70, 84, 517, 526 |
| `rt_metrics.rs` | 6, 187, 220, 227 |
| `rt_unstable_metrics.rs` | 15, 827, 834, 842 |
| `rt_unstable_eager_driver_handoff.rs` | 85, 142 |
| `rt_panic.rs` | 8, 109 |
| `rt_shutdown_err.rs` | 9 |
| `rt_worker_index.rs` | 4, 62, 76 |
| `task_blocking.rs` | 86, 103, 121, 143, 155, 201 |
| `task_join_set.rs` | 10 |
| `task_local_set.rs` | 374, 690, 697, 803 |
| `task_id.rs` | 8, 211, 290 |
| `time_rt.rs` | 5, 11, 59, 62 |
| `time_alt.rs` | 4, 13 |
| `time_panic.rs` | 8, 16, 121, 137, 150 |
| `io_async_fd.rs` | 568 |
| `io_driver_drop.rs` | 55 |
| `io_panic.rs` | 141, 164, 186, 209 |
| `net_panic.rs` | 7, 191–192 |
| `sync_mpsc.rs` | 935, 960 |
| `sync_panic.rs` | 7, 229 |
| `async_send_sync.rs` | 560 |
| `signal_drop_rt.rs` | 11, 40 |
| `signal_multi_rt.rs` | 11, 50 |
| `process_change_of_runtime.rs` | 9, 13, 20 |
| `fs_uring.rs` | 19, 23, 33, 37, 50, 73, 89 |
| `fs_uring_read.rs` | 20, 24, 34, 38, 51, 94 |
| `fs_uring_file_read.rs` | 18, 21, 31, 35 |
| `fs_uring_statx.rs` | 23, 33, 43, 47, 64, 107 |

---

## Crates (`tokio-util/`, `tokio-macros/`, `tokio-test/`, `benches/`, `examples/`)

| File | Lines |
|------|-------|
| `tokio-util/src/context.rs` | 15, 22, 24–25, 65, 192 |
| `tokio-util/src/task/spawn_pinned.rs` | 400 |
| `tokio-util/tests/task_join_map.rs` | 12 |
| `tokio-util/tests/panic.rs` | 9, 237 |
| `tokio-macros/src/entry.rs` | 518, 527 |
| `tokio-macros/src/lib.rs` | 21–22, 45, 318–319, 383–384 |
| `tokio-test/src/lib.rs` | 24, 26 |
| `examples/custom-executor.rs` | 35 |
| `benches/remote_spawn.rs` | 17, 97 |
| `benches/spawn.rs` | 13, 19 |
| `benches/spawn_blocking.rs` | 9, 64 |
| `benches/rt_multi_threaded.rs` | 5, 250 |
| `benches/rt_current_thread.rs` | 5, 78 |
| `benches/sync_mpsc.rs` | 22 |
| `benches/sync_mpsc_oneshot.rs` | 2, 25 |
| `benches/sync_semaphore.rs` | 2, 8, 14 |
| `benches/sync_watch.rs` | 9 |
| `benches/sync_notify.rs` | 9 |
| `benches/sync_broadcast.rs` | 9 |
| `benches/time_timeout.rs` | 5, 14 |
| `benches/copy.rs` | 170 |
| `benches/fs.rs` | 14 |

---

**Summary:** `Runtime` is canonically defined at `tokio/src/runtime/runtime.rs:97`, with a test-local shadow at `tokio/src/runtime/tests/task.rs:384`. It is referenced at ~250+ distinct sites across `tokio/src/`, `tokio/tests/`, `tokio-util/`, `tokio-macros/`, `tokio-test/`, `benches/`, and `examples/`.
