# transcript: Give the complete end-to-end picture of how Django's ORM executes a QuerySet against the database as a subsystem: from QuerySet evaluation, through the Query...


💬 I'll trace the full ORM execution pipeline using grove's semantic tools.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now I'll fan out across all key ORM files in parallel to build the full picture.
  ▸ mcp__grove__outline({"file":"django/db/models/query.py","detail":0})
  ▸ mcp__grove__outline({"file":"django/db/models/sql/query.py","detail":0})
  ▸ mcp__grove__outline({"file":"django/db/models/sql/compiler.py","detail":0})
  ▸ mcp__grove__outline({"file":"django/db/backends/utils.py","detail":0})

💬 Good. Now I'll pull the key method bodies in parallel — the evaluation trigger, SQL building, execution, and model construction paths.
  ▸ mcp__grove__source({"file":"django/db/models/query.py","name":"__iter__"})
  ▸ mcp__grove__source({"file":"django/db/models/query.py","name":"_fetch_all"})
  ▸ mcp__grove__source({"file":"django/db/models/query.py","name":"_iterator"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/query.py","name":"get_compiler"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"execute_sql"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"results_iter"})
  ▸ mcp__grove__source({"file":"django/db/backends/utils.py","name":"execute"})

💬 Now I'll pull the SQL assembly methods, cursor internals, model construction, and the QuerySet-level `__iter__` in parallel.
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#__iter__@420"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"as_sql"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"pre_sql_setup"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"get_select"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"get_from_clause"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"get_converters"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"apply_converters"})
  ▸ mcp__grove__source({"file":"django/db/backends/utils.py","name":"_execute_with_wrappers"})
  ▸ mcp__grove__source({"file":"django/db/backends/utils.py","name":"_execute"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#cursor_iter@2258"})

💬 Now I'll pull the `SQLCompiler.as_sql` (main body), `setup_query`, `compile`, `from_db`, and `RelatedPopulator` to complete the construction chain.
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#as_sql@757"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"setup_query"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"compile"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"get_default_columns"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"get_related_selections"})
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#populate@3032"})
  ▸ mcp__grove__symbols({"dir":"django/db/models","name":"from_db"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"get_order_by"})

💬 Final batch: `Model.from_db`, `RelatedPopulator.__init__`, `SQLCompiler.__init__`, and `Query.__init__` structure.
  ▸ mcp__grove__source({"id":"python:django/db/models/base.py#from_db@618"})
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#__init__@2971"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#__init__@50"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/compiler.py","name":"get_group_by"})
  ▸ mcp__grove__symbols({"dir":"django/db/backends/base","name":"cursor"})

💬 Two final lookups to complete the connection/cursor chain.
  ▸ mcp__grove__source({"id":"python:django/db/backends/base/base.py#cursor@318"})
  ▸ mcp__grove__symbols({"dir":"django/db/backends/base","name":"_cursor"})
  ▸ mcp__grove__source({"file":"django/db/models/sql/query.py","name":"__init__"})
  ▸ mcp__grove__source({"file":"django/db/models/query.py","name":"__init__"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/query.py#__init__@306"})
  ▸ mcp__grove__source({"id":"python:django/db/backends/base/base.py#_cursor@294"})
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#__init__@329"})

💬 I now have everything. Here is the complete picture.  ---  ## Django ORM Execution Pipeline  ### Key Classes  | Class | File | Role | |---|---|---| | `QueryS...

──────── RESULT (success, 212348ms, 43 turns) ────────
I now have everything. Here is the complete picture.

---

## Django ORM Execution Pipeline

### Key Classes

| Class | File | Role |
|---|---|---|
| `QuerySet` | `django/db/models/query.py:326` | Public API; lazy, caches results |
| `Query` | `django/db/models/sql/query.py:232` | Logical query state (joins, filters, ordering, annotations) |
| `SQLCompiler` | `django/db/models/sql/compiler.py:43` | Translates `Query` → SQL string |
| `ModelIterable` | `django/db/models/query.py:89` | Drives the three-level iterator; instantiates model objects |
| `RelatedPopulator` | `django/db/models/query.py:2955` | Hydrates `select_related` objects from row slices |
| `BaseDatabaseWrapper` | `django/db/backends/base/base.py` | Connection, cursor lifecycle |
| `CursorWrapper` | `django/db/backends/utils.py:17` | Wraps DBAPI cursor; applies execute wrappers |

---

### Phase 1 — QuerySet Evaluation (Lazy → Eager)

Every ordinary Python access to a `QuerySet` (iteration, slicing, `len()`, `bool()`) ultimately calls `_fetch_all`.

```
QuerySet.__iter__                           query.py:420
  └─ QuerySet._fetch_all                   query.py:2256
       └─ list(ModelIterable(self))        query.py:2256
            # ModelIterable.__init__ inherited from BaseIterable; just stores the qs
```

`QuerySet.__init__` (`query.py:329`) sets up:
- `self._query = sql.Query(self.model)` — the mutable logical query
- `self._iterable_class = ModelIterable` — swapped to `ValuesIterable` etc. for `.values()`
- `self._result_cache = None` — populated by `_fetch_all`

`QuerySet.iterator()` (`query.py:561`) skips the cache and delegates to `_iterator` (`query.py:546`), which constructs the same `ModelIterable` but `yield from`s it directly (used by `.iterator(chunk_size=…)` for streaming).

---

### Phase 2 — Compiler Creation

```
ModelIterable.__iter__                     query.py:92
  └─ Query.get_compiler(using=db)          sql/query.py:370
       ├─ connection = connections[using]   # DatabaseWrapper from DATABASES setting
       └─ connection.ops.compiler("SQLCompiler")(query, connection, using, elide_empty)
            └─ SQLCompiler.__init__         compiler.py:50
                 # stores .query, .connection, .using
                 # .select / .klass_info / .annotation_col_map = None  (filled later)
```

`Query.__init__` (`sql/query.py:306`) initialises:
- `self.alias_map = {}` — table → `Join` objects (the join graph)
- `self.alias_refcount = {}` — reference counts driving INNER vs. LEFT OUTER promotion
- `self.where = WhereNode()` — the predicate tree
- `self.annotations`, `self.extra`, `self._filtered_relations`

---

### Phase 3 — SQL Construction

```
ModelIterable.__iter__
  └─ SQLCompiler.execute_sql(chunked_fetch, chunk_size)  compiler.py:1595
       └─ sql, params = SQLCompiler.as_sql()             compiler.py:757
            └─ extra_select, order_by, group_by =
                 SQLCompiler.pre_sql_setup()             compiler.py:83
                   ├─ SQLCompiler.setup_query()          compiler.py:75
                   │    ├─ Query.get_initial_alias()     sql/query.py:1113
                   │    │    # registers the root table alias in alias_map
                   │    └─ SQLCompiler.get_select()      compiler.py:241
                   │         ├─ Query.get_select_mask()  sql/query.py:878
                   │         │    # applies defer()/only() → set of fields to include
                   │         ├─ SQLCompiler.get_default_columns(select_mask)  compiler.py:984
                   │         │    # iterates opts.concrete_fields
                   │         │    # per field: Query.join_parent_model() + field.get_col(alias)
                   │         │    # → list of Col expressions
                   │         ├─ [if select_related]
                   │         │    SQLCompiler.get_related_selections(select, select_mask)
                   │         │                           compiler.py:1175
                   │         │    # recursive; per FK/O2O: Query.setup_joins() adds JOIN,
                   │         │    # get_default_columns() for the joined model,
                   │         │    # returns klass_info tree with select_fields ranges
                   │         └─ per column: SQLCompiler.compile(col)  compiler.py:574
                   │              # → col.as_<vendor>(compiler, connection)
                   │              #   or col.as_sql(compiler, connection)
                   │              # stores (expression, (sql, params), alias) in self.select
                   │              # → self.select, self.klass_info, self.annotation_col_map set
                   │
                   ├─ SQLCompiler.get_order_by()          compiler.py:480
                   │    ├─ SQLCompiler._order_by_pairs()  compiler.py:339
                   │    ├─ expr.resolve_expression(query) # per ordering expression
                   │    └─ SQLCompiler.compile(resolved)  compiler.py:574
                   │
                   ├─ WhereNode.split_having_qualify()    # splits predicate tree
                   ├─ SQLCompiler.get_extra_select()      compiler.py:541
                   └─ SQLCompiler.get_group_by(select, order_by)  compiler.py:99
                        └─ SQLCompiler.compile(expr)      compiler.py:574  (per group-by col)
```

Back in `as_sql` after `pre_sql_setup`:

```
       ├─ SQLCompiler.get_distinct()        compiler.py:1035
       ├─ SQLCompiler.get_from_clause()     compiler.py:1141
       │    # iterates query.alias_map (only refcount > 0 aliases)
       │    # per join: SQLCompiler.compile(from_clause) → Join.as_sql()
       ├─ SQLCompiler.compile(self.where)   compiler.py:574  → WhereNode.as_sql()
       ├─ SQLCompiler.compile(self.having)  compiler.py:574
       └─ assembles:
            ["SELECT", cols, "FROM", from_, "WHERE", where,
             "GROUP BY", ..., "HAVING", ..., "ORDER BY", ..., "LIMIT n OFFSET m"]
            → returns " ".join(result), tuple(params)
```

`SQLCompiler.compile` (`compiler.py:574`) is the universal dispatch point — it checks for a vendor-specific method (`as_sqlite`, `as_postgresql`, …) before falling back to `as_sql`. Every expression node (`Col`, `Value`, `F`, `Func`, `Lookup`, `WhereNode`, `Join`, …) implements `as_sql(compiler, connection)`.

---

### Phase 4 — Cursor & Execution

```
SQLCompiler.execute_sql                    compiler.py:1595
  ├─ BaseDatabaseWrapper.cursor()          base/base.py:318
  │    └─ BaseDatabaseWrapper._cursor()   base/base.py:294
  │         ├─ self.ensure_connection()   # opens connection if needed
  │         └─ self._prepare_cursor(
  │                self.create_cursor())  # backend-specific DBAPI cursor creation
  │                                       # _prepare_cursor wraps in CursorWrapper
  │                                       # (or CursorDebugWrapper when DEBUG=True)
  │
  └─ CursorWrapper.execute(sql, params)   backends/utils.py:78
       └─ CursorWrapper._execute_with_wrappers(sql, params, many=False,
                                          executor=self._execute)  utils.py:88
            # chains any connection.execute_wrappers (e.g. logging, tracing)
            └─ CursorWrapper._execute(sql, params, …)   utils.py:94
                 ├─ self.db.validate_no_broken_transaction()
                 └─ self.cursor.execute(sql, params)
                      # self.cursor is the raw DBAPI2 cursor
                      # (sqlite3.Cursor, psycopg2.cursor, etc.)
```

---

### Phase 5 — Row Fetching

```
SQLCompiler.execute_sql   (result_type=MULTI)
  └─ cursor_iter(cursor, empty_fetchmany_value, col_count, chunk_size)
                                             compiler.py:2258
       # loops: cursor.fetchmany(2000) until sentinel (empty list)
       # yields chunks (list-of-tuples), applying col_count masking if needed
       # closes cursor in finally block
       → returns list-of-chunks  (or lazy iterator if chunked_fetch=True)
```

---

### Phase 6 — Value Conversion

```
SQLCompiler.results_iter(results)          compiler.py:1565
  ├─ fields = [s[0] for s in self.select]  # expression objects
  ├─ SQLCompiler.get_converters(fields)    compiler.py:1514
  │    # per expression:
  │    #   connection.ops.get_db_converters(expr)  → backend converters (UUID→uuid.UUID, etc.)
  │    #   expression.get_db_converters(connection) → field converters (JSONField parse, etc.)
  │    → {col_index: ([converter_fns], expression)}
  ├─ rows = chain.from_iterable(results)   # flatten chunks → individual row tuples
  └─ SQLCompiler.apply_converters(rows, converters)  compiler.py:1536
       # per row, per converter position:
       #   value = converter(value, expression, connection)
       → yields converted rows (still flat tuples/lists)
```

---

### Phase 7 — Model Instantiation

```
ModelIterable.__iter__                     query.py:92
  # reads compiler.select, compiler.klass_info, compiler.annotation_col_map
  # (set as side-effect of execute_sql → as_sql → setup_query)
  ├─ model_cls  = klass_info["model"]
  ├─ select_fields = klass_info["select_fields"]   # column index range for root model
  ├─ init_list = [f[0].target.attname for f in select[start:end]]
  ├─ related_populators = get_related_populators(klass_info, select, db, fetch_mode)
  │                                          query.py:3053
  │    # recursively builds RelatedPopulator tree mirroring klass_info tree
  │
  └─ for row in compiler.results_iter(results):
       ├─ Model.from_db(db, init_list, row[start:end], fetch_mode=fetch_mode)
       │                                  base.py:618
       │    ├─ if deferred: interleaves DEFERRED sentinel for missing fields
       │    ├─ new = cls(*values)          # Model.__init__ with positional field values
       │    ├─ new._state.adding = False
       │    ├─ new._state.db = db
       │    └─ return new
       │
       ├─ for rel_populator in related_populators:
       │    RelatedPopulator.populate(row, obj)   query.py:3032
       │      ├─ obj_data = row[cols_start:cols_end]   (or reorder_for_init(row) for child models)
       │      ├─ if obj_data[pk_idx] is None → obj = None
       │      ├─ else: Model.from_db(db, init_list, obj_data, fetch_mode=…)  base.py:618
       │      │         (recurse for deeper select_related)
       │      ├─ self.local_setter(from_obj, obj)   # field.set_cached_value on parent
       │      └─ self.remote_setter(obj, from_obj)  # back-fill reverse (e.g. O2O)
       │
       ├─ for attr_name, col_pos in annotation_col_map.items():
       │    setattr(obj, attr_name, row[col_pos])   # attach annotation values
       │
       └─ yield obj
```

After `list(ModelIterable(qs))` returns, `_fetch_all` (`query.py:2256`) runs `prefetch_related_objects` (`query.py:2617`) if any prefetch lookups are pending — that fires one additional query per relation and populates `obj._prefetched_objects_cache`.

---

### Unified Call Graph

```
QuerySet.__iter__                                    query.py:420
└─ QuerySet._fetch_all                               query.py:2256
   └─ list(ModelIterable(qs))
      └─ ModelIterable.__iter__                      query.py:92
         │
         ├─[compiler creation]
         │  Query.get_compiler(using)                sql/query.py:370
         │  └─ SQLCompiler.__init__                  compiler.py:50
         │
         ├─[sql build + execute]
         │  SQLCompiler.execute_sql                  compiler.py:1595
         │  ├─ SQLCompiler.as_sql                    compiler.py:757
         │  │  └─ SQLCompiler.pre_sql_setup          compiler.py:83
         │  │     ├─ SQLCompiler.setup_query         compiler.py:75
         │  │     │  ├─ Query.get_initial_alias      sql/query.py:1113
         │  │     │  └─ SQLCompiler.get_select       compiler.py:241
         │  │     │     ├─ Query.get_select_mask     sql/query.py:878
         │  │     │     ├─ SQLCompiler.get_default_columns   compiler.py:984
         │  │     │     │  └─ Query.join_parent_model + Field.get_col
         │  │     │     ├─ SQLCompiler.get_related_selections  compiler.py:1175
         │  │     │     │  └─ (recursive; calls Query.setup_joins + get_default_columns)
         │  │     │     └─ SQLCompiler.compile(col)  compiler.py:574
         │  │     │        └─ col.as_sql / as_<vendor>
         │  │     ├─ SQLCompiler.get_order_by        compiler.py:480
         │  │     │  ├─ SQLCompiler._order_by_pairs  compiler.py:339
         │  │     │  └─ SQLCompiler.compile          compiler.py:574
         │  │     ├─ WhereNode.split_having_qualify
         │  │     ├─ SQLCompiler.get_extra_select    compiler.py:541
         │  │     └─ SQLCompiler.get_group_by        compiler.py:99
         │  │        └─ SQLCompiler.compile          compiler.py:574
         │  │  [back in as_sql]
         │  │  ├─ SQLCompiler.get_distinct           compiler.py:1035
         │  │  ├─ SQLCompiler.get_from_clause        compiler.py:1141
         │  │  │  └─ SQLCompiler.compile(Join)       compiler.py:574
         │  │  ├─ SQLCompiler.compile(where)         compiler.py:574
         │  │  └─ assembles SQL string + params tuple
         │  │
         │  ├─ BaseDatabaseWrapper.cursor            base/base.py:318
         │  │  └─ BaseDatabaseWrapper._cursor        base/base.py:294
         │  │     ├─ BaseDatabaseWrapper.ensure_connection
         │  │     └─ BaseDatabaseWrapper._prepare_cursor(create_cursor())
         │  │        └─ → CursorWrapper (or CursorDebugWrapper)
         │  │
         │  ├─ CursorWrapper.execute(sql, params)    backends/utils.py:78
         │  │  └─ CursorWrapper._execute_with_wrappers  utils.py:88
         │  │     └─ CursorWrapper._execute          utils.py:94
         │  │        └─ dbapi_cursor.execute(sql, params)   ← DBAPI2 boundary
         │  │
         │  └─ cursor_iter(cursor, …, chunk_size)    compiler.py:2258
         │     └─ cursor.fetchmany(2000)  [repeated]
         │        → yields list-of-row-tuples per chunk
         │
         ├─[value conversion]
         │  SQLCompiler.results_iter(results)        compiler.py:1565
         │  ├─ SQLCompiler.get_converters(fields)    compiler.py:1514
         │  │  ├─ connection.ops.get_db_converters
         │  │  └─ expression.get_db_converters
         │  └─ SQLCompiler.apply_converters(rows, converters)  compiler.py:1536
         │     └─ converter(value, expression, connection)  [per col per row]
         │
         └─[model construction]  (per row from results_iter)
            ├─ Model.from_db(db, init_list, row_slice, fetch_mode)   base.py:618
            │  └─ Model.__init__(*values)
            ├─ RelatedPopulator.populate(row, obj)   query.py:3032  [per select_related depth]
            │  └─ Model.from_db(…)  (recursive for nested related models)
            │     └─ local_setter(from_obj, obj)   field.set_cached_value
            │        remote_setter(obj, from_obj)
            ├─ setattr(obj, annotation_name, row[col_pos])  [per annotation]
            └─ yield obj
   │
   └─[prefetch, after list() completes]
      prefetch_related_objects(result_cache, *lookups)   query.py:2617
      └─ prefetch_one_level(…)  [per relation, per batch]
```

---

### Key Structural Insights

**Three-level iterator** (documented in `QuerySet.__iter__` at `query.py:420`):
1. `execute_sql` → raw DB rows in chunks of 2000 (`cursor.fetchmany`)
2. `results_iter` → one row at a time, with type converters applied
3. `ModelIterable.__iter__` → one model instance per row

**`self.select` / `self.klass_info` coupling**: `setup_query` populates these on the compiler as a side-effect of `execute_sql`. `ModelIterable` reads them back *after* `execute_sql` returns to know which row slice belongs to which model field — this is the handshake between SQL-building and model-building.

**`klass_info` tree**: a nested dict `{"model", "select_fields", "related_klass_infos": [...]}` that mirrors the JOIN graph. `get_related_populators` (`query.py:3053`) converts this tree into a parallel tree of `RelatedPopulator` instances, one per JOIN depth level.

**`compile()` dispatch** (`compiler.py:574`): every node in the query expression tree (`Col`, `Value`, `F`, `Func`, `WhereNode`, `Join`, aggregates, lookups, …) exposes `as_sql(compiler, connection)`. `compile()` is the single call site that drives the entire recursive SQL generation.

**`DEFERRED` sentinel** (`base.py:618`): when `defer()`/`only()` excludes some fields, `from_db` inserts the `DEFERRED` object at those positions. The first attribute access triggers a new query to load the missing field.
