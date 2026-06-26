# transcript: I need to map the complete execution path of Django's ORM when a QuerySet is evaluated. Search "very thorough" across these files and find exact line numbers...


💬 I'll map the Django ORM execution path by reading the key source files directly. Let me explore the core files in parallel.
  ▸ Agent(Map Django ORM QuerySet evaluation path)
  ▸ Bash(find /home/bench/repos/django -type f -name "*.py" | grep -E "(query\.py|compiler\.py|subqueries\.py|utils\.py|datastructures\.py|base\.py|manager\.py)" | he...)
  ▸ Bash(ls -la /home/bench/repos/django)
  ▸ Read(/home/bench/repos/django)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Bash(grep -n "def __iter__\|def _iterator\|def _fetch_all\|def iterator\|def __len__\|def __bool__\|def __getitem__\|def filter\|def exclude\|def get" /home/bench...)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/backends/utils.py)
  ▸ Read(/home/bench/repos/django/django/db/backends/utils.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/datastructures.py)
  ▸ Read(/home/bench/repos/django/django/db/models/base.py)
  ▸ Read(/home/bench/repos/django/django/db/models/base.py)
  ▸ Read(/home/bench/repos/django/django/db/models/manager.py)
  ▸ Read(/home/bench/repos/django/django/db/models/manager.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/subqueries.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)

💬 Good initial map. Now let me read the actual source files to get precise details and verify line numbers.
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/backends/utils.py)
  ▸ Read(/home/bench/repos/django/django/db/models/base.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/datastructures.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/manager.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Bash(grep -n "def cursor_iter\|def get_from_clause\|def setup_joins\|def solve_lookup_type\|def build_lookup\|def get_order_by" /home/bench/repos/django/django/db...)
  ▸ Bash(grep -n "def cursor_iter\|def get_from_clause\|def setup_joins\|def solve_lookup_type\|def build_lookup\|def get_order_by" /home/bench/repos/django/django/db...)
  ▸ Bash(grep -n "def get_from_clause\|def setup_joins\|def solve_lookup_type\|def build_lookup\|def get_order_by\|def cursor_iter\|def get_select_mask\|def trim_join...)
  ▸ Agent(Find line numbers for remaining Django ORM methods)
  ▸ Bash(grep -n "def get_from_clause" /home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Bash(grep -n "def get_order_by" /home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Bash(grep -n "def compile" /home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Bash(grep -n "def cursor_iter" /home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Bash(grep -n "def setup_joins" /home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(grep -n "def solve_lookup_type" /home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(grep -n "def build_lookup" /home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(grep -n "def trim_joins" /home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(grep -n "def get_select_mask" /home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(grep -n "def get_initial_alias" /home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(grep -n "def names_to_path" /home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(grep -rn "def cursor_iter" /home/bench/repos/django/django/db/models/sql/)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Bash(cat /home/bench/repos/django/django/db/models/sql/compiler.py | grep -n "def get_from_clause\|def get_order_by\|def compile\|def cursor_iter")
  ▸ Bash(cat /home/bench/repos/django/django/db/models/sql/query.py | grep -n "def setup_joins\|def solve_lookup_type\|def build_lookup\|def trim_joins\|def get_selec...)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/query.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)
  ▸ Read(/home/bench/repos/django/django/db/models/sql/compiler.py)

💬 I now have everything I need to write the complete answer. Let me compose it.  ---  ## Django ORM: End-to-End Query Execution  This traces the path from `Mod...

──────── RESULT (success, 326332ms, 32 turns) ────────
I now have everything I need to write the complete answer. Let me compose it.

---

## Django ORM: End-to-End Query Execution

This traces the path from `Model.objects.filter(...)` through the database and back to Python model instances.

---

### Phase 1 — QuerySet Construction (lazy, no SQL yet)

**Entry point: `Manager.get_queryset`**
`django/db/models/manager.py:150`
```
Manager.get_queryset()
  → QuerySet(model=…, using=…)        # query.py: QuerySet.__init__
```
The `Manager` delegates every public method to a `QuerySet` via `__getattr__`. The `QuerySet` holds a `Query` object (`sql/query.py:Query`) but issues no SQL.

**`QuerySet.filter` / `QuerySet.exclude`**
`django/db/models/query.py:1666 / 1674`
```
QuerySet.filter(*args, **kwargs)
  → QuerySet._filter_or_exclude(negate=False, args, kwargs)   # :1682
      → QuerySet._chain()                                      # :2237
          → Query.chain()      sql/query.py:433
              → Query.clone()  sql/query.py:388
      → QuerySet._filter_or_exclude_inplace(…)                # :1693
          → Query.add_q(Q(*args, **kwargs))                   sql/query.py:1663
```

**`Query.add_q` → filter tree construction**
`sql/query.py:1663`
```
Query.add_q(q_object)
  → Query._add_q(q_object, can_reuse)                    # :1692
      for each child in q_object.children:
        → Query.build_filter(child, …)                   # :1488
            → Query.solve_lookup_type(arg)               # :1344
                → Query.names_to_path(parts, opts, …)   # :1775
                    → opts.get_field(name)               # resolves field path
            → Query.setup_joins(parts, opts, alias, …)  # :1891
                → Query.join(Join(…))                   # :1135
                    → Query.table_alias(…)              # registers alias_map entry
            → Query.trim_joins(targets, joins, path)     # :2008
            → Query.build_lookup(lookups, col, value)    # :1415
                → field.get_lookup(lookup_name)          # returns Lookup subclass
            → returns WhereNode([Lookup(…)])
  → self.where.add(clause, AND)                          # adds to Query.where
  → Query.demote_joins(existing_inner)                   # promotes/demotes JOIN types
```

Key data structures built here:
- `Query.alias_map`: `{alias → Join}` — every table/join in the query
- `Query.where`: `WhereNode` tree of `Lookup` nodes (the WHERE clause)

---

### Phase 2 — QuerySet Evaluation (triggers SQL)

Evaluation is triggered by consuming the queryset: `list(qs)`, `for obj in qs`, `qs[0]`, `bool(qs)`, `len(qs)`.

**`QuerySet.__iter__`**
`django/db/models/query.py:420`
```
QuerySet.__iter__()
  → QuerySet._fetch_all()              # :2256
      → list(ModelIterable(self))      # :2258
```

**`QuerySet._fetch_all`**
`django/db/models/query.py:2256`
```
QuerySet._fetch_all()
  if _result_cache is None:
    → self._result_cache = list(self._iterable_class(self))
                           ↑ default: ModelIterable
  if _prefetch_related_lookups and not _prefetch_done:
    → self._prefetch_related_objects()
```

Other entry points that bypass `_fetch_all` and stream rows:
- `QuerySet.iterator(chunk_size)` → `QuerySet._iterator(use_chunked_fetch, chunk_size)` `:546`
  - Wraps `ModelIterable` in a generator and batches `prefetch_related` per-chunk.

---

### Phase 3 — Iterable Layer

**`ModelIterable.__iter__`**
`django/db/models/query.py:92`

This is the bridge between the queryset and the compiler:
```
ModelIterable.__iter__(self)
  queryset = self.queryset
  compiler = queryset.query.get_compiler(using=db)   ← sql/query.py:370
  results  = compiler.execute_sql(                   ← compiler.py:1595
               chunked_fetch=…, chunk_size=…)
  # compiler.select, .klass_info, .annotation_col_map filled as side-effect

  for row in compiler.results_iter(results):          ← compiler.py:1565
    obj = model_cls.from_db(db, init_list,            ← base.py:618
                            row[model_fields_start:model_fields_end])
    for rel_populator in related_populators:
      rel_populator.populate(row, obj)                # select_related hydration
    for attr, col_pos in annotation_col_map.items():
      setattr(obj, attr, row[col_pos])               # annotation hydration
    yield obj
```

Other `BaseIterable` subclasses follow the same pattern but return dicts/tuples:
- `ValuesIterable.__iter__` `:228` — calls `compiler.results_iter()` directly, yields `{name: value}` dicts
- `ValuesListIterable.__iter__` `:255` — calls `compiler.results_iter(tuple_expected=True)`
- `RawModelIterable.__iter__` `:172` — used by `RawQuerySet`; calls `compiler.apply_converters`

---

### Phase 4 — Compiler: Query → SQL

**`Query.get_compiler`**
`django/db/models/sql/query.py:370`
```
Query.get_compiler(using=db)
  connection = connections[using]
  → connection.ops.compiler("SQLCompiler")(self, connection, using)
    # returns SQLCompiler(query, connection, using)   compiler.py:50
```
The string `"SQLCompiler"` is stored at `Query.compiler = "SQLCompiler"` (`:239`). The `DatabaseOperations.compiler()` method maps that name to the actual class (which may be a backend-specific subclass).

**`SQLCompiler.__init__`**
`django/db/models/sql/compiler.py:50`

Sets `self.query`, `self.connection`, `self.using`. `self.select`, `self.klass_info`, `self.annotation_col_map` start as `None` and are populated by `execute_sql`.

**`SQLCompiler.execute_sql`**
`django/db/models/sql/compiler.py:1595`
```
SQLCompiler.execute_sql(result_type=MULTI, chunked_fetch=False, chunk_size=2000)
  sql, params = self.as_sql()           # ← :757 — builds SQL string
  if chunked_fetch:
    cursor = self.connection.chunked_cursor()
  else:
    cursor = self.connection.cursor()   # returns CursorWrapper
  cursor.execute(sql, params)           # ← backends/utils.py:78
  # for MULTI result_type:
  result = cursor_iter(cursor, sentinel, col_count, chunk_size)  # ← :2258
  if not chunked_fetch:
    return list(result)                 # eagerly load all rows into memory
  return result                         # or lazy generator for server-side cursor
```

**`SQLCompiler.as_sql`**
`django/db/models/sql/compiler.py:757`
```
SQLCompiler.as_sql(with_limits=True, with_col_aliases=False)
  extra_select, order_by, group_by = self.pre_sql_setup()   # :83
    → self.setup_query()                                     # :75
        → self.get_select()                                  # :241
            → self.query.get_select_mask()                   # sql/query.py:878
            → self.get_default_columns(select_mask)          # :984
                # yields Col expressions for each concrete field
            if select_related:
              → self.get_related_selections(…)               # :1175
        → self.col_count = len(self.select)
    → self.get_order_by()                                    # :480
        → self._order_by_pairs()                             # :339
    → self.query.where.split_having_qualify()                # splits WHERE/HAVING/QUALIFY
    → self.get_extra_select(order_by, self.select)           # :541
    → self.get_group_by(select + extra_select, order_by)     # :99

  # Build clauses:
  distinct_fields, distinct_params = self.get_distinct()
  from_, f_params   = self.get_from_clause()               # :1141
  where, w_params   = self.compile(self.where)             # :574
  having, h_params  = self.compile(self.having)            # :574

  # Assemble:
  result = ["SELECT"] + out_cols + ["FROM"] + from_
  if where:   result += ["WHERE", where]
  if grouping: result += ["GROUP BY", …]
  if having:  result += ["HAVING", having]
  if order_by: result += ["ORDER BY", …]
  if with_limits: result += [ops.limit_offset_sql(low_mark, high_mark)]
  return " ".join(result), tuple(params)
```

**`SQLCompiler.get_from_clause`**
`django/db/models/sql/compiler.py:1141`
```
get_from_clause()
  for alias, from_clause in self.query.alias_map.items():
    if alias_refcount[alias] == 0: continue
    clause_sql, clause_params = self.compile(from_clause)
    # from_clause is either a BaseTable or a Join
    # Join.as_sql() is at sql/datastructures.py:76
```

**`SQLCompiler.compile`**
`django/db/models/sql/compiler.py:574`
```
compile(node)
  vendor_impl = getattr(node, "as_" + connection.vendor, None)
  if vendor_impl:
    return vendor_impl(compiler, connection)
  return node.as_sql(compiler, connection)
```
This is the universal node-to-SQL dispatcher. Every expression — `Col`, `Lookup`, `Join`, `WhereNode`, `OrderBy`, etc. — implements `as_sql(compiler, connection)`.

**`Join.as_sql`**
`django/db/models/sql/datastructures.py:76`
```
Join.as_sql(compiler, connection)
  # for each (lhs_field, rhs_field) in self.join_fields:
  #   lhs_sql, rhs_sql = compiler.compile(lhs), compiler.compile(rhs)
  # → "LEFT OUTER JOIN tablename T1 ON (T0.col = T1.col)"
```

---

### Phase 5 — Database Execution

**`CursorWrapper.execute`**
`django/db/backends/utils.py:78`
```
CursorWrapper.execute(sql, params=None)
  → self._execute_with_wrappers(sql, params, many=False, executor=self._execute)
      # applies any connection.execute_wrappers (instrumentation hooks)
      → self._execute(sql, params)                    # :94
          self.db.validate_no_broken_transaction()
          with self.db.wrap_database_errors:
            self.cursor.execute(sql, params)           # ← DB-API 2.0 cursor
```
If `DEBUG=True`, `CursorDebugWrapper.execute` `:120` wraps this to record timing in `connection.queries_log`.

**`cursor_iter`** (module-level function)
`django/db/models/sql/compiler.py:2258`
```
cursor_iter(cursor, sentinel, col_count, itersize)
  for rows in iter(lambda: cursor.fetchmany(itersize), sentinel):
    yield rows if col_count is None else [r[:col_count] for r in rows]
  # finally: cursor.close()
```
`GET_ITERATOR_CHUNK_SIZE = 2000` (from `sql/constants.py`). Each call to `fetchmany(2000)` is one round-trip returning up to 2000 raw DB rows as tuples.

---

### Phase 6 — Row → Python values

**`SQLCompiler.results_iter`**
`django/db/models/sql/compiler.py:1565`
```
results_iter(results=None, tuple_expected=False, chunked_fetch=False, …)
  if results is None:
    results = self.execute_sql(MULTI, …)   # triggers execution if not already done
  fields = [s[0] for s in self.select[:col_count]]
  converters = self.get_converters(fields)     # :1514
  rows = chain.from_iterable(results)          # flatten chunk-of-chunks
  if converters:
    rows = self.apply_converters(rows, converters)  # :1536
  if self.has_composite_fields(fields):
    rows = self.composite_fields_to_tuples(rows, fields)
  return rows   # iterator of row-tuples with Python-native values
```

**`SQLCompiler.get_converters`** `:1514`
Collects `get_db_converters()` from both the backend (`connection.ops`) and each field/expression. Converters translate raw DB values (strings, ints) to Python types (`datetime`, `Decimal`, `UUID`, etc.).

**`SQLCompiler.apply_converters`** `:1536`
```
apply_converters(rows, converters)
  for row in rows:
    for pos, (convs, expression) in converters:
      value = row[pos]
      for converter in convs:
        value = converter(value, expression, connection)
      row[pos] = value
    yield row
```

---

### Phase 7 — Model Instantiation

**`Model.from_db`**
`django/db/models/base.py:618`
```
Model.from_db(cls, db, field_names, values, *, fetch_mode=None)
  if len(values) != len(cls._meta.concrete_fields):
    # partial load (defer()/only()) — fill missing fields with DEFERRED sentinel
    values = [next(values_iter) if f.attname in field_names else DEFERRED
               for f in cls._meta.concrete_fields]
  new = cls(*values)       # calls Model.__init__
  new._state.adding = False
  new._state.db = db
  if fetch_mode: new._state.fetch_mode = fetch_mode
  return new
```

Back in `ModelIterable.__iter__`, after `from_db`:
- `RelatedPopulator.populate(row, obj)` — fills `select_related` foreign-key caches
- `setattr(obj, attr, row[col_pos])` — attaches annotation values

---

## Unified Call Graph

```
# ── QUERYSET CONSTRUCTION ──────────────────────────────────────────────────

Manager.get_queryset()                        manager.py:150
└─ QuerySet.__init__()                         query.py:~290
    └─ Query.__init__()                        sql/query.py:306

QuerySet.filter() / .exclude()                query.py:1666/1674
└─ QuerySet._filter_or_exclude()              query.py:1682
    ├─ QuerySet._chain()                      query.py:2237
    │   └─ Query.chain()                      sql/query.py:433
    │       └─ Query.clone()                  sql/query.py:388
    └─ QuerySet._filter_or_exclude_inplace()  query.py:1693
        └─ Query.add_q(Q(…))                  sql/query.py:1663
            └─ Query._add_q()                 sql/query.py:1692
                └─ Query.build_filter()       sql/query.py:1488
                    ├─ Query.solve_lookup_type()   sql/query.py:1344
                    │   └─ Query.names_to_path()   sql/query.py:1775
                    │       └─ opts.get_field()    (Options API)
                    ├─ Query.resolve_lookup_value()
                    ├─ Query.setup_joins()          sql/query.py:1891
                    │   └─ Query.join()             sql/query.py:1135
                    │       └─ Query.table_alias()  (registers alias_map)
                    ├─ Query.trim_joins()            sql/query.py:2008
                    └─ Query.build_lookup()          sql/query.py:1415
                        └─ field.get_lookup(name)   → Lookup subclass

# ── EVALUATION TRIGGER ─────────────────────────────────────────────────────

QuerySet.__iter__() / __len__() / __bool__()  query.py:420/416/448
└─ QuerySet._fetch_all()                       query.py:2256
    └─ list(ModelIterable(queryset))           query.py:2258

QuerySet.iterator()                            query.py:561
└─ QuerySet._iterator(use_chunked_fetch, …)   query.py:546
    └─ ModelIterable.__iter__()  [streaming]

# ── ITERABLE LAYER ────────────────────────────────────────────────────────

ModelIterable.__iter__()                       query.py:92
├─ Query.get_compiler(using=db)               sql/query.py:370
│   └─ connection.ops.compiler("SQLCompiler")(query, connection, using)
│       → SQLCompiler.__init__()              sql/compiler.py:50
│
├─ SQLCompiler.execute_sql(MULTI, …)          sql/compiler.py:1595
│   [see Phase 4–5 below]
│
├─ SQLCompiler.results_iter(results)          sql/compiler.py:1565
│   ├─ SQLCompiler.get_converters(fields)     sql/compiler.py:1514
│   └─ SQLCompiler.apply_converters(rows, …)  sql/compiler.py:1536
│
└─ for row in results_iter:
    ├─ Model.from_db(db, init_list, row[…])   base.py:618
    │   └─ Model.__init__(*values)
    ├─ RelatedPopulator.populate(row, obj)     (select_related hydration)
    └─ setattr(obj, attr, row[col_pos])        (annotation hydration)

# ── SQL COMPILATION ───────────────────────────────────────────────────────

SQLCompiler.execute_sql()                     sql/compiler.py:1595
└─ SQLCompiler.as_sql()                       sql/compiler.py:757
    └─ SQLCompiler.pre_sql_setup()            sql/compiler.py:83
        ├─ SQLCompiler.setup_query()          sql/compiler.py:75
        │   └─ SQLCompiler.get_select()       sql/compiler.py:241
        │       ├─ Query.get_select_mask()    sql/query.py:878
        │       ├─ SQLCompiler.get_default_columns()  sql/compiler.py:984
        │       │   └─ field.get_col(alias)   → Col expression
        │       └─ [if select_related]
        │           SQLCompiler.get_related_selections()  sql/compiler.py:1175
        ├─ SQLCompiler.get_order_by()         sql/compiler.py:480
        │   └─ SQLCompiler._order_by_pairs()  sql/compiler.py:339
        ├─ WhereNode.split_having_qualify()
        ├─ SQLCompiler.get_extra_select()     sql/compiler.py:541
        └─ SQLCompiler.get_group_by()         sql/compiler.py:99

    ├─ SQLCompiler.get_distinct()
    ├─ SQLCompiler.get_from_clause()          sql/compiler.py:1141
    │   └─ for each alias in alias_map:
    │       SQLCompiler.compile(from_clause)  sql/compiler.py:574
    │           ├─ BaseTable.as_sql()         → "tablename"
    │           └─ Join.as_sql()              sql/datastructures.py:76
    │               └─ SQLCompiler.compile(lhs/rhs Col)
    │
    ├─ SQLCompiler.compile(self.where)        sql/compiler.py:574
    │   └─ WhereNode.as_sql()
    │       └─ Lookup.as_sql()               → "col = %s"
    │
    ├─ [assemble SELECT … FROM … WHERE … GROUP BY … HAVING … ORDER BY … LIMIT]
    └─ return sql_string, params_tuple

# ── DATABASE EXECUTION ────────────────────────────────────────────────────

SQLCompiler.execute_sql() [continued]         sql/compiler.py:1595
├─ connection.cursor()                        → CursorWrapper
│   backends/utils.py:17
├─ CursorWrapper.execute(sql, params)         backends/utils.py:78
│   └─ CursorWrapper._execute_with_wrappers() backends/utils.py:88
│       └─ CursorWrapper._execute()           backends/utils.py:94
│           └─ self.cursor.execute(sql,params) ← DB-API 2.0 driver
│
└─ cursor_iter(cursor, sentinel, col_count,   sql/compiler.py:2258
               chunk_size=2000)
    └─ cursor.fetchmany(2000)                 → list[tuple] per chunk
```

---

## Key Classes & Files

| Class / Function | File | First Line | Role |
|---|---|---|---|
| `QuerySet` | `django/db/models/query.py` | ~290 | Public API; holds `Query`; lazy |
| `Query` | `django/db/models/sql/query.py` | 232 | Internal SQL state: alias_map, where, select, order_by, … |
| `WhereNode` | `django/db/models/sql/where.py` | — | Tree of `Lookup` nodes; compiled to WHERE/HAVING |
| `Join` | `django/db/models/sql/datastructures.py` | 27 | One JOIN clause; `as_sql()` emits `LEFT OUTER JOIN … ON …` |
| `BaseTable` | `django/db/models/sql/datastructures.py` | — | The FROM base table (no join) |
| `SQLCompiler` | `django/db/models/sql/compiler.py` | 43 | Turns `Query` → SQL string; executes; streams rows |
| `ModelIterable` | `django/db/models/query.py` | 89 | Iterator: calls compiler, calls `Model.from_db` per row |
| `CursorWrapper` | `django/db/backends/utils.py` | 17 | Wraps DB-API cursor; adds error wrapping & debug logging |
| `cursor_iter` | `django/db/models/sql/compiler.py` | 2258 | Calls `fetchmany` in a loop; closes cursor when done |
| `Model.from_db` | `django/db/models/base.py` | 618 | Classmethod; builds model instance from a raw DB row |
