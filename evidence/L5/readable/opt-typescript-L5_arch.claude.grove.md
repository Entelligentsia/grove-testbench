# transcript: Give a complete architectural walkthrough of the TypeScript compiler pipeline from source text to emitted JavaScript and diagnostics — the cross-cutting comp...


💬 I'll load the grove tools first, then systematically walk through each compiler phase.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__map)

💬 Now let me pull outlines for all the major compiler files in parallel.
  ▸ mcp__grove__outline({"file":"src/compiler/program.ts","detail":0})
  ▸ mcp__grove__outline({"file":"src/compiler/scanner.ts","detail":0})
  ▸ mcp__grove__outline({"file":"src/compiler/parser.ts","detail":0})
  ▸ mcp__grove__outline({"file":"src/compiler/binder.ts","detail":0})
  ▸ mcp__grove__outline({"file":"src/compiler/checker.ts","detail":0})
  ▸ mcp__grove__outline({"file":"src/compiler/emitter.ts","detail":0})
  ▸ mcp__grove__outline({"file":"src/compiler/types.ts","detail":0})
  ▸ mcp__grove__outline({"file":"src/compiler/types.ts","detail":0,"kind":"interface"})
  ▸ mcp__grove__source({"file":"src/compiler/scanner.ts","name":"createScanner"})
  ▸ mcp__grove__source({"file":"src/compiler/program.ts","name":"createProgram"})

💬 Let me search for the key entry-point functions across all phases.
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"createScanner"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"createSourceFile"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"bindSourceFile"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"createTypeChecker"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"emitFiles"})
  ▸ mcp__grove__symbols({"dir":"src/compiler/scanner.ts","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src/compiler/binder.ts","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"src/compiler/checker.ts","name":"createTypeChecker","nameContains":true})

💬 Let me use Bash to locate the key function definitions precisely, then read them with grove.
  ▸ Bash(grep -n "^function createScanner\|^export function createScanner\|^    function createScanner\|createScanner = " src/compiler/scanner.ts | head -5)
  ▸ Bash(grep -n "^function createBinder\|^export function createBinder\|^    function createBinder\|createBinder =" src/compiler/binder.ts | head -5 && grep -n "^fun...)
  ▸ Bash(grep -n "^function createTypeChecker\|^export function createTypeChecker" src/compiler/checker.ts | head -5)
  ▸ Bash(grep -n "^function emitFiles\|^export function emitFiles\|^    function emitFiles" src/compiler/emitter.ts | head -5 && grep -n "^export function createPrint...)

💬 Let me use grove with nameContains to locate the key functions.
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"createScanner","nameContains":true})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"createTypeChecker","nameContains":true})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"emitFiles","nameContains":true})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"bindSourceFile","nameContains":true})
  ▸ mcp__grove__outline({"file":"src/compiler/scanner.ts","detail":1})
  ▸ mcp__grove__map({"dir":"src/compiler","name":"Program"})

💬 Let me read key sections of the large files directly, starting with the scanner factory and parser entry.
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)

💬 Now let me find the binder's main entry point and the key parser, checker, emitter, and program entry-point signatures.
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/binder.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/emitter.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/emitter.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/emitter.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/emitter.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ mcp__grove__outline({"file":"src/compiler/transformers","detail":0})
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/transformers)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","kind":"function","name":"emit","nameContains":true})
  ▸ mcp__grove__symbols({"dir":"src/compiler","kind":"function","name":"transformNodes"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"transformNodes","nameContains":true})
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/emitter.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"getSemanticDiagnostics","nameContains":true})

💬 Let me find the `program.emit` function and key checker methods.
  ▸ mcp__grove__symbols({"dir":"src/compiler/program.ts","kind":"function","name":"emit"})
  ▸ mcp__grove__symbols({"dir":"src/compiler/checker.ts","kind":"function","name":"checkSourceFile"})
  ▸ mcp__grove__symbols({"dir":"src/compiler/checker.ts","kind":"function","name":"getTypeAtLocation"})
  ▸ mcp__grove__source({"file":"src/compiler/checker.ts","name":"checkSourceFile"})
  ▸ mcp__grove__source({"file":"src/compiler/checker.ts","name":"getTypeAtLocation"})
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"TypeChecker"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/checker.ts)
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"Node"})
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"Symbol"})

💬 Now let me get the remaining key type structures and look at the transformer chain.
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"Type"})
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"SourceFile"})
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"FlowLabel"})

💬 Now let me look at the transformer wiring and the checker's return object to complete the picture.
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"EmitTransformers"})
  ▸ mcp__grove__source({"file":"src/compiler/types.ts","name":"Signature"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/emitter.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/emitter.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"getTransformers","nameContains":true})

💬 Let me get the program `emit` implementation and the transformer-chain entry point.
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"getEmitTransformers","nameContains":true})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"getScriptTransformers","nameContains":true})
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"getEmitHost","nameContains":true})
  ▸ Read(/home/bench/repos/typescript/src/compiler/transformer.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/transformer.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/transformer.ts)

💬 Now let me find the program's `emit` function.
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler/program.ts","name":"emit","nameContains":true})
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/program.ts)

💬 I now have all the data needed. Let me compose the full architectural walkthrough.  ---  # TypeScript Compiler: Complete Architecture  ## 0. The Big Picture ...

──────── RESULT (success, 514751ms, 106 turns) ────────
I now have all the data needed. Let me compose the full architectural walkthrough.

---

# TypeScript Compiler: Complete Architecture

## 0. The Big Picture

The compiler is a **five-phase pipeline** wrapped by a `Program` conductor. Every phase is implemented as a closure factory returning an interface, so no phase holds a reference to the next one — the orchestration lives entirely in `Program.emitWorker`.

```
source text
    │
    ▼
[1] createScanner()        scanner.ts:1022     text → token stream
    │ SyntaxKind tokens
    ▼
[2] Parser.parseSourceFile()  parser.ts         tokens → SourceFile (AST)
    │ Node / NodeArray
    ▼
[3] bindSourceFile()       binder.ts:502       AST → Symbol table + FlowNodes
    │ Symbol / FlowNode
    ▼
[4] createTypeChecker()    checker.ts:1486     type inference + diagnostics
    │ Type / Signature / Diagnostic[]
    ▼
[5] emitFiles()            emitter.ts:752      transformed AST → .js / .d.ts
         │
    transformNodes()       transformer.ts      AST ──► AST (per-pass)
         │
    createPrinter()        emitter.ts:1211     AST ──► text + source map
```

---

## 1. Program — the orchestrator

**File:** `src/compiler/program.ts`

```
createProgram()    program.ts:1514
  ├─ tryReuseStructureFromOldProgram()   :2306 – incremental reuse
  ├─ processRootFile() / findSourceFile()  – load & parse each file (lazily)
  │     ↳ host.getSourceFile()  →  createSourceFile()  (parser entry)
  ├─ processImportedModules()  – resolve imports, recurse
  ├─ const program: Program = { ... }  :1876  – assembled
  │     .getTypeChecker()    :2684  → lazy createTypeChecker(program)
  │     .getSyntacticDiagnostics()    – from SourceFile.parseDiagnostics
  │     .getSemanticDiagnostics()     – triggers checker
  │     .emit()              :2688   → emitWorker()
  └─ verifyCompilerOptions()
```

Key types from `types.ts`:

| Type | Location | Purpose |
|------|----------|---------|
| `Program` | types.ts:4703 | public interface; extends `TypeCheckerHost` |
| `CompilerOptions` | types.ts:7403 | all `--xxx` flags |
| `CreateProgramOptions` | types.ts:7741 | structured arg to `createProgram` |
| `EmitResult` | types.ts:5033 | `{ emitSkipped, diagnostics, emittedFiles }` |
| `ResolvedProjectReference` | types.ts:4957 | project-references graph node |

**Incremental reuse.** `tryReuseStructureFromOldProgram()` (`program.ts:2306`) compares imports, triple-slash refs, and type-reference directives against the prior `Program`. If nothing module-relevant changed, `structureIsReused = StructureIsReused.Completely` and the old `SourceFile` objects are reused verbatim. If only file bodies changed, binder/checker re-run but module graph is kept (`SafeModules`).

---

## 2. Scanner — source text to tokens

**File:** `src/compiler/scanner.ts`

```
export function createScanner(     scanner.ts:1022
    languageVersion, skipTrivia, languageVariant?,
    textInitial?, onError?, start?, length?
): Scanner
```

`createScanner` is a **one-per-parser closure** (the `Parser` namespace re-uses a single shared instance, line 1444 of parser.ts). All state lives in closure-local `var`s:

```typescript
var text: string;         // the source text
var pos: number;          // current scan position (end of last token)
var end: number;          // end of text
var fullStartPos: number; // start of trivia before current token
var tokenStart: number;   // start of actual token text
var token: SyntaxKind;    // current token kind
var tokenValue: string;   // cooked value (string/identifier)
var tokenFlags: TokenFlags; // ContainsUnicode, OctalLiteral, etc.
```

The returned `Scanner` interface (`scanner.ts:51`) exposes:

| Method | Line | Role |
|--------|------|------|
| `scan()` | :100 | advance one token; dispatches on char codes |
| `reScanGreaterToken()` | :80 | re-lex `>>` / `>>>` in type positions |
| `reScanSlashToken()` | :81 | re-lex `/` as regex literal |
| `reScanTemplateToken()` | :85 | re-lex `}` back as template middle/tail |
| `reScanJsxToken()` | :91 | re-lex inside JSX text |
| `lookAhead<T>(cb)` | :121 | speculative scan: save/restore position |
| `tryScan<T>(cb)` | :131 | speculative + keep on success |
| `scanRange<T>(start, length, cb)` | :125 | re-scan a subrange |

**Token kind.** `SyntaxKind` is a 400+ member enum (defined in `types.ts`). Every leaf in the AST and every punctuation/keyword has a distinct member. The scanner maps char codes to `SyntaxKind` values in one large `switch` inside `scan()`.

Re-scanning is necessary because TypeScript's grammar is context-sensitive: `>>` is either right-shift or two closing `>` in `Array<Array<T>>`.

---

## 3. Parser — tokens to AST

**File:** `src/compiler/parser.ts`

**Public entry:**

```typescript
export function createSourceFile(          // parser.ts:1344
    fileName: string,
    sourceText: string,
    languageVersionOrOptions: ScriptTarget | CreateSourceFileOptions,
    setParentNodes = false,
    scriptKind?: ScriptKind,
): SourceFile
```

This delegates to the singleton `Parser` namespace (`parser.ts:1437`) which wraps a single shared `Scanner`:

```
Parser (namespace, parser.ts:1437)
  var scanner = createScanner(ScriptTarget.Latest, skipTrivia:true)  :1444
  var factory  = createNodeFactory(NoParenthesizerRules|…, baseNodeFactory)  :1470
  │
  parseSourceFile()      → initializeState() → parseSourceFileWorker()
  parseSourceFileWorker()
    ├─ parseList(StatementListElements, parseStatement)
    ├─ parseStatement() → dispatches on currentToken
    │     ├─ parseVariableStatement(), parseFunctionDeclaration(), parseClassDeclaration(), …
    │     └─ parseExpression() (Pratt-style with precedence climbing)
    ├─ parseExpected(SyntaxKind.X)  – advances + error if mismatch
    ├─ parseOptionalToken(SyntaxKind.X)  – advance if match
    └─ createMissingNode()  – error recovery, always returns a node
```

**Error recovery.** The parser never throws. `createMissingNode` (`parser.ts:2617`) inserts a zero-width node with `ParseError` flag so the AST is always complete.

**Incremental parsing.** `IncrementalParser.updateSourceFile` (`parser.ts:~10085`) accepts a `TextChangeRange` and provides a `SyntaxCursor` (`parser.ts:10445`) that replays old nodes when they aren't in the changed range. The parser checks `canReuseNode()` before invoking the scanner, making re-parse of unchanged regions O(unchanged nodes).

**Key AST data structures** (`types.ts`):

| Type | Line | Description |
|------|------|-------------|
| `Node` | 942 | base: `kind`, `flags`, `transformFlags`, `parent`, `emitNode` |
| `NodeArray<T>` | 1589 | `T[] & ReadonlyTextRange` with `pos`/`end` |
| `SourceFile` | 4320 | top-level node; carries `statements`, `text`, `lineMap`, `parseDiagnostics`, `imports`, `referencedFiles` |
| `Identifier` | 1701 | `escapedText: __String` + source range |
| `Declaration` | 1756 | anything that introduces a name; `symbol?: Symbol` |
| `Expression` / `Statement` | 2396 / 3321 | abstract AST categories |
| `FunctionLikeDeclarationBase` | 2063 | shared shape for functions, methods, arrows |
| `FlowContainer` | 973 | nodes that carry `flowNode?: FlowNode` |
| `LocalsContainer` | 967 | nodes that carry `locals?: SymbolTable` |

Every node stores its **source range** (`pos`, `end`) inherited from `ReadonlyTextRange`. The parser sets these from the scanner's `fullStartPos`/`end` at node construction.

---

## 4. Binder — symbols and control flow

**File:** `src/compiler/binder.ts`

**Public API:**

```typescript
// binder.ts:499-507
const binder = /* @__PURE__ */ createBinder();   // singleton

export function bindSourceFile(file: SourceFile, options: CompilerOptions): void {
    performance.mark("beforeBind");
    binder(file, options);                        // closure call
    performance.mark("afterBind");
    performance.measure("Bind", …);
}
```

`createBinder()` at `:509` returns the inner `bindSourceFile` function (`:571`) which closes over:

```typescript
var file, options, languageVersion;
var parent: Node;
var container: IsContainer | EntityNameExpression;   // current symbol scope
var blockScopeContainer: IsBlockScopedContainer;     // for let/const/class
var lastContainer: HasLocals;

// control flow
var currentFlow: FlowNode;
var currentBreakTarget, currentContinueTarget: FlowLabel;
var currentReturnTarget, currentExceptionTarget: FlowLabel;
var currentTrueTarget, currentFalseTarget: FlowLabel;
var activeLabelList: ActiveLabel;           // binder.ts:321
```

**Symbol creation.** `bind(node)` walks every node recursively. For declarations (`FunctionDeclaration`, `ClassDeclaration`, `VariableDeclaration`, etc.) it calls `declareSymbol()` which either creates a new `Symbol` or merges into an existing one:

```
bind(SourceFile)
  → bindWorker(node)  – dispatches on SyntaxKind
  → bindChildren(node) – recursively binds children
      bindEach(statements)
```

`Symbol` (`types.ts:6037`) core fields:
```typescript
interface Symbol {
    flags: SymbolFlags;           // Value | Type | Namespace | Alias | …
    escapedName: __String;        // interned name
    declarations?: Declaration[]; // all declaration sites
    valueDeclaration?: Declaration;
    members?: SymbolTable;        // class/interface instance members
    exports?: SymbolTable;        // module exports
    parent?: Symbol;
}
```

`SymbolTable` is `Map<__String, Symbol>`. Every `LocalsContainer` node (`SourceFile`, `FunctionDeclaration`, `Block`, etc.) gets a `.locals` SymbolTable. The binder also sets `.parent` on every node (required by the checker to walk up the tree).

**Control flow graph.** The binder builds a graph of `FlowNode` objects (`types.ts:4182`) on each `FlowContainer` node:

| FlowNode type | Line | Represents |
|---------------|------|------------|
| `FlowStart` | 4199 | function/file entry |
| `FlowLabel` | 4206 | merge point (if-join, loop-header) |
| `FlowAssignment` | 4214 | `x = expr` narrows `x`'s type |
| `FlowCondition` | 4228 | `if (cond)` — true/false branch |
| `FlowCall` | 4220 | call to assertion function (narrows) |
| `FlowSwitchClause` | 4235 | individual case of a switch |
| `FlowArrayMutation` | 4250 | `.push()` / `[i]=` on an array |
| `FlowUnreachable` | 4190 | dead code |

Each `FlowLabel` has an `antecedent: FlowNode[]`, forming a DAG. The checker traverses this DAG backward from a use-site to compute the **narrowed type** at that point.

The binder also produces `file.bindDiagnostics` (duplicate declarations, unreachable code, etc.) and `file.classifiableNames` (for quick class/interface lookup).

---

## 5. Type Checker — inference, narrowing, diagnostics

**File:** `src/compiler/checker.ts`

**Entry:**

```typescript
export function createTypeChecker(host: TypeCheckerHost): TypeChecker  // checker.ts:1486
```

`TypeCheckerHost` is the `Program` interface slice the checker needs: `getSourceFiles()`, `getCompilerOptions()`, `getResolvedModule()`, etc. (`types.ts:5042`).

The body of `createTypeChecker` is a ~53,000-line closure that initialises:

```typescript
// allocation pools (avoid object polymorphism)
var Symbol    = objectAllocator.getSymbolConstructor();
var Type      = objectAllocator.getTypeConstructor();
var Signature = objectAllocator.getSignatureConstructor();

// side tables (keyed by id, not by node identity)
var symbolLinks: SymbolLinks[] = [];  // index = symbol.id
var nodeLinks: NodeLinks[] = [];      // index = node.id

// caches
var tupleTypes, unionTypes, intersectionTypes, stringLiteralTypes, …;

// relation caches (assignability memoisation)
var subtypeRelation    = new Map<string, RelationComparisonResult>();
var assignableRelation = new Map<string, RelationComparisonResult>();
var identityRelation   = new Map<string, RelationComparisonResult>();
var comparableRelation = new Map<string, RelationComparisonResult>();

// intrinsic types (created eagerly)
var anyType, unknownType, stringType, numberType, booleanType, …;
var neverType, voidType, undefinedType, nullType, …;

// name resolution
var globals: SymbolTable = createSymbolTable();
var resolveName = createNameResolver({ globals, … });

// sub-components
var emitResolver  = createResolver();
var nodeBuilder   = createNodeBuilder();
var checkBinaryExpression = createCheckBinaryExpressionFlow();
var evaluate      = createEvaluator(…);
```

**Type data model** (`types.ts`):

```
Type (6439)  { flags: TypeFlags; id: TypeId; symbol; aliasSymbol; … }
 ├── IntrinsicType (6459)       string / number / boolean / any / unknown / never / void
 ├── LiteralType (6482)         "hello" / 42 / true
 ├── UniqueESSymbolType (6487)  unique symbol
 ├── EnumType (6505)
 ├── ObjectType (6600)          objectFlags: ObjectFlags
 │    ├── InterfaceType (6612)  typeParameters, outerTypeParameters, localTypeParameters
 │    │    └── InterfaceTypeWithDeclaredMembers (6629)
 │    ├── TypeReference (6646)  target: GenericType; typeArguments
 │    ├── GenericType (6683)    instantiations cache
 │    ├── TupleType (6702)      minLength, hasRestElement, …
 │    ├── AnonymousType (6767)  call/construct sigs, index infos
 │    ├── MappedType (6779)     {[K in T]: V}
 │    └── ReverseMappedType(6796)
 ├── UnionType (6741)           types: Type[]
 ├── IntersectionType (6756)    types: Type[]
 ├── TypeParameter (6864)       constraint, default, isThisType
 ├── IndexedAccessType (6900)   objectType[indexType]
 ├── ConditionalType (6940)     checkType extends extendsType ? T : F
 ├── TemplateLiteralType (6958) `${A}${B}` types
 └── SubstitutionType (6975)    type parameter + constraint intersection (deferred)

Signature (7019)  { declaration; typeParameters; parameters; resolvedReturnType; … }
IndexInfo  (7067)  { keyType; type; isReadonly; declaration }
```

**Checking flow:**

```
program.getSemanticDiagnostics(file)
  → typeChecker.getDiagnostics(file)
      → checkSourceFile(file)         (inner fn, not exported by grove)
          → checkSourceElements(file.statements)
              → checkStatement(stmt)
                  ├── checkVariableStatement → checkVariableDeclaration → checkExpression
                  ├── checkFunctionDeclaration → checkFunctionLikeDeclaration
                  │       → checkBody → checkStatement…
                  ├── checkClassDeclaration → checkClassLikeDeclaration
                  └── checkExpressionStatement → checkExpression(expr)
                           → getTypeOfExpression(expr)
                               ├── getContextualType() – inward contextual type propagation
                               ├── resolveSymbol() / getTypeOfSymbol()
                               └── narrowType() – walks FlowNode DAG from currentFlow
```

**Symbol resolution.** `resolveSymbol()` (`:4295`) follows `SymbolFlags.Alias` chains. `getMergedSymbol()` (`:5307`) joins declaration-merged symbols (e.g., two `interface Foo` declarations). `resolveExternalModuleSymbol()` (`:4985`) resolves `export = X`.

**Type instantiation.** Generic types are instantiated lazily: `instantiateType(type, mapper)` (`:21014`) substitutes `TypeMapper` (a function `TypeParameter → Type`) into a generic type, with a string-keyed cache. Relation checking (`isTypeAssignableTo`) drives much of this.

**Flow narrowing.** `getFlowTypeOfReference(reference, declaredType, initialType, flowNode)` walks the flow graph backward from `flowNode`, computing the narrowed type at each `FlowCondition` / `FlowAssignment` / `FlowCall` node. Results are cached per `flowNode.id` in `flowLoopCaches`.

**NodeLinks / SymbolLinks.** The checker never mutates AST nodes or Symbol objects directly. Instead it uses two parallel side-table arrays:

```typescript
NodeLinks (types.ts:6272)   // checker.ts: nodeLinks[node.id]
  resolvedType?:      Type
  resolvedSymbol?:    Symbol
  resolvedSignature?: Signature
  contextFreeType?:   Type
  flags:              NodeCheckFlags  // TypeChecked, ContextChecked, …

SymbolLinks (types.ts:6058) // checker.ts: symbolLinks[symbol.id]
  type?:              Type            // value type
  declaredType?:      Type            // declared/class instance type
  typeParameters?:    TypeParameter[]
  instantiations?:    Map<string, Type>
  target?:            Symbol          // alias target
```

**The TypeChecker returned object** (`types.ts:5073`) exposes ~150 public/internal methods including `getTypeAtLocation`, `getSymbolAtLocation`, `getSignaturesOfType`, `typeToString`, `getDiagnostics`, `getEmitResolver`.

---

## 6. Transformer chain — AST to AST

**File:** `src/compiler/transformer.ts`

The transformer stage transforms the typed AST into an AST that is safe for JavaScript emission. It is built by `getTransformers()`:

```typescript
export function getTransformers(           // transformer.ts:120
    compilerOptions, customTransformers?, emitOnly?
): EmitTransformers {
    return {
        scriptTransformers:      getScriptTransformers(…),   // .ts → .js AST
        declarationTransformers: getDeclarationTransformers(…), // .d.ts AST
    };
}
```

**`scriptTransformers` pipeline** (applied in order, `transformer.ts:127–189`):

```
custom.before transformers
transformTypeScript           – erase type annotations, enums, namespaces
transformLegacyDecorators     – (if experimentalDecorators)
transformJsx                  – JSX → React.createElement / jsxs()
transformESNext               – (if target < ESNext)
transformESDecorators         – TC39 decorator proposal
transformClassFields          – class field declarations
transformES2021               – logical assignment (&&=, ||=, ??=)
transformES2020               – optional chaining (?.), nullish coalescing (??)
transformES2019               – optional catch binding
transformES2018               – async iteration, object spread/rest
transformES2017               – async/await → generators
transformES2016               – exponentiation (**)
transformES2015               – classes, arrow functions, destructuring, …
transformGenerators           – (if target < ES2015)
getModuleTransformer(kind)    – CommonJS / ESM / System / AMD
custom.after transformers
```

**`declarationTransformers`:**

```
transformDeclarations         – strip implementations, synthesise .d.ts
custom.afterDeclarations
```

**Execution.** `transformNodes()` (`transformer.ts:236`) wraps the chain in a `TransformationContext` (types.ts:9599) which provides `hoistVariableDeclaration`, `startLexicalEnvironment`, `endLexicalEnvironment`, `visitNode`/`visitEachChild`, and `onSubstituteNode`/`onEmitNode` hooks. Each transformer factory receives the context, returns a `Transformer<SourceFile | Bundle>`.

---

## 7. Emitter — AST to text + source maps

**File:** `src/compiler/emitter.ts`

**Entry:**

```typescript
export function emitFiles(             // emitter.ts:752
    resolver: EmitResolver,
    host: EmitHost,
    targetSourceFile: SourceFile | undefined,
    { scriptTransformers, declarationTransformers }: EmitTransformers,
    emitOnly, onlyBuildInfo, forceDtsEmit?, skipBuildInfo?,
): EmitResult
```

Internal flow:

```
emitFiles()
  forEachEmittedFile(host, emitSourceFileOrBundle, …)
    emitSourceFileOrBundle()
      ├── emitJsFileOrBundle()          emitter.ts:821
      │     transformNodes(…, scriptTransformers)    → TransformationResult
      │     createPrinter(printerOptions, hooks)      emitter.ts:1211
      │     printSourceFileOrBundle()
      │       writeFile() → writer.getText() → host.writeFile()
      │     transform.dispose()  – clean up emitNode annotations
      │
      ├── emitDeclarationFileOrBundle()  emitter.ts:886
      │     transformNodes(…, declarationTransformers)
      │     createPrinter(…)
      │     printSourceFileOrBundle()
      │
      └── emitBuildInfo()               emitter.ts:808
            writeFile(tsbuildinfo)
```

**`createPrinter()`** (`emitter.ts:1211`) is the AST-to-text engine:

```
createPrinter(printerOptions, handlers: PrintHandlers): Printer
  var writer: EmitTextWriter    – buffered output
  var sourceMapGenerator        – source map accumulation

  print(hint, node, sourceFile)
    pipelineEmit(hint, node)    – main dispatch
      emitNode(hint, node)
        handlers.onEmitNode?.(hint, node, emitNode)   – transformer hook
          ↳ substituteNode(hint, node)                – node substitution hook
          ↳ emitNodeWithSourceMap(hint, node)
              emitBinaryExpression / emitBlock / emitFunctionDeclaration / …
                write(text) / writeKeyword() / writeOperator()
                emitToken(kind, pos) → writer.write(tokenToString(kind))
                emitList(nodes, format) → iterates NodeArray
```

`EmitTextWriter` (`types.ts:9959`) accumulates text in a string buffer, tracking column/line for source map purposes. `SourceMapGenerator` (`types.ts:9899`) records the V3 source-map mappings. After printing, the source map is base64-encoded and either embedded as a `//# sourceMappingURL=data:...` comment or written as a `.map` file.

**EmitNode.** Rather than mutating the real AST, transformers annotate nodes via `node.emitNode: EmitNode` (`types.ts:8312`). This carries synthesized comments, source-map ranges, emit helpers (like `__awaiter`), and substitution nodes. `createPrinter` reads `emitNode` instead of node properties wherever they differ.

**EmitResolver** (`types.ts:5897`). Created by `checker.createResolver()`, it answers the printer's questions about types without exposing the full checker API: `isDeclarationVisible`, `isEntityNameVisible`, `getTypeReferenceSerializationKind`, `hasGlobalName`, etc. This is the only coupling point between the emit phase and the type checker.

---

## 8. Diagnostic model

Diagnostics are accumulated at multiple phases and collected by `Program`:

| Phase | Where stored | Collected via |
|-------|-------------|---------------|
| Scanner | passed to `onError` callback | `parseDiagnostics` |
| Parser | `SourceFile.parseDiagnostics` | `getSyntacticDiagnostics()` |
| Binder | `SourceFile.bindDiagnostics` | `getSyntacticDiagnostics()` (included) |
| Checker | `checker.diagnostics` collection | `getSemanticDiagnostics()` |
| Declaration emit | `declarationTransform.diagnostics` | `getDeclarationDiagnostics()` |
| Program options | `programDiagnostics` | `getOptionsDiagnostics()` / `getGlobalDiagnostics()` |

`Diagnostic` (`types.ts:7259`) ⊃ `DiagnosticRelatedInformation` (`types.ts:7290`): `{ file, start, length, messageText, category, code }`. `DiagnosticMessage` (`types.ts:7218`) lives in `diagnosticMessages.json`; all messages are keyed by numeric code and carry a `DiagnosticCategory` (Error/Warning/Message/Suggestion).

---

## 9. Unified architecture diagram

```
┌─────────────────────────────── Program ────────────────────────────────────────┐
│  createProgram()  program.ts:1514                                               │
│                                                                                 │
│  files: SourceFile[]   ◄──────── processRootFile / findSourceFile              │
│  filesByName: Map<Path, SourceFile>                                             │
│  resolvedModules: Map<Path, ModeAwareCache<…>>                                  │
│                                                                                 │
│  ┌──────────┐    ┌──────────────┐   ┌────────────────┐   ┌──────────────────┐  │
│  │ SCANNER  │    │   PARSER     │   │    BINDER      │   │  TYPE CHECKER    │  │
│  │          │    │              │   │                │   │                  │  │
│  │createScan│───▶│Parser.parse  │──▶│ bindSourceFile │──▶│createTypeChecker │  │
│  │ner()     │    │ SourceFile() │   │  binder.ts:502 │   │ checker.ts:1486  │  │
│  │ :1022    │◀───│ parser.ts    │   │                │   │                  │  │
│  │          │    │ :1344        │   │ Produces:       │   │ Produces:        │  │
│  │ Produces:│    │              │   │ Symbol table   │   │ Type objects     │  │
│  │ tokens   │    │ Produces:    │   │ FlowNode DAG   │   │ Signature objs   │  │
│  │ SyntaxKd │    │ SourceFile   │   │ parent links   │   │ NodeLinks/Sym-   │  │
│  │ TokenFlgs│    │ Node tree    │   │ bindDiagnostics│   │ bolLinks caches  │  │
│  │          │    │ parseDiagnos │   │                │   │ Diagnostics[]    │  │
│  └──────────┘    └──────────────┘   └────────────────┘   └──────────────────┘  │
│                                                                 │               │
│                                                          EmitResolver           │
│                                                                 │               │
│  ┌────────────────────────────── EMIT ─────────────────────────▼──────────┐    │
│  │  emitWorker()   program.ts:2718                                        │    │
│  │    getTransformers()  transformer.ts:120                               │    │
│  │    emitFiles()        emitter.ts:752                                   │    │
│  │                                                                        │    │
│  │  ┌────────────────────────────────────────────┐                       │    │
│  │  │  scriptTransformers  (transformer.ts:127)   │                       │    │
│  │  │  ─────────────────────────────────────────  │                       │    │
│  │  │  custom.before                              │                       │    │
│  │  │  transformTypeScript    (strip types/enums) │                       │    │
│  │  │  transformLegacyDecorators (if opted-in)   │                       │    │
│  │  │  transformJsx           (JSX → calls)       │                       │    │
│  │  │  transformESNext … transformES2015          │                       │    │
│  │  │  transformGenerators   (if target < ES2015) │                       │    │
│  │  │  getModuleTransformer() (CJS/ESM/System)   │                       │    │
│  │  │  custom.after                               │                       │    │
│  │  └─────────────────────┬──────────────────────┘                       │    │
│  │                         │  TransformationResult (transformed AST)      │    │
│  │                         ▼                                              │    │
│  │  ┌────────────────────────────────────────────┐                       │    │
│  │  │  createPrinter()    emitter.ts:1211         │                       │    │
│  │  │  ─────────────────────────────────────────  │                       │    │
│  │  │  pipelineEmit()                             │                       │    │
│  │  │    substituteNode() ◄── transformer hooks   │                       │    │
│  │  │    emitNode() ──► emitBinaryExpression,     │                       │    │
│  │  │                   emitFunctionDeclaration,  │                       │    │
│  │  │                   emitBlock, …              │                       │    │
│  │  │    emitTokenWithSourceMap()                 │                       │    │
│  │  │    SourceMapGenerator.addMapping()          │                       │    │
│  │  │    EmitTextWriter.write()                   │                       │    │
│  │  └─────────────────────┬──────────────────────┘                       │    │
│  │                         │                                              │    │
│  │          .js + .js.map  │   .d.ts + .d.ts.map (declarationTransform)  │    │
│  │                         ▼                                              │    │
│  │              host.writeFile()                                          │    │
│  └────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘

KEY DATA STRUCTURES
───────────────────
Node          types.ts:942    { kind:SyntaxKind, flags:NodeFlags, parent, emitNode }
SourceFile    types.ts:4320   Node + statements[] + text + lineMap + locals + endFlowNode
Symbol        types.ts:6037   { flags:SymbolFlags, escapedName, declarations[], members, exports }
SymbolLinks   types.ts:6058   { type, declaredType, instantiations, target }   — side-table by id
NodeLinks     types.ts:6272   { resolvedType, resolvedSymbol, resolvedSignature } — side-table by id
FlowNode      types.ts:4182   { flags:FlowFlags, id, node, antecedent }
FlowLabel     types.ts:4206   convergence node; antecedent: FlowNode[]
Type          types.ts:6439   { flags:TypeFlags, id, symbol, aliasSymbol }
Signature     types.ts:7019   { typeParameters, parameters, resolvedReturnType, flags }
Diagnostic    types.ts:7259   { file, start, length, messageText, code, category }
EmitNode      types.ts:8312   { emitFlags, leadingComments, trailingComments, sourceMapRange }
```

---

## Summary of entry points by file and line

| Phase | Factory/entry | File | Line |
|-------|--------------|------|------|
| Scanner creation | `createScanner()` | scanner.ts | 1022 |
| Scanner interface | `Scanner` | scanner.ts | 51 |
| Parse source file (public) | `createSourceFile()` | parser.ts | 1344 |
| Parse source file (internal) | `Parser.parseSourceFile()` (namespace) | parser.ts | 1437 |
| Incremental update | `updateSourceFile()` | parser.ts | 1399 |
| Bind (public) | `bindSourceFile()` | binder.ts | 502 |
| Bind (factory) | `createBinder()` | binder.ts | 509 |
| Type check | `createTypeChecker()` | checker.ts | 1486 |
| Build transformer list | `getTransformers()` | transformer.ts | 120 |
| Script transformers | `getScriptTransformers()` | transformer.ts | 127 |
| Decl transformers | `getDeclarationTransformers()` | transformer.ts | 192 |
| Emit files | `emitFiles()` | emitter.ts | 752 |
| Create printer | `createPrinter()` | emitter.ts | 1211 |
| Create program | `createProgram()` | program.ts | 1514 |
| Program emit method | `emit()` → `emitWorker()` | program.ts | 2688 / 2718 |
| Lazy type checker | `getTypeChecker()` | program.ts | 2684 |
