# transcript: Trace how Django handles an incoming HTTP request: name every function it passes through, in order, from the WSGI entry point (`WSGIHandler.__call__`) to whe...


💬 I'll use the grove MCP tools to trace Django's request handling path. Let me load their schemas first.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__source,mcp__grove__outline,mcp__grove__callers,mcp__grove__definition)

💬 Now let me find `WSGIHandler.__call__` and begin tracing.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/django","name":"WSGIHandler","kind":"class"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/wsgi.py#WSGIHandler@113"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/django/django/core/handlers","name":"BaseHandler","kind":"class"})
  ▸ mcp__grove__outline({"file":"/home/bench/repos/django/django/core/handlers/base.py","kind":"method"})
  ▸ mcp__grove__outline({"file":"/home/bench/repos/django/django/core/handlers/base.py"})

💬 Good, now let me read the key methods in order.
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#get_response@138"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#_get_response@176"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#resolve_request@302"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#load_middleware@27"})

💬 Now let me check the URL resolver's `resolve` method.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/django/django/urls","name":"resolve"})
  ▸ mcp__grove__source({"id":"python:django/urls/resolvers.py#resolve@670"})
  ▸ mcp__grove__source({"id":"python:django/urls/resolvers.py#resolve@471"})

💬 Let me also check `make_view_atomic` to see how the callback is wrapped before calling.
  ▸ mcp__grove__source({"id":"python:django/core/handlers/base.py#make_view_atomic@347"})

💬 Let me also look at `convert_exception_to_response` since it wraps `_get_response` in the chain.
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/django/django/core/handlers","name":"convert_exception_to_response"})
  ▸ mcp__grove__source({"id":"python:django/core/handlers/exception.py#convert_exception_to_response@25"})

💬 I now have everything needed. Here is the complete call chain, in order:  ---  ## Django request handling: `WSGIHandler.__call__` → view call  ### 1. `WSGIHa...

──────── RESULT (success, 78328ms, 17 turns) ────────
I now have everything needed. Here is the complete call chain, in order:

---

## Django request handling: `WSGIHandler.__call__` → view call

### 1. `WSGIHandler.__call__` — `django/core/handlers/wsgi.py:120`
The WSGI entry point. Three things happen here before anything else:
- `set_script_prefix(get_script_name(environ))` — stores the script prefix for URL reversals
- `signals.request_started.send(...)` — fires the `request_started` signal
- `request = self.request_class(environ)` — constructs a `WSGIRequest` from the raw environ dict

Then it delegates: `response = self.get_response(request)`

---

### 2. `BaseHandler.get_response` — `django/core/handlers/base.py:138`
Sets the thread-local URL config (`set_urlconf(settings.ROOT_URLCONF)`), then calls:

```
response = self._middleware_chain(request)
```

`_middleware_chain` is **not** a method — it's a callable built at startup by `load_middleware`. It is the outermost middleware instance wrapped so that each middleware calls the next one down, with `_get_response` at the bottom of the stack. Each layer is wrapped in `convert_exception_to_response`.

---

### 3. Middleware chain (each `__call__`) — `settings.MIDDLEWARE`, outermost first
Each middleware's `__call__` runs `process_request` hooks and then passes the request down the stack. Django wraps each layer with `convert_exception_to_response` (`django/core/handlers/exception.py:25`), so exceptions never leak upward raw.

When control reaches the bottom of the middleware stack, Django calls:

---

### 4. `BaseHandler._get_response` — `django/core/handlers/base.py:176`
This is the innermost callable in the chain. It does:

**a) `BaseHandler.resolve_request(request)`** — `base.py:302`  
Determines which `URLconf` to use (checking `request.urlconf` first, then the default), then calls:

**b) `URLResolver.resolve(request.path_info)`** — `django/urls/resolvers.py:670`  
Walks the URL pattern tree recursively:
- Matches the root pattern prefix
- Iterates `self.url_patterns`, calling **`URLPattern.resolve(new_path)`** (`resolvers.py:471`) on each leaf
  - Each `URLPattern.resolve` calls `self.pattern.match(path)` (a `RoutePattern` or `RegexPattern`)
  - On match, returns a `ResolverMatch(self.callback, args, kwargs, ...)`
- The resolver merges captured kwargs and wraps everything in a `ResolverMatch`, which is stored as `request.resolver_match`

`resolve_request` returns `(callback, callback_args, callback_kwargs)`.

**c) `_view_middleware` loop** — `base.py:189`  
Each middleware with a `process_view` method is called: `middleware_method(request, callback, callback_args, callback_kwargs)`. If any returns a response, the view is skipped.

**d) `BaseHandler.make_view_atomic(callback)`** — `base.py:347`  
If `ATOMIC_REQUESTS` is enabled for any database alias, wraps the view in `transaction.atomic(using=alias)`.

**e) `async_to_sync(wrapped_callback)` (async views only)**  
If the resolved view is a coroutine function, it is wrapped with `asgiref.sync.async_to_sync` so it can be invoked synchronously.

**f) `wrapped_callback(request, *callback_args, **callback_kwargs)`** — `base.py:201`  
**The view is called here.** This is the user-defined view function (or `View.as_view()` closure for class-based views).

---

### Summary table

| # | Function | File | Purpose |
|---|----------|------|---------|
| 1 | `WSGIHandler.__call__` | `handlers/wsgi.py:120` | WSGI entry; build `WSGIRequest`; fire signal |
| 2 | `BaseHandler.get_response` | `handlers/base.py:138` | Set urlconf; enter middleware chain |
| 3 | Each middleware `__call__` | `settings.MIDDLEWARE` | Process request hooks; pass down stack |
| 4 | `convert_exception_to_response.inner` | `handlers/exception.py:41` | Exception boundary wrapping each layer |
| 5 | `BaseHandler._get_response` | `handlers/base.py:176` | Bottom of middleware stack |
| 6 | `BaseHandler.resolve_request` | `handlers/base.py:302` | Pick urlconf; invoke resolver |
| 7 | `URLResolver.resolve` | `urls/resolvers.py:670` | Walk URL tree recursively |
| 8 | `URLPattern.resolve` | `urls/resolvers.py:471` | Match leaf pattern; return `ResolverMatch` |
| 9 | `process_view` middleware loop | `handlers/base.py:189` | View middleware hooks |
| 10 | `BaseHandler.make_view_atomic` | `handlers/base.py:347` | Wrap in DB transaction if configured |
| 11 | `wrapped_callback(request, ...)` | `handlers/base.py:201` | **View is called** |
