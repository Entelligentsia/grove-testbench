# transcript: When the router finishes matching an incoming URL, it hands the rest of the request machinery a single object that captures everything known about which view...

  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__source,mcp__grove__outline)
  ▸ mcp__grove__symbols({"dir":"django/urls","name":"ResolverMatch","kind":"class"})
  ▸ mcp__grove__source({"id":"python:django/urls/resolvers.py#ResolverMatch@34"})

💬 Here is a complete walkthrough of `ResolverMatch` (`django/urls/resolvers.py:34`).  ---  ## The core triple  `ResolverMatch` stores the resolved view as thre...

──────── RESULT (success, 28121ms, 4 turns) ────────
Here is a complete walkthrough of `ResolverMatch` (`django/urls/resolvers.py:34`).

---

## The core triple

`ResolverMatch` stores the resolved view as three pieces:

- **`func`** — the actual callable that will handle the request. For a class-based view Django stores `MyView.as_view()` here, which is the per-instance wrapper; the underlying class is detectable via `func.view_class`.
- **`args`** — positional URL captures (from unnamed groups in a regex pattern).
- **`kwargs`** — keyword URL captures (from named groups, or named path converters).

The class makes the triple directly subscriptable via `__getitem__` (`resolvers.py:77`):

```python
def __getitem__(self, index):
    return (self.func, self.args, self.kwargs)[index]
```

This is what lets calling code do `func, args, kwargs = match` — the object unpacks like a 3-tuple.

---

## Naming layers

There are two parallel naming hierarchies, both built from lists so colon-joined namespaces compose correctly:

| Attribute | What it holds |
|---|---|
| `url_name` | The bare `name=` given to `path()` / `re_path()`, e.g. `"detail"`. No namespace prefix. |
| `app_names` / `app_name` | Per-`include()` **app** namespace list, joined as `"app1:app2"`. Represents the *application* identity, shared across all deployments of an app. |
| `namespaces` / `namespace` | Per-`include()` **instance** namespace list, joined the same way. Represents *this particular mount* of the app. |
| `view_name` | The fully-qualified reversible name: `namespace + ":" + url_name` (or the dotted import path if `url_name` is absent). This is what `reverse()` works from. |

`app_names` and `namespaces` are always lists (empty lists, not `None`) because a URL can be included inside multiple nested `include()` calls, each adding a layer.

---

## View-path resolution (lines 55–62)

`__init__` immediately inspects `func` to build `_func_path`, a dotted import path used for debugging:

```python
if hasattr(func, "view_class"):
    func = func.view_class          # peel the as_view() wrapper
if not hasattr(func, "__name__"):
    # class instance used as view
    self._func_path = func.__class__.__module__ + "." + func.__class__.__name__
else:
    # plain function or class itself
    self._func_path = func.__module__ + "." + func.__name__
```

This is used in `__repr__` (and as a fallback for `view_name`) but is not normally consumed by request dispatch.

---

## Extra route metadata

Three more attributes carry context from the resolver:

- **`route`** — the raw URL pattern string (`"articles/<int:pk>/"`) that was matched. Useful for debugging.
- **`tried`** — the list of patterns that were attempted before this one matched; populated on `Resolver404` but also stored on a successful match for introspection.
- **`captured_kwargs`** / **`extra_kwargs`** — a split of `kwargs` that distinguishes captures from the URL pattern itself (`captured_kwargs`) versus kwargs injected by the route definition's `kwargs=` dict (`extra_kwargs`). This split exists so code that inspects or transforms the match can distinguish "came from the URL" from "came from the route definition".

---

## Summary

`ResolverMatch` is essentially a named 3-tuple (`func`, `args`, `kwargs`) that also carries the resolved name (`url_name`, `view_name`), the full namespace chain (`app_names`, `namespaces`), and diagnostic metadata (`route`, `tried`). The `__getitem__` protocol makes destructuring it like a tuple work without losing access to the named attributes.
