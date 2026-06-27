# transcript: Give a complete architectural walkthrough of how a tokio task lives from spawn to completion across the whole multi-threaded runtime — the cross-cutting sche...


💬 I'll start by loading the grove tool schemas, then systematically trace every subsystem the task touches.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me fan out across all the key subsystems in parallel.
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/scheduler"})
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/task"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/scheduler/multi_thread/mod.rs"})

💬 Good — I now have the full architectural map. Let me read the critical load-bearing implementations in parallel.
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/handle.rs#bind_new_task@81"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#schedule_task@1327"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#schedule_local@1353"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#run@561"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#run_task@630"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#park@810"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#park_internal@844"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#next_task@1062"})

💬 Now I need the spawn entry point, the parker, the I/O driver, and the waker path.
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/handle.rs#spawn@55"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/park.rs#park_timeout@85"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/park.rs#unpark@277"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#notify_parked_local@1441"})

💬 Now I need the I/O driver and the waker path.
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/driver.rs"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/park.rs#park_driver@228"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/harness.rs#poll@153"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/harness.rs#wake_by_val@68"})

💬 Now I need the I/O driver internals, the thread entry `run`, and the remaining waker/state pieces.
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/driver.rs#park@66"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/driver.rs#unpark@80"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#run@508"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/harness.rs#poll_inner@193"})

💬 One more layer — the I/O driver stack and task `complete`.
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/io"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/task/harness.rs#complete@331"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/scheduler/multi_thread/worker.rs#steal_work@1141"})

💬 Two final pieces — the I/O driver's `turn` loop and `ScheduledIo::wake`.
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#turn@179"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#wake@236"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#poll_readiness@303"})

💬 I now have everything needed. Here is the complete walkthrough.  ---  # Tokio Task Lifecycle: Multi-Thread Scheduler Architecture  ## Type glossary (before w...

──────── RESULT (success, 344164ms, 31 turns) ────────
I now have everything needed. Here is the complete walkthrough.

---

# Tokio Task Lifecycle: Multi-Thread Scheduler Architecture

## Type glossary (before we start)

| Type | File | Role |
|---|---|---|
| `Cell<T,S>` | `task/core.rs:126` | Heap allocation: `Header` + `Core<T,S>` + `Trailer` |
| `Header` | `task/core.rs:168` | vtable ptr, state `AtomicUsize`, intrusive-list pointers, owner-id |
| `Trailer` | `task/core.rs:201` | join waker slot + `TaskHarnessScheduleHooks` |
| `State` | `task/state.rs:6` | single `AtomicUsize` encoding RUNNING/NOTIFIED/COMPLETE/ref-count/… |
| `RawTask` | `task/raw.rs:20` | thin `NonNull<Header>` + static `Vtable` |
| `Task<S>` | `task/mod.rs:232` | owning wrapper around `RawTask` (ref-counted) |
| `Notified<S>` | `task/mod.rs:242` | `Task<S>` that has been put in the NOTIFIED state |
| `LocalNotified<S>` | `task/mod.rs:260` | `Notified` that has been proven to be on the owning thread |
| `OwnedTasks<S>` | `task/list.rs:58` | sharded linked-list of all live tasks owned by a scheduler |
| `Worker` | `worker.rs:99` | per-thread struct; `Arc` shared between the main loop and the handle |
| `Core` | `worker.rs:111` | mutable state owned by exactly one thread: `lifo_slot`, `run_queue`, `park`, … |
| `Shared` | `worker.rs:168` | data shared across all workers: `owned`, `inject`, `idle`, `remotes`, `config` |
| `Remote` | `worker.rs:228` | per-worker remote data: `Unparker` + `Steal<Arc<Handle>>` |
| `Local<T>` | `queue.rs:29` | 256-slot circular SPSC run queue (owned by one worker) |
| `Steal<T>` | `queue.rs:34` | clone of `Arc<Inner<T>>` that other workers use to steal from a `Local` |
| `Inject<T>` | `inject.rs:23` | lock-protected MPMC linked-list global queue |
| `Idle` | `idle.rs:9` | atomic counter of (num_searching, num_unparked); locked list of parked worker indices |
| `Parker` / `Unparker` | `park.rs:16/20` | per-worker park primitive wrapping either the I/O driver or a condvar |
| `io::Driver` | `io/driver.rs:25` | mio `Poll` loop; only one worker holds it at a time |
| `ScheduledIo` | `io/scheduled_io.rs:101` | per-fd readiness state + waker storage |

---

## Phase 1 — `tokio::spawn` → task allocation → initial queue placement

```
tokio::spawn(future)
  └─ runtime::Handle::spawn      (tokio/src/runtime/handle.rs)
       └─ scheduler::Handle::MultiThread(h) → h.spawn(future, id, spawned_at)
```

**`Handle::spawn`** — `scheduler/multi_thread/handle.rs:55`

```rust
pub(crate) fn spawn<F>(me: &Arc<Self>, future: F, id: task::Id, spawned_at: SpawnLocation)
    -> JoinHandle<F::Output>
{
    Self::bind_new_task(me, future, id, spawned_at)
}
```

**`Handle::bind_new_task`** — `handle.rs:81`

```rust
pub(super) fn bind_new_task<T>(me: &Arc<Self>, future: T, id: task::Id, spawned_at: SpawnLocation)
    -> JoinHandle<T::Output>
{
    // 1. Allocate Cell<T,S> on the heap; register in OwnedTasks; get back (JoinHandle, Option<Notified>)
    let (handle, notified) = me.shared.owned.bind(future, me.clone(), id, spawned_at);
    // 2. Call any spawn hook
    me.task_hooks.spawn(&TaskMeta { id, spawned_at, .. });
    // 3. Schedule the freshly notified task
    me.schedule_option_task_without_yield(notified);
    handle
}
```

**`OwnedTasks::bind`** — `task/list.rs:87` — allocates `Cell<T,S>` with `Box::new` via `RawTask::new`, pushes the `Task` into a shard of the sharded intrusive linked-list, sets the owner-id on the `Header`, and returns `(JoinHandle, Notified)`. The `State` starts as `NOTIFIED | ref_count=2` (one for the scheduler, one for the `JoinHandle`).

---

## Phase 2 — Routing the Notified task into the right queue

**`Handle::schedule_option_task_without_yield`** — `worker.rs:1347` — just calls:

**`Handle::schedule_task`** — `worker.rs:1327`

```rust
pub(super) fn schedule_task(&self, task: Notified, is_yield: bool) {
    with_current(|maybe_cx| {
        if let Some(cx) = maybe_cx {
            if self.ptr_eq(&cx.worker.handle) {           // same scheduler?
                if let Some(core) = cx.core.borrow_mut().as_mut() {  // thread owns Core?
                    self.schedule_local(core, task, is_yield);
                    return;
                }
            }
        }
        // Spawned from outside this scheduler (or from block_in_place context)
        self.push_remote_task(task);
        self.notify_parked_remote();
    });
}
```

### 2a — Local path (spawned from within a worker of this runtime)

**`Handle::schedule_local`** — `worker.rs:1353`

```
is_yield==true  ──► push to run_queue tail via push_back_or_overflow
lifo_enabled    ──► try LIFO slot:
                       old = lifo_slot.replace(task)
                       if old.is_some() → push old to run_queue tail
                    → if previous lifo_slot was occupied: should_notify=true
should_notify && core.park.is_some()  ──► notify_parked_local()
```

The **LIFO slot** (`core.lifo_slot: Option<Notified>`) is a single-slot cache for the most-recently-scheduled task. It gives cache-hot tasks priority and reduces latency in wakeup chains (e.g., a producer waking a consumer). It is capped by `MAX_LIFO_POLLS_PER_TICK` to prevent starvation (`lifo_enabled` flag, `worker.rs:769`).

**`Local::push_back_or_overflow`** — `queue.rs:188` — pushes to the circular `Local` buffer (256 slots). If the buffer is more than half full, `push_overflow` spills half the tasks atomically into the global `Inject` queue.

### 2b — Remote path (spawned from a different thread or scheduler)

**`Handle::push_remote_task`** — `worker.rs:1397` — locks `shared.synced` (a `Mutex<Synced>`) and calls `inject.shared.push(&mut synced.inject, task)`. The `Inject` queue is a lock-protected singly-linked list threaded through `Header::queue_next`.

**`Handle::notify_parked_remote`** — `worker.rs:1453`

```rust
fn notify_parked_remote(&self) {
    if let Some(index) = self.shared.idle.worker_to_notify(&self.shared) {
        self.shared.remotes[index].unpark.unpark(&self.driver);
    }
}
```

---

## Phase 3 — Worker parking, idle state machine, and unparking

### Idle state machine — `idle.rs`

`Idle` — `idle.rs:9` — holds:
- `State`: a single `AtomicUsize` packing `num_searching` (workers in work-steal mode) and `num_unparked` (workers not parked).
- `Synced.sleepers: Vec<usize>`: list of parked worker indices, behind `shared.synced` lock.

**`Idle::worker_to_notify`** — `idle.rs:51`

```rust
pub(super) fn worker_to_notify(&self, shared: &Shared) -> Option<usize> {
    if !self.notify_should_wakeup() { return None; }
    let mut synced = shared.synced.lock();
    synced.idle.sleepers.pop()   // picks the most-recently-parked worker (LIFO among sleepers)
}
```

**`notify_should_wakeup`** — `idle.rs:153` — only wakes if `num_searching == 0 && num_unparked < num_workers`, avoiding thundering herd.

### Unparking — `park.rs`

**`Unparker::unpark`** — `park.rs:125` → **`Inner::unpark`** — `park.rs:277`

```rust
fn unpark(&self, driver: &driver::Handle) {
    match self.state.swap(NOTIFIED, SeqCst) {
        EMPTY          => {}                    // was idle but not yet parked; NOTIFIED is enough
        NOTIFIED       => {}                    // already woken
        PARKED_CONDVAR => self.unpark_condvar(),  // ─► Condvar::notify_one
        PARKED_DRIVER  => driver.unpark(),        // ─► io::Handle::unpark ─► mio wakeup write
        _              => panic!(),
    }
}
```

**`driver::Handle::unpark`** — `runtime/driver.rs:80` — delegates to `io::Handle::unpark` (and `time::Handle::unpark` if the time feature is on), which writes to the mio `Waker` (an `eventfd` on Linux / pipe elsewhere), unblocking the `epoll_wait` / `kevent` call.

### Parker implementation — `park.rs`

Each `Core` owns a `Parker`. When a worker is about to park:

**`Context::park`** — `worker.rs:810`

```rust
fn park(&self, mut core: Box<Core>) -> Box<Core> {
    if core.transition_to_parked(&self.worker) {       // updates Idle state; pushes index into sleepers
        while !core.is_shutdown && !core.is_traced {
            core.stats.about_to_park();
            core = self.park_internal(core, None);     // actually sleeps
            core.stats.unparked();
            core.maintenance(&self.worker);
            if core.transition_from_parked(&self.worker) { break; }  // check if we won the race to wake up
        }
    }
    core
}
```

**`Context::park_internal`** — `worker.rs:844`

```rust
fn park_internal(&self, mut core: Box<Core>, duration: Option<Duration>) -> Box<Core> {
    let mut park = core.park.take().expect("park missing");
    *self.core.borrow_mut() = Some(core);              // release Core so run_task can use it during wakeup

    let had_driver = if let Some(timeout) = duration {
        park.park_timeout(&self.worker.handle.driver, timeout)
    } else {
        park.park(&self.worker.handle.driver)
    };

    self.defer.wake();                                  // flush deferred wakers accumulated during this park

    core = self.core.borrow_mut().take().expect("core missing");
    core.park = Some(park);
    core.had_driver = had_driver;
    // ...
    core
}
```

**`Parker::park_timeout`** — `park.rs:85`

```rust
pub(crate) fn park_timeout(&mut self, handle: &driver::Handle, duration: Duration) -> HadDriver {
    if let Some(mut driver) = self.inner.shared.driver.try_lock() {
        self.inner.park_driver(&mut driver, handle, Some(duration))   // wins I/O driver
    } else if !duration.is_zero() {
        self.inner.park_condvar(Some(duration));                      // uses condvar instead
        HadDriver::No
    } else {
        HadDriver::No
    }
}
```

Only **one worker at a time** holds the I/O driver (via `try_lock` on a `Mutex<Driver>`). All other parked workers sleep on a `Condvar`. This is the "I/O driver handoff" mechanism.

**`Inner::park_driver`** — `park.rs:228` — CAS `state: EMPTY → PARKED_DRIVER`, then calls `driver.park()` / `driver.park_timeout()`, which blocks in `mio::Poll::poll` (an `epoll_wait`/`kevent`/`IOCP` call). On return, CAS state back to `EMPTY`.

---

## Phase 4 — Worker main loop and task selection

### Thread entry point

**`fn run(worker: Arc<Worker>)`** — `worker.rs:508`

```rust
fn run(worker: Arc<Worker>) {
    let core = match worker.core.take() { Some(c) => c, None => return };
    let handle = scheduler::Handle::MultiThread(worker.handle.clone());
    crate::runtime::context::enter_runtime(&handle, true, |_| {
        let cx = Context { worker, core: RefCell::new(None), defer: Defer::new() };
        context::set_scheduler(&cx, || {
            assert!(cx.run(core).is_err());  // normal exit is Err(())
            cx.defer.wake();
        });
    });
}
```

### Main scheduler loop

**`Context::run`** — `worker.rs:561`

```
loop:
  core.tick()                          ← increment tick counter (wrapping u32)
  self.maintenance(core)               ← periodic: metrics submit, trace, timer checks
  if let Some(task) = core.next_task() → run_task(task, core)   [continue]
  // local queues exhausted
  if let Some(task) = core.steal_work() → run_task(task, core)
  else if !self.defer.is_empty() → park_yield(core)   ← yield, wake deferred wakers
  else                           → park(core)          ← fully sleep
```

### Task selection — `Core::next_task` — `worker.rs:1062`

```
if tick % global_queue_interval == 0:          ← fairness: drain global first every N ticks
    global_inject.pop() OR local.pop()
else:
    local lifo_slot → local run_queue pop
    if local empty AND inject non-empty:
        n = min(inject.len / num_workers + 1, remaining_slots, max_capacity/2)
        batch = inject.pop_n(n)
        first = batch.next()      ← returned immediately
        rest → local run_queue    ← prefetch
        return first
```

`global_queue_interval` is tuned dynamically by `Stats::tuned_global_queue_interval` (`stats.rs:55`) using an EWMA of scheduling batch times — workers that spend longer between global checks push tasks out to the inject queue more rarely.

**`Core::next_local_task`** — `worker.rs:1132` — checks `lifo_slot` first, then `run_queue.pop()`.

### Work stealing — `Core::steal_work` — `worker.rs:1141`

```rust
fn steal_work(&mut self, worker: &Worker) -> Option<Notified> {
    if !self.transition_to_searching(worker) { return None; }  // register as searching in Idle
    let start = self.rand.fastrand_n(num as u32) as usize;    // random starting victim
    for i in 0..num {
        let target = &worker.handle.shared.remotes[(start + i) % num];
        if let Some(task) = target.steal.steal_into(&mut self.run_queue, &mut self.stats) {
            return Some(task);
        }
    }
    worker.handle.next_remote_task()   // fallback: global inject
}
```

**`Steal::steal_into`** — `queue.rs:417` — reads the victim's `tail` atomically (unsynchronized fast-path read of its own `tail` is safe because only the owner writes `tail`), computes how many tasks to steal (≈ half), then CAS-loops on the packed `(steal_head, real_head)` field to atomically claim them, copying the `RawTask` pointers into the destination's run queue.

After stealing, `transition_from_searching` (`worker.rs:1179`) decrements the `num_searching` counter; if it hits zero and there is still work in other queues, `notify_parked_local` wakes another idle worker.

---

## Phase 5 — Running a task

**`Context::run_task`** — `worker.rs:630`

```rust
fn run_task(&self, task: Notified, mut core: Box<Core>) -> RunResult {
    let task = self.worker.handle.shared.owned.assert_owner(task);   // LocalNotified<S>
    let notified_parked = core.transition_from_searching(&self.worker);

    core.stats.start_poll();
    *self.core.borrow_mut() = Some(core);   // donate Core to context; allows nested schedule_local

    coop::budget(|| {
        task.run();    // ──► LocalNotified::run → Harness::poll

        loop {         // LIFO loop: keep running tasks from lifo_slot while budget remains
            let mut core = self.core.borrow_mut().take()?;
            let task = match core.lifo_slot.take() { Some(t) => t, None => { return Ok(core); } };
            if !coop::has_budget_remaining() {
                core.run_queue.push_back_or_overflow(task, ..);
                return Ok(core);
            }
            *self.core.borrow_mut() = Some(core);
            task.run();   // run LIFO task
        }
    })
}
```

**`LocalNotified::run`** — `task/mod.rs:502` → **`RawTask::poll`** (vtable dispatch) — `task/raw.rs:271` → **`Harness::<T,S>::poll`** — `task/harness.rs:153`

```rust
pub(super) fn poll(self) {
    match self.poll_inner() {
        PollFuture::Notified  => { self.core().scheduler.yield_now(Notified(self.get_new_task())); self.drop_reference(); }
        PollFuture::Complete  => { self.complete(); }
        PollFuture::Dealloc   => { self.dealloc(); }
        PollFuture::Done      => (),
    }
}
```

**`Harness::poll_inner`** — `task/harness.rs:193`

```rust
fn poll_inner(&self) -> PollFuture {
    match self.state().transition_to_running() {        // CAS: IDLE+NOTIFIED → RUNNING
        TransitionToRunning::Success => {
            let header_ptr = self.header_ptr();
            let waker_ref = waker_ref::<S>(&header_ptr);   // zero-copy Waker from raw pointer
            let cx = Context::from_waker(&waker_ref);
            let res = poll_future(self.core(), cx);         // Future::poll(pin_of_future, cx)

            if res == Poll::Ready(()) { return PollFuture::Complete; }

            match self.state().transition_to_idle() {   // CAS: RUNNING → IDLE (or RUNNING+NOTIFIED → RUNNING)
                TransitionToIdle::Ok          => PollFuture::Done,
                TransitionToIdle::OkNotified  => PollFuture::Notified,  // woken during this poll
                TransitionToIdle::OkDealloc   => PollFuture::Dealloc,
                TransitionToIdle::Cancelled   => { cancel_task(..); PollFuture::Complete }
            }
        }
        // ...
    }
}
```

The `State` machine (`task/state.rs`) is a single `AtomicUsize` with CAS loops. Key transitions:

| Transition | Old state | New state |
|---|---|---|
| `transition_to_running` | `IDLE+NOTIFIED` | `RUNNING` |
| `transition_to_idle` | `RUNNING` | `IDLE` |
| `transition_to_idle` (woken during poll) | `RUNNING+NOTIFIED` | `RUNNING` → yields `OkNotified` |
| `transition_to_notified_by_val` | `IDLE` | `IDLE+NOTIFIED` → schedules |
| `transition_to_notified_by_val` | `RUNNING` | `RUNNING+NOTIFIED` → defers |
| `transition_to_complete` | `RUNNING` | `COMPLETE` |

---

## Phase 6 — I/O blocking: suspending a task on readiness

When a task awaits a `TcpStream` read (for example), the future chain resolves to:

**`Registration::poll_read_ready`** — `io/registration.rs:109` → **`ScheduledIo::poll_readiness`** — `io/scheduled_io.rs:303`

```rust
pub(super) fn poll_readiness(&self, cx: &mut Context<'_>, direction: Direction) -> Poll<ReadyEvent> {
    let curr = self.readiness.load(Acquire);
    let ready = direction.mask() & Ready::from_usize(READINESS.unpack(curr));

    if ready.is_empty() && !is_shutdown {
        let mut waiters = self.waiters.lock();
        let waker_slot = match direction {
            Direction::Read  => &mut waiters.reader,    // one fast slot per direction
            Direction::Write => &mut waiters.writer,
        };
        match waker_slot {
            Some(w) => w.clone_from(cx.waker()),        // reuse allocation if same task
            None    => *waker_slot = Some(cx.waker().clone()),
        }
        // double-check under lock to avoid lost-wake race
        // ...
        Poll::Pending
    } else {
        Poll::Ready(ReadyEvent { tick, ready, is_shutdown })
    }
}
```

The waker stored here is the task's waker: a `RawWaker` whose data pointer is the `NonNull<Header>` and whose vtable calls `Harness::wake_by_val`.

`transition_to_idle` runs next (returning the task to IDLE state). The task is now suspended — no reference to it in any run queue.

---

## Phase 7 — I/O event arrives → task wakeup

### The driver loop

**`io::Driver::turn`** — `io/driver.rs:179`

```rust
fn turn(&mut self, handle: &Handle, max_wait: Option<Duration>) {
    handle.release_pending_registrations();
    self.poll.poll(&mut self.events, max_wait);    // epoll_wait / kevent (blocking)

    for event in self.events.iter() {
        let token = event.token();
        if token == TOKEN_WAKEUP { /* mio waker write; nothing else to do */ }
        else {
            let ready = Ready::from_mio(event);
            let io: &ScheduledIo = unsafe { &*token_to_ptr(token) };
            io.set_readiness(Tick::Set, |curr| curr | ready);   // atomic OR into readiness word
            io.wake(ready);                                       // drain waiters and call .wake()
        }
    }
}
```

**`ScheduledIo::wake`** — `io/scheduled_io.rs:236`

```rust
pub(super) fn wake(&self, ready: Ready) {
    let mut wakers = WakeList::new();
    let mut waiters = self.waiters.lock();

    if ready.is_readable() { if let Some(w) = waiters.reader.take() { wakers.push(w); } }
    if ready.is_writable() { if let Some(w) = waiters.writer.take() { wakers.push(w); } }

    // drain general interest list
    loop {
        let mut iter = waiters.list.drain_filter(|w| ready.satisfies(w.interest));
        while wakers.can_push() {
            match iter.next() { Some(waiter) => { wakers.push(waiter.waker.take()?); } None => break }
        }
        drop(waiters);
        wakers.wake_all();    // call Waker::wake() — releases lock first to avoid re-entrancy
        waiters = self.waiters.lock();
    }
    wakers.wake_all();
}
```

### Waker vtable → re-schedule

`Waker::wake()` dispatches through the vtable to `wake_by_val` in `task/waker.rs:93` → **`RawTask::wake_by_val`** — `task/harness.rs:68`

```rust
pub(super) fn wake_by_val(&self) {
    match self.state().transition_to_notified_by_val() {
        TransitionToNotifiedByVal::Submit    => { self.schedule(); self.drop_reference(); }
        TransitionToNotifiedByVal::Dealloc   => { self.dealloc(); }
        TransitionToNotifiedByVal::DoNothing => {}
    }
}
```

`transition_to_notified_by_val` (`state.rs:215`) CAS-loops:
- If `IDLE`: sets `NOTIFIED`, returns `Submit` → task goes back into a queue.
- If `RUNNING`: sets `RUNNING+NOTIFIED`, returns `DoNothing` → poll_inner will see it on `transition_to_idle` and re-schedule.
- If `COMPLETE`: returns `Dealloc`.

**`RawTask::schedule`** — `raw.rs:276` — calls vtable `schedule` fn → `unsafe fn schedule<S>` — `raw.rs:346` — which reconstructs a `Notified<S>` and calls `S::schedule(self, notified)`.

`S = Arc<Handle>`, so this lands at `<Arc<Handle> as Schedule>::schedule` — `handle.rs:110`:

```rust
fn schedule(&self, task: Notified<Self>) {
    self.schedule_task(task)   // ── back to Phase 2 ──►
}
```

The task is now back in the run queue (LIFO slot if woken by another task on the same worker, or inject queue if woken by the I/O driver thread).

---

## Phase 8 — Task completion and deallocation

When `Future::poll` returns `Poll::Ready(output)`, `poll_future` stores the output in `CoreStage` and returns `Poll::Ready(())`. `poll_inner` returns `PollFuture::Complete`. `Harness::poll` calls:

**`Harness::complete`** — `task/harness.rs:331`

```rust
fn complete(self) {
    let snapshot = self.state().transition_to_complete();  // clears RUNNING, sets COMPLETE

    if !snapshot.is_join_interested() {
        self.core().drop_future_or_output();    // JoinHandle dropped; throw away output
    } else if snapshot.is_join_waker_set() {
        self.trailer().wake_join();             // wake the task awaiting JoinHandle
        // ... manage JOIN_WAKER bit
    }

    let num_release = self.release();           // OwnedTasks::remove → shrinks ownership list

    if self.state().transition_to_terminal(num_release) {   // ref-count reaches zero?
        self.dealloc();                          // Box::from_raw → drop Cell<T,S>
    }
}
```

**`Trailer::wake_join`** — `core.rs:559` — calls `self.waker.wake_by_ref()` on the waker stored by `JoinHandle::poll` via `try_set_join_waker`. This wakes the task that was awaiting the join handle, re-scheduling it through the same waker → schedule path.

**`Harness::dealloc`** — `harness.rs:253` — reconstructs the `Box<Cell<T,S>>` from the raw pointer and drops it. The `Header` + `Core` + `Trailer` allocation is freed.

---

## Phase 9 — `JoinHandle` as a future

The `JoinHandle<T>` is itself a future. When awaited, `JoinHandle::poll` (`join.rs:327`) calls `Harness::try_read_output` → `can_read_output` (`harness.rs:420`):

- If `COMPLETE` is set → reads output from `CoreStage`, returns `Poll::Ready`.
- Otherwise → stores the calling task's waker into `Trailer.waker` via `set_join_waker`, returns `Poll::Pending`.

When the spawned task completes and calls `wake_join`, this waker fires, and the awaiting task gets re-scheduled.

---

## Unified architecture diagram

```
tokio::spawn(future)
        │
        ▼
Handle::spawn (handle.rs:55)
        │
        ▼
Handle::bind_new_task (handle.rs:81)
  │  OwnedTasks::bind (list.rs:87)
  │    allocates Box<Cell<T,S>>
  │    Header { vtable, State(NOTIFIED|rc=2), queue_next }
  │    Core   { stage: Future }
  │    Trailer{ join_waker, hooks }
  │    pushes into sharded OwnedTasks linked-list
  │    returns (JoinHandle, Notified)
  ▼
Handle::schedule_task (worker.rs:1327)
  │
  ├─[on worker thread of THIS scheduler]──────────────────────────────────────────────►
  │   Handle::schedule_local (worker.rs:1353)                                          │
  │     if is_yield OR !lifo_enabled:                                                  │
  │       Local::push_back_or_overflow ──[queue full?]──► push_overflow → Inject      │
  │     else:                                                                          │
  │       old = lifo_slot.replace(task)     ◄── "hot slot" for wakeup chains          │
  │       if old.is_some(): push old to run_queue                                     │
  │     if should_notify: notify_parked_local()                                       │
  │                                                                                    │
  └─[external / different scheduler]──────────────────────────────────────────────────►
      Handle::push_remote_task (worker.rs:1397)                                        │
        lock(synced) → Inject::push (inject/shared.rs:68)                             │
      Handle::notify_parked_remote (worker.rs:1453)                                    │
        Idle::worker_to_notify (idle.rs:51)                                            │
          ─[notify_should_wakeup: num_searching==0 && num_unparked < num_workers]─►   │
          sleepers.pop() → index                                                        │
        remotes[index].unpark.unpark(&driver)                                          │
          Inner::unpark (park.rs:277)                                                  │
            swap(NOTIFIED, SeqCst)                                                     │
            PARKED_CONDVAR ──► Condvar::notify_one                                     │
            PARKED_DRIVER  ──► driver::Handle::unpark (driver.rs:80)                  │
                                 io::Handle::unpark ──► mio::Waker::wake()             │
                                 (writes to eventfd / pipe → unblocks epoll_wait)      │
                                                                                        │
◄──────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────── WORKER THREAD (one of N) ─────────────────────────────────────┐
│                                                                                         │
│  fn run(Arc<Worker>) (worker.rs:508)                                                    │
│    enter_runtime context                                                                │
│    Context { worker, core: RefCell<None>, defer: Defer }                               │
│    cx.run(core)  (worker.rs:561)                                                        │
│    ┌─────────────────────────── MAIN LOOP ─────────────────────────────────────────┐   │
│    │ loop {                                                                         │   │
│    │   core.tick()          ← wrapping tick counter                                │   │
│    │   maintenance(core)    ← metrics, tracing, timer checks                       │   │
│    │                                                                                │   │
│    │   Core::next_task (worker.rs:1062)                                            │   │
│    │   ┌─ every global_queue_interval ticks:                                       │   │
│    │   │    inject.pop() OR run_queue.pop()   [fairness]                           │   │
│    │   └─ otherwise:                                                               │   │
│    │        lifo_slot.take()                  [hottest, lowest latency]            │   │
│    │        OR run_queue.pop()               [FIFO from local 256-slot ring]       │   │
│    │        OR inject batch-pull (pop_n)     [fairness refill]                     │   │
│    │                                                                                │   │
│    │   if task found ──► run_task(task, core)                                      │   │
│    │       assert_owner → LocalNotified                                            │   │
│    │       transition_from_searching                                               │   │
│    │       *self.core.borrow_mut() = Some(core)   ← donate Core                   │   │
│    │       coop::budget(|| {                                                       │   │
│    │           task.run() ──► LocalNotified::run (mod.rs:502)                     │   │
│    │                    ──► RawTask::poll [vtable] (raw.rs:271)                   │   │
│    │                    ──► Harness::poll (harness.rs:153)                        │   │
│    │                    ──► Harness::poll_inner (harness.rs:193)                  │   │
│    │                         state.transition_to_running()  [CAS]                 │   │
│    │                         waker_ref from Header ptr (waker.rs:16)              │   │
│    │                         Future::poll(cx)  ──── awaits I/O? → Phase 6 ──►    │   │
│    │                         state.transition_to_idle()    [CAS]                  │   │
│    │           LIFO loop: check lifo_slot, run while budget remains               │   │
│    │       })                                                                       │   │
│    │       continue;                                                                │   │
│    │                                                                                │   │
│    │   // no local work                                                             │   │
│    │   Core::steal_work (worker.rs:1141)                                           │   │
│    │     transition_to_searching (Idle atomic)                                     │   │
│    │     for victim in random_order(remotes):                                      │   │
│    │       Steal::steal_into(&mut run_queue)  ← CAS half of victim's tasks        │   │
│    │     fallback: inject.pop()                                                    │   │
│    │                                                                                │   │
│    │   if stolen ──► run_task(...)                                                  │   │
│    │   else if defer non-empty ──► park_yield   (flush deferred wakers, re-check) │   │
│    │   else ──► park(core)                                                         │   │
│    │       Core::transition_to_parked → Idle::transition_worker_to_parked         │   │
│    │         updates State atomic; pushes index into sleepers list                 │   │
│    │       park_internal(core, None) (worker.rs:844)                               │   │
│    │         core.park.take()   ← removes Parker from Core                        │   │
│    │         *self.core = Some(core)   ← release Core                             │   │
│    │         Parker::park(&driver) (park.rs:76)                                   │   │
│    │           try_lock(shared.driver):                                            │   │
│    │             Ok  → park_driver → io::Driver::park → Driver::turn              │   │
│    │                    mio::Poll::poll(events, None)   [BLOCKS on epoll/kqueue]   │   │
│    │             Err → park_condvar   [BLOCKS on Condvar::wait]                    │   │
│    │         ← woken by unpark or I/O event                                        │   │
│    │         self.defer.wake()   ← call any deferred wakers                       │   │
│    │         Core::transition_from_parked                                          │   │
│    │ }                                                                              │   │
│    └────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────── I/O DRIVER (held by one worker at a time) ─────────────────────┐
│                                                                                          │
│  io::Driver::turn (io/driver.rs:179)                                                     │
│    mio::Poll::poll(events, timeout)   ← epoll_wait / kevent / IOCP                      │
│    for event in events:                                                                  │
│      TOKEN_WAKEUP  → skip (was unpark write)                                            │
│      TOKEN_SIGNAL  → signal_ready = true                                                │
│      else:                                                                               │
│        let io: &ScheduledIo = token_to_ptr(event.token())   ← pointer cast, safe (Arc) │
│        io.set_readiness(Tick::Set, |r| r | ready)   ← atomic OR into readiness word    │
│        io.wake(ready)  (scheduled_io.rs:236)                                            │
│          lock(waiters)                                                                   │
│          drain reader/writer fast slots + interest list matching ready bits             │
│          for each waker: drop(lock); waker.wake_all()                                  │
│             │                                                                            │
│             ▼                                                                            │
│        wake_by_val (harness.rs:68)                                                      │
│          state.transition_to_notified_by_val()   [CAS]                                 │
│            IDLE → IDLE+NOTIFIED → Submit → RawTask::schedule                           │
│            RUNNING → RUNNING+NOTIFIED → DoNothing (poll_inner will re-schedule)        │
│          schedule → Arc<Handle>::schedule → Handle::schedule_task                       │
│            ──► back into queue routing (Phase 2)                                        │
└──────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────── TASK COMPLETION ───────────────────────────────────────────────────────┐
│                                                                                          │
│  Future::poll returns Poll::Ready(output)                                               │
│    poll_future stores output in CoreStage::Finished(output)                             │
│    poll_inner → PollFuture::Complete → Harness::complete (harness.rs:331)              │
│      state.transition_to_complete()   ← sets COMPLETE, clears RUNNING                  │
│      if join_waker_set: Trailer::wake_join (core.rs:559)                               │
│         → wakes the task that awaited JoinHandle                                        │
│      OwnedTasks::remove   ← unlinks from sharded ownership list                        │
│      state.transition_to_terminal(num_release)   ← dec ref-count                       │
│        if reaches zero: Harness::dealloc   ← Box::from_raw, drop Cell<T,S>             │
│                                                                                          │
│  JoinHandle<T>: Future::poll (join.rs:327)                                              │
│    Harness::try_read_output                                                             │
│      COMPLETE set → take_output from CoreStage → Poll::Ready(Ok(output))               │
│      not yet     → set_join_waker(cx.waker()) → Poll::Pending                          │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## End-to-end function call chain (chronological)

```
tokio::spawn
  Handle::spawn                              handle.rs:55
  Handle::bind_new_task                      handle.rs:81
    OwnedTasks::bind                         task/list.rs:87
      OwnedTasks::bind_inner                 task/list.rs:127
        RawTask::new → Box<Cell<T,S>>        task/raw.rs:211
    task_hooks.spawn()
  Handle::schedule_option_task_without_yield worker.rs:1347
  Handle::schedule_task                      worker.rs:1327
    with_current(...)
    ├─ [local]  Handle::schedule_local       worker.rs:1353
    │     Local::push_back_or_overflow       queue.rs:188
    │       Local::push_overflow → Inject    queue.rs:253  [if full]
    │     Handle::notify_parked_local        worker.rs:1441
    │       Idle::worker_to_notify           idle.rs:51
    │       Unparker::unpark                 park.rs:125
    │       Inner::unpark                    park.rs:277
    │         driver::Handle::unpark         runtime/driver.rs:80
    │           io::Handle::unpark           io/driver.rs:258
    └─ [remote] Handle::push_remote_task     worker.rs:1397
                  Inject::push               inject/shared.rs:68
                Handle::notify_parked_remote worker.rs:1453

--- WORKER THREAD ---
fn run(Arc<Worker>)                          worker.rs:508
  Context::run(core)                         worker.rs:561
    Core::tick                               worker.rs:1057
    Context::maintenance                     worker.rs:780
    Core::next_task                          worker.rs:1062
      Core::next_local_task                  worker.rs:1132
        lifo_slot.take()  OR  Local::pop     queue.rs:361
      Handle::next_remote_task               worker.rs:1387
        Inject::pop                          inject.rs:61
    Context::run_task                        worker.rs:630
      OwnedTasks::assert_owner               task/list.rs:152
      Core::transition_from_searching        worker.rs:1179
      coop::budget(|| task.run())
        LocalNotified::run                   task/mod.rs:502
          RawTask::poll [vtable]             task/raw.rs:271
            Harness::poll                    task/harness.rs:153
              Harness::poll_inner            task/harness.rs:193
                State::transition_to_running task/state.rs:117
                waker_ref(header_ptr)        task/waker.rs:16
                poll_future(core, cx)        task/harness.rs:521
                  Future::poll(pin, cx)
                  ─── if Pending ────────────────────────────────────────────►
                  ScheduledIo::poll_readiness io/scheduled_io.rs:303
                    waiters.reader = cx.waker().clone()
                    Poll::Pending
                  State::transition_to_idle  task/state.rs:151
              ─── if Ready ──────────────────────────────────────────────────►
              Harness::complete              task/harness.rs:331
                State::transition_to_complete task/state.rs:184
                Trailer::wake_join           task/core.rs:559
                OwnedTasks::remove           task/list.rs:202
                State::transition_to_terminal task/state.rs:198
                Harness::dealloc             task/harness.rs:253

    ─── if no work ───────────────────────────────────────────────────────────►
    Core::steal_work                         worker.rs:1141
      Core::transition_to_searching          worker.rs:1171
      Steal::steal_into                      queue.rs:417
        Steal::steal_into2                   queue.rs:472  [CAS half of victim's queue]
    Context::park                            worker.rs:810
      Core::transition_to_parked             worker.rs:1204
        Idle::transition_worker_to_parked    idle.rs:86
      Context::park_internal                 worker.rs:844
        Parker::park / park_timeout          park.rs:76 / 85
          Inner::park_driver                 park.rs:228
            CAS EMPTY→PARKED_DRIVER
            io::Driver::park_timeout         io/driver.rs:164
              Driver::turn                   io/driver.rs:179
                mio::Poll::poll(max_wait)    ← BLOCKS
                ScheduledIo::set_readiness   io/scheduled_io.rs:207
                ScheduledIo::wake            io/scheduled_io.rs:236
                  Waker::wake()
                    wake_by_val              task/harness.rs:68
                      State::transition_to_notified_by_val  task/state.rs:215
                      RawTask::schedule      task/raw.rs:276
                        Arc<Handle>::schedule task/mod.rs:???
                          Handle::schedule_task  worker.rs:1327  ← re-enters Phase 2
          OR Inner::park_condvar             park.rs:158
               Condvar::wait / wait_timeout
        Defer::wake()
        Core::transition_from_parked         worker.rs:1231
```

---

## Key invariants to remember

1. **Exactly one thread owns `Core` at a time.** During `run_task`, `Core` is moved into `self.core: RefCell<Option<Box<Core>>>` so that nested `schedule_local` calls (from inside `Future::poll`) can access it. If `block_in_place` is called, it removes `Core` and parks it in a new thread, leaving the current thread core-less.

2. **LIFO slot is a single-element hot-path cache.** It holds the most-recently-woken task (typically the consumer in a producer–consumer pair). `lifo_enabled` is disabled after `MAX_LIFO_POLLS_PER_TICK` consecutive LIFO runs to prevent starvation.

3. **Only one worker drives I/O at a time.** The `Mutex<Driver>` in `Parker::Shared` ensures this. Losers fall back to `Condvar::wait`. The winning parker wakes the others via `notify_parked_local` after re-acquiring `Core` when there is pending work.

4. **The `State` word encodes six logical fields atomically** — RUNNING, NOTIFIED, CANCELLED, COMPLETE, JOIN_INTERESTED, JOIN_WAKER, and a ref-count — all manipulated with `compare_exchange` CAS loops. No separate lock protects task state.

5. **`ScheduledIo` wakers are stored under a `Mutex<Waiters>`, but `wake_all` is called after dropping the lock** to avoid re-entrancy: a task's `wake()` leads back to `schedule_task`, which could try to lock the same mutex if not careful.
