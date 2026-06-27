# transcript: Where is `QuerySet` defined, and list every place it is referenced or called across the source tree, with file and line.


💬 Loading grove tool schemas first.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__callers,mcp__grove__definition,mcp__grove__source,mcp__grove__outline)

💬 Now running definition lookup and full reference scan in parallel.
  ▸ mcp__grove__definition({"name":"QuerySet","dir":"/home/bench/repos/django"})
  ▸ mcp__grove__callers({"name":"QuerySet","dir":"/home/bench/repos/django"})

💬 ## `QuerySet` — Definition and References  ### Definition  **`django/db/models/query.py:326`** ```python class QuerySet(AltersData): ```  ---  ### References...

──────── RESULT (success, 69752ms, 4 turns) ────────
## `QuerySet` — Definition and References

### Definition

**`django/db/models/query.py:326`**
```python
class QuerySet(AltersData):
```

---

### References across the source tree

Organized by file:

#### Core ORM

| File | Line | Context |
|---|---|---|
| `django/db/models/query.py` | 47 | `REPR_OUTPUT_SIZE` comment |
| `django/db/models/query.py` | 225 | `ValuesIterable` docstring |
| `django/db/models/query.py` | 251 | `ValuesListIterable` docstring |
| `django/db/models/query.py` | 268 | `NamedValuesListIterable` docstring |
| `django/db/models/query.py` | 291 | `FlatValuesListIterable` docstring |
| `django/db/models/query.py` | 306 | `_AvoidCloning` docstring |
| `django/db/models/query.py` | 377 | `__deepcopy__` docstring |
| `django/db/models/query.py` | 456 | `__getitem__` error message |
| `django/db/models/query.py` | 563 | `iterator()` docstring |
| `django/db/models/query.py` | 570 | `iterator()` error message |
| `django/db/models/query.py` | 582 | `aiterator()` docstring |
| `django/db/models/query.py` | 593 | `aiterator()` error message |
| `django/db/models/query.py` | 667 | `count()` docstring |
| `django/db/models/query.py` | 685 | `get()` error message |
| `django/db/models/query.py` | 1230 | `in_bulk()` docstring |
| `django/db/models/query.py` | 1330 | `delete()` docstring |
| `django/db/models/query.py` | 1355 | `delete()` cache comment |
| `django/db/models/query.py` | 1381 | `update()` docstring |
| `django/db/models/query.py` | 1451 | `exists()` docstring |
| `django/db/models/query.py` | 1462–1476 | `contains()` docstring + error messages |
| `django/db/models/query.py` | 1491 | `explain()` docstring |
| `django/db/models/query.py` | 1650 | `none()` docstring |
| `django/db/models/query.py` | 1661–1662 | `all()` docstring |
| `django/db/models/query.py` | 1668 | `filter()` docstring |
| `django/db/models/query.py` | 1676 | `exclude()` docstring |
| `django/db/models/query.py` | 1704 | `complex_filter()` docstring |
| `django/db/models/query.py` | 1761 | `select_for_update()` docstring |
| `django/db/models/query.py` | 1777 | `select_related()` docstring |
| `django/db/models/query.py` | 1809–1810 | `prefetch_related()` docstring |
| `django/db/models/query.py` | 1906 | `order_by()` docstring |
| `django/db/models/query.py` | 1916 | `distinct()` docstring |
| `django/db/models/query.py` | 1945 | `reverse()` docstring |
| `django/db/models/query.py` | 1991 | `using()` docstring |
| `django/db/models/query.py` | 1997 | `fetch_mode()` docstring |
| `django/db/models/query.py` | 2009 | `ordered` property docstring |
| `django/db/models/query.py` | 2030 | `totally_ordered` property docstring |
| `django/db/models/query.py` | 2189–2211 | `_disable_cloning` / `_enable_cloning` / `_avoid_cloning` |
| `django/db/models/query.py` | 2220–2225 | `_chain()` docstring |
| `django/db/models/query.py` | 2238 | `_clone()` docstring |
| `django/db/models/query.py` | 2269 | `_next_is_sticky()` docstring |
| `django/db/models/query.py` | 2277 | `_merge_sanity_check()` docstring |
| `django/db/models/query.py` | 2290 | `_merge_known_related_objects()` docstring |
| `django/db/models/query.py` | 2311 | `_has_filters()` docstring |
| `django/db/models/query.py` | 2324 | `_validate_values_are_expressions()` error message |
| `django/db/models/query.py` | 2334 | `_not_support_combined_queries()` error message |
| `django/db/models/query.py` | 2353 | `_check_ordering_first_last_queryset_aggregation()` error |
| `django/db/models/query.py` | 2368 | `InstanceCheckMeta.__instancecheck__` — `isinstance(instance, QuerySet)` |
| `django/db/models/query.py` | 2430 | `RawQuerySet.prefetch_related()` docstring |
| `django/db/models/query.py` | 2443 | `RawQuerySet._clone()` docstring |
| `django/db/models/query.py` | 2569 | `Prefetch.__getstate__()` comment |
| `django/db/models/query.py` | 2647 | `prefetch_related_objects()` comment |
| `django/db/models/query.py` | 2674 | `prefetch_related_objects()` comment |
| `django/db/models/query.py` | 2879 | `prefetch_one_level()` comment |

| File | Line | Context |
|---|---|---|
| `django/db/models/__init__.py` | 57, 124 | Exported as `QuerySet` in public API |
| `django/db/models/manager.py` | 7 | `from django.db.models.query import QuerySet` |
| `django/db/models/manager.py` | 152, 158–159 | `get_queryset()` / `all()` docstrings |
| `django/db/models/manager.py` | 176 | `class Manager(BaseManager.from_queryset(QuerySet))` |
| `django/db/models/deletion.py` | 120, 176, 285, 435 | Comments in `Collector` |
| `django/db/models/deletion.py` | 512 | `isinstance(instances, models.QuerySet)` |
| `django/db/models/lookups.py` | 43 | Comment in `Lookup.__init__` |
| `django/db/models/lookups.py` | 379, 385 | `Exact.get_prep_lookup()` error messages |
| `django/db/models/lookups.py` | 510 | `In.get_prep_lookup()` error message |
| `django/db/models/lookups.py` | 670 | `IsNull.as_sql()` error message |
| `django/db/models/expressions.py` | 1828 | `Subquery.__init__()` comment |
| `django/db/models/utils.py` | 44 | Comment |
| `django/db/models/fields/related_descriptors.py` | 81 | `from django.db.models.query import QuerySet, prefetch_related_objects` |
| `django/db/models/fields/related_descriptors.py` | 980, 1143, 1146 | Comments + `isinstance(removed_vals, QuerySet)` |
| `django/db/models/fields/tuple_lookups.py` | 82, 173 | Error messages |
| `django/db/models/sql/query.py` | 107 | `from django.db.models.query import QuerySet` |
| `django/db/models/sql/query.py` | 123–129 | `isinstance(child, QuerySet)` + error message |
| `django/db/models/sql/query.py` | 837, 883, 1393, 1832, 2784 | Comments |
| `django/db/models/sql/compiler.py` | 59 | Comment |

#### Views, Forms, Shortcuts

| File | Line | Context |
|---|---|---|
| `django/views/generic/list.py` | 3 | `from django.db.models import QuerySet` |
| `django/views/generic/list.py` | 27, 31, 37 | `get_queryset()` — `isinstance(queryset, QuerySet)` |
| `django/views/generic/list.py` | 212 | Error message |
| `django/views/generic/detail.py` | 63, 73 | `get_queryset()` docstring + error message |
| `django/forms/models.py` | 1453, 1469, 1564, 1569, 1617, 1656 | `ModelChoiceField`, `ModelMultipleChoiceField` |
| `django/shortcuts.py` | 68, 84, 87, 97, 119, 134, 144, 163 | `_get_queryset()`, `get_object_or_404()`, `get_list_or_404()` |

#### Contrib

| File | Line | Context |
|---|---|---|
| `django/contrib/admin/utils.py` | 130, 259, 263, 278–282 | `model_format_dict()`, `model_ngettext()` — `isinstance(obj, models.query.QuerySet)` |
| `django/contrib/admin/options.py` | 482 | `get_queryset()` docstring |
| `django/contrib/contenttypes/fields.py` | 792 | Comment in `GenericRelatedObjectManager._clear` |
| `django/contrib/contenttypes/prefetch.py` | 27 | Comment in `GenericPrefetch.__getstate__` |

#### Core

| File | Line | Context |
|---|---|---|
| `django/core/paginator.py` | 74, 320 | `_check_object_list_is_ordered()`, `Page.__getitem__()` |
| `django/core/serializers/python.py` | 16 | Module docstring |
| `django/core/serializers/xml_serializer.py` | 19 | Module docstring |

---

### Tests (subclasses and structural references)

| File | Line | Context |
|---|---|---|
| `tests/custom_managers/models.py` | 35 | `class CustomQuerySet(models.QuerySet)` |
| `tests/custom_managers/models.py` | 75 | `class CustomInitQuerySet(models.QuerySet)` |
| `tests/generic_views/models.py` | 2, 33 | `from django.db.models import QuerySet`; `class DoesNotExistQuerySet(QuerySet)` |
| `tests/prefetch_related/models.py` | 113 | `class TeacherQuerySet(models.QuerySet)` |
| `tests/queryset_pickle/models.py` | 17, 24 | `PreviousDjangoVersionQuerySet`, `MissingDjangoVersionQuerySet` |
| `tests/migrations/models.py` | 55 | `class FoodQuerySet(models.query.QuerySet)` |
| `tests/get_earliest_or_latest/models.py` | 35 | `class IndexErrorQuerySet(models.QuerySet)` |
| `tests/basic/tests.py` | 439, 878 | Inline `CustomQuerySet` and `FakeQuerySet` subclasses |
| `tests/forms_tests/tests/tests.py` | 80, 84 | `assertIsInstance(..., models.query.QuerySet)` |
| `tests/serializers/test_natural.py` | 347 | `mock.patch.object(models.QuerySet, "order_by")` |
| `tests/model_inheritance/tests.py` | 314–316 | `models.QuerySet[Post]` subscript tests |
| `tests/basic/tests.py` | 832 | `BaseManager._get_queryset_methods(models.QuerySet)` |
| `tests/basic/tests.py` | 837–838 | `models.QuerySet.get.__doc__`, `models.QuerySet.count.__name__` |
| + many others in `tests/` | — | Comments, error-message assertions, string literals |

---

**Summary:** `QuerySet` is defined at `django/db/models/query.py:326`. It is directly imported or referenced in ~20 production source files and subclassed in at least 8 test model files, with hundreds of additional comment/string mentions across the test suite.
