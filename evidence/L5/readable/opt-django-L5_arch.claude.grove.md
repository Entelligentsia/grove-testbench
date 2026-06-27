# transcript: Give a complete architectural walkthrough of Django's full HTTP request/response lifecycle — the cross-cutting request architecture. Span every subsystem it ...


💬 I'll load the grove tools first, then fan out a parallel exploration across all the subsystems.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now I'll fan out parallel grove queries across all the subsystems simultaneously.
  ▸ mcp__grove__outline({"file":"django/core/handlers/wsgi.py"})
  ▸ mcp__grove__outline({"file":"django/core/handlers/base.py"})
  ▸ mcp__grove__outline({"file":"django/urls/resolvers.py","detail":0})
  ▸ mcp__grove__outline({"file":"django/template/base.py","detail":0})
  ▸ mcp__grove__outline({"file":"django/http/request.py","detail":0})
  ▸ mcp__grove__outline({"file":"django/http/response.py","detail":0})

💬 Good — now I'll fetch all the key method bodies in parallel across every subsystem.
  ▸ mcp__grove__source({"id":"python:django/core/handlers/wsgi.py#__call__@120"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#load_middleware@27"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#_get_response@176"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#resolve_request@302"})
  ▸ mcp__grove__source({"id":"python:django/urls/resolvers.py#resolve@670"})
  ▸ mcp__grove__source({"id":"python:django/urls/resolvers.py#resolve@471"})

💬 Now fetching the template engine, ORM, view layer, and middleware internals in parallel.
  ▸ mcp__grove__source({"id":"python:django/template/base.py#render@169"})
  ▸ mcp__grove__source({"id":"python:django/template/base.py#_render@166"})
  ▸ mcp__grove__source({"id":"python:django/template/base.py#compile_nodelist@179"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/wsgi.py#__init__@57"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#get_response@138"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/wsgi.py#__init__@116"})
  ▸ mcp__grove__outline({"file":"django/template/response.py"})
  ▸ mcp__grove__outline({"file":"django/views/generic/base.py","detail":0})

💬 Now fetching the view dispatch, template response rendering, ORM query path, and template engine loading.
  ▸ mcp__grove__source({"id":"python:django/template/response.py#render@105"})
  ▸ mcp__grove__source({"id":"python:django/template/response.py#rendered_content@82"})
  ▸ mcp__grove__source({"id":"python:django/views/generic/base.py#as_view@82"})
  ▸ mcp__grove__source({"id":"python:django/views/generic/base.py#dispatch@134"})
  ▸ mcp__grove__outline({"file":"django/template/engine.py","detail":0})
  ▸ mcp__grove__outline({"file":"django/db/models/sql/compiler.py","detail":0})

💬 Fetching the remaining load-bearing methods: ORM execution, template loading, and transaction wrapping.
  ▸ mcp__grove__source({"id":"python:django/template/engine.py#get_template@172"})
  ▸ mcp__grove__source({"id":"python:django/template/engine.py#find_template@155"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#execute_sql@1595"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#as_sql@757"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#make_view_atomic@347"})
  ▸ mcp__grove__source({"id":"python:django/views/generic/base.py#render_to_response@191"})
  ▸ mcp__grove__symbols({"dir":"django/db/models","kind":"function","name":"__iter__"})

💬 Two more sources to complete the ORM path.
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#__iter__@420"})
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#__iter__@92"})
  ▸ mcp__grove__source({"id":"python:django/template/base.py#__init__@143"})
  ▸ mcp__grove__source({"id":"python:django/template/base.py#tokenize@419"})
  ▸ mcp__grove__source({"id":"python:django/template/base.py#parse@530"})

💬 I have all the data I need. Here is the complete walkthrough.  ---  ## Django HTTP Request/Response Architecture  ---  ### Phase 0 — Startup: Building the Mi...

──────── RESULT (success, 240702ms, 40 turns) ────────
I have all the data I need. Here is the complete walkthrough.

---

## Django HTTP Request/Response Architecture

---

### Phase 0 — Startup: Building the Middleware Onion

Before the first request arrives, `WSGIHandler.__init__` (`django/core/handlers/wsgi.py:116`) calls `self.load_middleware()`.

**`BaseHandler.load_middleware`** (`django/core/handlers/base.py:27`) assembles a single nested callable — `self._middleware_chain` — by walking `settings.MIDDLEWARE` **in reverse**:

1. Starts with the innermost callable: `_get_response` (sync) or `_get_response_async` (async), wrapped in `convert_exception_to_response`.
2. For each middleware class (outermost last in settings, processed first in the reverse loop):
   - `adapt_method_mode` reconciles sync/async compatibility (`django/core/handlers/base.py:106`).
   - `mw_instance = middleware(adapted_handler)` — each class receives the *next* handler in the chain as its argument. This is the standard WSGI onion pattern.
   - Side-channel hooks are extracted and stored separately:
     - `process_view` → prepended to `self._view_middleware` (so outer middleware runs first)
     - `process_template_response` → appended to `self._template_response_middleware`
     - `process_exception` → appended to `self._exception_middleware`
   - The instance itself is wrapped in `convert_exception_to_response` and becomes the new `handler`.
3. The final `handler` is stored as `self._middleware_chain`.

The result is a chain of callables: `OuterMW → ... → InnerMW → convert_exception_to_response(_get_response)`.

---

### Phase 1 — WSGI Entry: `WSGIHandler.__call__`

**`WSGIHandler.__call__`** (`django/core/handlers/wsgi.py:120`) is invoked by the WSGI server (gunicorn, uWSGI, Django's dev server) with the raw `environ` dict and `start_response` callback.

```
def __call__(self, environ, start_response):
```

Step by step:

| Step | Code | File:Line |
|---|---|---|
| Set `SCRIPT_NAME` prefix in thread-local | `set_script_prefix(get_script_name(environ))` | `wsgi.py:121` |
| Fire `request_started` signal | `signals.request_started.send(...)` | `wsgi.py:122` |
| Wrap environ in request object | `request = self.request_class(environ)` | `wsgi.py:123` |
| Dispatch through middleware chain | `response = self.get_response(request)` | `wsgi.py:124` |
| Serialize status + headers | `status = "%d %s" % (...)` | `wsgi.py:130` |
| Hand off to WSGI server | `start_response(status, response_headers)` | `wsgi.py:135` |
| Return body iterator | `return response` | `wsgi.py:145` |

---

### Phase 2 — Request Construction: `WSGIRequest.__init__`

**`WSGIRequest`** (`django/core/handlers/wsgi.py:56`) subclasses `HttpRequest` (`django/http/request.py:54`).

**`WSGIRequest.__init__`** (`django/core/handlers/wsgi.py:57`):

| Field | Source |
|---|---|
| `path_info` | `get_path_info(environ)` → decodes `PATH_INFO` from Latin-1 bytes |
| `path` | `script_name.rstrip("/") + "/" + path_info.lstrip("/")` |
| `META` | the raw `environ` dict (WSGI headers live here as `HTTP_*` keys) |
| `method` | `environ["REQUEST_METHOD"].upper()` |
| `content_type`, `encoding` | `_set_content_type_params(environ)` → parses `CONTENT_TYPE` |
| `_stream` | `LimitedStream(environ["wsgi.input"], content_length)` — wraps body for safe reading |
| `resolver_match` | `None` — filled in during URL resolution |

`HttpHeaders` (`django/http/request.py:528`) provides case-insensitive access to `HTTP_*` environ keys, normalizing e.g. `HTTP_ACCEPT_ENCODING` → `Accept-Encoding`.

---

### Phase 3 — Middleware Traversal (request direction)

**`BaseHandler.get_response`** (`django/core/handlers/base.py:138`):

```python
set_urlconf(settings.ROOT_URLCONF)          # thread-local URL conf
response = self._middleware_chain(request)   # entire onion, one call
response._resource_closers.append(request.close)
```

`self._middleware_chain(request)` calls each middleware's `__call__` in the order they appear in `settings.MIDDLEWARE`. Each one can:
- Inspect/mutate the request before calling `get_response(request)`.
- Inspect/mutate the response on the way back out.
- Short-circuit by returning a response without calling `get_response`.

Common built-in middleware in order:
1. `SecurityMiddleware` — HTTPS redirect, HSTS, XSS headers
2. `SessionMiddleware` — loads session from cookie/store
3. `CommonMiddleware` — `APPEND_SLASH`, `PREPEND_WWW`, `Content-Length`
4. `CsrfViewMiddleware` — CSRF token validation (runs `process_view`)
5. `AuthenticationMiddleware` — attaches `request.user` (lazy `SimpleLazyObject`)
6. `MessageMiddleware` — attaches messages framework
7. `XFrameOptionsMiddleware` — `X-Frame-Options` header

---

### Phase 4 — URL Resolution

**`BaseHandler._get_response`** (`django/core/handlers/base.py:176`) is the innermost callable. Its first act is resolution:

**`BaseHandler.resolve_request`** (`django/core/handlers/base.py:302`):

```python
resolver = get_resolver()                           # → _get_cached_resolver(ROOT_URLCONF)
resolver_match = resolver.resolve(request.path_info)
request.resolver_match = resolver_match
return resolver_match   # (callback, args, kwargs)
```

`get_resolver` → **`_get_cached_resolver`** (`django/urls/resolvers.py:115`) — memoized per `urlconf`. Returns a **`URLResolver`** instance rooted at `ROOT_URLCONF`.

**`URLResolver.resolve`** (`django/urls/resolvers.py:670`) — recursive descent:

```python
match = self.pattern.match(path)       # strip the prefix this resolver owns
for pattern in self.url_patterns:      # iterate child patterns
    sub_match = pattern.resolve(new_path)   # recurse
    if sub_match:
        return ResolverMatch(sub_match.func, merged_args, merged_kwargs,
                             url_name, app_names, namespaces, route, tried)
raise Resolver404(...)
```

`self.url_patterns` is a lazy property (`django/urls/resolvers.py:727`) that imports the URLconf module on first access and returns its `urlpatterns` list.

Each child `pattern` is either:
- Another **`URLResolver`** (from `include(...)`) → recurse, collects namespace/app info.
- A **`URLPattern`** (from `path()` / `re_path()`) → leaf match.

**`URLPattern.resolve`** (`django/urls/resolvers.py:471`):

```python
match = self.pattern.match(path)     # RoutePattern or RegexPattern
if match:
    new_path, args, captured_kwargs = match
    return ResolverMatch(self.callback, args, {**captured_kwargs, **self.default_args},
                         self.pattern.name, route=str(self.pattern))
```

**`RoutePattern.match`** (`django/urls/resolvers.py:324`) — converts `<int:pk>` syntax to a named-group regex via `_route_to_regex` (`django/urls/resolvers.py:250`) and matches against the path.

**`RegexPattern.match`** (`django/urls/resolvers.py:202`) — raw `re.search` against the path.

**`ResolverMatch`** (`django/urls/resolvers.py:34`) carries `func` (the view callable), `args`, `kwargs`, `url_name`, `app_names`, `namespaces`, `route` (the matched URL pattern string), and `tried` (for 404 debugging).

---

### Phase 5 — View Middleware and View Dispatch

Back in **`BaseHandler._get_response`** (`django/core/handlers/base.py:176`):

```python
callback, callback_args, callback_kwargs = self.resolve_request(request)

# 1. process_view hooks (can short-circuit)
for middleware_method in self._view_middleware:
    response = middleware_method(request, callback, callback_args, callback_kwargs)
    if response:
        break

# 2. Optionally wrap in transaction.atomic
if response is None:
    wrapped_callback = self.make_view_atomic(callback)
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
```

**`BaseHandler.make_view_atomic`** (`django/core/handlers/base.py:347`): if any database in `DATABASES` has `ATOMIC_REQUESTS = True`, wraps the view callable in `transaction.atomic(using=alias)`. This makes the entire view a single database transaction.

**For function-based views**, `callback` is the function directly.

**For class-based views**, `callback` is the `view` closure returned by **`View.as_view()`** (`django/views/generic/base.py:82`):

```python
def view(request, *args, **kwargs):
    self = cls(**initkwargs)           # instantiate the view class
    self.setup(request, *args, **kwargs)  # attach request, args, kwargs, url kwargs
    return self.dispatch(request, *args, **kwargs)
```

**`View.dispatch`** (`django/views/generic/base.py:134`):

```python
method = request.method.lower()          # "get", "post", "put", …
handler = getattr(self, method, self.http_method_not_allowed)
return handler(request, *args, **kwargs)
```

For a `TemplateView`, `get()` calls **`TemplateResponseMixin.render_to_response`** (`django/views/generic/base.py:191`):

```python
return self.response_class(             # TemplateResponse
    request=self.request,
    template=self.get_template_names(),
    context=context,
    using=self.template_engine,
)
```

This returns a **`TemplateResponse`** (a *deferred* response — the template has not been rendered yet).

---

### Phase 6 — ORM Query Execution

Views typically hit the database before (or while) building the context. The path for a standard `queryset.filter(...)`-style query:

**`QuerySet.__iter__`** (`django/db/models/query.py:420`):

```python
self._fetch_all()           # fills self._result_cache
return iter(self._result_cache)
```

`_fetch_all` calls `self._iterator()` which returns a `ModelIterable`.

**`ModelIterable.__iter__`** (`django/db/models/query.py:92`):

```python
compiler = queryset.query.get_compiler(using=db)  # SQLCompiler
results = compiler.execute_sql(chunked_fetch=..., chunk_size=...)
for row in compiler.results_iter(results):
    obj = model_cls.from_db(db, init_list, row[model_fields_start:model_fields_end])
    # populate related objects (select_related, prefetch_related, annotations)
    yield obj
```

**`SQLCompiler.as_sql`** (`django/db/models/sql/compiler.py:757`):

- `pre_sql_setup()` — resolves `SELECT` columns, `ORDER BY`, `GROUP BY`.
- `get_distinct()`, `get_from_clause()` — builds `FROM` / `JOIN` clauses.
- Compiles `self.where` (`WhereNode`) → `WHERE` fragment.
- Assembles `["SELECT", cols, "FROM", tables, "WHERE", ..., "ORDER BY", ..., "LIMIT ..."]`.
- Returns `(" ".join(result), tuple(params))`.

**`SQLCompiler.execute_sql`** (`django/db/models/sql/compiler.py:1595`):

```python
sql, params = self.as_sql()
cursor = self.connection.cursor()
cursor.execute(sql, params)          # actual DB I/O
result = cursor_iter(cursor, ..., chunk_size)   # chunked fetchmany
return list(result)                  # or streaming iterator
```

`self.connection` is a backend-specific `DatabaseWrapper` (e.g. `django/db/backends/sqlite3/base.py`). `cursor.execute` goes through the backend's `DatabaseOperations`, which handles quoting, paramstyle, and type coercion.

`results_iter` (`django/db/models/sql/compiler.py:1565`) applies `apply_converters` to turn database primitives into Python types (e.g. datetime strings → `datetime` objects).

---

### Phase 7 — Template Rendering

After the view returns, **`_get_response`** checks for deferred rendering:

```python
if hasattr(response, "render") and callable(response.render):
    for middleware_method in self._template_response_middleware:
        response = middleware_method(request, response)   # process_template_response
    response = response.render()
```

**`SimpleTemplateResponse.render`** (`django/template/response.py:105`):

```python
if not self._is_rendered:
    self.content = self.rendered_content   # triggers actual rendering
    for callback in self._post_render_callbacks:
        callback(self)
return self
```

**`SimpleTemplateResponse.rendered_content`** (`django/template/response.py:82`):

```python
template = self.resolve_template(self.template_name)  # Engine.get_template(name)
context  = self.resolve_context(self.context_data)    # RequestContext wrapping
return template.render(context, self._request)
```

#### Template Loading

**`Engine.get_template`** (`django/template/engine.py:172`):

```python
template, origin = self.find_template(template_name)
if not hasattr(template, "render"):
    template = Template(template, origin, template_name, engine=self)
return template
```

**`Engine.find_template`** (`django/template/engine.py:155`): iterates `self.template_loaders` in order (typically `FilesystemLoader` then `AppDirectoriesLoader`), calling `loader.get_template(name)` until one succeeds or all raise `TemplateDoesNotExist`.

#### Template Compilation

**`Template.__init__`** (`django/template/base.py:143`):

```python
self.nodelist = self.compile_nodelist()
```

**`Template.compile_nodelist`** (`django/template/base.py:179`):

```python
lexer = Lexer(self.source)           # or DebugLexer in DEBUG mode
tokens = lexer.tokenize()
parser = Parser(tokens, libraries, builtins, origin)
nodelist = parser.parse()
```

**`Lexer.tokenize`** (`django/template/base.py:419`): splits the template source string on `tag_re` (a compiled regex alternating over `{% %}`, `{{ }}`, `{# #}`). Returns a flat list of `Token` objects with types `TEXT`, `VAR`, `BLOCK`, `COMMENT`.

**`Parser.parse`** (`django/template/base.py:530`): processes the token list into a `NodeList`:

| Token type | Action | Result node |
|---|---|---|
| `TEXT` (0) | `TextNode(token.contents)` | `TextNode` |
| `VAR` (1) | `FilterExpression(token.contents)` | `VariableNode` |
| `BLOCK` (2) | looks up tag name in `self.tags`, calls `compile_func(parser, token)` | custom `Node` subclass |

Built-in tag compile functions (e.g. `do_if`, `do_for`, `do_block`) call `parser.parse(until=["endif"])` recursively to consume their body tokens.

#### Template Execution

**`Template.render`** (`django/template/base.py:169`):

```python
with context.render_context.push_state(self):
    return self._render(context)       # → self.nodelist.render(context)
```

**`NodeList.render`** (`django/template/base.py:1107`): iterates `Node` objects, calls `node.render_annotated(context)` on each, concatenates the string results.

- **`TextNode.render`** → returns the literal string verbatim.
- **`VariableNode.render`** → `FilterExpression.resolve(context)` → `Variable._resolve_lookup(context)` → walks dotted attribute paths.
- Block tag nodes (e.g. `IfNode`, `ForNode`) → evaluate their condition/iterable, recurse into their child `NodeList`s.

The final string — the fully-rendered HTML — is stored as `self.content` on the `HttpResponse`.

---

### Phase 8 — Exception Handling

At any point in phases 4–7, exceptions propagate up through middleware hooks in reverse:

1. Inside `_get_response`: `self.process_exception_by_middleware(e, request)` iterates `_exception_middleware` (`django/core/handlers/base.py:358`). Each `process_exception(request, exception)` can return a response to suppress the exception.
2. `Http404` raised in a view → caught by `_get_response` (via `convert_exception_to_response`) → dispatched to `URLResolver.resolve_error_handler("404")` → `handler404` view.
3. Unhandled exceptions → 500 response via Django's technical error page or custom `handler500`.

---

### Phase 9 — Building and Returning the Response

**`HttpResponse`** (`django/http/response.py:377`) is the standard response. Key internals:

| Class | File:Line | Role |
|---|---|---|
| `HttpResponseBase.__init__` | `response.py:120` | sets `status_code`, `reason_phrase`, initializes `ResponseHeaders` |
| `ResponseHeaders` | `response.py:40` | case-insensitive `CaseInsensitiveMapping` for header values; validates for control chars |
| `HttpResponse.content` (setter) | `response.py:409` | encodes string → bytes via `self.charset`; stores in `self._container` |
| `HttpResponseBase.serialize_headers` | `response.py:183` | encodes all headers to bytes for WSGI |
| `HttpResponseBase.set_cookie` | `response.py:223` | sets `Morsel` objects in `self.cookies` (`SimpleCookie`) |

Back in **`WSGIHandler.__call__`** (`django/core/handlers/wsgi.py:130`):

```python
status = "%d %s" % (response.status_code, response.reason_phrase)
response_headers = [
    *response.items(),
    *((k, c.OutputString()) for c in response.cookies.values()),
]
start_response(status, response_headers)
return response   # __iter__ yields self._container chunks
```

For `StreamingHttpResponse` (`response.py:450`) or `FileResponse` (`response.py:557`), the body is a generator; WSGI iterates it lazily. If `wsgi.file_wrapper` is available (e.g. sendfile), it wraps `response.file_to_stream` directly.

---

### Unified Architecture Diagram

```
WSGI server (gunicorn/uWSGI/runserver)
│
│  environ dict + start_response callback
▼
┌─────────────────────────────────────────────────────────────────────┐
│  WSGIHandler.__call__                  wsgi.py:120                  │
│  ├─ set_script_prefix()                                             │
│  ├─ request_started.send()            [signal]                      │
│  ├─ WSGIRequest(environ)              wsgi.py:57                    │
│  │   ├─ get_path_info / get_script_name                             │
│  │   ├─ _set_content_type_params()                                  │
│  │   └─ LimitedStream(wsgi.input)     [body guard]                  │
│  ├─ get_response(request)             base.py:138                   │
│  │   ├─ set_urlconf(ROOT_URLCONF)                                   │
│  │   └─ self._middleware_chain(request)  ◄─── built at startup      │
│  │                                                                  │
│  ├─ start_response(status, headers)                                 │
│  └─ return response  (body iterator)                                │
└──────────────────────┬──────────────────────────────────────────────┘
                       │
          ┌────────────▼──────────────────────────────────────────────┐
          │  Middleware Onion  (settings.MIDDLEWARE order)            │
          │                                                           │
          │  SecurityMiddleware.__call__(request)                     │
          │    └─ SessionMiddleware.__call__(request)                 │
          │         └─ CommonMiddleware.__call__(request)             │
          │              └─ CsrfViewMiddleware.__call__(request)      │
          │                   └─ AuthenticationMiddleware.__call__    │
          │                        └─ ...                             │
          │  [each calls next handler; may short-circuit]             │
          └────────────┬──────────────────────────────────────────────┘
                       │
          ┌────────────▼──────────────────────────────────────────────┐
          │  BaseHandler._get_response(request)       base.py:176    │
          │                                                           │
          │  1. resolve_request(request)              base.py:302    │
          │      └─ get_resolver() → URLResolver      resolvers.py   │
          │          └─ URLResolver.resolve(path_info) line:670       │
          │              ├─ RoutePattern.match / RegexPattern.match   │
          │              ├─ recurse into include()d URLResolvers      │
          │              └─ URLPattern.resolve()       line:471        │
          │                  └─ ResolverMatch(func, args, kwargs)     │
          │                                                           │
          │  2. _view_middleware loop                                 │
          │      └─ mw.process_view(req, callback, args, kwargs)      │
          │          [CsrfViewMiddleware validates token here]        │
          │                                                           │
          │  3. make_view_atomic(callback)            base.py:347    │
          │      └─ transaction.atomic() wrap if ATOMIC_REQUESTS      │
          │                                                           │
          │  4. response = callback(request, *args, **kwargs)         │
          └────────────┬──────────────────────────────────────────────┘
                       │
          ┌────────────▼──────────────────────────────────────────────┐
          │  View                                                     │
          │                                                           │
          │  [Function-based]                                         │
          │  def my_view(request, pk): ...                            │
          │                                                           │
          │  [Class-based]  View.as_view() closure   views/base.py   │
          │    ├─ cls(**initkwargs)                   line:82         │
          │    ├─ self.setup(request, *args, **kwargs) line:126       │
          │    └─ self.dispatch(request, ...)         line:134        │
          │        └─ getattr(self, "get")(request, ...)              │
          │            └─ render_to_response(context) line:191        │
          │                └─ TemplateResponse(request, tmpl, ctx)    │
          │                                                           │
          │  ┌── ORM (when view queries the DB) ──────────────────┐  │
          │  │  QuerySet.__iter__              query.py:420        │  │
          │  │   └─ _fetch_all()                                   │  │
          │  │       └─ ModelIterable.__iter__  query.py:92        │  │
          │  │           ├─ query.get_compiler(using=db)           │  │
          │  │           │   └─ SQLCompiler                        │  │
          │  │           ├─ SQLCompiler.execute_sql  compiler.py   │  │
          │  │           │   ├─ as_sql() → SQL string + params     │  │
          │  │           │   │   (SELECT … FROM … WHERE … ORDER …) │  │
          │  │           │   ├─ connection.cursor()                │  │
          │  │           │   ├─ cursor.execute(sql, params)  ←DB   │  │
          │  │           │   └─ cursor_iter(cursor, chunk_size)    │  │
          │  │           └─ model_cls.from_db(…row…) → Model obj   │  │
          │  └────────────────────────────────────────────────────┘  │
          └────────────┬──────────────────────────────────────────────┘
                       │  TemplateResponse (not yet rendered)
          ┌────────────▼──────────────────────────────────────────────┐
          │  Back in _get_response                    base.py:176    │
          │                                                           │
          │  5. _template_response_middleware loop                    │
          │      └─ mw.process_template_response(request, response)   │
          │                                                           │
          │  6. response.render()           template/response.py:105 │
          │      └─ rendered_content                          line:82 │
          │          ├─ resolve_template(template_name)               │
          │          │   └─ Engine.get_template(name)   engine.py:172 │
          │          │       ├─ find_template(name)         line:155  │
          │          │       │   └─ loader.get_template(name)         │
          │          │       │       [FilesystemLoader/AppDirs]        │
          │          │       └─ Template(source, origin, name, engine) │
          │          │           └─ compile_nodelist()    base.py:179 │
          │          │               ├─ Lexer.tokenize()   line:419   │
          │          │               │   └─ tag_re.split(source)      │
          │          │               │       → [Token, Token, …]      │
          │          │               └─ Parser.parse()     line:530   │
          │          │                   ├─ TEXT  → TextNode          │
          │          │                   ├─ VAR   → VariableNode      │
          │          │                   └─ BLOCK → tag compile fn    │
          │          │                              → Node subclass   │
          │          ├─ resolve_context(context_data)                 │
          │          └─ template.render(context, request)  line:169   │
          │              └─ nodelist.render(context)        line:1107  │
          │                  └─ node.render_annotated(ctx) per node   │
          │                      ├─ TextNode   → literal string       │
          │                      ├─ VariableNode → lookup + filters   │
          │                      └─ BlockNode  → recurse child nodes  │
          │                  → final HTML string                       │
          │      HttpResponse.content = html_string  (encode → bytes) │
          └────────────┬──────────────────────────────────────────────┘
                       │  rendered HttpResponse
          ┌────────────▼──────────────────────────────────────────────┐
          │  Middleware Onion (response direction, same stack unwinds) │
          │  Each middleware's __call__ resumes after its get_response │
          │  call and may mutate/replace the response.                │
          │  e.g. SessionMiddleware saves session; GZipMiddleware      │
          │       compresses body; SecurityMiddleware adds headers     │
          └────────────┬──────────────────────────────────────────────┘
                       │
          ┌────────────▼──────────────────────────────────────────────┐
          │  WSGIHandler.__call__ (continued)          wsgi.py:130   │
          │  status = "200 OK"                                        │
          │  response_headers = [*headers, *cookies]                  │
          │  start_response(status, response_headers)                 │
          │  return response   ← body: HttpResponse.__iter__          │
          │                       yields self._container (bytes)      │
          └────────────┬──────────────────────────────────────────────┘
                       │
            WSGI server reads body iterator, sends bytes to TCP socket
```

---

### Key Class and Function Index

| Symbol | File | Line | Role |
|---|---|---|---|
| `WSGIHandler.__call__` | `django/core/handlers/wsgi.py` | 120 | WSGI entry point |
| `WSGIRequest.__init__` | `django/core/handlers/wsgi.py` | 57 | Wraps environ into request |
| `LimitedStream` | `django/core/handlers/wsgi.py` | 15 | Guards body reads by Content-Length |
| `BaseHandler.load_middleware` | `django/core/handlers/base.py` | 27 | Builds middleware onion at startup |
| `BaseHandler.adapt_method_mode` | `django/core/handlers/base.py` | 106 | Sync/async adapter |
| `BaseHandler.get_response` | `django/core/handlers/base.py` | 138 | Sets urlconf; fires `_middleware_chain` |
| `BaseHandler._get_response` | `django/core/handlers/base.py` | 176 | Inner dispatch: resolve→view→render |
| `BaseHandler.resolve_request` | `django/core/handlers/base.py` | 302 | URL resolution; sets `request.resolver_match` |
| `BaseHandler.make_view_atomic` | `django/core/handlers/base.py` | 347 | Wraps view in `transaction.atomic` |
| `BaseHandler.process_exception_by_middleware` | `django/core/handlers/base.py` | 358 | Runs `_exception_middleware` list |
| `URLResolver.resolve` | `django/urls/resolvers.py` | 670 | Recursive URL descent |
| `URLPattern.resolve` | `django/urls/resolvers.py` | 471 | Leaf pattern match |
| `RoutePattern.match` | `django/urls/resolvers.py` | 324 | `path()` converter matching |
| `RegexPattern.match` | `django/urls/resolvers.py` | 202 | `re_path()` matching |
| `ResolverMatch` | `django/urls/resolvers.py` | 34 | Carries view func, args, kwargs, name |
| `View.as_view` | `django/views/generic/base.py` | 82 | Produces `view` closure for URLconf |
| `View.dispatch` | `django/views/generic/base.py` | 134 | Routes to `self.get/post/…` |
| `TemplateResponseMixin.render_to_response` | `django/views/generic/base.py` | 191 | Creates deferred `TemplateResponse` |
| `QuerySet.__iter__` | `django/db/models/query.py` | 420 | Populates `_result_cache`, returns iterator |
| `ModelIterable.__iter__` | `django/db/models/query.py` | 92 | Calls compiler, hydrates model instances |
| `SQLCompiler.as_sql` | `django/db/models/sql/compiler.py` | 757 | Assembles full SQL string + params |
| `SQLCompiler.execute_sql` | `django/db/models/sql/compiler.py` | 1595 | Runs query on DB cursor |
| `SQLCompiler.results_iter` | `django/db/models/sql/compiler.py` | 1565 | Applies converters to raw rows |
| `SimpleTemplateResponse.render` | `django/template/response.py` | 105 | Triggers deferred rendering (idempotent) |
| `SimpleTemplateResponse.rendered_content` | `django/template/response.py` | 82 | Resolves template + context, calls `template.render` |
| `Engine.get_template` | `django/template/engine.py` | 172 | Finds template source, compiles `Template` |
| `Engine.find_template` | `django/template/engine.py` | 155 | Walks loaders until source found |
| `Template.__init__` | `django/template/base.py` | 143 | Stores source, calls `compile_nodelist` |
| `Template.compile_nodelist` | `django/template/base.py` | 179 | Lex → parse → `NodeList` |
| `Lexer.tokenize` | `django/template/base.py` | 419 | `tag_re.split` → `[Token, …]` |
| `Parser.parse` | `django/template/base.py` | 530 | Tokens → `NodeList` of `Node` objects |
| `Template.render` | `django/template/base.py` | 169 | Pushes render context, calls `nodelist.render` |
| `NodeList.render` | `django/template/base.py` | 1107 | Concatenates all node outputs |
| `HttpRequest.__init__` | `django/http/request.py` | 62 | Base request state |
| `HttpResponse.__init__` | `django/http/response.py` | 386 | Stores body, status, headers |
| `ResponseHeaders` | `django/http/response.py` | 40 | Case-insensitive header dict with validation |
| `HttpResponseBase.serialize_headers` | `django/http/response.py` | 183 | Encodes headers to bytes for WSGI |
