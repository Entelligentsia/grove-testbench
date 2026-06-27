# transcript: When the router finishes matching an incoming URL, it hands the rest of the request machinery a single object that captures everything known about which view...

  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__source,mcp__grove__outline)
  ▸ mcp__grove__symbols({"dir":"django/urls","name":"ResolverMatch"})
  ▸ mcp__grove__source({"id":"python:django/urls/resolvers.py#ResolverMatch@34"})

💬 Here is a thorough walkthrough of `ResolverMatch` (`django/urls/resolvers.py:34`).  ---  ## What it records  ### The callable  `self.func` is the raw view ca...

──────── RESULT (success, 41860ms, 4 turns) ────────
Here is a thorough walkthrough of `ResolverMatch` (`django/urls/resolvers.py:34`).

---

## What it records

### The callable

`self.func` is the raw view callable as stored on the URL pattern — this is exactly what Django calls with `(request, *args, **kwargs)`. For a class-based view, the pattern stores the result of `MyView.as_view()`, which is a plain function, so `func` is always callable. The `__init__` also inspects `func` sideways (without mutating `self.func`) to build a human-readable dotted path:

- If `func` has a `view_class` attribute (set by `as_view()`), it peeks at that class instead.
- If the result has `__name__` → function-based view → `module.funcname`.
- If not → bare class instance → `module.classname`.

That path goes into `self._func_path`, used only for `__repr__` and as a fallback for `view_name`.

---

### URL arguments

`self.args` — positional captures from the URL pattern (from unnamed groups in a regex route).  
`self.kwargs` — keyword captures (from named groups or `path()` converters).

These are exactly the values that will be spread into the view call. Two finer-grained attributes distinguish where kwargs came from:

- `self.captured_kwargs` — only the kwargs pulled directly from the URL match itself.
- `self.extra_kwargs` — kwargs added by the `URLPattern`/`URLResolver` via the static `kwargs` dict on the pattern definition (the third positional arg to `path()`/`re_path()`).

In the normal case `kwargs = captured_kwargs | extra_kwargs`. The split lets tooling or middleware tell them apart.

---

### Naming

`self.url_name` — the bare `name=` string from the pattern definition, with no namespace prefix. `None` if the pattern was anonymous.

`self.route` — the raw route string from the matched pattern (e.g. `"articles/<int:pk>/"`), useful for debugging and for `reverse()` consistency checks.

---

### Namespace handling

Namespaces are stacked: each nested `include()` can contribute one app namespace and one instance namespace. Both are collected as lists so nothing is lost when includes are nested multiple levels deep.

| Attribute | What it holds |
|---|---|
| `self.app_names` | List of app namespaces, outer-to-inner (`["myapp", "subapp"]`) |
| `self.app_name` | Colon-joined string: `"myapp:subapp"` |
| `self.namespaces` | List of instance namespaces in the same order |
| `self.namespace` | Colon-joined string: `"myapp:subapp"` |

Empty strings from `include()` calls that carry no namespace are filtered out before joining, so the strings are always clean.

`self.view_name` is the fully-qualified, `reverse()`-compatible name:

```python
view_path = url_name or self._func_path   # prefer the declared name
self.view_name = ":".join([*self.namespaces, view_path])
# e.g. "admin:auth:user-list"
```

---

### The (view, args, kwargs) triple

`__getitem__` makes the object subscriptable as a 3-tuple:

```python
def __getitem__(self, index):
    return (self.func, self.args, self.kwargs)[index]
```

This means older code can unpack `match` directly:

```python
func, args, kwargs = match          # tuple-style
view  = match[0]                    # also works
```

That convention predates named attributes; the subscript interface is kept for backward compatibility. Modern code reads the named attributes.

---

### Other bits

`self.tried` — the list of patterns that were attempted before this one matched, used to build the `404` detail page.

`__reduce_ex__` raises `PicklingError` unconditionally. `ResolverMatch` holds a live callable and namespace state that cannot survive serialization, so pickling is explicitly blocked rather than silently producing bad results.

---

## Summary picture

```
ResolverMatch
├── func              ← the callable Django will invoke
├── args / kwargs     ← URL captures ready to pass to the view
├── captured_kwargs   ┐ kwargs split by origin
├── extra_kwargs      ┘
├── url_name          ← bare pattern name
├── route             ← raw pattern string
├── app_names / app_name      ← app namespace stack
├── namespaces / namespace    ← instance namespace stack
├── view_name         ← fully-qualified, reversible name
├── tried             ← patterns tested before this one
└── __getitem__       ← (func, args, kwargs) tuple protocol
```

The object is essentially a named record: the router fills it in once, then the WSGI/ASGI handler reads `func`, `args`, and `kwargs` to make the call, while middleware and `reverse()` use the name and namespace fields.
