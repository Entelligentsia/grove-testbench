# transcript: Where is `Scanner` defined, and list every place it is referenced or called across the source tree, with file and line.


💬 Loading grove tool schemas first.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__callers,mcp__grove__definition,mcp__grove__source)

💬 Now searching for the `Scanner` definition and all its references.
  ▸ mcp__grove__definition({"name":"Scanner","dir":"/home/bench/repos/typescript"})
  ▸ mcp__grove__callers({"name":"Scanner","dir":"/home/bench/repos/typescript"})

💬 The grove server reconnected. Reloading and retrying the callers search.
  ▸ ToolSearch(select:mcp__grove__callers,mcp__grove__symbols)
  ▸ mcp__grove__callers({"name":"Scanner","dir":"/home/bench/repos/typescript"})

💬 Here is the full picture.  ---  ## Definition  | File | Line | Kind | Signature | |---|---|---|---| | `src/compiler/scanner.ts` | 51 | `export interface Scan...

──────── RESULT (success, 613782ms, 6 turns) ────────
Here is the full picture.

---

## Definition

| File | Line | Kind | Signature |
|---|---|---|---|
| `src/compiler/scanner.ts` | 51 | `export interface Scanner` | The canonical compiler definition |
| `tests/cases/compiler/staticAnonymousTypeNotReferencingTypeParameter.ts` | 38 | `interface Scanner` | A local test-only interface, unrelated to the compiler |

---

## References across the source tree

### `src/compiler/scanner.ts`
| Line | Context |
|---|---|
| 1030 | Return type of `createScanner`: `): Scanner {` |
| 1060 | Implementation object: `var scanner: Scanner = {` (inside `createScanner`) |

### `src/compiler/factory/nodeFactory.ts`
| Line | Context |
|---|---|
| 386 | Named import: `Scanner,` |
| 7235 | Type annotation: `let rawTextScanner: Scanner \| undefined;` |

### `src/compiler/checker.ts`
| Line | Context |
|---|---|
| 998 | Named import: `Scanner,` |
| 1507 | Type annotation inside `createTypeChecker`: `var scanner: Scanner \| undefined;` |

### `src/compiler/parser.ts`
| Line | Context |
|---|---|
| 2666 | Comment inside `createIdentifier`: `// Scanner has already recorded an 'Invalid character' error…` |

### `src/services/utilities.ts`
| Line | Context |
|---|---|
| 323 | Named import: `Scanner,` |
| 391 | Module-level export: `export const scanner: Scanner = createScanner(ScriptTarget.Latest, /*skipTrivia*/ true);` |

### `src/services/classifier.ts`
| Line | Context |
|---|---|
| 64 | Named import: `Scanner,` |
| 281 | Parameter type in `getNewEndOfLineState`: `scanner: Scanner` |

### `src/services/organizeImports.ts`
| Line | Context |
|---|---|
| 56 | Named import: `Scanner,` |
| 245 | Parameter type in `isNewGroup`: `scanner: Scanner` |

### Test baselines (generated, not hand-edited)
| File | Line | Context |
|---|---|---|
| `tests/baselines/reference/staticAnonymousTypeNotReferencingTypeParameter.js` | 40 | Compiled output of the test-only interface |
| `tests/baselines/reference/staticAnonymousTypeNotReferencingTypeParameter.js` | 68 | Compiled output of `let scanner: Scanner;` |

---

**Summary:** The real `Scanner` interface is defined once at `src/compiler/scanner.ts:51` and instantiated by `createScanner` at line 1060. It is used as a type in four other source files — `checker.ts`, `nodeFactory.ts`, `services/utilities.ts`, `services/classifier.ts`, and `services/organizeImports.ts` — all importing it from `scanner.ts`.
