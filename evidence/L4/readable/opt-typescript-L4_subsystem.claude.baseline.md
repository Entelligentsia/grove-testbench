# transcript: I need a deep structural analysis of TypeScript's binder in /home/bench/repos/typescript/src/compiler/binder.ts. Do NOT read the whole file at once — it is e...


💬 I'll explore the binder systematically using parallel agents — one to map the top-level structure and key data types, another to trace control-flow graph con...
  ▸ Agent(Binder structure and Symbol/SymbolTable wiring)
  ▸ Bash(wc -l /home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Bash(cat /home/bench/repos/typescript/src/compiler/binder.ts | wc -l)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Agent(Binder control-flow graph construction)
  ▸ Bash(grep -n "^function bindSourceFile\|^function bind(\|^function bindChildren\|^function bindEachChild\|^function createSymbol\|^function declareSymbol\|^functi...)
  ▸ Bash(grep -n "function create.*Flow" /home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Bash(grep -n "createFlow\|currentFlow\|FlowFlags\|FlowNode\|FlowLabel\|FlowBranch\|FlowAssignment\|FlowCall\|FlowReduceLabel\|FlowStart\|FlowUnreachable" /home/be...)
  ▸ Bash(ls -la /home/bench/repos/typescript/src/compiler/ | head -20)
  ▸ Agent(Symbol and SymbolTable type definitions in types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Bash(grep -n "interface Symbol\|interface SymbolTable\|interface FlowNode\|interface FlowLabel\|interface FlowAssignment\|interface FlowCall\|interface FlowCondit...)
  ▸ Bash(grep -n "^    interface Symbol\|^export interface Symbol" /home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Bash(cat /home/bench/repos/typescript/src/compiler/binder.ts | grep -n "function create.*Flow\|function createBranch\|function createLoop\|function addAntecedent\...)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Bash(grep -n "interface Symbol\|interface SymbolTable\|interface FlowNode\|interface FlowLabel\|interface FlowAssignment\|interface FlowCall\|interface FlowCondit...)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Bash(cat /home/bench/repos/typescript/src/compiler/types.ts | grep -n "interface Symbol\|interface SymbolTable\|interface FlowNode\|interface FlowLabel\|interface...)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Bash(grep -n "enum FlowFlags\|export.*FlowFlags\|interface FlowNode\|interface FlowLabel\|interface FlowCondition\|interface FlowAssignment\|interface FlowCall\|i...)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/types.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Now I have everything. Let me synthesize a complete picture.  ---  # TypeScript Binder Subsystem: Complete Picture  ## 1. Key Data Structures  ### `Symbol` —...

──────── RESULT (success, 249347ms, 4 turns) ────────
Now I have everything. Let me synthesize a complete picture.

---

# TypeScript Binder Subsystem: Complete Picture

## 1. Key Data Structures

### `Symbol` — `types.ts:6037`
```
interface Symbol {
    flags: SymbolFlags          // what kind(s) of thing this is (bitmask)
    escapedName: __String       // __-prefixed internal name
    declarations?: Declaration[]
    valueDeclaration?: Declaration
    members?: SymbolTable       // class/interface/object instance members
    exports?: SymbolTable       // module exports
    globalExports?: SymbolTable // UMD conditional global exports
    id: SymbolId                // unique integer, assigned lazily
    mergeId: number             // identity key for merged symbols
    parent?: Symbol
    exportSymbol?: Symbol
    constEnumOnlyModule: boolean | undefined
    isReferenced?: SymbolFlags
    lastAssignmentPos?: number
    isReplaceableByMethod?: boolean
    assignmentDeclarationMembers?: Map<number, Declaration>
}
```

### `SymbolTable` — `types.ts:6205`
```
type SymbolTable = Map<__String, Symbol>
```
A plain ES6 `Map`. Used for `.members`, `.exports`, container `.locals`, and `file.locals`.

### `SymbolFlags` (key members) — `types.ts:5942`
```
FunctionScopedVariable = 1<<0   BlockScopedVariable = 1<<1
Property = 1<<2                 EnumMember = 1<<3
Function = 1<<4                 Class = 1<<5
Interface = 1<<6                ConstEnum = 1<<7
RegularEnum = 1<<8              ValueModule = 1<<9
NamespaceModule = 1<<10         TypeAlias = 1<<19
ExportValue = 1<<20             Alias = 1<<21
```
Each declaration kind has a paired `*Excludes` mask for conflict detection.

### `ContainerFlags` (bitmask) — `binder.ts:465`
```
IsContainer = 1<<0                    // classes, interfaces, object literals
IsBlockScopedContainer = 1<<1         // blocks, catch clauses, for-loops
IsControlFlowContainer = 1<<2         // resets currentFlow (functions, modules)
IsFunctionLike = 1<<3
IsFunctionExpression = 1<<4
HasLocals = 1<<5
IsInterface = 1<<6
IsObjectLiteralOrClassExpressionMethodOrAccessor = 1<<7
PropagatesThisKeyword = 1<<8
```

### `FlowFlags` — `types.ts:4150`
```
Unreachable = 1<<0    Start = 1<<1       BranchLabel = 1<<2
LoopLabel = 1<<3      Assignment = 1<<4  TrueCondition = 1<<5
FalseCondition = 1<<6 SwitchClause = 1<<7 ArrayMutation = 1<<8
Call = 1<<9           ReduceLabel = 1<<10
Referenced = 1<<11    Shared = 1<<12
Label = BranchLabel | LoopLabel
Condition = TrueCondition | FalseCondition
```

### `FlowNode` union — `types.ts:4170`
```
type FlowNode =
  | FlowUnreachable    // singleton, dead code
  | FlowStart          // function entry; node = function node or undefined
  | FlowLabel          // junction; antecedent: FlowNode[]
  | FlowAssignment     // variable write; node = Expression | VariableDeclaration | BindingElement
  | FlowCondition      // type guard branch; node = Expression
  | FlowSwitchClause   // node = {switchStatement, clauseStart, clauseEnd}
  | FlowArrayMutation  // node = CallExpression | BinaryExpression
  | FlowCall           // assertion call; node = CallExpression
  | FlowReduceLabel    // try-finally reduction; node = {target, antecedents}
```

All share `FlowNodeBase` (`types.ts:4182`): `flags: FlowFlags`, `id: number`, `node: unknown`, `antecedent: FlowNode | FlowNode[] | undefined`.

---

## 2. Module Skeleton — `binder.ts`

```
binder.ts
├─ (module-level) createFlowNode()          :495   ← exported, used by checker too
├─ (module-level) bindSourceFile()          :502   ← EXPORTED entry point
└─ createBinder()                           :509   ← closure factory; returns the binder fn
   │  Closure state variables               :513-558
   │   container, blockScopeContainer, lastContainer, thisParentContainer
   │   currentFlow, currentBreakTarget, currentContinueTarget,
   │   currentReturnTarget, currentTrueTarget, currentFalseTarget,
   │   currentExceptionTarget, preSwitchCaseFlow, activeLabelList
   │   hasExplicitReturn, inReturnPosition, hasFlowEffects
   │   inStrictMode, inAssignmentPattern
   │   symbolCount, Symbol (ctor), unreachableFlow
   │
   ├─ bindSourceFile()     [inner impl]      :571   ← drives the whole pass
   ├─ createSymbol()                         :630
   ├─ addDeclarationToSymbol()               :635
   ├─ getDeclarationName()                   :661
   ├─ declareSymbol()                        :749
   ├─ declareModuleMember()                  :887
   ├─ bindContainer()                        :953
   ├─ bindEachChild()                        :1092
   ├─ bindChildren()                         :1096
   ├─ createBranchLabel()                    :1356
   ├─ createLoopLabel()                      :1360
   ├─ createReduceLabel()                    :1364
   ├─ setFlowNodeReferenced()                :1368
   ├─ addAntecedent()                        :1373
   ├─ createFlowCondition()                  :1380
   ├─ createFlowSwitchClause()               :1401
   ├─ createFlowMutation()                   :1406
   ├─ createFlowCall()                       :1416
   ├─ finishFlowLabel()                      :1422
   ├─ bindCondition()                        :1487
   ├─ bindWhileStatement()                   :1515
   ├─ bindForStatement()                     :1541
   ├─ bindIfStatement()                      :1578
   ├─ bindReturnOrThrow()                    :1592
   ├─ bindBreakOrContinueStatement()         :1625
   ├─ bindTryStatement()                     :1639
   ├─ addToContainerChain()                  :2256
   ├─ declareSymbolAndAddToSymbolTable()     :2264
   ├─ bind()               [main dispatcher] :2751
   ├─ bindWorker()         [switch table]    :2846
   └─ updateStrictModeStatementList()        :3822
```

---

## 3. The Binding Pipeline — Function by Function

### Phase 0: Module entry
**`bindSourceFile` (exported)** — `binder.ts:502`  
Called by `program.ts` for each `SourceFile`. Calls the internal closure returned by `createBinder()`, wrapped in a `performance.mark`.

---

### Phase 1: Initialization
**`bindSourceFile` (inner)** — `binder.ts:571`

1. Assigns `file`, `options`, `languageVersion`.
2. Checks `file.locals` — if already set (incremental re-use), skips.
3. Initializes `container = blockScopeContainer = file`.
4. Creates `file.locals = new Map()` (the top-level `SymbolTable`).
5. Sets `currentFlow = createFlowNode(FlowFlags.Start, undefined, undefined)`.
6. Sets `unreachableFlow = createFlowNode(FlowFlags.Unreachable, undefined, undefined)`.
7. Calls **`bind(file)`** — the recursive walk begins.
8. After walk: calls `delayedBindJSDocTypedefTag()` then `bindJSDocImports()`.
9. Nulls out closure state for GC.

---

### Phase 2: Main recursive walk
**`bind(node)`** — `binder.ts:2751`

Every node in the AST passes through here. Steps in order:

1. Guard: if `node === undefined`, return.
2. `node.parent = parent` — wires parent pointer.
3. Saves and potentially updates `inStrictMode` via `updateStrictModeStatementList` for statement lists.
4. Calls **`bindWorker(node)`** — handles symbol creation for this node.
5. Checks `getContainerFlags(node)`:
   - Non-zero flags → calls **`bindContainer(node, containerFlags)`** (manages scope + recurses).
   - Zero flags → calls **`bindChildren(node)`** (recurses with flow-sensitive dispatch).
6. Binds any attached JSDoc nodes via `bindJSDoc(node)`.

---

### Phase 3: Symbol binding for this node
**`bindWorker(node)`** — `binder.ts:2846`

A giant `switch (node.kind)` with ~100 cases. Representative paths:

| Node kind | Handler called |
|-----------|---------------|
| `VariableDeclaration` | `bindVariableDeclarationOrBindingElement()` |
| `FunctionDeclaration` | `bindFunctionDeclaration()` |
| `ClassDeclaration` | `bindClassLikeDeclaration()` |
| `InterfaceDeclaration` | `declareSymbolAndAddToSymbolTable(…, Interface, InterfaceExcludes)` |
| `TypeAliasDeclaration` | `declareSymbolAndAddToSymbolTable(…, TypeAlias, TypeAliasExcludes)` |
| `EnumDeclaration` | `bindEnumDeclaration()` |
| `ImportDeclaration` | `bindImportDeclaration()` |
| `BinaryExpression` | `bindBinaryExpressionFlow()` |
| `PrefixUnaryExpression` | `bindPrefixUnaryExpressionFlow()` |
| `CallExpression` | `bindCallExpressionFlow()` |
| `Identifier` | `bindIdentifier()` |
| default | nothing (no symbol for this node) |

Most declaration handlers ultimately reach **`declareSymbolAndAddToSymbolTable`**.

---

### Phase 4: Routing to the right symbol table
**`declareSymbolAndAddToSymbolTable(node, symbolFlags, symbolExcludes)`** — `binder.ts:2264`

Inspects `container.kind` and routes:

| Container | Target function |
|-----------|----------------|
| `ModuleDeclaration` | `declareModuleMember()` |
| `SourceFile` | `declareSourceFileMember()` |
| `ClassDeclaration/Expression` | `declareClassMember()` |
| `EnumDeclaration` | `declareSymbol(container.symbol.exports, …)` |
| `TypeLiteral/ObjectLiteral` | `declareSymbol(container.symbol.members, …)` |
| function body (`HasLocals`) | `declareSymbol(container.locals, …)` |

For module members specifically, **`declareModuleMember`** (`binder.ts:887`) creates _two_ symbols when there is an export: a local symbol in `container.locals` with `SymbolFlags.ExportValue`, and an export symbol in `container.symbol.exports`.

---

### Phase 5: Creating or merging the Symbol
**`declareSymbol(symbolTable, parent, node, includes, excludes, …)`** — `binder.ts:749`

1. Calls `getDeclarationName(node)` to get the `__String` key.
2. Looks up the name in `symbolTable`.
3. If **not found**: calls `createSymbol(includes, name)` — returns a fresh `Symbol` with `symbolCount++`.
4. If **found** and flags conflict with `excludes` mask: reports a duplicate-identifier diagnostic.
5. If **found** and flags are compatible (e.g., two overloads of same function): merges by OR-ing flags.
6. Calls **`addDeclarationToSymbol(symbol, node, includes)`**.
7. Sets `symbol.parent = parent`.
8. Returns the symbol.

**`createSymbol(flags, name)`** — `binder.ts:630`  
`symbolCount++; return new Symbol(flags, name)` — the `Symbol` constructor here is the one injected into the closure; it sets `flags`, `escapedName`, and zeros out the rest.

---

### Phase 6: Attaching the declaration to the symbol
**`addDeclarationToSymbol(symbol, node, symbolFlags)`** — `binder.ts:635`

1. `symbol.flags |= symbolFlags` — merges in the new flags.
2. `node.symbol = symbol` — back-pointer from AST node → Symbol.
3. `symbol.declarations = [..., node]` — appends to declaration list.
4. If `symbolFlags` includes a value (Variable/Function/Class/etc.): calls `setValueDeclaration(symbol, node)` to update `symbol.valueDeclaration` (takes the "earliest" value decl).
5. Lazily creates `symbol.members` or `symbol.exports` (`Map`) if flagged as needing them.

---

### Phase 7: Container transitions
**`bindContainer(node, containerFlags)`** — `binder.ts:953`

Called when `getContainerFlags(node)` is nonzero. Manages the four container pointers:

```
save: container, thisParentContainer, blockScopeContainer, lastContainer
      + full CFG state (currentFlow, currentBreak/ContinueTarget, etc.)

if IsContainer flag:
    thisParentContainer = container
    container = blockScopeContainer = node
    if HasLocals flag:
        node.locals = new Map()          // fresh SymbolTable
        addToContainerChain(node)        // link into lastContainer chain

if IsBlockScopedContainer only:
    blockScopeContainer = node
    if HasLocals: node.locals = new Map()

if IsControlFlowContainer flag:
    reset all CFG state:
        currentFlow = FlowFlags.Start node
        currentBreak/ContinueTarget = undefined
        currentReturnTarget = new BranchLabel (for functions)
        currentExceptionTarget = undefined
        hasExplicitReturn = false

bindChildren(node)    ← recurse

restore: all saved state
```

**`addToContainerChain(next)`** — `binder.ts:2256`  
`lastContainer.nextContainer = next; lastContainer = next` — maintains a singly-linked list of containers-with-locals that the checker later walks to validate local name uniqueness.

---

### Phase 8: Recursing into children with flow dispatch
**`bindChildren(node)`** — `binder.ts:1096`

For flow-sensitive node kinds, calls specialized handlers instead of `bindEachChild`. Selection (partial):

| Node kind | Handler |
|-----------|---------|
| `IfStatement` | `bindIfStatement()` |
| `WhileStatement` | `bindWhileStatement()` |
| `DoStatement` | `bindDoStatement()` |
| `ForStatement` | `bindForStatement()` |
| `ForInStatement/ForOfStatement` | `bindForInOrOfStatement()` |
| `ReturnStatement/ThrowStatement` | `bindReturnOrThrow()` |
| `BreakStatement/ContinueStatement` | `bindBreakOrContinueStatement()` |
| `TryStatement` | `bindTryStatement()` |
| `SwitchStatement` | `bindSwitchStatement()` |
| `BinaryExpression` | `bindBinaryExpressionFlow()` |
| `ConditionalExpression` | `bindConditionalExpressionFlow()` |
| anything else | `bindEachChild(node)` |

**`bindEachChild(node)`** — `binder.ts:1092`  
`forEachChild(node, bind)` — walks all children via the parser's generic visitor, calling `bind` on each.

---

## 4. Control-Flow Graph Construction

### Primitive: `createFlowNode` — `binder.ts:495`
```
createFlowNode(flags, node, antecedent) → FlowNode
```
The only FlowNode allocator. Every specific factory calls it. The public export is used by `checker.ts` as well.

### Helper: `setFlowNodeReferenced` — `binder.ts:1368`
Sets `Referenced` on first reference, `Shared` on second+. The checker uses `Shared` to decide whether to cache narrowed types at a junction.

### Helper: `addAntecedent(label, antecedent)` — `binder.ts:1373`
Appends `antecedent` to `label.antecedent[]` if it isn't unreachable and not already present. Also calls `setFlowNodeReferenced`.

### Helper: `finishFlowLabel(flow)` — `binder.ts:1422`
- 0 antecedents → return `unreachableFlow`
- 1 antecedent → collapse the label, return that single node directly
- 2+ antecedents → return the label itself (a real merge point)

### Specific factories

| Factory | Line | FlowFlags | Creates |
|---------|------|-----------|---------|
| `createBranchLabel()` | 1356 | `BranchLabel` | Junction for if/switch/post-loop |
| `createLoopLabel()` | 1360 | `LoopLabel` | Back-edge target for loops |
| `createReduceLabel(target,ants,ant)` | 1364 | `ReduceLabel` | try-finally antecedent reduction |
| `createFlowCondition(flags,ant,expr)` | 1380 | `TrueCondition\|FalseCondition` | Type-narrowing branch |
| `createFlowSwitchClause(ant,sw,s,e)` | 1401 | `SwitchClause` | One case arm |
| `createFlowMutation(flags,ant,node)` | 1406 | `Assignment\|ArrayMutation` | Variable write or `.push()` |
| `createFlowCall(ant,node)` | 1416 | `Call` | Assertion call (`assert(x)`) |

`createFlowMutation` and `createFlowCall` also call `addAntecedent(currentExceptionTarget, result)` so exception paths see mutations.

### `bindCondition(expr, trueTarget, falseTarget)` — `binder.ts:1487`
The workhorse for boolean-valued expressions. Calls `doWithConditionalBranches(bind, expr, trueTarget, falseTarget)` which temporarily sets `currentTrueTarget`/`currentFalseTarget` then binds the expression. After that, if the expression isn't itself a logical/optional-chain, it creates two `FlowCondition` nodes and adds them to `trueTarget` and `falseTarget` respectively.

### Statement handlers
Each follows the same pattern: allocate labels → wire antecedents → update `currentFlow` → call `bind` on sub-nodes → finish labels.

**`bindIfStatement`** — `binder.ts:1578`
```
thenLabel = createBranchLabel()
elseLabel = createBranchLabel()
postIfLabel = createBranchLabel()
bindCondition(expr, thenLabel, elseLabel)
currentFlow = finishFlowLabel(thenLabel)
bind(thenStatement)
addAntecedent(postIfLabel, currentFlow)
currentFlow = finishFlowLabel(elseLabel)
bind(elseStatement)
addAntecedent(postIfLabel, currentFlow)
currentFlow = finishFlowLabel(postIfLabel)
```

**`bindWhileStatement`** — `binder.ts:1515`
```
preWhileLabel = createLoopLabel()
preBodyLabel  = createBranchLabel()
postWhileLabel = createBranchLabel()
addAntecedent(preWhileLabel, currentFlow)
currentFlow = preWhileLabel
bindCondition(expr, preBodyLabel, postWhileLabel)
currentFlow = finishFlowLabel(preBodyLabel)
bindIterativeStatement(body, postWhileLabel, preWhileLabel)
addAntecedent(preWhileLabel, currentFlow)    // back-edge
currentFlow = finishFlowLabel(postWhileLabel)
```

**`bindForStatement`** — `binder.ts:1541`
```
preLoopLabel       = createLoopLabel()
preBodyLabel       = createBranchLabel()
preIncrementorLabel = createBranchLabel()
postLoopLabel      = createBranchLabel()
bind(initializer)
addAntecedent(preLoopLabel, currentFlow)
currentFlow = preLoopLabel
bindCondition(condition, preBodyLabel, postLoopLabel)
currentFlow = finishFlowLabel(preBodyLabel)
bindIterativeStatement(body, postLoopLabel, preIncrementorLabel)
addAntecedent(preIncrementorLabel, currentFlow)
currentFlow = finishFlowLabel(preIncrementorLabel)
bind(incrementor)
addAntecedent(preLoopLabel, currentFlow)    // back-edge
currentFlow = finishFlowLabel(postLoopLabel)
```

**`bindReturnOrThrow`** — `binder.ts:1592`
```
bind(expression)
if ReturnStatement: hasExplicitReturn = true
                    addAntecedent(currentReturnTarget, currentFlow)
currentFlow = unreachableFlow     // everything after is dead
hasFlowEffects = true
```

**`bindBreakOrContinueStatement`** — `binder.ts:1625`  
Resolves the label (or uses `currentBreakTarget`/`currentContinueTarget`), calls `bindBreakOrContinueFlow` which does `addAntecedent(target, currentFlow); currentFlow = unreachableFlow`.

**`bindTryStatement`** — `binder.ts:1639`  
Most complex. Creates `normalExitLabel`, `returnLabel`, `exceptionLabel`. The try-block binds with `currentExceptionTarget = exceptionLabel` so mutations inside add antecedents to the exception path. The catch-block gets its own exception label. The finally-block is fed a merged label from all three exit paths; its post-flow is then wrapped with `createReduceLabel` nodes so the checker can replay the finally for each original exit path.

---

## 5. Strict Mode
**`updateStrictModeStatementList`** — `binder.ts:3822`  
Called from `bind` when setting parent on statement lists. Walks prologue directives; if `"use strict"` is found, sets `inStrictMode = true`. `inStrictMode` is saved/restored in `bind` so strict mode propagates lexically but doesn't leak.

---

## 6. Unified Call Graph

```
bindSourceFile() [exported, binder.ts:502]
└─ [closure fn from createBinder, binder.ts:509]
   └─ bindSourceFile() [inner, binder.ts:571]
      │  ─ initializes file.locals (SymbolTable), currentFlow (FlowStart)
      ├─ bind(file)  [binder.ts:2751]  ◄────────────────────┐
      │  │  ─ node.parent = parent                           │ recursion
      │  │  ─ updateStrictModeStatementList() [3822]         │
      │  ├─ bindWorker(node)  [binder.ts:2846]               │
      │  │  └─ switch(node.kind)                             │
      │  │     ├─ declareSymbolAndAddToSymbolTable() [2264]  │
      │  │     │  └─ switch(container.kind)                  │
      │  │     │     ├─ declareModuleMember() [887]          │
      │  │     │     │  └─ declareSymbol(exports/locals)     │
      │  │     │     ├─ declareSourceFileMember() [...]      │
      │  │     │     ├─ declareClassMember() [...]           │
      │  │     │     └─ declareSymbol() [749]                │
      │  │     │        ├─ getDeclarationName() [661]        │
      │  │     │        ├─ createSymbol() [630]              │
      │  │     │        │  └─ new Symbol(flags, name)        │
      │  │     │        └─ addDeclarationToSymbol() [635]    │
      │  │     │           └─ symbol.declarations.push(node) │
      │  │     │              node.symbol = symbol           │
      │  │     └─ bindBinaryExpressionFlow() / etc.          │
      │  │        └─ createFlowMutation() [1406]             │
      │  │           └─ createFlowNode(Assignment,…) [495]   │
      │  │                                                   │
      │  └─ getContainerFlags(node) ?                        │
      │     ├─ nonzero → bindContainer(node, flags) [953]    │
      │     │  │  ─ saves container/blockScopeContainer      │
      │     │  │  ─ updates container, blockScopeContainer   │
      │     │  │  ─ node.locals = new Map()  [SymbolTable]   │
      │     │  │  ─ addToContainerChain(node) [2256]         │
      │     │  │  ─ if IsControlFlowContainer:               │
      │     │  │       currentFlow = FlowStart               │
      │     │  │       currentReturnTarget = BranchLabel     │
      │     │  ├─ bindChildren(node) [1096] ─────────────────┤
      │     │  └─ restores saved state                       │
      │     │                                                │
      │     └─ zero → bindChildren(node) [1096] ────────────►┤
      │        └─ switch(node.kind)                          │
      │           ├─ IfStatement → bindIfStatement() [1578]  │
      │           │  ├─ createBranchLabel() ×3  [1356]       │
      │           │  ├─ bindCondition() [1487]               │
      │           │  │  ├─ doWithConditionalBranches(bind,…) │
      │           │  │  └─ createFlowCondition() [1380] ×2   │
      │           │  │     └─ createFlowNode(True/False,…)   │
      │           │  ├─ finishFlowLabel() [1422] ×3          │
      │           │  ├─ bind(thenStatement) ────────────────►┘
      │           │  ├─ addAntecedent() [1373] ×2
      │           │  └─ bind(elseStatement)  (recursive)
      │           │
      │           ├─ WhileStatement → bindWhileStatement() [1515]
      │           │  ├─ createLoopLabel() [1360]
      │           │  ├─ createBranchLabel() ×2
      │           │  ├─ addAntecedent() (pre-loop)
      │           │  ├─ bindCondition()
      │           │  ├─ bindIterativeStatement() → bind(body)
      │           │  ├─ addAntecedent() (back-edge)
      │           │  └─ finishFlowLabel() (post-loop)
      │           │
      │           ├─ ForStatement → bindForStatement() [1541]
      │           │  ├─ createLoopLabel() + createBranchLabel() ×3
      │           │  ├─ bind(initializer)
      │           │  ├─ addAntecedent() (loop entry)
      │           │  ├─ bindCondition()
      │           │  ├─ bindIterativeStatement() → bind(body)
      │           │  ├─ bind(incrementor)
      │           │  ├─ addAntecedent() (back-edge)
      │           │  └─ finishFlowLabel() (post-loop)
      │           │
      │           ├─ ReturnStatement/ThrowStatement
      │           │  └─ bindReturnOrThrow() [1592]
      │           │     ├─ bind(expression)
      │           │     ├─ addAntecedent(currentReturnTarget, currentFlow)
      │           │     └─ currentFlow = unreachableFlow
      │           │
      │           ├─ BreakStatement/ContinueStatement
      │           │  └─ bindBreakOrContinueStatement() [1625]
      │           │     └─ bindBreakOrContinueFlow()
      │           │        ├─ addAntecedent(target, currentFlow)
      │           │        └─ currentFlow = unreachableFlow
      │           │
      │           ├─ TryStatement → bindTryStatement() [1639]
      │           │  ├─ createBranchLabel() ×3
      │           │  ├─ bind(tryBlock) [with exceptionTarget set]
      │           │  ├─ bind(catchClause) [with new exceptionTarget]
      │           │  ├─ bind(finallyBlock) [merged label of all exits]
      │           │  └─ createReduceLabel() ×2-3 [1364]
      │           │     └─ createFlowNode(ReduceLabel,…)
      │           │
      │           └─ default → bindEachChild(node) [1092]
      │              └─ forEachChild(node, bind)  ──────────► (recursive)
      │
      ├─ delayedBindJSDocTypedefTag()
      └─ bindJSDocImports()
```

---

## 7. Key Invariants to Remember

1. **`bind` is the only entry point for recursion** — all statement handlers call `bind(child)`, never `bindWorker` or `bindChildren` directly.

2. **Symbol tables are `Map<__String, Symbol>`** — `__String` is a branded `string` type; names get `__`-prefixed to avoid collisions with `Object.prototype` properties.

3. **Two symbols per exported declaration** — `declareModuleMember` creates a local `Symbol` (with `ExportValue` flag, in `container.locals`) and an export `Symbol` (in `container.symbol.exports`). The checker always resolves `exports` for external consumers.

4. **`currentFlow` is a mutable cursor** — every statement handler reads it as "the flow arriving here" and writes it as "the flow leaving here". Branches split it; labels (`finishFlowLabel`) merge it.

5. **`LoopLabel` nodes accumulate back-edges** — when `addAntecedent(preLoopLabel, currentFlow)` runs at the end of a loop body, it adds the back-edge. The checker sees this as a cycle and widens types accordingly.

6. **`ReduceLabel` decouples finally from its callers** — rather than duplicating the finally CFG for each exit path, the checker replays the finally block's narrowing against each antecedent path at analysis time.

7. **`bindContainer` is the scope-boundary gate** — anything that introduces a new `SymbolTable` (`.locals`, `.exports`, `.members`) goes through here. The checker traverses `lastContainer.nextContainer` to find all locals tables.
