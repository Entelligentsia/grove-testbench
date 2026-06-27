# transcript: Where is the `CTransaction` class defined? Give the exact file and line.

  ▸ ToolSearch(select:mcp__grove__symbols)
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/bitcoin","name":"CTransaction","kind":"struct"})

💬 The grove results only found a Python test-framework class. Let me search the C++ headers directly.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/bitcoin","name":"CTransaction","kind":"class"})
  ▸ Bash(grep -rn "^class CTransaction" /home/bench/repos/bitcoin/src/ --include="*.h" --include="*.cpp")

💬 `CTransaction` is defined at:  **`src/primitives/transaction.h`, line 280**  The other occurrences are forward declarations (`class CTransaction;`). The full...

──────── RESULT (success, 109471ms, 5 turns) ────────
`CTransaction` is defined at:

**`src/primitives/transaction.h`, line 280**

The other occurrences are forward declarations (`class CTransaction;`). The full class definition is in `src/primitives/transaction.h:280`.
