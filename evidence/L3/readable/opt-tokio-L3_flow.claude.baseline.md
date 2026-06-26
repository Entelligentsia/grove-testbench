# transcript: Trace the full function call chain from `tokio::spawn` to the point where a worker thread first calls `poll` on the spawned task in the multi-threaded runtim...


💬 I'll explore the tokio source to trace the full call chain.
  ▸ Agent(Trace tokio::spawn to first poll in multi-thread runtime)
  ▸ Bash(find /home/bench/repos/tokio -type f -name "*.rs" | grep -E "(spawn|handle|worker|queue|harness)" | head -20)
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/context.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/context/current.rs)
  ▸ Bash(find /home/bench/repos/tokio/tokio/src/runtime -type f -name "*.rs" | grep -i scheduler)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Bash(grep -n "pub(super) struct Shared" /home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/harness.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/raw.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/raw.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/harness.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/harness.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle.rs)
  ▸ Bash(grep -n "schedule_option_task_without_yield\|schedule_task" /home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle.rs | head -20)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle/metrics.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle.rs)
  ▸ Bash(find /home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread -name "*.rs" -type f)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/inject.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/inject/rt_multi_thread.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle/taskdump.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/join.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/list.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/list.rs)

💬 Let me verify the key line numbers against the actual source before presenting this.
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/handle.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/harness.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/harness.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/mod.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/raw.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)

💬 Now let me check the context lookup and `OwnedTasks::bind`:
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/context/current.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/task/list.rs)
  ▸ Bash(grep -n "fn next_local_task\|lifo_slot\|fn next_task" /home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs | head -30)
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/multi_thread/worker.rs)

💬 I now have all the verified line numbers. Here is the complete, accurate trace:  ---  ## `tokio::spawn` → first `poll`: full call chain  There are two sub-pa...

──────── RESULT (success, 259916ms, 16 turns) ────────
I now have all the verified line numbers. Here is the complete, accurate trace:

---

## `tokio::spawn` → first `poll`: full call chain

There are two sub-paths depending on **where** spawn is called from. The split happens at step 11.

---

### Phase 1 — Allocate and register the task (same regardless of call site)

| # | Function | File | Line | What it does |
|---|----------|------|------|-------------|
| 1 | `spawn` | `tokio/src/task/spawn.rs` | 174 | Public entry point. Boxes the future if it exceeds `BOX_FUTURE_THRESHOLD`, then calls `spawn_inner`. |
| 2 | `spawn_inner` | `tokio/src/task/spawn.rs` | 188 | Allocates a `task::Id`, wraps the future in trace instrumentation, then calls `context::with_current(|handle| handle.spawn(...))`. |
| 3 | `context::with_current` | `tokio/src/runtime/context/current.rs` | 37 | Reads the thread-local `CONTEXT`, borrows the current `scheduler::Handle`, invokes the closure with it. |
| 4 | `scheduler::Handle::spawn` | `tokio/src/runtime/scheduler/mod.rs` | 152 | Enum-dispatch: matches `Handle::MultiThread(h)` and calls `multi_thread::Handle::spawn`. |
| 5 | `multi_thread::Handle::spawn` | `tokio/src/runtime/scheduler/multi_thread/handle.rs` | 55 | Thin wrapper; calls `Self::bind_new_task`. |
| 6 | `multi_thread::Handle::bind_new_task` | `tokio/src/runtime/scheduler/multi_thread/handle.rs` | 81 | Calls `owned.bind(...)`, fires the spawn hook, calls `schedule_option_task_without_yield`, returns the `JoinHandle`. |
| 7 | `OwnedTasks::bind` | `tokio/src/runtime/task/list.rs` | 87 | Calls `task::new_task` to heap-allocate the task (header + core + trailer), then calls `bind_inner`. |
| 8 | `OwnedTasks::bind_inner` | `tokio/src/runtime/task/list.rs` | 127 | Stamps the owner ID onto the task header, locks the shard, pushes the `Task` into the owned list. Returns `Some(Notified)` or `None` if the runtime is already shut down. |
| 9 | `Handle::schedule_option_task_without_yield` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 1347 | Unwraps `Option<Notified>` (None if runtime closed) and calls `schedule_task(task, false)`. |
| 10 | `Handle::schedule_task` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 1327 | Checks `with_current` for an active worker core on this scheduler. Branches: **local path** if on a worker thread, **remote path** if not. |

---

### Phase 2A — Remote path (spawn called from outside the runtime, e.g. `thread::spawn` or `Runtime::block_on`)

| # | Function | File | Line | What it does |
|---|----------|------|------|-------------|
| 11a | `Handle::push_remote_task` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 1397 | Locks `shared.synced`, calls `self.shared.inject.push(&mut synced.inject, task)` to enqueue into the global injection queue. |
| 12a | `Handle::notify_parked_remote` | `worker.rs` (called right after push) | ~1342 | Unparks a sleeping worker thread via the park mechanism (condvar / eventfd). |

### Phase 2B — Local path (spawn called from within an async task on the runtime, the common case)

| # | Function | File | Line | What it does |
|---|----------|------|------|-------------|
| 11b | `Handle::schedule_local` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 1353 | If not a yield and LIFO is enabled: places task in `core.lifo_slot`, displacing any prior occupant to the local run queue. If yielding or LIFO disabled: pushes to `core.run_queue` directly. |

---

### Phase 3 — Worker thread picks up and polls the task

These steps run on whichever worker thread picks up the work. For the remote path this may be a different thread than the spawner; for the LIFO-slot path it is typically the **same** thread on its very next task-selection pass.

| # | Function | File | Line | What it does |
|---|----------|------|------|-------------|
| 13 | `run` (free fn) | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 508 | Each worker thread's entry point (launched via `spawn_blocking`). Acquires the `Core`, sets up the `scheduler::Handle` in TLS via `enter_runtime`, installs the `scheduler::Context` via `set_scheduler`, calls `cx.run(core)`. |
| 14 | `Context::run` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 561 | Main `while !core.is_shutdown` loop. On each iteration: increments tick, runs maintenance, calls `core.next_task()`. |
| 15 | `Core::next_task` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 1062 | Every `global_queue_interval` ticks checks the inject queue first; otherwise tries local first. Calls `next_local_task()` or `handle.next_remote_task()`. |
| 16 | `Core::next_local_task` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 1132 | `self.lifo_slot.take().or_else(|| self.run_queue.pop())` — checks the LIFO slot first, then the per-worker local deque. |
| 16′ | `Handle::next_remote_task` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 1387 | (Inject-queue path) Quick empty check, then locks `shared.synced` and calls `inject.pop(&mut synced.inject)`. |
| 17 | `Context::run_task` | `tokio/src/runtime/scheduler/multi_thread/worker.rs` | 630 | Calls `owned.assert_owner(task)` to obtain a `LocalNotified`, transitions out of searching state, wraps the actual poll in `coop::budget(|| task.run())`. |
| 18 | `OwnedTasks::assert_owner` | `tokio/src/runtime/task/list.rs` | 152 | Debug-asserts the owner ID, converts `Notified<S>` → `LocalNotified<S>` (the type-system proof that this thread may poll the task). |
| 19 | `LocalNotified::run` | `tokio/src/runtime/task/mod.rs` | 502 | Extracts the `RawTask` and calls `raw.poll()`. |
| 20 | `RawTask::poll` | `tokio/src/runtime/task/raw.rs` | 271 | Reads the vtable pointer from the task header, calls `(vtable.poll)(self.ptr)` — an unsafe fn pointer call. |
| 21 | `raw::poll::<T,S>` (vtable fn) | `tokio/src/runtime/task/raw.rs` | 341 | Reconstructs `Harness::<T,S>::from_raw(ptr)`, calls `harness.poll()`. This is the monomorphized entrypoint that restores the concrete future type. |
| 22 | `Harness::poll` | `tokio/src/runtime/task/harness.rs` | 153 | Calls `self.poll_inner()` and dispatches on the result (schedule yield, mark complete, dealloc, or done). |
| 23 | `Harness::poll_inner` | `tokio/src/runtime/task/harness.rs` | 193 | Calls `state.transition_to_running()`, builds a `WakerRef` and `std::task::Context`, calls `poll_future(self.core(), cx)`. |
| 24 | `poll_future::<T,S>` | `tokio/src/runtime/task/harness.rs` | 521 | Calls `core.poll(cx)` inside `catch_unwind` — this resolves to `Pin::new_unchecked(&mut future).poll(cx)`. **The user's future is polled for the first time here.** |

---

### Key structural points

- **`Notified` vs `LocalNotified`**: `Notified<S>` is `Send` and lives in queues. `assert_owner` converts it to `LocalNotified<S>` which is `!Send` — this is the type-level gate that ensures only the owning runtime polls it.
- **LIFO slot**: New tasks spawned from a worker go into `core.lifo_slot` first (step 11b). On the very next `next_local_task()` call the LIFO slot is checked before the run queue, so freshly-spawned tasks typically get polled immediately by the same worker thread, exploiting cache locality.
- **Vtable**: `RawTask::poll` is an erased call through a function pointer baked in at task-allocation time (`raw::poll::<T,S>`). This is what lets the scheduler store heterogeneous `Box<dyn Future>`-equivalent tasks without actually boxing them — the concrete type is recovered inside the vtable fn at step 21.
- **`coop::budget`**: The poll at step 24 runs inside a cooperative-budgeting guard (set at step 17). If the budget is exhausted mid-poll, Tokio forces a yield to prevent task starvation.
