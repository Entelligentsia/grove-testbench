# transcript: I'm planning a change to how persisting a model instance interacts with the database, so I need to understand the full journey of saving a single object. Sta...


💬 Let me load the grove tools and start mapping the save flow.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me outline the model base file and find the key save-related methods.
  ▸ mcp__grove__outline({"file":"django/db/models/base.py","kind":"method","detail":0})
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__map,mcp__grove__definition,mcp__grove__callers)
  ▸ mcp__grove__outline({"file":"django/db/models/base.py","kind":"method","detail":1})
  ▸ mcp__grove__symbols({"dir":"django/db/models","name":"save","kind":"method"})
  ▸ mcp__grove__map({"dir":"django/db/models","name":"save"})

💬 Found the entry point. Now let me read all the key stages in parallel.
  ▸ mcp__grove__source({"id":"python:django/db/models/base.py#save@841"})
  ▸ mcp__grove__map({"dir":"django/db/models","name":"save_base"})
  ▸ mcp__grove__map({"dir":"django/db/models","nameContains":true,"name":"_do_insert"})
  ▸ mcp__grove__source({"id":"python:django/db/models/base.py#save_base@950"})
  ▸ mcp__grove__map({"dir":"django/db/models","name":"_save_table"})
  ▸ mcp__grove__map({"dir":"django/db/models","name":"_do_update"})
  ▸ mcp__grove__source({"id":"python:django/db/models/base.py#_save_table@1069"})
  ▸ mcp__grove__source({"id":"python:django/db/models/base.py#_do_update@1206"})
  ▸ mcp__grove__source({"id":"python:django/db/models/base.py#_do_insert@1246"})

💬 Now let me find the `_update` and `_insert` methods on QuerySet/manager, and the SQL compiler that executes them.
  ▸ mcp__grove__map({"dir":"django/db/models","name":"_update"})
  ▸ mcp__grove__map({"dir":"django/db/models","name":"_insert"})
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#_update@1428"})
  ▸ mcp__grove__source({"id":"python:django/db/models/query.py#_insert@2112"})

💬 Now let me look at the SQL compiler layer — how `InsertQuery` and `UpdateQuery` become actual SQL.
  ▸ mcp__grove__map({"dir":"django/db/models/sql","name":"execute_sql"})
  ▸ mcp__grove__map({"dir":"django/db/models/sql","name":"as_sql","kind":"method"})
  ▸ mcp__grove__map({"dir":"django/db/models/sql","nameContains":true,"name":"as_sql"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#execute_sql@1925"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#execute_sql@2114"})

💬 Now let me grab the `execute_returning_sql` method and the insert/update `as_sql` bodies to complete the picture.
  ▸ mcp__grove__map({"dir":"django/db/models/sql","name":"execute_returning_sql"})
  ▸ mcp__grove__source({"id":"python:django/db/models/sql/compiler.py#as_sql@2037"})

💬 I have the complete picture. Here is the full journey from `Model.save()` to `cursor.execute()`.  ---  ## The four stages of a Django model save  ### Stage 1...

──────── RESULT (success, 135809ms, 27 turns) ────────
I have the complete picture. Here is the full journey from `Model.save()` to `cursor.execute()`.

---

## The four stages of a Django model save

### Stage 1 — `Model.save()` (`base.py:841`): public entry point & pre-flight

This is the only method callers touch. Before handing off, it does three things:

1. **`_prepare_related_fields_for_save()`** — walks every FK/O2O field and ensures that any related instance has been saved first (or that the raw FK id column is set), raising errors otherwise.
2. **Database routing** — picks the alias with `router.db_for_write()`, defaulting to whatever `using` the caller supplied.
3. **`update_fields` resolution** — if the object is *deferred* (some fields were never loaded into `self.__dict__`) and no `force_insert` is set, it computes a `frozenset` of only the loaded concrete fields and passes that down as `update_fields`, so the UPDATE doesn't wipe columns that were never fetched.

Everything then flows into `save_base()`.

---

### Stage 2 — `Model.save_base()` (`base.py:950`): once-per-save lifecycle bookkeeping

This is the layer that fires lifecycle signals and wraps everything in a transaction. The key steps:

1. **Proxy stripping** — if the current class is a proxy model the concrete model is used for the actual DB work, but `origin` keeps the proxy class (so signals carry the proxy as `sender`).
2. **`pre_save` signal** — fired on `origin` before any DB work, passing `raw`, `using`, and `update_fields`.
3. **Transaction context**:
   - Multi-table inheritance (`meta.parents` is non-empty): `transaction.atomic(savepoint=False)` so parent-table INSERTs and the child-table INSERT/UPDATE are one unit.
   - Simple single-table model: `mark_for_rollback_on_error`, which is cheaper (no savepoint).
4. **Parent saves** — in non-raw mode, `_validate_force_insert()` then `_save_parents()` recursively upserts each ancestor table row (for MTI). Whether this resulted in a fresh INSERT is passed down as `parent_inserted`.
5. **`_save_table()`** — the actual row work (stage 3).
6. **State update** — `self._state.db = using` and `self._state.adding = False`.
7. **`post_save` signal** — fired with `created=(not updated)` so receivers know whether this was an INSERT or an UPDATE.

---

### Stage 3 — `Model._save_table()` (`base.py:1069`): INSERT-vs-UPDATE decision

This is where the branching logic lives. It operates on a single concrete table.

**First**, it resolves the PK:
- If the PK is not yet set, it tries `get_pk_value_on_save()` (e.g. a UUID with a `default`).

**Fast-path to INSERT** — if `_state.adding` is `True` *and* every PK field has a `default` or `has_db_default`, it sets `force_insert = True` without attempting an UPDATE, avoiding a wasted round-trip.

**UPDATE attempt** — if the PK is set and we're not forcing an INSERT:
- Calls `field.pre_save(self, False)` (the `False` means "not adding") on every non-PK, non-generated field to give fields a chance to modify their value (e.g. `DateTimeField(auto_now=True)`).
- Builds `returning_fields` — generated columns that depend on the fields being updated, plus any expression values that need to be read back.
- Hands off to `_do_update()`.
- If `_do_update()` returns a non-empty list, the UPDATE matched a row — record success and assign any returned values to the instance.
- If the UPDATE matched nothing and either `force_update` or `update_fields` was set, raises `Model.NotUpdated`.

**INSERT path** — reached if the UPDATE attempt returned empty (row didn't exist yet) or if the PK was never set:
- Optionally queries for the `_order` counter value if `order_with_respect_to` is configured.
- Builds `insert_fields` (all local concrete non-generated fields, excluding the auto-field when no PK was set) and `returning_fields` (all `db_returning` columns, plus expression fields).
- Calls `_do_insert()`.
- Assigns any returned values (e.g. the newly generated PK) back onto the instance.

---

### Stage 4 — SQL compilation and execution

#### UPDATE path

**`Model._do_update()` (`base.py:1206`)**
Wraps the QuerySet to `filter(pk=pk_val)` and calls `qs._update(values, returning_fields)`.

There is one special case: if `Meta.select_on_save` is set, it does an `EXISTS` check first so it can distinguish "row not found" from "row found but UPDATE returned 0 due to a database quirk."

**`QuerySet._update()` (`query.py:1428`)**
Chains a new `sql.UpdateQuery` off the existing queryset, calls `add_update_fields(values)` to register the (field, model, value) triples, then asks for a compiler:
- No returning fields → `compiler.execute_sql(ROW_COUNT)`
- Returning fields → `compiler.execute_returning_sql(returning_fields)`

**`SQLUpdateCompiler.as_sql()` (`compiler.py:2037`)**
Iterates the `(field, model, val)` triples. For each:
- Expressions: calls `val.resolve_expression(query, for_save=True)` then `compile(val)`.
- Related-model instances: calls `val.prepare_database_save(field)`.
- Plain values: calls `field.get_db_prep_save(val, connection=...)`.

Assembles `UPDATE table SET col = %s, ... WHERE pk = %s`, optionally appending a `RETURNING ...` clause if the backend supports it.

**`SQLUpdateCompiler.execute_returning_sql()` (`compiler.py:2135`)**
Opens a cursor, runs `cursor.execute(sql, params)`, fetches the returned rows via `connection.ops.fetch_returned_rows()`, applies field converters, and returns the row list. `execute_sql(ROW_COUNT)` takes a simpler path and just returns the affected row count.

---

#### INSERT path

**`Model._do_insert()` (`base.py:1246`)**
A thin wrapper: calls `manager._insert([self], fields=..., returning_fields=..., using=..., raw=...)`.

**`QuerySet._insert()` (`query.py:2112`)**
Creates a fresh `sql.InsertQuery`, calls `insert_values(fields, objs, raw=raw)` to load the row data, then calls `query.get_compiler(using).execute_sql(returning_fields)`.

**`SQLInsertCompiler.as_sql()` (`compiler.py:1801`)**
Builds the `INSERT INTO table (col, ...) VALUES (%s, ...)` string. Calls `field.pre_save(self, add=True)` for each field (note: add=True this time), calls `field.get_db_prep_save()` on each value, and appends an `ON CONFLICT` suffix and/or `RETURNING` clause when the backend and `on_conflict` settings support them.

**`SQLInsertCompiler.execute_sql()` (`compiler.py:1925`)**
Opens a cursor and calls `cursor.execute(sql, params)` for each SQL statement from `as_sql()`. Then retrieves the generated PK one of three ways depending on backend capabilities:
- `can_return_columns_from_insert` (Postgres, etc.): reads the `RETURNING` rows directly.
- `last_insert_id()`: asks the connection for the auto-increment ID (SQLite, MySQL).
- Neither: returns an empty list (caller must have supplied the PK explicitly).

Applies field converters and returns the row list back up to `_save_table`, which writes the values (e.g. the new PK) onto `self`.

---

## How the stages connect

```
Model.save()
  └─ resolves DB alias, update_fields, deferred fields
     └─ Model.save_base()
           ├─ fires pre_save signal
           ├─ _save_parents()    ← MTI parent rows first
           ├─ _save_table()
           │     ├─ pk set + not force_insert?
           │     │     └─ _do_update()
           │     │           └─ QuerySet._update()
           │     │                 └─ SQLUpdateCompiler.as_sql() → cursor.execute()
           │     └─ UPDATE hit nothing (or force_insert)?
           │           └─ _do_insert()
           │                 └─ QuerySet._insert()
           │                       └─ SQLInsertCompiler.as_sql() → cursor.execute()
           │                             └─ last_insert_id() / RETURNING rows
           └─ fires post_save signal  (created = not updated)
```

The key invariant to keep in mind if you're modifying this flow: `_save_table` returns `True` only when an UPDATE found and modified a row. That boolean propagates up to `save_base` which uses it to set `created` on the `post_save` signal and to flip `_state.adding` to `False`. Any change to when `_do_update` returns an empty list versus a populated list will shift what callers observe as "this was a create vs an update."
