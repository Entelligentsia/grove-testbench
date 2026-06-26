# transcript: Trace the exact function call chain Django uses to handle an incoming HTTP request, from `WSGIHandler.__call__` all the way to where the matched view functio...


💬 Let me trace through the Django source to map this precisely.
  ▸ Bash(find /home/bench/repos/django -type f -name "*.py" | grep -E "(wsgi|handler|base)" | head -20)
  ▸ Bash(ls /home/bench/repos/django/django/core/handlers/)
  ▸ Agent(Trace Django HTTP request path from WSGIHandler to view call)
  ▸ Read(/home/bench/repos/django/django/core/handlers/wsgi.py)
  ▸ Read(/home/bench/repos/django/django/core/handlers/base.py)
  ▸ Read(/home/bench/repos/django/django/urls/resolvers.py)
  ▸ Read(/home/bench/repos/django/django/urls/resolvers.py)
  ▸ Read(/home/bench/repos/django/django/urls/resolvers.py)
  ▸ Read(/home/bench/repos/django/django/core/handlers/exception.py)
  ▸ Bash(grep -n "wrapped_callback(request" django/core/handlers/base.py)
  ▸ Read(/home/bench/repos/django/django/core/handlers/base.py)

💬 Good overview. Let me verify the exact line numbers and code in the key files to give you precise references.
  ▸ Read(/home/bench/repos/django/django/core/handlers/wsgi.py)
  ▸ Read(/home/bench/repos/django/django/core/handlers/base.py)
  ▸ Read(/home/bench/repos/django/django/core/handlers/exception.py)
  ▸ Read(/home/bench/repos/django/django/urls/resolvers.py)
  ▸ Read(/home/bench/repos/django/django/urls/resolvers.py)

💬 Now I have everything. Here is the precise, annotated call chain from WSGI entry to view invocation:  ---  ## Django request path: WSGI entry → view call  ##...

──────── RESULT (success, 99418ms, 9 turns) ────────
Now I have everything. Here is the precise, annotated call chain from WSGI entry to view invocation:

---

## Django request path: WSGI entry → view call

### 1. `WSGIHandler.__call__` — `handlers/wsgi.py:120`

```python
request = self.request_class(environ)   # builds WSGIRequest
response = self.get_response(request)   # hands off to BaseHandler
```

Fires `request_started` signal, wraps the raw WSGI `environ` into a `WSGIRequest`, calls `get_response`.

---

### 2. `BaseHandler.get_response` — `handlers/base.py:138`

```python
set_urlconf(settings.ROOT_URLCONF)
response = self._middleware_chain(request)
```

Sets the thread-local URL conf, then invokes `_middleware_chain` — a callable built during `load_middleware()`.

---

### 3. `BaseHandler.load_middleware` (setup, called once in `__init__`) — `handlers/base.py:27`

This isn't called per-request but it's essential to understand what `_middleware_chain` is. It builds a nested callable stack:

```
convert_exception_to_response(outermost_middleware(
    convert_exception_to_response(next_middleware(
        ...
            convert_exception_to_response(_get_response)
    ))
))
```

Each middleware wraps the next; the innermost layer is `_get_response`, and each layer is individually wrapped by `convert_exception_to_response`.

---

### 4. `convert_exception_to_response(get_response)` — `handlers/exception.py:25`

A decorator/wrapper applied around every layer (middleware + `_get_response`). Its `inner(request)` simply calls through to the wrapped callable and converts any unhandled exception into an HTTP error response. It is **transparent on the happy path** — it just calls `get_response(request)`.

---

### 5. Each middleware's `__call__` — (various middleware classes)

Each middleware object is called in turn. Standard middleware like `SecurityMiddleware`, `SessionMiddleware`, etc. run their `process_request` logic, then call `self.get_response(request)` to pass control deeper. This is the "request phase" of middleware.

---

### 6. `BaseHandler._get_response` — `handlers/base.py:176`

The innermost callable. Everything from here down is URL resolution and view dispatch:

```python
callback, callback_args, callback_kwargs = self.resolve_request(request)
```

---

### 7. `BaseHandler.resolve_request` — `handlers/base.py:302`

```python
resolver = get_resolver()               # or get_resolver(request.urlconf)
resolver_match = resolver.resolve(request.path_info)
request.resolver_match = resolver_match
return resolver_match                   # a ResolverMatch (unpacked into callback, args, kwargs)
```

Gets the root `URLResolver` (cached) and resolves `request.path_info`.

---

### 8. `URLResolver.resolve` — `urls/resolvers.py:670`

```python
match = self.pattern.match(path)        # match the resolver's own prefix
for pattern in self.url_patterns:
    sub_match = pattern.resolve(new_path)   # recurse or leaf-match
    if sub_match:
        return ResolverMatch(sub_match.func, ...)
```

The root resolver matches the empty prefix, then iterates `url_patterns` — each of which is either another `URLResolver` (an `include()`) or a `URLPattern` (a leaf). This recurses for nested `include()` blocks.

---

### 9. `URLPattern.resolve` — `urls/resolvers.py:471`

```python
match = self.pattern.match(path)        # RoutePattern or RegexPattern
if match:
    new_path, args, captured_kwargs = match
    return ResolverMatch(self.callback, args, kwargs, ...)
```

Calls `Pattern.match()` on the concrete pattern type.

---

### 10. `RoutePattern.match` / `RegexPattern.match` — `urls/resolvers.py` (~202 / ~324)

The leaf pattern matching. `RoutePattern` uses `_route_to_regex` compiled at startup; `RegexPattern` uses `re.search`. On success, returns `(remaining_path, args, kwargs)`. On failure, returns `None`.

---

### Back in `_get_response` — `handlers/base.py:183–199`

After `resolve_request` returns:

```python
# 11. View middleware
for middleware_method in self._view_middleware:        # base.py:186
    response = middleware_method(request, callback, callback_args, callback_kwargs)
    if response:
        break   # middleware short-circuited; skip the view

# 12. Atomic wrapper
if response is None:
    wrapped_callback = self.make_view_atomic(callback) # base.py:194
```

---

### 11. `middleware.process_view` — (per-middleware, collected in `_view_middleware`)

Each middleware that defines `process_view` gets a chance to inspect or replace the response before the view runs. If any returns a response, the view is skipped entirely.

---

### 12. `BaseHandler.make_view_atomic` — `handlers/base.py:347`

```python
if settings_dict["ATOMIC_REQUESTS"]:
    view = transaction.atomic(using=alias)(view)
return view
```

Optionally wraps the view in a database transaction. Returns the (possibly wrapped) callable.

---

### 13. View invocation — `handlers/base.py:199`

```python
response = wrapped_callback(request, *callback_args, **callback_kwargs)
```

**This is where the matched view function is called.** `wrapped_callback` is either the raw function, a `transaction.atomic`-wrapped version of it, or (for async views run synchronously) an `async_to_sync`-wrapped coroutine.

---

## Summary diagram

```
WSGIHandler.__call__                      wsgi.py:120
  └─ BaseHandler.get_response             base.py:138
       └─ _middleware_chain(request)       [built by load_middleware]
            │  (each layer wrapped by convert_exception_to_response  exception.py:25)
            ├─ Middleware.__call__ × N     [outermost → innermost]
            └─ BaseHandler._get_response  base.py:176
                 ├─ resolve_request       base.py:302
                 │    └─ URLResolver.resolve          resolvers.py:670
                 │         └─ URLPattern.resolve      resolvers.py:471
                 │              └─ RoutePattern.match (or RegexPattern.match)
                 ├─ process_view × M      [_view_middleware list]
                 ├─ make_view_atomic      base.py:347
                 └─ wrapped_callback(request, *args, **kwargs)   ← view called here  base.py:199
```

**Key structural details:**

- `load_middleware` builds the chain **once at startup**; each layer including `_get_response` is individually wrapped in `convert_exception_to_response` so no exception can escape a layer.
- `_view_middleware` is a flat list collected during `load_middleware`, iterated in **forward** (outermost-first) order — opposite of the outer middleware chain order.
- `resolve_request` returns a `ResolverMatch` which Python unpacks directly: `callback, callback_args, callback_kwargs = resolver_match` (because `ResolverMatch.__iter__` yields those three).
- For class-based views, `callback` is the result of `View.as_view()`, so `wrapped_callback(request, ...)` lands in `View.__call__`, which dispatches to `self.get()`, `self.post()`, etc.
