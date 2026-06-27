# transcript: Where is the `spawn` function (the free function that schedules a future onto the runtime) defined? Give the exact file and line.

  ▸ Bash(grep -rn "^pub fn spawn" /home/bench/repos/tokio/tokio/src/ | head -20)
  ▸ Bash(grep -rn "^pub fn spawn" /home/bench/repos/tokio/ --include="*.rs" | head -20)
  ▸ Bash(find /home/bench/repos/tokio -name "*.rs" | xargs grep -n "pub fn spawn" | grep -v "test\|mock\|tokio-test" | head -20)
  ▸ Bash(find /home/bench/repos/tokio/tokio/src/task -name "spawn.rs" -o -name "mod.rs" | xargs grep -n "^pub fn spawn" 2>/dev/null)
  ▸ Bash(find /home/bench/repos/tokio/tokio/src/task -type f -name "*.rs" | xargs grep -n "pub fn spawn" 2>/dev/null)

💬 The free function `spawn` is defined at:  **`tokio/src/task/spawn.rs:174`**

──────── RESULT (success, 18089ms, 6 turns) ────────
The free function `spawn` is defined at:

**`tokio/src/task/spawn.rs:174`**
