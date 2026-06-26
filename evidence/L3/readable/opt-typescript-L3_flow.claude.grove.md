# transcript: Trace how the TypeScript compiler turns a source file's text into an abstract syntax tree: name every function it passes through, in order, from where a sour...


💬 I'll load the grove tools first, then trace the parsing pipeline.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)
  ▸ Bash(ls /home/bench/repos/typescript/src/compiler/ | head -30)
  ▸ mcp__grove__symbols({"dir":".","name":"createSourceFile"})
  ▸ mcp__grove__symbols({"dir":".","name":"parseSourceFile"})
  ▸ mcp__grove__symbols({"dir":".","name":"createSourceFile","kind":"function"})
  ▸ mcp__grove__outline({"file":"src/compiler/parser.ts","detail":0})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"createSourceFile"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"parseSourceFile"})
  ▸ mcp__grove__map({"dir":"src/compiler","name":"createSourceFile","nameContains":true})
  ▸ mcp__grove__outline({"file":"src/compiler/parser.ts","detail":1,"kind":"function"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Bash(grep -n "export function createSourceFile\|^function createSourceFile\|^function parseSourceFile\|export function parseSourceFile\|function parseSourceFileWo...)

💬 Let me search for key parser entry points directly in the file.
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"parseSourceFileWorker"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"initializeState"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","nameContains":true,"name":"parseSourceFile"})
  ▸ mcp__grove__symbols({"dir":"src/compiler","nameContains":true,"name":"createSourceFile"})

💬 Grove's symbol index is limited for this large file. Let me read the parser directly to trace the call chain.
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)

💬 Good. `createSourceFile` calls `Parser.parseSourceFile`. Now let me find that function inside the `Parser` namespace.
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)

💬 Now let me find `nextToken`, `parseList`, `createSourceFile` (inner), and `finishNode`.
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"nextToken"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)

💬 Now let me find `parseList`, `finishNode`, and the scanner's `scan` function.
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"finishNode"})
  ▸ mcp__grove__map({"dir":"src/compiler","name":"finishNode"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)

💬 Now let me find `parseList` and `parseListElement`.
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)

💬 Now let me look at the scanner's `scan` function, which is the innermost step.
  ▸ mcp__grove__outline({"file":"src/compiler/scanner.ts","detail":0,"kind":"function"})
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ mcp__grove__symbols({"dir":"src/compiler","name":"createScanner"})
  ▸ mcp__grove__map({"dir":"src/compiler","name":"createScanner","nameContains":true})
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)

💬 Now let me find the `scan` function body in scanner.ts.
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/scanner.ts)

💬 Let me quickly locate `parseStatement` to confirm its line number.
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)
  ▸ Read(/home/bench/repos/typescript/src/compiler/parser.ts)

💬 I now have everything needed to give the complete trace. Here it is:  ---  ## TypeScript source text → `SourceFile` AST: the complete call chain  All code is...

──────── RESULT (success, 564119ms, 51 turns) ────────
I now have everything needed to give the complete trace. Here it is:

---

## TypeScript source text → `SourceFile` AST: the complete call chain

All code is in `src/compiler/parser.ts` unless noted.

---

### 1. `createSourceFile` — parser.ts:1344 (public API)

The single public entry point. Takes `fileName`, `sourceText`, and a `ScriptTarget | CreateSourceFileOptions`. Records `performance.mark("beforeParse")`, unpacks options, then hands off entirely to the `Parser` singleton namespace:

```
result = Parser.parseSourceFile(fileName, sourceText, languageVersion, ...)
```

The `Parser` namespace is a module-level singleton (not a class) so its scanner and mutable state are shared across calls and reset per call rather than allocated fresh.

---

### 2. `Parser.parseSourceFile` — parser.ts:1603

Top of the `Parser` namespace. Does three things in order:

1. `ensureScriptKind(fileName, scriptKind)` — infers `.ts` / `.tsx` / `.js` / `.d.ts` if `scriptKind` was omitted.
2. `initializeState(...)` — configures all singleton state.
3. `parseSourceFileWorker(...)` — performs the actual parse.
4. `clearState()` — releases references so the GC can collect.

Returns the `SourceFile` from `parseSourceFileWorker`.

---

### 3. `initializeState` — parser.ts:1735

Sets up every piece of mutable parser state before a parse begins:

- Fetches constructor functions from `objectAllocator` and stores them in the closed-over `NodeConstructor`, `TokenConstructor`, `IdentifierConstructor`, `PrivateIdentifierConstructor`, `SourceFileConstructor` vars. Every node allocation goes through these.
- Resets `parseDiagnostics`, `identifiers`, `nodeCount`, `identifierCount`, `contextFlags`, `parsingContext`.
- Configures the shared `scanner` (created once at namespace level via `createScanner` in scanner.ts:1022):
  - `scanner.setText(sourceText)` — loads the source string and resets `pos = 0`.
  - `scanner.setOnError(scanError)` — pipes lexer errors into `parseDiagnostics`.
  - `scanner.setScriptTarget(languageVersion)`
  - `scanner.setLanguageVariant(languageVariant)`
  - `scanner.setScriptKind(scriptKind)`
  - `scanner.setJSDocParsingMode(jsDocParsingMode)`

---

### 4. `parseSourceFileWorker` — parser.ts:1803

Does the real work:

```
nextToken();   // prime: reads the first token from the scanner
const statements = parseList(ParsingContext.SourceElements, parseStatement);
// assert token() === EndOfFileToken
const endOfFileToken = withJSDoc(parseTokenNode<EndOfFileToken>(), ...);
const sourceFile = createSourceFile(fileName, languageVersion, scriptKind, ..., statements, endOfFileToken, ...);
processCommentPragmas / processPragmasIntoFields / attachFileToDiagnostics / ...
```

---

### 5. `nextToken` — parser.ts:2207

```ts
function nextToken(): SyntaxKind {
    if (isKeyword(currentToken) && (scanner.hasUnicodeEscape() || ...))
        parseErrorAt(...);   // escaped keyword is a syntax error
    return nextTokenWithoutCheck();
}
```

---

### 6. `nextTokenWithoutCheck` — parser.ts:2198

```ts
return currentToken = scanner.scan();
```

This is the bridge from the parser to the scanner. Every token advance goes through here.

---

### 7. `scanner.scan` — scanner.ts:1891

The main lexer loop. Runs inside a `while(true)`:

```
fullStartPos = pos;
tokenFlags = TokenFlags.None;
loop:
  tokenStart = pos;
  if (pos >= end) → return EndOfFileToken;
  ch = codePointUnchecked(pos);
  switch(ch):
    whitespace/newlines → if(skipTrivia) { pos++; continue; }  // trivia skipped transparently
    '!'  → ExclamationToken / ExclamationEqualsToken / ExclamationEqualsEqualsToken
    '"' '\'' → scanString() → StringLiteral
    '`'  → scanTemplateAndSetTokenValue() → NoSubstitutionTemplateLiteral / TemplateHead
    '0'-'9' → scanNumber() → NumericLiteral / BigIntLiteral
    'a'-'z' 'A'-'Z' '_' '$' → scanIdentifier:
              scanIdentifierParts()   // consumes rest of identifier
              getIdentifierToken()    // textToKeyword.get(tokenValue) → keyword kind, else Identifier
    ... (every other character → its punctuation SyntaxKind)
  return token = <SyntaxKind>;
```

`skipTrivia` was set to `true` when the parser called `createScanner`, so whitespace and newlines are silently consumed inside the loop and `token` is never a trivia kind during normal parsing.

Key helpers called from `scan`:
- `scanString()` — reads a quoted string literal, handling escapes.
- `scanNumber()` / `scanNumberFragment()` — handles decimal, hex (`0x`), binary (`0b`), octal (`0o`), numeric separators (`_`), and bigint suffix (`n`).
- `scanIdentifierParts()` — walks forward consuming `[a-zA-Z0-9_$\uXXXX]` characters.
- `getIdentifierToken()` — O(1) keyword lookup via a prebuilt `textToKeyword` `Map`.
- `scanTemplateAndSetTokenValue()` — template literal tokenization.

---

### 8. `parseList` — parser.ts:3094

Generic loop for any `NodeArray`:

```ts
function parseList<T extends Node>(kind: ParsingContext, parseElement: () => T): NodeArray<T> {
    parsingContext |= 1 << kind;
    while (!isListTerminator(kind)) {
        if (isListElement(kind, false))
            list.push(parseListElement(kind, parseElement));
        else if (abortParsingListOrMoveToNextToken(kind))
            break;
    }
    return createNodeArray(list, listPos);   // stamps .pos/.end on the array
}
```

`ParsingContext.SourceElements` terminates on `EndOfFileToken`. For each iteration it calls `parseListElement`.

---

### 9. `parseListElement` — parser.ts:3116

```ts
function parseListElement<T>(parsingContext, parseElement): T {
    const node = currentNode(parsingContext);   // incremental reuse?
    if (node) return consumeNode(node) as T;    // yes: advance scanner past it
    return parseElement();                       // no: parse fresh
}
```

`currentNode` (parser.ts:3125) consults the `syntaxCursor` (only non-null during an incremental re-parse via `updateSourceFile`). For a fresh parse, `syntaxCursor` is `undefined` and `currentNode` always returns `undefined`, so `parseElement()` — i.e. `parseStatement` — is always called.

---

### 10. `parseStatement` — parser.ts:7380

A large `switch(token())` that dispatches to the concrete parse function for each statement kind:

| Token | Calls |
|---|---|
| `;` | `parseEmptyStatement()` |
| `{` | `parseBlock()` |
| `var`/`let`/`const`/`using` | `parseVariableStatement()` |
| `function` | `parseFunctionDeclaration()` |
| `class` | `parseClassDeclaration()` |
| `if` | `parseIfStatement()` |
| `do` | `parseDoStatement()` |
| `while` | `parseWhileStatement()` |
| `for` | `parseForOrForInOrForOfStatement()` |
| `return` | `parseReturnStatement()` |
| `switch` | `parseSwitchStatement()` |
| `throw` | `parseThrowStatement()` |
| `try`/`catch`/`finally` | `parseTryStatement()` |
| `debugger` | `parseDebuggerStatement()` |
| `@`/`export`/`import`/`declare`/… | `parseDeclaration()` |
| *(anything else)* | `parseExpressionOrLabeledStatement()` |

---

### 11. Each concrete parse function (e.g. `parseFunctionDeclaration`, `parseIfStatement`, …)

They all share the same structural pattern:

```ts
function parseIfStatement(): IfStatement {
    const pos = getNodePos();              // = scanner.getTokenFullStart()
    const hasJSDoc = hasPrecedingJSDocComment();
    parseExpected(SyntaxKind.IfKeyword);  // consumes 'if', calls nextToken()
    parseExpected(SyntaxKind.OpenParenToken);
    const expression = allowInAnd(parseExpression);   // recursive descent
    parseExpected(SyntaxKind.CloseParenToken);
    const thenStatement = parseStatement();            // recursive
    const elseStatement = parseOptional(SyntaxKind.ElseKeyword) ? parseStatement() : undefined;
    return withJSDoc(finishNode(factoryCreateIfStatement(expression, thenStatement, elseStatement), pos), hasJSDoc);
}
```

`parseExpected` / `parseOptional` / `parseOptionalToken` each call `nextToken()` → `nextTokenWithoutCheck()` → `scanner.scan()` to advance past the consumed token. `getNodePos()` reads `scanner.getTokenFullStart()` — the position including any preceding trivia — to record where this node begins.

Expression parsing descends through: `parseExpression` → `parseAssignmentExpressionOrHigher` → `parseBinaryExpressionOrHigher` → `parseUnaryExpressionOrHigher` → `parseUpdateExpression` → `parseLeftHandSideExpression` → `parseMemberExpressionOrHigher` → `parsePrimaryExpression`, with each level calling `finishNode` on the sub-expression it produces.

---

### 12. `finishNode` — parser.ts:2600

Called to close every completed AST node (statements, expressions, declarations, type nodes, tokens — everything):

```ts
function finishNode<T extends Node>(node: T, pos: number, end?: number): T {
    setTextRangePosEnd(node, pos, end ?? scanner.getTokenFullStart());
    if (contextFlags)
        (node as Mutable<T>).flags |= contextFlags;   // e.g. Ambient, YieldContext
    if (parseErrorBeforeNextFinishedNode) {
        parseErrorBeforeNextFinishedNode = false;
        (node as Mutable<T>).flags |= NodeFlags.ThisNodeHasError;
    }
    return node;
}
```

`setTextRangePosEnd` stamps `node.pos` and `node.end` with byte offsets into the source text. `node.pos` is the full start (before leading trivia); `node.end` is the position of the first character of the *next* token (i.e. `scanner.getTokenFullStart()` at the time `finishNode` is called). This is what gives every AST node its source range.

---

### 13. Inner `createSourceFile` — parser.ts:1978

After `parseList` returns all top-level statements and `parseTokenNode` returns the EOF token, `parseSourceFileWorker` calls this private function:

```ts
function createSourceFile(fileName, languageVersion, scriptKind, isDeclarationFile, statements, endOfFileToken, flags, setExternalModuleIndicator): SourceFile {
    let sourceFile = factory.createSourceFile(statements, endOfFileToken, flags);
    setTextRangePosWidth(sourceFile, 0, sourceText.length);
    setFields(sourceFile);   // .text, .fileName, .languageVersion, .scriptKind, ...
    // if ES module + ContainsPossibleTopLevelAwait:
    sourceFile = reparseTopLevelAwait(sourceFile);   // selective reparse with AwaitContext
    return sourceFile;
}
```

---

### 14. `factory.createSourceFile` (inside `createNodeFactory`)

The node-factory method that actually allocates the `SourceFile` object:

```
baseNodeFactory.createBaseSourceFileNode(SyntaxKind.SourceFile)
  → countNode(new SourceFileConstructor(SyntaxKind.SourceFile, /*pos*/ 0, /*end*/ 0))
```

`SourceFileConstructor` is set during `initializeState` from `objectAllocator.getSourceFileConstructor()`. The result is populated with `.statements`, `.endOfFileToken`, and `flags`, and returned up the chain.

---

### Summary: the ordered call sequence

```
createSourceFile                          parser.ts:1344
  └─ Parser.parseSourceFile              parser.ts:1603
       ├─ ensureScriptKind               (utilities.ts)
       ├─ initializeState                parser.ts:1735
       │    └─ scanner.setText / setOnError / setScriptTarget / …  scanner.ts
       ├─ parseSourceFileWorker          parser.ts:1803
       │    ├─ nextToken                 parser.ts:2207
       │    │    └─ nextTokenWithoutCheck → scanner.scan()  scanner.ts:1891
       │    ├─ parseList(SourceElements, parseStatement)    parser.ts:3094
       │    │    └─ [loop] parseListElement                 parser.ts:3116
       │    │              └─ parseStatement                parser.ts:7380
       │    │                   └─ parse{If,Function,Var,…}Statement
       │    │                        ├─ getNodePos()
       │    │                        ├─ nextToken → scanner.scan  [per token consumed]
       │    │                        ├─ [recursive sub-parses]
       │    │                        └─ finishNode(factory.createXxx(…), pos)  parser.ts:2600
       │    ├─ parseTokenNode<EndOfFileToken>
       │    └─ createSourceFile (inner)  parser.ts:1978
       │         ├─ factory.createSourceFile → new SourceFileConstructor(…)
       │         ├─ setTextRangePosWidth
       │         └─ setFields (+ optional reparseTopLevelAwait)
       └─ clearState                     parser.ts:1780
```
