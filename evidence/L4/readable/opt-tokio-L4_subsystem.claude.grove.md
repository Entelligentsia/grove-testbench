# transcript: Give the complete end-to-end picture of tokio's I/O driver (reactor) subsystem: how an I/O resource registers its interest, how the driver parks on the OS po...


💬 I'll load the grove tools first, then systematically map the I/O driver subsystem.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me explore the I/O driver subsystem systematically. I'll start with the high-level map of the runtime and I/O directories simultaneously.
  ▸ mcp__grove__map({"dir":"tokio/src/runtime/io"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/io/mod.rs"})

💬 Good map. Now let me fetch all the key method bodies in parallel.
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#new@117"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#turn@179"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#add_source@266"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#park@159"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#shutdown@169"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#set_readiness@207"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#wake@236"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#poll_readiness@303"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#poll@427"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/registration.rs#new_with_interest_and_handle@73"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/registration.rs#poll_ready@144"})

💬 Now let me fetch the struct definitions and a few more key methods:
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#ScheduledIo@101"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#Waiters@111"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/registration_set.rs#allocate@56"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/registration.rs#poll_io@162"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#Driver@25"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#Handle@37"})

💬 Let me get the remaining pieces: token encoding, Registration struct, unpark, clear_readiness, and how a real I/O type uses Registration:
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#token@187"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#clear_readiness@357"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#unpark@258"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#deregister_source@293"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#park_timeout@164"})
  ▸ mcp__grove__outline({"file":"tokio/src/runtime/io/registration.rs"})

💬 Now let me get the Registration struct and a concrete user (TcpStream):
  ▸ mcp__grove__source({"file":"tokio/src/runtime/io/registration.rs","name":"Registration"})
  ▸ mcp__grove__outline({"file":"tokio/src/net/tcp/stream.rs","detail":0})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#readiness_fut@390"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/registration_set.rs#RegistrationSet@13"})

💬 Let me get the TcpStream struct, its `new` method, and the concrete poll implementations:
  ▸ mcp__grove__source({"file":"tokio/src/net/tcp/stream.rs","name":"TcpStream"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/net/tcp/stream.rs#new@163"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/net/tcp/stream.rs#poll_read_priv@1436"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/registration.rs#readiness@204"})

💬 Now let me find and read `PollEvented`, the bridge layer:
  ▸ mcp__grove__symbols({"dir":"tokio/src/io","name":"PollEvented"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/scheduled_io.rs#Waiter@123"})
  ▸ mcp__grove__symbols({"dir":"tokio/src","name":"PollEvented"})
  ▸ Bash(find /home/bench/repos/tokio -name "poll_evented.rs" 2>/dev/null; grep -rn "PollEvented" /home/bench/repos/tokio/tokio/src --include="*.rs" -l 2>/dev/null | ...)
  ▸ mcp__grove__symbols({"dir":"tokio/src","name":"PollEvented","nameContains":true})
  ▸ mcp__grove__map({"dir":"tokio/src/io/poll_evented.rs"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/io/poll_evented.rs#new_with_interest_and_handle@115"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/io/poll_evented.rs#new@89"})
  ▸ mcp__grove__source({"file":"tokio/src/io/poll_evented.rs","name":"PollEvented"})
  ▸ Read(tokio/src/io/poll_evented.rs)
  ▸ mcp__grove__source({"id":"rust:tokio/src/io/poll_evented.rs#new_with_interest@110"})

💬 Let me get the `AsyncRead`/`AsyncWrite` impl for `PollEvented` and the `release_pending_registrations` method:
  ▸ Read(tokio/src/io/poll_evented.rs)
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/driver.rs#release_pending_registrations@314"})
  ▸ mcp__grove__source({"id":"rust:tokio/src/runtime/io/registration_set.rs#Synced@17"})

💬 One final read to get the `poll_read` entry point in `PollEvented`:
  ▸ Read(tokio/src/io/poll_evented.rs)
  ▸ Read(tokio/src/runtime/io/scheduled_io.rs)

💬 I now have everything needed. Here is the complete end-to-end picture.  ---  # Tokio I/O Driver (Reactor) — Complete Subsystem Reference  ## Key types and fi...

──────── RESULT (success, 234327ms, 51 turns) ────────
I now have everything needed. Here is the complete end-to-end picture.

---

# Tokio I/O Driver (Reactor) — Complete Subsystem Reference

## Key types and files

| Type | File | Role |
|---|---|---|
| `Driver` | `tokio/src/runtime/io/driver.rs:25` | Owns `mio::Poll` + `mio::Events`; runs the poll loop |
| `Handle` | `tokio/src/runtime/io/driver.rs:37` | Shared ref to the driver; owns `mio::Registry`, `mio::Waker`, `RegistrationSet` |
| `RegistrationSet` | `tokio/src/runtime/io/registration_set.rs:13` | Just holds `AtomicUsize num_pending_release`; all real state is in `Synced` |
| `Synced` | `tokio/src/runtime/io/registration_set.rs:17` | Mutex-guarded: `LinkedList<Arc<ScheduledIo>>` of live registrations + `Vec` of pending-release |
| `ScheduledIo` | `tokio/src/runtime/io/scheduled_io.rs:101` | One per live fd. Cache-line padded. Holds `readiness: AtomicUsize` + `waiters: Mutex<Waiters>` |
| `Waiters` | `tokio/src/runtime/io/scheduled_io.rs:111` | `reader: Option<Waker>`, `writer: Option<Waker>`, `list: LinkedList<Waiter>` |
| `Waiter` | `tokio/src/runtime/io/scheduled_io.rs:123` | Intrusive list node: `waker`, `interest`, `is_ready`, `PhantomPinned` |
| `Readiness<'a>` | `tokio/src/runtime/io/scheduled_io.rs:147` | Future returned by `readiness_fut`; owns the `Waiter` node inline |
| `Registration` | `tokio/src/runtime/io/registration.rs` | User-facing: `scheduler::Handle` + `Arc<ScheduledIo>` (as `shared`) |
| `PollEvented<E>` | `tokio/src/io/poll_evented.rs:66` | Wraps any `mio::event::Source E` + `Registration`; provides `poll_read`/`poll_write` |
| `ReadyEvent` | `tokio/src/runtime/io/driver.rs:74` | Token returned to callers: `{tick: u8, ready: Ready, is_shutdown: bool}` |

### The `readiness` word

`ScheduledIo::readiness` is a single `AtomicUsize` packing three fields via `bit`:

```
┌──────────┬──────────┬────────────────────┐
│ SHUTDOWN │  TICK    │    READINESS bits  │
│  1 bit   │  8 bits  │  readable/writable │
│          │ (wraps)  │  HUP / ERROR / ... │
└──────────┴──────────┴────────────────────┘
```

The **tick** is the stale-clear guard: `set_readiness(Tick::Set, …)` increments it; `clear_readiness(event)` uses `Tick::Clear(event.tick)` and is a no-op if the current tick has already moved past the event's tick (preventing a `WouldBlock` from clearing a *newer* readiness event).

---

## Path 1 — Registration: I/O resource registers interest

```
TcpStream::new(mio::net::TcpStream)                         net/tcp/stream.rs:163
 └─ PollEvented::new(io)                                    io/poll_evented.rs:89
     └─ PollEvented::new_with_interest(io, RD|WR)          io/poll_evented.rs:110
         └─ PollEvented::new_with_interest_and_handle(      io/poll_evented.rs:115
              io, interest, scheduler::Handle::current())
             └─ Registration::new_with_interest_and_handle( runtime/io/registration.rs:73
                  &mut io, interest, handle)
                 └─ handle.driver().io().add_source(         runtime/io/driver.rs:266
                       source, interest)
                    ├─ RegistrationSet::allocate(            registration_set.rs:56
                    │     &mut synced)
                    │    └─ Arc::new(ScheduledIo::default()) scheduled_io.rs:177
                    │         // pushed to synced.registrations (LinkedList)
                    ├─ scheduled_io.token()                  scheduled_io.rs:187
                    │    └─ mio::Token(
                    │         EXPOSE_IO.expose_provenance(self))
                    │       // Token IS the raw *const ScheduledIo as usize
                    └─ self.registry.register(               // mio → epoll_ctl(ADD) / kevent ADD
                            source, token, interest.to_mio())
```

The `ScheduledIo *` is stored directly as the mio token. The `Arc` inside `Synced::registrations` keeps the object alive until explicit deregistration.

---

## Path 2 — Parking: driver blocks on the OS poller

```
[scheduler runs out of runnable tasks]
 └─ Driver::park(&mut self, rt_handle)                     driver.rs:159
     └─ Driver::turn(handle, None)                         driver.rs:179
         ├─ handle.release_pending_registrations()         driver.rs:314
         │    └─ RegistrationSet::needs_release()          registration_set.rs:52
         │        └─ if true: RegistrationSet::release(    registration_set.rs:104
         │                     &mut synced)
         │              // drains synced.pending_release Vec,
         │              // dropping Arc<ScheduledIo> — safe because
         │              // driver thread is the only one touching events
         └─ mio::Poll::poll(&mut self.events, max_wait)
              // BLOCKS in epoll_wait() / kevent() / etc.
              // returns when: event fires, timeout expires,
              //   or mio::Waker writes to the wakeup fd
```

`park_timeout(duration)` at `driver.rs:164` is identical but passes `Some(duration)`.

---

## Path 3 — Event dispatch: mio fires → task woken

Still inside `Driver::turn`, after `mio::Poll::poll` returns:

```
for event in self.events.iter():
 │
 ├─ token == TOKEN_WAKEUP
 │    └─ skip (used only to unblock the poll; no I/O to dispatch)
 │
 ├─ token == TOKEN_SIGNAL
 │    └─ self.signal_ready = true
 │
 └─ [user I/O token]:
      ├─ Ready::from_mio(event)
      │    // translate mio flags → Ready bitset
      ├─ ptr = EXPOSE_IO.from_exposed_addr(token.0)
      │    // recover *const ScheduledIo from token
      ├─ io: &ScheduledIo = &*ptr
      │    // SAFETY: Arc in synced.registrations keeps it alive;
      │    // no free can race because deregister puts ScheduledIo
      │    // in pending_release (freed only by THIS call above)
      ├─ io.set_readiness(Tick::Set,                    scheduled_io.rs:207
      │     |curr| curr | ready)
      │    └─ AtomicUsize::fetch_update(AcqRel, Acquire, …)
      │         // atomically: tick.wrapping_add(1), ready |= new bits
      └─ io.wake(ready)                                 scheduled_io.rs:236
           ├─ lock self.waiters
           ├─ if readable: take waiters.reader Waker → WakeList
           ├─ if writable: take waiters.writer Waker → WakeList
           ├─ drain waiters.list where w.interest.satisfies(ready)
           │    // for each matching Waiter:
           │    //   waiter.is_ready = true
           │    //   take waiter.waker → WakeList
           ├─ drop lock
           └─ WakeList::wake_all()
                └─ Waker::wake() per entry
                     // posts task back to scheduler run queue
```

---

## Path 4 — Poll path: task checks readiness synchronously

```
[task future polled by scheduler]
 └─ TcpStream::poll_read_priv(cx, buf)               net/tcp/stream.rs:1436
     └─ PollEvented::poll_read(cx, buf)              io/poll_evented.rs:161
          loop:
          ├─ Registration::poll_read_ready(cx)        registration.rs:109
          │    └─ Registration::poll_ready(           registration.rs:144
          │          cx, Direction::Read)
          │       ├─ task::coop::poll_proceed(cx)     // cooperative budget check
          │       └─ ScheduledIo::poll_readiness(     scheduled_io.rs:303
          │               cx, Direction::Read)
          │            ├─ load self.readiness (Acquire)
          │            ├─ mask = Direction::Read.mask()
          │            ├─ ready = READINESS.unpack(curr) & mask
          │            ├─ if ready non-empty
          │            │    └─ Poll::Ready(ReadyEvent{tick, ready})
          │            └─ if empty:
          │                 ├─ lock self.waiters
          │                 ├─ waiters.reader ← cx.waker().clone()
          │                 ├─ re-check readiness under lock (TOCTOU guard)
          │                 └─ Poll::Pending  ← returns here; task parked
          │
          [on Poll::Ready(evt)]:
          ├─ self.io.read(buf)   // actual syscall (std::io::Read on mio socket)
          ├─ Ok(n)  → Poll::Ready(Ok(()))
          └─ WouldBlock:
               └─ Registration::clear_readiness(evt)   registration.rs:103
                    └─ ScheduledIo::clear_readiness(    scheduled_io.rs:357
                           event)
                         └─ set_readiness(
                              Tick::Clear(event.tick),
                              |curr| curr - mask_no_closed)
                            // clears ready bits atomically IFF tick matches;
                            // HUP/closed bits are never cleared
```

---

## Path 5 — Async future path: `readiness()` / interest-based waiting

Used by higher-level APIs (`TcpStream::readable()`, `TcpStream::ready(interest)`, etc.):

```
Registration::readiness(self, interest)               registration.rs:204
 └─ ScheduledIo::readiness(self, interest)            scheduled_io.rs:382
     └─ ScheduledIo::readiness_fut(self, interest)    scheduled_io.rs:390
          // builds Readiness { scheduled_io, state: Init,
          //   waiter: UnsafeCell<Waiter{waker:None, interest, …}} }
     .await → Readiness::poll(cx)                     scheduled_io.rs:427

  State::Init:
   ├─ load readiness (SeqCst), intersect with interest
   ├─ if ready → State::Done, Poll::Ready(ReadyEvent)
   └─ lock waiters:
        ├─ re-check (TOCTOU guard)
        ├─ if ready now → State::Done, Poll::Ready
        └─ else:
             ├─ waiter.waker ← cx.waker().clone()
             ├─ waiters.list.push_front(&waiter)
             ├─ *state = State::Waiting
             └─ (continue loop → Waiting arm)

  State::Waiting:
   ├─ lock waiters
   ├─ if waiter.is_ready (set by ScheduledIo::wake()):
   │    └─ *state = State::Done  (→ loop to Done arm)
   └─ else: update waker, Poll::Pending

  State::Done:
   └─ Poll::Ready(ReadyEvent{tick, ready ∩ interest})

  Drop<Readiness>:                                    scheduled_io.rs:567
   └─ if state==Waiting: lock waiters, remove(&waiter)
        // unlinks the waiter node from the list safely
```

---

## Path 6 — Unpark: waking the driver from another thread

```
[new task spawned, timer fires, or deregister on non-driver thread]
 └─ Handle::unpark(&self)                            driver.rs:258
     └─ self.waker.wake()                            // mio::Waker
          └─ write to eventfd (Linux) / pipe / kqueue fd
               // causes mio::Poll::poll() to return with TOKEN_WAKEUP
               // Driver::turn() sees TOKEN_WAKEUP and skips it
```

---

## Path 7 — Deregistration

```
[PollEvented::drop, or explicit deregister()]
 └─ Registration::drop                               registration.rs:242
     └─ ScheduledIo::clear_wakers()                 scheduled_io.rs:364
          └─ lock waiters; take reader, writer (drops them)
 └─ Handle::deregister_source(registration, source)  driver.rs:293
     ├─ self.registry.deregister(source)             // epoll_ctl(DEL) / kevent DEL
     ├─ RegistrationSet::deregister(                 registration_set.rs:74
     │     &mut synced, registration)
     │    // removes from synced.registrations LinkedList
     │    // moves Arc<ScheduledIo> to synced.pending_release
     │    // (NOT dropped here — driver thread owns the drop)
     └─ if pending release: Handle::unpark()
          // wake driver so it runs release_pending_registrations()
          // on the next turn(), ensuring ScheduledIo outlives any
          // in-flight mio token reference
```

---

## Unified call graph

```
══════════════════════════════════════════════════════════════════════════
REGISTRATION PATH (startup, once per fd)
══════════════════════════════════════════════════════════════════════════

TcpStream::new                            net/tcp/stream.rs:163
 └─ PollEvented::new                      io/poll_evented.rs:89
     └─ PollEvented::new_with_interest    io/poll_evented.rs:110
         └─ PollEvented::new_with_interest_and_handle  io/poll_evented.rs:115
             └─ Registration::new_with_interest_and_handle  registration.rs:73
                 └─ Handle::add_source                      driver.rs:266
                     ├─ RegistrationSet::allocate           registration_set.rs:56
                     │   └─ Arc::new(ScheduledIo::default()) scheduled_io.rs:177
                     ├─ ScheduledIo::token                  scheduled_io.rs:187
                     │   └─ expose_provenance(self ptr)
                     └─ mio::Registry::register             → OS epoll_ctl/kevent ADD

══════════════════════════════════════════════════════════════════════════
DRIVER LOOP (per scheduler park)
══════════════════════════════════════════════════════════════════════════

Driver::park / park_timeout               driver.rs:159/164
 └─ Driver::turn                          driver.rs:179
     ├─ Handle::release_pending_registrations  driver.rs:314
     │   └─ RegistrationSet::release      registration_set.rs:104
     │       └─ drop Arc<ScheduledIo> x N
     └─ mio::Poll::poll                   → BLOCKS in epoll_wait/kevent
         │
         │  [events arrive]
         │
         ├─ TOKEN_WAKEUP → skip
         ├─ TOKEN_SIGNAL → self.signal_ready = true
         └─ [fd token]:
             ├─ Ready::from_mio(event)
             ├─ from_exposed_addr(token) → *const ScheduledIo
             ├─ ScheduledIo::set_readiness(Tick::Set, |r| r|ready)  scheduled_io.rs:207
             │   └─ AtomicUsize::fetch_update (AcqRel) — tick++ , ready |= bits
             └─ ScheduledIo::wake(ready)             scheduled_io.rs:236
                 ├─ lock Waiters
                 ├─ take reader/writer Wakers matching ready
                 ├─ drain list: Waiter.is_ready=true, take Waker
                 ├─ drop lock
                 └─ WakeList::wake_all → Waker::wake → enqueue task

══════════════════════════════════════════════════════════════════════════
TASK POLL PATH (per future poll, synchronous)
══════════════════════════════════════════════════════════════════════════

AsyncRead::poll_read on TcpStream
 └─ TcpStream::poll_read_priv             net/tcp/stream.rs:1436
     └─ PollEvented::poll_read            io/poll_evented.rs:161
         └─ Registration::poll_read_ready registration.rs:109
             └─ Registration::poll_ready  registration.rs:144
                 ├─ coop::poll_proceed    (budget check)
                 └─ ScheduledIo::poll_readiness(Direction::Read)  scheduled_io.rs:303
                     ├─ load readiness (Acquire), mask, check
                     ├─ [ready] → Poll::Ready(ReadyEvent)
                     └─ [empty] → lock Waiters
                                   store cx.waker() in .reader
                                   recheck, Poll::Pending
         [ready]:
         ├─ self.io.read(buf)              → syscall
         ├─ Ok → Poll::Ready
         └─ WouldBlock:
             └─ Registration::clear_readiness    registration.rs:103
                 └─ ScheduledIo::clear_readiness scheduled_io.rs:357
                     └─ set_readiness(Tick::Clear(tick), |r| r-mask)
                         └─ fetch_update: no-op if tick mismatch (stale clear guard)

══════════════════════════════════════════════════════════════════════════
ASYNC FUTURE PATH (interest-based; readiness().await)
══════════════════════════════════════════════════════════════════════════

Registration::readiness                   registration.rs:204
 └─ ScheduledIo::readiness               scheduled_io.rs:382
     └─ readiness_fut → Readiness future  scheduled_io.rs:390
         .await → Readiness::poll         scheduled_io.rs:427
             State::Init:
               load readiness (SeqCst)
               if ready → State::Done → Poll::Ready
               else: lock Waiters
                      store cx.waker() in waiter.waker
                      push_front waiter into waiters.list
                      State::Waiting → Poll::Pending
             State::Waiting:
               lock Waiters
               if waiter.is_ready (set by wake()) → State::Done
               else update waker → Poll::Pending
             State::Done:
               load readiness → Poll::Ready(ReadyEvent)
         Drop<Readiness>:
           if Waiting: lock Waiters, remove(&waiter)   scheduled_io.rs:567

══════════════════════════════════════════════════════════════════════════
CROSS-THREAD UNPARK
══════════════════════════════════════════════════════════════════════════

Handle::unpark                            driver.rs:258
 └─ mio::Waker::wake → write to eventfd/pipe → mio::Poll::poll returns TOKEN_WAKEUP

══════════════════════════════════════════════════════════════════════════
DEREGISTRATION PATH
══════════════════════════════════════════════════════════════════════════

Registration::drop                        registration.rs:242
 └─ ScheduledIo::clear_wakers            scheduled_io.rs:364

Handle::deregister_source                 driver.rs:293
 ├─ mio::Registry::deregister            → OS epoll_ctl(DEL)/kevent DEL
 ├─ RegistrationSet::deregister          → move Arc<ScheduledIo> to pending_release
 └─ Handle::unpark                       (if pending) → wake driver for cleanup
     ... next Driver::turn:
         └─ release_pending_registrations → drop Arc<ScheduledIo>
```

---

## Key invariants worth knowing

**Token = pointer.** `ScheduledIo::token()` (`scheduled_io.rs:187`) exposes the `self` pointer as a `mio::Token`. The driver casts it back with `from_exposed_addr` inside `turn()`. The `Arc` in `Synced::registrations` prevents the object from being freed while it can appear as a token; the `pending_release` queue defers the actual drop until the driver thread is the one doing the dropping — eliminating any race between event dispatch and deallocation.

**Two waiter slots + one list.** `Waiters` has a dedicated fast-path `reader` and `writer` slot (one `Option<Waker>` each, for `poll_read_ready`/`poll_write_ready`) plus a general intrusive `LinkedList<Waiter>` for the `readiness().await` path. `ScheduledIo::wake()` drains all three.

**Tick prevents stale clears.** Every `set_readiness(Tick::Set, …)` increments the 8-bit tick. `clear_readiness(event)` passes `Tick::Clear(event.tick)` and is a no-op when the current tick ≠ event tick, meaning a later event cannot be erased by an earlier `WouldBlock`.

**`ScheduledIo` is cache-line padded** (`repr(align(128))` on x86\_64/aarch64/ppc64) to avoid false sharing between concurrent read and write waiters on different cores.
