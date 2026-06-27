# transcript: Where is the `createScanner` function defined? Give the exact file and line.

  ▸ ToolSearch(select:mcp__grove__symbols)
  ▸ mcp__grove__symbols({"dir":".","name":"createScanner","kind":"function"})

💬 That result is the `.d.ts` declaration. Let me also check for the implementation.
  ▸ mcp__grove__symbols({"dir":".","name":"createScanner","refs":true})
  ▸ Bash(grep -rn "^export function createScanner\|^function createScanner" /home/bench/repos/typescript/src/ 2>/dev/null | head -20)

💬 `createScanner` is defined at:  **`src/compiler/scanner.ts`, line 1022**  The declaration in `tests/baselines/reference/api/typescript.d.ts:8520` is the gene...

──────── RESULT (success, 321892ms, 5 turns) ────────
`createScanner` is defined at:

**`src/compiler/scanner.ts`, line 1022**

The declaration in `tests/baselines/reference/api/typescript.d.ts:8520` is the generated type declaration; the actual implementation is in `src/compiler/scanner.ts:1022`.
