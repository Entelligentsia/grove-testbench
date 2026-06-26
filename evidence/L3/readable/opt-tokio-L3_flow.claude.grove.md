# transcript: Trace how `tokio::spawn` schedules a future onto the multi-threaded runtime: name every function it passes through, in order, from the `spawn` call to the po...


💬 I'll load the grove tools first and then trace the full path.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__outline,mcp__grove__map)

💬 Now let me trace the path systematically, starting with `tokio::spawn`.
  ▸ mcp__grove__symbols({"dir":"tokio/src","name":"spawn","kind":"function"})
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/scheduler","kind":"function","name":"spawn"})
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__outline,mcp__grove__map,mcp__grove__definition)

💬 Good, tools are loaded. Let me trace the path layer by layer.
  ▸ mcp__grove__symbols({"dir":"tokio/src","name":"spawn","kind":"function"})
  ▸ mcp__grove__outline({"file":"tokio/src/task/spawn.rs"})
  ▸ Bash(find /home/bench/repos/tokio/tokio/src -name "spawn.rs" | head -20)
  ▸ Bash(ls /home/bench/repos/tokio/tokio/src/task/)

💬 Let me try grove with absolute paths.
  ▸ mcp__grove__outline({"file":"/home/bench/repos/tokio/tokio/src/task/spawn.rs"})
  ▸ mcp__grove__outline({"file":"/home/bench/repos/tokio/tokio/src/runtime/scheduler"})
  ▸ mcp__grove__map({"dir":"/home/bench/repos/tokio/tokio/src/task","name":"spawn"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/tokio/tokio/src/task","name":"spawn"})

💬 I see the task module has `spawn` but not the top-level free function. Let me find it.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/tokio/tokio/src","name":"spawn","kind":"function"})
  ▸ Read(/home/bench/repos/tokio/tokio/src/task)
  ▸ mcp__grove__outline({"file":"/home/bench/repos/tokio/tokio/src/task/mod.rs"})
  ▸ mcp__grove__outline({"file":"tokio/src/task/mod.rs"})
  ▸ mcp__grove__outline({"file":"tokio/src/lib.rs","detail":0})
  ▸ mcp__grove__source({"file":"tokio/src/lib.rs","name":"task"})
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/scheduler/multi_thread","kind":"function","name":"spawn"})
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/scheduler/multi_thread"})

💬 Now I have the skeleton of the multi-thread scheduler. Let me read the key functions in the spawn path.
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/handle.rs#spawn@55"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/handle.rs#bind_new_task@81"})

💬 Good. Now let me read the top-level `spawn` function body and the task system's `bind`.
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#schedule_task@1327"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#schedule_local@1353"})

💬 Now let me get `spawn_inner`, how the context dispatches to the scheduler, and how `run_task` finally polls.
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#run_task@630"})

💬 Now let me find how `context::with_current` → `handle.spawn` dispatches to the multi-thread variant.
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime","name":"spawn","kind":"method"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/context.rs","kind":"function","detail":0})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime","name":"with_current","kind":"function"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/scheduler/handle.rs","detail":0})
  ▸ mcp__grove__source({"file":"tokio/src/runtime/context/current.rs","name":"with_current"})
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/scheduler","name":"spawn"})

💬 Now I need the `scheduler::Handle::spawn` dispatcher and the `OwnedTasks::bind` function.
  ▸ mcp__grove__source({"file":"tokio/src/runtime/handle.rs","name":"spawn"})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/scheduler","name":"spawn"})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/scheduler","name":"spawn","kind":"method"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/scheduler/mod.rs","detail":0})
  ▸ mcp__grove__source({"file":"tokio/src/runtime/scheduler/mod.rs","name":"Handle"})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/context","name":"spawn"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/context/current.rs","detail":0})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime","name":"spawn","kind":"method"})

💬 I need to find where `scheduler::Handle::spawn` is implemented (the enum dispatch method).
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/scheduler","kind":"method","name":"spawn"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/scheduler/mod.rs"})

💬 The `spawn` impl on the `scheduler::Handle` enum must be elsewhere. Let me find it.
  ▸ Read(/home/bench/repos/tokio/tokio/src/runtime/scheduler/mod.rs)

💬 Now I have all the pieces for the scheduling path. Let me get `OwnedTasks::bind` and `task::run` to complete the polling end.
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/task","name":"bind","kind":"method"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#run@508"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/list.rs#bind@87"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#run@561"})

💬 Now let me get `new_task` and `task.run()` to see the final polling call.
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/task","name":"new_task"})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/task","name":"run","kind":"method"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/mod.rs#run@502"})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/task","name":"poll","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/task","name":"poll","kind":"method"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/raw.rs#poll@271"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/harness.rs#poll@153"})
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/task","name":"poll_inner","kind":"method"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/harness.rs#poll_inner@193"})

💬 I have the complete picture. Let me verify the final `poll_future` call to confirm where `Future::poll` is invoked.
  ▸ mcp__grove__symbols({"dir":"tokio/src/runtime/task","name":"poll_future"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/harness.rs#poll_future@521"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/core.rs#poll@362"})

💬 I now have the full call chain. Here is the complete trace from `tokio::spawn` to the first `Future::poll`, with every function in order.  ---  ## `tokio::sp...

──────── RESULT (success, 273261ms, 63 turns) ────────
I now have the full call chain. Here is the complete trace from `tokio::spawn` to the first `Future::poll`, with every function in order.

---

## `tokio::spawn` → first `Future::poll`: the complete call chain

The path splits in two phases: the **spawning thread** builds the task and enqueues it, then a **worker thread** dequeues it and polls it.

---

### Phase 1 — Spawning thread

**① `tokio::spawn(future)`**  
`tokio/src/task/spawn.rs:174`  
Checks `size_of::<F>()` against `BOX_FUTURE_THRESHOLD`; boxes the future if it's large. Then calls:

**② `spawn_inner(future, SpawnMeta)`**  
`tokio/src/task/spawn.rs:188`  
Allocates a `task::Id`, wraps the future in a tracing/instrumentation shim (`crate::util::trace::task`), then does:
```rust
context::with_current(|handle| handle.spawn(task, id, meta.spawned_at))
```

**③ `context::with_current(f)`**  
`tokio/src/runtime/context/current.rs:37`  
Reads the thread-local `CONTEXT` cell. If the calling thread is a worker (or inside `Runtime::block_on`), this yields the current `scheduler::Handle`. Calls `f(&handle)`.

**④ `scheduler::Handle::spawn(future, id, spawned_at)`**  
`tokio/src/runtime/scheduler/mod.rs:152`  
The `Handle` enum dispatches on flavor:
```rust
Handle::MultiThread(h) => multi_thread::Handle::spawn(h, future, id, spawned_at)
```

**⑤ `multi_thread::Handle::spawn(me, future, id, spawned_at)`**  
`tokio/src/runtime/scheduler/multi_thread/handle.rs:55`  
Thin forwarder — calls:

**⑥ `multi_thread::Handle::bind_new_task(me, future, id, spawned_at)`**  
`tokio/src/runtime/scheduler/multi_thread/handle.rs:81`  
Three things happen here:
1. `me.shared.owned.bind(future, me.clone(), id, spawned_at)` — allocates the task and returns `(JoinHandle, Option<Notified>)`.
2. `me.task_hooks.spawn(...)` — fires any registered spawn callbacks.
3. `me.schedule_option_task_without_yield(notified)` — enqueues the `Notified` token.

**⑦ `OwnedTasks::bind(task, scheduler, id, spawned_at)`**  
`tokio/src/runtime/task/list.rs:87`  
Calls `super::new_task(...)` — allocates the task on the heap with its type-erased vtable, producing a `Task`, a `Notified` token, and a `JoinHandle`. Then `bind_inner` registers it in the owned set (returns `None` if the runtime is shutting down).

**⑧ `Handle::schedule_option_task_without_yield(notified)`**  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:1347`  
Unwraps `Option<Notified>`, calls `schedule_task(task, is_yield=false)`.

**⑨ `Handle::schedule_task(task, is_yield=false)`**  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:1327`  
Uses `with_current(|maybe_cx| …)` to ask: *is the calling thread a worker of this exact runtime, and does it still hold its core?*

> **Path A — called from a worker thread** → `schedule_local(core, task, false)`  
> **Path B — called from outside** → `push_remote_task(task)` + `notify_parked_remote()`

**⑩-A `Handle::schedule_local(core, task, is_yield=false)`**  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:1353`  
With `is_yield=false` and LIFO enabled, places the task into `core.lifo_slot` (evicting any previous occupant to the run queue via `push_back_or_overflow`). Calls `notify_parked_local()` to wake an idle sibling if needed.

**⑩-B `Handle::push_remote_task(task)`**  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:1397`  
Locks the global inject queue (`shared.inject`) and pushes the task. Then `notify_parked_remote()` → `idle.worker_to_notify()` → `unparker.unpark()` — unblocks a sleeping OS thread.

---

### Phase 2 — Worker thread (the thread that polls)

**⑪ `run(worker: Arc<Worker>)`** ← entry point for each OS thread  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:508`  
Acquires the exclusive `Core` box (`worker.core.take()`), enters the runtime context with `context::enter_runtime`, sets the per-thread scheduler context with `context::set_scheduler`, then calls `cx.run(core)`.

**⑫ `Context::run(mut core: Box<Core>)`** ← the main worker loop  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:561`  
```
loop:
  core.tick()
  self.maintenance(core)
  if let Some(task) = core.next_task(&self.worker) → run_task
  else try steal_work → run_task
  else park / park_yield
```

**⑬ `Core::next_task(worker)` → `Core::next_local_task()`**  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:1062, 1132`  
Priority order: LIFO slot (`core.lifo_slot.take()`) → local run queue (`run_queue.pop()`) → global inject queue (`next_remote_task()`).  
For a freshly spawned task that went through Path A, the LIFO slot is checked first.

**⑭ `Context::run_task(task, core)`**  
`tokio/src/runtime/scheduler/multi_thread/worker.rs:630`  
- `shared.owned.assert_owner(task)` — promotes `Notified` to `LocalNotified` (proves this thread owns the task).  
- `core.transition_from_searching(&self.worker)` — exits work-stealing mode, potentially waking another worker.  
- `core.stats.start_poll()`  
- `*self.core.borrow_mut() = Some(core)` — parks the `Core` in a thread-local `RefCell` so re-entrant code (e.g. a nested spawn from within the task) can access it.  
- `coop::budget(|| task.run())` — runs under the cooperative-budgeting guard.

**⑮ `LocalNotified::run(self)`**  
`tokio/src/runtime/task/mod.rs:502`  
```rust
let raw = self.task.raw;
mem::forget(self);
raw.poll();
```

**⑯ `RawTask::poll(self)`**  
`tokio/src/runtime/task/raw.rs:271`  
```rust
(vtable.poll)(self.ptr)   // type-erased dispatch
```

**⑰ `Harness::<T, S>::poll(self)`** ← vtable target  
`tokio/src/runtime/task/harness.rs:153`  
Calls `self.poll_inner()`.

**⑱ `Harness::poll_inner(self)`**  
`tokio/src/runtime/task/harness.rs:193`  
- `self.state().transition_to_running()` — atomic CAS: marks the task `Running`.  
- `waker_ref::<S>(&header_ptr)` — constructs a `Waker` whose wake implementation re-enqueues this task as a `Notified`.  
- `Context::from_waker(&waker_ref)` — builds the standard `std::task::Context`.  
- `poll_future(self.core(), cx)`

**⑲ `poll_future(core, cx)`**  
`tokio/src/runtime/task/harness.rs:521`  
Wraps the call in `panic::catch_unwind` (panic isolation), then calls `core.poll(cx)`.

**⑳ `Core::poll(cx)`** ← **first `Future::poll`**  
`tokio/src/runtime/task/core.rs:362`  
```rust
let future = Pin::new_unchecked(future);
future.poll(&mut cx)         // ← user future polled here
```
Retrieves the future from the `Stage::Running` variant, pins it in place, and calls `Future::poll`. This is the first time the user's async code executes.

---

### Summary table

| # | Function | File |
|---|----------|------|
| 1 | `tokio::spawn` | `task/spawn.rs:174` |
| 2 | `spawn_inner` | `task/spawn.rs:188` |
| 3 | `context::with_current` | `runtime/context/current.rs:37` |
| 4 | `scheduler::Handle::spawn` | `runtime/scheduler/mod.rs:152` |
| 5 | `multi_thread::Handle::spawn` | `…/multi_thread/handle.rs:55` |
| 6 | `multi_thread::Handle::bind_new_task` | `…/multi_thread/handle.rs:81` |
| 7 | `OwnedTasks::bind` (→ `new_task`) | `runtime/task/list.rs:87` |
| 8 | `Handle::schedule_option_task_without_yield` | `…/multi_thread/worker.rs:1347` |
| 9 | `Handle::schedule_task` | `…/multi_thread/worker.rs:1327` |
| 10A | `Handle::schedule_local` (worker-thread path) | `…/multi_thread/worker.rs:1353` |
| 10B | `Handle::push_remote_task` (external path) | `…/multi_thread/worker.rs:1397` |
| 11 | `run(worker)` — OS thread entry | `…/multi_thread/worker.rs:508` |
| 12 | `Context::run` — main loop | `…/multi_thread/worker.rs:561` |
| 13 | `Core::next_task` / `next_local_task` | `…/multi_thread/worker.rs:1062` |
| 14 | `Context::run_task` | `…/multi_thread/worker.rs:630` |
| 15 | `LocalNotified::run` | `runtime/task/mod.rs:502` |
| 16 | `RawTask::poll` | `runtime/task/raw.rs:271` |
| 17 | `Harness::poll` (vtable) | `runtime/task/harness.rs:153` |
| 18 | `Harness::poll_inner` | `runtime/task/harness.rs:193` |
| 19 | `poll_future` | `runtime/task/harness.rs:521` |
| 20 | `Core::poll` → **`future.poll(&mut cx)`** | `runtime/task/core.rs:362` |

---

### Key design points visible in this trace

- **LIFO slot** (step 10A): when spawned from within a worker, the new task goes into `core.lifo_slot` rather than the back of the queue — it will be polled *before* the next task from the queue, exploiting cache locality at the cost of fairness (capped at `MAX_LIFO_POLLS_PER_TICK`).
- **Inject queue** (step 10B): tasks spawned from outside a worker (e.g. from `std::thread::spawn`) go through a global lock-protected inject queue; a parked worker OS thread is explicitly unparked.
- **`coop::budget`** (step 14): the polling call sits inside a cooperative budget scope so a task can't hog the thread by looping through many `.await` points without yielding.
- **Type erasure via vtable** (steps 16–17): the scheduler stores tasks as raw pointers + vtable, so `schedule_task` / `push_remote_task` are monomorphized-free at the cost of one indirect call per poll.
