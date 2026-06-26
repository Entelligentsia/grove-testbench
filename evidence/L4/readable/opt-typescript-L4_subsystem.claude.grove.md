# transcript: Give the complete end-to-end picture of TypeScript's binder subsystem: how bindSourceFile walks the AST creating Symbols, wiring them into SymbolTables, and ...


💬 I'll load the grove tools first, then systematically map the binder subsystem.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me get the outline of binder.ts and simultaneously look up the key top-level entry points.
  ▸ mcp__grove__outline({"file":"/home/bench/repos/typescript/src/compiler/binder.ts","detail":0})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"bindSourceFile"})

💬 The outline was truncated — binder.ts is enormous. Let me map the file's functions directly and also search for the key entry point.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"bindSourceFile","nameContains":true})
  ▸ mcp__grove__map({"dir":"/home/bench/repos/typescript/src/compiler","name":"bindSourceFile"})

💬 Let me try searching the file directly and with the full path.
  ▸ mcp__grove__outline({"file":"/home/bench/repos/typescript/src/compiler/binder.ts","detail":1})
  ▸ Bash(grep -n "function bindSourceFile\|function createBinder\|export function bind\|^function bind\|    function bind" /home/bench/repos/typescript/src/compiler/b...)
  ▸ Bash(grep -n "function bindSourceFile\|function createBinder\|^function bind\|^export function" /home/bench/repos/typescript/src/compiler/binder.ts | head -60)
  ▸ Bash(wc -l /home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ mcp__grove__source({"file":"/home/bench/repos/typescript/src/compiler/binder.ts","name":"bindSourceFile"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Good — I can see `createBinder()` is the factory. Let me read further to find its definition and `bindSourceFile`.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Good, I can see the core. Let me now read the `bind` function and its surrounding machinery — the key dispatch point.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Let me continue reading — I need to see `bindContainer` completion, then `bind`, `bindWorker`, and the control flow creation functions.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Now let me find the main `bind` dispatch function and `bindWorker`.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Now let me find the main `bind` function and `bindWorker`.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Let me find the main `bind` and `bindWorker` functions — they're likely around line 3500+.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 The file is 3917 lines total. Let me find `bind` and `bindWorker` in the remaining section.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 The main `bind`/`bindWorker` functions are between 2400-3500. Let me find them.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Found `bind` at 2751 and `bindWorker` at 2846. Let me read the rest of `bindWorker`.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Now let me find the core control-flow node constructors: `createBranchLabel`, `addAntecedent`, `finishFlowLabel`, and the `createFlow*` helpers.
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Now let me pull the key data structure definitions from `types.ts` — `Symbol`, `SymbolTable`, and `FlowNode`.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"Symbol","kind":"interface"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"FlowNode"})
  ▸ mcp__grove__source({"id":"typescript:src/compiler/types.ts#Symbol@6037"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"FlowNodeBase"})
  ▸ mcp__grove__source({"id":"typescript:src/compiler/types.ts#FlowNodeBase@4182"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"SymbolTable"})
  ▸ mcp__grove__definition({"name":"SymbolTable","dir":"/home/bench/repos/typescript/src/compiler"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"FlowFlags"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)

💬 Now let me grab the `FlowFlags` enum and `SymbolTable` type definition.
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"createSymbolTable"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)

💬 Let me find `SymbolTable` and `maybeBind` quickly.
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/typescript/src/compiler","name":"SymbolTable","nameContains":true})
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ mcp__grove__callers({"name":"SymbolTable","dir":"/home/bench/repos/typescript/src/compiler"})

💬 I now have everything I need. Let me compose the complete end-to-end picture.  ---  # TypeScript Binder Subsystem — Complete Picture  ## Architecture overvie...

──────── RESULT (success, 341181ms, 44 turns) ────────
I now have everything I need. Let me compose the complete end-to-end picture.

---

# TypeScript Binder Subsystem — Complete Picture

## Architecture overview

The binder is a single-pass, depth-first AST walker that does three interleaved jobs:

1. **Symbol creation** — creates `Symbol` objects, inserts them into the right `SymbolTable`, and wires parent/child relationships.
2. **Container tracking** — maintains a stack of *containers* (nodes whose children form a new declaration scope) and *block-scope containers* (nodes that introduce `let`/`const` scope), threading a linked list of containers across the whole file.
3. **Control-flow graph (CFG) construction** — builds a linked network of `FlowNode` objects as statements are visited, so the checker can perform narrowing.

Everything lives inside one closure factory (`createBinder`) in `src/compiler/binder.ts`.

---

## Key data structures

### `Symbol` — `src/compiler/types.ts:6037`
```
interface Symbol {
  flags: SymbolFlags            // e.g. Function | Export
  escapedName: __String
  declarations?: Declaration[]  // all AST nodes that contribute to this symbol
  valueDeclaration?: Declaration
  members?: SymbolTable         // instance members (class/interface/object literal)
  exports?: SymbolTable         // module / static exports
  globalExports?: SymbolTable   // UMD global exports
  parent?: Symbol               // owning symbol
  exportSymbol?: Symbol         // for dual local+export symbols
  id: SymbolId                  // unique numeric id
  ...
}
```

### `SymbolTable` — `src/compiler/types.ts:6205`
```
type SymbolTable = Map<__String, Symbol>
```
An ES6 `Map` keyed by escaped identifier strings. Every container node that can have *locals* gets one; classes and modules also get `symbol.exports` and `symbol.members` SymbolTables.

### `FlowNode` — `src/compiler/types.ts:4182–4265`
Base structure:
```
interface FlowNodeBase {
  flags: FlowFlags   // Unreachable | Start | BranchLabel | LoopLabel |
                     // Assignment | TrueCondition | FalseCondition |
                     // SwitchClause | ArrayMutation | Call | ReduceLabel
  id: number         // used by checker's flow-type cache
  node: unknown      // AST node or structured data (kind-dependent)
  antecedent: FlowNode | FlowNode[] | undefined
}
```
The `FlowNode` union type has nine concrete subtypes: `FlowUnreachable`, `FlowStart`, `FlowLabel` (shared by BranchLabel and LoopLabel), `FlowAssignment`, `FlowCall`, `FlowCondition` (true/false), `FlowSwitchClause`, `FlowArrayMutation`, `FlowReduceLabel`.

### `ContainerFlags` — `src/compiler/binder.ts:465`
A bitset enum (`IsContainer | IsBlockScopedContainer | IsControlFlowContainer | IsFunctionLike | IsFunctionExpression | HasLocals | IsInterface | IsObjectLiteralOrClassExpressionMethodOrAccessor | PropagatesThisKeyword`) computed by `getContainerFlags` for every node that needs scope management.

### Binder closure state — `src/compiler/binder.ts:513–558`
Mutable variables captured in the `createBinder` closure:
| Variable | Purpose |
|---|---|
| `container` | Current symbol-owning container (receives `exports`/`members`) |
| `thisParentContainer` | Container one level up (used for `this` type) |
| `blockScopeContainer` | Current block-scope container (receives `let`/`const` locals) |
| `lastContainer` | Tail of `nextContainer` linked list |
| `currentFlow` | Current node in the CFG |
| `currentBreakTarget` | `FlowLabel` for `break` |
| `currentContinueTarget` | `FlowLabel` for `continue` |
| `currentReturnTarget` | `FlowLabel` for `return` |
| `currentExceptionTarget` | `FlowLabel` for thrown exceptions |
| `currentTrueTarget / currentFalseTarget` | Conditional branch targets |
| `inStrictMode` | Strict mode flag |
| `symbolCount` | Monotonically increasing symbol counter |

---

## The call sequence, function by function

### Phase 0 — Entry point

**`bindSourceFile(file, options)`** — `binder.ts:502` (`export function`, called by `program.ts`)  
Wraps timing markers, then delegates to `binder(file, options)` where `binder` is the singleton returned by `createBinder()` (`binder.ts:499`).

**`createBinder()`** — `binder.ts:509`  
Allocates all closure state variables (all `var` for TDZ-avoidance), returns the inner `bindSourceFile` function.

**Inner `bindSourceFile(f, opts)`** — `binder.ts:571`  
1. Copies args into closure state: `file`, `options`, `languageVersion`, `inStrictMode` (via `bindInStrictMode`).
2. Allocates `classifiableNames` set; sets `Symbol` constructor from `objectAllocator`.
3. If `!file.locals` (not already bound): calls `bind(file)`.
4. Records `file.symbolCount`, `file.classifiableNames`.
5. Calls `delayedBindJSDocTypedefTag()` then `bindJSDocImports()`.
6. Clears all closure state (incremental reset).

---

### Phase 1 — The core recursive descent

**`bind(node)`** — `binder.ts:2751`  
The only recursive entry point. Every node in the AST is visited exactly through this function.

1. `setParent(node, parent)` — wires `node.parent`.
2. Saves `inStrictMode`.
3. Calls **`bindWorker(node)`** — attaches symbols to this node.
4. If `node.kind > SyntaxKind.LastToken` (non-terminal):
   - Saves `parent`; sets `parent = node`.
   - Calls `getContainerFlags(node)` → `containerFlags`.
   - If `containerFlags === None`: calls **`bindChildren(node)`**.
   - Else: calls **`bindContainer(node, containerFlags)`**.
5. Else (terminal / leaf token): calls **`bindJSDoc(node)`**.
6. Restores `inStrictMode`.

**`bindWorker(node)`** — `binder.ts:2846`  
A giant `switch (node.kind)` that handles symbol creation for the current node *before* descending. Key branches:

| Node kind(s) | Calls |
|---|---|
| `Identifier`, `ThisKeyword` | `checkContextualIdentifier`; stamps `flowNode` |
| `VariableDeclaration`, `BindingElement` | `bindVariableDeclarationOrBindingElement` |
| `Parameter` | `bindParameter` |
| `FunctionDeclaration` | `bindFunctionDeclaration` |
| `FunctionExpression`, `ArrowFunction` | `bindFunctionExpression` |
| `ClassDeclaration`, `ClassExpression` | `bindClassLikeDeclaration` |
| `MethodDeclaration`, `PropertyDeclaration`, `GetAccessor`, `SetAccessor` | `bindPropertyOrMethodOrAccessor` |
| `InterfaceDeclaration` | `bindBlockScopedDeclaration` |
| `TypeAliasDeclaration` | `bindBlockScopedDeclaration` |
| `EnumDeclaration` | `bindEnumDeclaration` |
| `ModuleDeclaration` | `bindModuleDeclaration` |
| `FunctionType`, `ConstructorType`, `JSDocSignature` | `bindFunctionOrConstructorType` |
| `TypeLiteral`, `MappedType`, `JSDocTypeLiteral` | `bindAnonymousTypeWorker` |
| `ObjectLiteralExpression` | `bindObjectLiteralExpression` |
| `TypeParameter` | `bindTypeParameter` |
| `ImportClause` | `bindImportClause` |
| `ExportDeclaration` | `bindExportDeclaration` |
| `ExportAssignment` | `bindExportAssignment` |
| `SourceFile` | `updateStrictModeStatementList` + `bindSourceFileIfExternalModule` |
| `BinaryExpression` | detects assignment-declaration kinds → various `bind*Assignment` helpers |
| `CallExpression` | detects JS expando calls → `bindObjectDefineProperty*` etc. |
| `JSDocTypedefTag`, `JSDocCallbackTag`, `JSDocEnumTag` | pushes to `delayedTypeAliases` |
| `JSDocImportTag` | pushes to `jsDocImports` |

**`getContainerFlags(node)`** — `binder.ts:3815` (exported top-level function)  
Returns the bitset of `ContainerFlags` for a node kind. For example:
- `SourceFile` → `IsContainer | IsControlFlowContainer | HasLocals`
- `FunctionDeclaration/Constructor` → `IsContainer | IsControlFlowContainer | HasLocals | IsFunctionLike`
- `Block` (non-function-body) → `IsBlockScopedContainer | HasLocals`
- `ArrowFunction` → adds `IsFunctionExpression | PropagatesThisKeyword`
- `ModuleBlock` → `IsControlFlowContainer` only

---

### Phase 2 — Container management

**`bindContainer(node, containerFlags)`** — `binder.ts:953`  
Called when `containerFlags !== None`. Manages the container stack:

1. Saves `container`, `thisParentContainer`, `blockScopeContainer`.
2. If `IsContainer`: sets `container = blockScopeContainer = node`; if `HasLocals`, allocates `container.locals = createSymbolTable()` and calls `addToContainerChain`.
3. Else if `IsBlockScopedContainer`: sets `blockScopeContainer = node`; lazily clears stale `locals`.
4. If `IsControlFlowContainer`:
   - Saves all current flow targets (`currentFlow`, `currentBreakTarget`, etc.).
   - Unless IIFE: creates a fresh `FlowStart` node as `currentFlow`.
   - Creates `currentReturnTarget` (for constructors, IIFEs, JS functions).
   - Calls **`bindChildren(node)`**.
   - Stamps `node.flags` with `HasImplicitReturn`/`HasExplicitReturn` and sets `node.endFlowNode`.
   - If `currentReturnTarget`: calls `addAntecedent` + `finishFlowLabel`, sets `node.returnFlowNode`.
   - Restores all saved flow state.
5. Else if `IsInterface`: saves/restores `seenThisKeyword`; calls `bindChildren`.
6. Else: just calls `bindChildren`.
7. Restores `container`, `thisParentContainer`, `blockScopeContainer`.

**`addToContainerChain(next)`** — `binder.ts:2256`  
Links `lastContainer.nextContainer = next`; advances `lastContainer`. This builds the singly-linked list of all `HasLocals` containers that the checker walks to merge globals.

---

### Phase 3 — Child traversal and CFG construction

**`bindChildren(node)`** — `binder.ts:1096`  
Decides *how* to recurse and builds CFG edges for statement nodes.

1. Saves/restores `inAssignmentPattern`.
2. If current flow is `unreachableFlow`: stamps `NodeFlags.Unreachable` on executable nodes; calls `bindEachChild` + `bindJSDoc` and returns early.
3. Stamps `node.flowNode = currentFlow` for statement nodes.
4. Dispatches on `node.kind` with specialized CFG builders for:  
   `While/Do/For/ForInOf/If/Return/Throw/Break/Continue/Try/Switch/CaseBlock/CaseClause/ExpressionStatement/LabeledStatement/PrefixUnary/PostfixUnary/BinaryExpression/Delete/Conditional/VariableDeclaration/PropertyAccess/ElementAccess/Call/NonNull/JSDocTypeAlias/JSDocImportTag`.
5. For `SourceFile` and `Block`/`ModuleBlock`: calls **`bindEachFunctionsFirst`** (hoist function declarations).
6. Default: calls **`bindEachChild`**.
7. Calls **`bindJSDoc(node)`**.

**`bindEachFunctionsFirst(nodes)`** — `binder.ts:1079`  
Two passes over a statement list: first `bind` only `FunctionDeclaration` nodes (hoisting), then `bind` everything else.

**`bindEach(nodes, bindFn?)`** — `binder.ts:1084`  
`forEach(nodes, bind)`.

**`bindEachChild(node)`** — `binder.ts:1092`  
`forEachChild(node, bind, bindEach)` — the generic "recurse into all children" path.

---

### Phase 4 — Symbol table insertion

**`declareSymbolAndAddToSymbolTable(node, symbolFlags, symbolExcludes)`** — `binder.ts:2264`  
Routes to the correct symbol table based on `container.kind`:
- `ModuleDeclaration` → `declareModuleMember`
- `SourceFile` → `declareSourceFileMember`
- `ClassDeclaration/ClassExpression` → `declareClassMember`
- `EnumDeclaration` → `container.symbol.exports`
- `TypeLiteral/Interface/ObjectLiteral/JsxAttributes` → `container.symbol.members`
- Functions/methods/type aliases/mapped types → `container.locals`

**`declareModuleMember(node, symbolFlags, symbolExcludes)`** — `binder.ts:887`  
For exported members: creates a dual-symbol (`local.exportSymbol`) so the local name and the export are distinct. For aliases and non-exports: uses `container.locals`.

**`declareSourceFileMember(node, symbolFlags, symbolExcludes)`** — `binder.ts:3330`  
External modules delegate to `declareModuleMember`; scripts go into `file.locals`.

**`declareClassMember(node, symbolFlags, symbolExcludes)`** — `binder.ts:3324`  
`isStatic` → `container.symbol.exports`; otherwise → `container.symbol.members`.

**`declareSymbol(symbolTable, parent, node, includes, excludes, ...)`** — `binder.ts:749`  
The core insertion function:
1. Computes the declaration name (`getDeclarationName` → `__String`).
2. Looks up existing symbol in `symbolTable`.
3. If no existing symbol: `symbolTable.set(name, symbol = createSymbol(None, name))`.
4. If existing symbol has conflicting flags (`symbol.flags & excludes`): reports duplicate-identifier diagnostics (via `file.bindDiagnostics`), then creates a fresh symbol.
5. Calls `addDeclarationToSymbol(symbol, node, includes)`.
6. Sets `symbol.parent = parent`.

**`addDeclarationToSymbol(symbol, node, symbolFlags)`** — `binder.ts:635`  
- `symbol.flags |= symbolFlags`
- `node.symbol = symbol`
- `symbol.declarations = appendIfUnique(symbol.declarations, node)`
- Allocates `symbol.exports` / `symbol.members` on first use.
- Calls `setValueDeclaration` for value symbols.

**`createSymbol(flags, name)`** — `binder.ts:630`  
`symbolCount++; return new Symbol(flags, name)`.

**`bindBlockScopedDeclaration(node, symbolFlags, symbolExcludes)`** — `binder.ts:2437`  
Routes block-scoped names (`let`, `const`, `class`, `interface`, `enum`) to `blockScopeContainer.locals` (lazily allocated) or to module/source-file scope when appropriate.

**`bindAnonymousDeclaration(node, symbolFlags, name)`** — `binder.ts:2428`  
Creates a symbol that is *not* inserted into a parent SymbolTable (used for object literals, type literals, function expressions, etc.).

---

### Phase 5 — Control-flow graph construction

These functions live inside `createBinder` and mutate `currentFlow`.

**`createFlowNode(flags, node, antecedent)`** — `binder.ts:495` (exported top-level helper)  
Allocates `{ flags, id: 0, node, antecedent }`. The `id` is assigned lazily by the checker.

**`createBranchLabel()`** — `binder.ts:1356`  
→ `createFlowNode(FlowFlags.BranchLabel, undefined, undefined)` as `FlowLabel`.

**`createLoopLabel()`** — `binder.ts:1360`  
→ `createFlowNode(FlowFlags.LoopLabel, undefined, undefined)` as `FlowLabel`.

**`createReduceLabel(target, antecedents, antecedent)`** — `binder.ts:1364`  
Used for try/finally: `createFlowNode(FlowFlags.ReduceLabel, {target, antecedents}, antecedent)`.

**`addAntecedent(label, antecedent)`** — `binder.ts:1373`  
Pushes `antecedent` into `label.antecedent[]`; marks the antecedent as `Referenced`/`Shared`.

**`finishFlowLabel(flow)`** — `binder.ts:1422`  
Collapses single-antecedent labels (returns the sole antecedent directly) and converts zero-antecedent labels to `unreachableFlow`.

**`createFlowCondition(flags, antecedent, expression)`** — `binder.ts:1380`  
Creates a `FlowCondition` (TrueCondition or FalseCondition) only if `expression` is a narrowing expression; otherwise returns the antecedent unchanged.

**`createFlowMutation(flags, antecedent, node)`** — `binder.ts:1406`  
Creates `FlowAssignment` or `FlowArrayMutation`; also feeds into `currentExceptionTarget` for try blocks; sets `hasFlowEffects = true`.

**`createFlowCall(antecedent, node)`** — `binder.ts:1416`  
Creates `FlowCall` for assertion-like calls; sets `hasFlowEffects = true`.

**`createFlowSwitchClause(antecedent, switchStatement, start, end)`** — `binder.ts:1401`  
Creates `FlowSwitchClause` wrapping `{switchStatement, clauseStart, clauseEnd}`.

**`bindCondition(node, trueTarget, falseTarget)`** — `binder.ts:1487`  
Sets `currentTrueTarget`/`currentFalseTarget` via `doWithConditionalBranches`, calls `bind(node)`, then (if not a logical expression) adds `TrueCondition`/`FalseCondition` antecedents.

**`doWithConditionalBranches(action, value, trueTarget, falseTarget)`** — `binder.ts:1477`  
Temporarily swaps `currentTrueTarget`/`currentFalseTarget`, runs `action(value)`, restores.

**`bindIterativeStatement(node, breakTarget, continueTarget)`** — `binder.ts:1495`  
Sets break/continue targets and calls `bind(node)`.

**Per-statement CFG binders** (all within `createBinder` closure):

| Function | Line | CFG shape |
|---|---|---|
| `bindWhileStatement` | 1515 | `preWhile(Loop)` → condition → `preBody` / `postWhile`; back-edge to `preWhile` |
| `bindDoStatement` | 1528 | `preDo(Loop)` → body → `preCondition` → condition → `preDo` / `postDo` |
| `bindForStatement` | 1541 | init → `preLoop(Loop)` → condition → body → incrementor → back-edge |
| `bindForInOrForOfStatement` | ~1562 | `preLoop(Loop)` → body → back-edge → `postLoop` |
| `bindIfStatement` | ~1593 | condition → `thenLabel` / `elseLabel` → `postIf(Branch)` |
| `bindReturnOrThrow` | ~1630 | `bind(expression)`; `addAntecedent(returnTarget/exceptionTarget, currentFlow)`; `currentFlow = unreachableFlow` |
| `bindBreakOrContinueStatement` | ~1648 | adds to named or current break/continue label; `currentFlow = unreachableFlow` |
| `bindTryStatement` | ~1660 | try body → catch/finally with `ReduceLabel` for finally |
| `bindSwitchStatement` | 1717 | expression → `caseBlock`; `preSwitchCaseFlow` for fall-through |
| `bindCaseBlock` | 1739 | per-clause: `BranchLabel` merging `SwitchClause` + fall-through |
| `bindCaseClause` | 1766 | expression at `preSwitchCaseFlow`; then body |
| `bindExpressionStatement` | 1774 | `bind(expr)` + `maybeBindExpressionFlowIfCall` |
| `bindLabeledStatement` | 1790 | `postStatementLabel(Branch)`; registers in `activeLabelList` |
| `bindLogicalLikeExpression` | 1847 | `&&`/`\|\|`/`??` short-circuit: left binds condition, right in true/false branch |
| `bindConditionalExpressionFlow` | 2032 | ternary: condition → `trueLabel` / `falseLabel` → `postExpressionLabel` |
| `bindVariableDeclarationFlow` | 2070 | `bindEachChild`; `bindInitializedVariableFlow` → `FlowAssignment` |
| `bindBindingElementFlow` | 2077 | ordered: dotDotDot → propertyName → initializer → name |
| `bindParameterFlow` | 2089 | ordered: modifiers → dotDotDot → questionToken → type → initializer → name |
| `bindAccessExpressionFlow` | 2218 | optional chains → `bindOptionalChainFlow`; else `bindEachChild` |
| `bindCallExpressionFlow` | 2227 | IIFE: args then expression; `super()` → `FlowCall`; push/unshift → `FlowArrayMutation` |
| `bindNonNullExpressionFlow` | 2209 | optional chain → `bindOptionalChainFlow`; else `bindEachChild` |
| `bindOptionalChainFlow` | 2195 | top-level optional chain → `BranchLabel`; inner → uses current true/false targets |
| `bindOptionalChain` | 2171 | recursively models `a?.b` as `a && a.b` with `preChainLabel` |
| `bindAssignmentTargetFlow` | 1818 | narrowable ref → `FlowAssignment`; arrays/objects recurse into elements |
| `bindPrefixUnaryExpressionFlow` | 1870 | `!` → swaps true/false targets; `++`/`--` → `FlowAssignment` |
| `bindPostfixUnaryExpressionFlow` | 1887 | `++`/`--` → `FlowAssignment` |
| `bindDestructuringAssignmentFlow` | 1894 | handles binding order for `{a} = rhs` patterns |

**`createBindBinaryExpressionFlow()`** — `binder.ts:1912`  
Returns a *trampoline* (via `createBinaryExpressionTrampoline`) to avoid stack overflows on deeply nested `+`/`&&` chains. Has four callbacks: `onEnter` (calls `bindWorker`, detects logical operators → `bindLogicalLikeExpression`), `onLeft` / `onOperator` / `onRight` (call `maybeBind`/`bind`), `onExit` (assignment targets → `FlowAssignment`).

---

### Phase 6 — Delayed binding passes

**`delayedBindJSDocTypedefTag()`** — `binder.ts:2458`  
After the main walk: re-enters each collected `@typedef`/`@callback`/`@enum` JSDoc tag with a restored container context, binds its `typeExpression`, and routes its name into the right symbol table.

**`bindJSDocImports()`** — `binder.ts:2526`  
Similar: re-enters each `@import` JSDoc tag and binds its `importClause` in the tag's enclosing container context.

---

## Unified call graph

```
bindSourceFile (export, :502)
└─ binder = createBinder() (:509) [singleton]
   └─ bindSourceFile (inner, :571)
      ├─ bindInStrictMode (:620)
      ├─ bind(file) (:586)          ← recursive core
      │   ├─ setParent
      │   ├─ bindWorker(node) (:2846)
      │   │   ├─ checkContextualIdentifier (:2558)
      │   │   ├─ bindVariableDeclarationOrBindingElement (:3648)
      │   │   │   └─ bindBlockScopedDeclaration (:2437) / declareSymbolAndAddToSymbolTable (:2264)
      │   │   ├─ bindParameter (:3684)
      │   │   │   └─ bindAnonymousDeclaration (:2428) / declareSymbolAndAddToSymbolTable
      │   │   ├─ bindFunctionDeclaration (:3709)
      │   │   │   └─ bindBlockScopedDeclaration / declareSymbolAndAddToSymbolTable
      │   │   ├─ bindFunctionExpression (:3726)
      │   │   │   └─ bindAnonymousDeclaration
      │   │   ├─ bindClassLikeDeclaration (:3606)
      │   │   │   └─ bindBlockScopedDeclaration / bindAnonymousDeclaration
      │   │   ├─ bindModuleDeclaration (:2352)
      │   │   │   └─ declareModuleSymbol (:2389) → declareSymbolAndAddToSymbolTable
      │   │   ├─ bindEnumDeclaration (:3642)
      │   │   │   └─ bindBlockScopedDeclaration
      │   │   ├─ bindTypeParameter (:3759)
      │   │   │   └─ declareSymbol / declareSymbolAndAddToSymbolTable
      │   │   ├─ bindPropertyOrMethodOrAccessor (:3740)
      │   │   │   └─ bindAnonymousDeclaration / declareSymbolAndAddToSymbolTable
      │   │   ├─ bindFunctionOrConstructorType (:2400)
      │   │   │   └─ createSymbol + addDeclarationToSymbol (x2)
      │   │   ├─ bindObjectLiteralExpression (:2416) → bindAnonymousDeclaration
      │   │   ├─ bindAnonymousTypeWorker (:3104) → bindAnonymousDeclaration
      │   │   ├─ bindSourceFileIfExternalModule (:3108)
      │   │   │   └─ bindSourceFileAsExternalModule (:3122) → bindAnonymousDeclaration
      │   │   ├─ bindImportClause / bindExportDeclaration / bindExportAssignment
      │   │   │   └─ declareSymbolAndAddToSymbolTable / declareSymbol
      │   │   └─ [BinaryExpression/CallExpression JS special forms]
      │   │       └─ bindExportsPropertyAssignment / bindThisPropertyAssignment /
      │   │          bindPrototypePropertyAssignment / bindSpecialPropertyAssignment / ...
      │   │          └─ declareSymbol (into dynamic expando tables)
      │   │
      │   └─ bind recurses via:
      │       ├─ getContainerFlags(node) (:3815)
      │       ├─ [flags == None] bindChildren(node) (:1096)
      │       │   ├─ [unreachable] bindEachChild + bindJSDoc → return
      │       │   ├─ stamps node.flowNode = currentFlow
      │       │   ├─ [WhileStatement]    bindWhileStatement (:1515)
      │       │   │   ├─ createLoopLabel / createBranchLabel (x2)
      │       │   │   ├─ addAntecedent / bindCondition / finishFlowLabel
      │       │   │   └─ bindIterativeStatement (:1495) → bind(body)
      │       │   ├─ [DoStatement]       bindDoStatement (:1528)  [similar]
      │       │   ├─ [ForStatement]      bindForStatement (:1541) [similar]
      │       │   ├─ [ForIn/Of]          bindForInOrForOfStatement
      │       │   ├─ [IfStatement]       bindIfStatement
      │       │   │   └─ bindCondition (:1487)
      │       │   │       └─ doWithConditionalBranches (:1477) → bind(cond)
      │       │   │          + createFlowCondition (:1380) (x2)
      │       │   ├─ [Return/Throw]      bindReturnOrThrow → currentFlow = unreachableFlow
      │       │   ├─ [Break/Continue]    bindBreakOrContinueStatement
      │       │   ├─ [TryStatement]      bindTryStatement
      │       │   │   └─ createReduceLabel / bindEach / addAntecedent / finishFlowLabel
      │       │   ├─ [SwitchStatement]   bindSwitchStatement (:1717)
      │       │   │   └─ bindCaseBlock (:1739) → bindCaseClause (:1766)
      │       │   │      └─ createFlowSwitchClause (:1401)
      │       │   ├─ [ExpressionStatement] bindExpressionStatement (:1774)
      │       │   │   └─ bind(expr) + maybeBindExpressionFlowIfCall (:1779)
      │       │   │      └─ createFlowCall (:1416)
      │       │   ├─ [LabeledStatement]  bindLabeledStatement (:1790)
      │       │   ├─ [BinaryExpression]  bindBinaryExpressionFlow (trampoline, :1912)
      │       │   │   ├─ bindLogicalLikeExpression (:1847)
      │       │   │   │   └─ bindCondition (x2) + createFlowCondition (x2)
      │       │   │   └─ bindAssignmentTargetFlow (:1818) → createFlowMutation (:1406)
      │       │   ├─ [Conditional]       bindConditionalExpressionFlow (:2032)
      │       │   ├─ [VariableDecl]      bindVariableDeclarationFlow (:2070)
      │       │   │   └─ bindInitializedVariableFlow (:2058)
      │       │   │      └─ createFlowMutation (FlowFlags.Assignment)
      │       │   ├─ [BindingElement]    bindBindingElementFlow (:2077) → bindInitializer (:2099)
      │       │   ├─ [Parameter]         bindParameterFlow (:2089)
      │       │   ├─ [AccessExpression]  bindAccessExpressionFlow (:2218)
      │       │   ├─ [CallExpression]    bindCallExpressionFlow (:2227)
      │       │   ├─ [NonNull]           bindNonNullExpressionFlow (:2209)
      │       │   │   └─ [optional chain] bindOptionalChainFlow (:2195)
      │       │   │      └─ bindOptionalChain (:2171)
      │       │   │         ├─ bindOptionalExpression (:2145)
      │       │   │         └─ bindOptionalChainRest (:2153) [via doWithConditionalBranches]
      │       │   ├─ [PrefixUnary]       bindPrefixUnaryExpressionFlow (:1870)
      │       │   ├─ [PostfixUnary]      bindPostfixUnaryExpressionFlow (:1887)
      │       │   ├─ [SourceFile/Block]  bindEachFunctionsFirst (:1079)
      │       │   │   └─ bindEach (:1084) [two passes: fn-decls first, then rest]
      │       │   │      └─ bind(node) [recursive]
      │       │   └─ [default]           bindEachChild (:1092)
      │       │      └─ forEachChild(node, bind, bindEach) [recursive]
      │       │
      │       └─ [flags != None] bindContainer(node, flags) (:953)
      │           ├─ [IsContainer] → container = node; allocate locals; addToContainerChain (:2256)
      │           ├─ [IsBlockScopedContainer] → blockScopeContainer = node
      │           ├─ [IsControlFlowContainer]
      │           │   ├─ createFlowNode(FlowFlags.Start, ...) → currentFlow
      │           │   ├─ createBranchLabel() → currentReturnTarget [constructors/IIFEs]
      │           │   ├─ bindChildren(node)  ← recursive
      │           │   ├─ addAntecedent + finishFlowLabel (return target)
      │           │   └─ restore all saved flow state
      │           └─ bindChildren(node) [IsInterface or plain block-scope-only]
      │
      │   [All paths through bind eventually reach]
      │   └─ declareSymbolAndAddToSymbolTable (:2264)
      │       ├─ declareModuleMember (:887) → declareSymbol (:749)
      │       ├─ declareSourceFileMember (:3330) → declareModuleMember / declareSymbol
      │       ├─ declareClassMember (:3324) → declareSymbol
      │       └─ declareSymbol (:749)
      │           ├─ getDeclarationName (:661)
      │           ├─ createSymbol (:630) → new Symbol(flags, name)
      │           └─ addDeclarationToSymbol (:635)
      │               └─ setValueDeclaration
      │
      ├─ delayedBindJSDocTypedefTag() (:2458)
      │   └─ bind(typeAlias.typeExpression) + bindBlockScopedDeclaration / declareModuleMember
      │
      └─ bindJSDocImports() (:2526)
          └─ bind(jsDocImportTag.importClause)
```

---

## Summary of responsibilities

| Phase | Key functions | Output |
|---|---|---|
| Bootstrap | `bindSourceFile` (outer+inner), `createBinder` | Closure state initialized; `file.locals` created |
| Per-node symbol | `bind` → `bindWorker` → `declareSymbol` family | `node.symbol`, `SymbolTable` entries |
| Container stack | `bindContainer`, `addToContainerChain`, `getContainerFlags` | `container`/`blockScopeContainer` pushed; `nextContainer` list |
| Child traversal | `bindChildren`, `bindEachChild`, `bindEachFunctionsFirst` | Depth-first AST walk; function-declaration hoisting |
| CFG construction | `createBranchLabel/LoopLabel/ReduceLabel`, `addAntecedent`, `finishFlowLabel`, `createFlowCondition/Mutation/Call/SwitchClause`, `bindCondition`, per-statement binders | `FlowNode` graph; `node.flowNode` stamps on identifiers and statements |
| Delayed passes | `delayedBindJSDocTypedefTag`, `bindJSDocImports` | JSDoc type alias and import symbols placed in correct scopes |
