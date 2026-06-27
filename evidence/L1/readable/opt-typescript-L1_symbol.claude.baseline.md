# transcript: Where is the `createScanner` function defined? Give the exact file and line.

  ▸ Bash(grep -rn "^function createScanner\|^export function createScanner" /home/bench/repos/typescript/src --include="*.ts" -l)
  ▸ Bash(grep -n "^export function createScanner\|^function createScanner" /home/bench/repos/typescript/src/compiler/scanner.ts)

💬 `createScanner` is defined at `src/compiler/scanner.ts:1022`.

──────── RESULT (success, 8657ms, 3 turns) ────────
`createScanner` is defined at `src/compiler/scanner.ts:1022`.
