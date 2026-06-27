# transcript: Where is the `spawn` function (the free function that schedules a future onto the runtime) defined? Give the exact file and line.

  ▸ ToolSearch(select:mcp__grove__symbols)
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/tokio","kind":"function","name":"spawn"})

💬 The results are noisy. Let me narrow to a definition-only search in the `tokio/src` directory with an exact name match.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/tokio/tokio/src","kind":"function","name":"spawn"})

💬 The top-level `spawn` isn't surfacing. Let me look in the task module directly.
  ▸ Bash(find /home/bench/repos/tokio/tokio/src/task -type f -name "*.rs" | head -20)
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/tokio/tokio/src/task/spawn.rs","kind":"function","name":"spawn"})
  ▸ mcp__grove__outline(tokio/src/task/spawn.rs)
  ▸ ToolSearch(select:mcp__grove__outline)
  ▸ mcp__grove__outline({"file":"/home/bench/repos/tokio/tokio/src/task/spawn.rs"})
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)
  ▸ Read(/home/bench/repos/tokio/tokio/src/task/spawn.rs)

💬 The `spawn` free function is defined at:  **`tokio/src/task/spawn.rs`, line 174**  ```rust pub fn spawn<F>(future: F) -> JoinHandle<F::Output> ```  It's insi...

──────── RESULT (success, 68479ms, 13 turns) ────────
The `spawn` free function is defined at:

**`tokio/src/task/spawn.rs`, line 174**

```rust
pub fn spawn<F>(future: F) -> JoinHandle<F::Output>
```

It's inside a `cfg_rt! { ... }` macro block (which gates it on the `rt` feature). The actual work is delegated to `spawn_inner` on line 188.
