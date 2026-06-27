# transcript: Where is `ActiveRecord::Relation` defined, and list every place it is referenced or called across the source tree, with file and line.


💬 I'll load the grove MCP tools first, then use them to find the definition and all references.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__definition,mcp__grove__callers,mcp__grove__outline,mcp__grove__source,mcp__grove__map)

💬 Now I'll search for the definition and all references in parallel.
  ▸ mcp__grove__definition({"name":"Relation","dir":"/home/bench/repos/rails"})
  ▸ mcp__grove__symbols({"dir":"/home/bench/repos/rails","name":"Relation","kind":"class"})

💬 Good — the canonical definition is `activerecord/lib/active_record/relation.rb:5`. Now let me pull all textual and structural references across the repo.
  ▸ mcp__grove__callers({"name":"Relation","dir":"/home/bench/repos/rails"})

💬 Here is the complete picture.  ---  ## Definition  The canonical class is defined at:  | File | Line | Signature | |------|------|-----------| | `activerecor...

──────── RESULT (success, 111508ms, 5 turns) ────────
Here is the complete picture.

---

## Definition

The canonical class is defined at:

| File | Line | Signature |
|------|------|-----------|
| `activerecord/lib/active_record/relation.rb` | **5** | `class Relation` (inside `module ActiveRecord`) |

Five supporting files open additional inner `class Relation` blocks (nested namespaces, not the core class):

| File | Line | Notes |
|------|------|-------|
| `activerecord/lib/active_record/relation/merger.rb` | 6 | `ActiveRecord::Relation` — adds `Merger`/`HashMerger` inside |
| `activerecord/lib/active_record/relation/where_clause.rb` | 6 | adds `WhereClause` |
| `activerecord/lib/active_record/relation/query_attribute.rb` | 6 | adds `QueryAttribute` |
| `activerecord/lib/active_record/relation/from_clause.rb` | 4 | adds `FromClause` |
| `activerecord/test/cases/relation/where_clause_test.rb` | 5 | `class ActiveRecord::Relation` (test stub) |

---

## Subclasses

| File | Line | Class |
|------|------|-------|
| `activerecord/lib/active_record/association_relation.rb` | 4 | `AssociationRelation < Relation` |
| `activerecord/lib/active_record/disable_joins_association_relation.rb` | 4 | `DisableJoinsAssociationRelation < Relation` |
| `activerecord/lib/active_record/associations/collection_proxy.rb` | 31 | `CollectionProxy < Relation` |

---

## References by file

### `activerecord/lib/active_record/relation/query_methods.rb`
| Line | Description |
|------|-------------|
| 162 | `Relation::VALUE_METHODS.each` |
| 165 | `when *Relation::MULTI_VALUE_METHODS` |
| 167 | `when *Relation::SINGLE_VALUE_METHODS` |
| 169 | `when *Relation::CLAUSE_METHODS` |
| 170 | string: `"Relation::FromClause.empty"` / `"Relation::WhereClause.empty"` |
| 1200 | `other.is_a?(Relation)` (in `#and`) |
| 1203 | error message: `"Pass an ActiveRecord::Relation object instead."` |
| 1211 | error message: `"Relation passed to #and …"` |
| 1232 | `other.is_a?(Relation)` (in `#or`) |
| 1239 | error message: `"Pass an ActiveRecord::Relation object instead."` |
| 1247 | error message: `"Relation passed to #or …"` |
| 1462 | `Relation::FromClause.new(…)` |
| 1649 | `element.is_a?(Relation)` (in `#excluding`) |
| 1726 | `Relation::WhereClause.new(parts)` |
| 1757 | `ActiveRecord::Relation === value` (named bind) |
| 1777 | `ActiveRecord::Relation === value` (positional bind) |
| 1855 | `when Relation` (in `#build_from`) |
| 2003 | `when ActiveRecord::Relation` (in `#build_with_expression_from_value`) |
| 2383 | `Relation::VALUE_METHODS -` |
| 439, 448, 459, 466 | doc comments: `# => ActiveRecord::Relation` |
| 472, 494, 509, 1334 | doc/comment references |

### `activerecord/lib/active_record/relation/merger.rb`
| Line | Description |
|------|-------------|
| 11 | `hash.assert_valid_keys(*Relation::VALUE_METHODS)` |
| 26 | `other = Relation.create(…)` |
| 52 | `Relation::VALUE_METHODS - Relation::CLAUSE_METHODS …` |

### `activerecord/lib/active_record/relation/spawn_methods.rb`
| Line | Description |
|------|-------------|
| 13 | doc: `"if other is an ActiveRecord::Relation"` |
| 45 | `Relation::HashMerger.new(self, other).merge` |
| 46 | `elsif other.is_a?(Relation)` |
| 47 | `Relation::Merger.new(self, other).merge` |
| 51 | error: `"is not an ActiveRecord::Relation"` |

### `activerecord/lib/active_record/relation/predicate_builder.rb`
| Line | Description |
|------|-------------|
| 18 | `register_handler(Relation, RelationHandler.new)` |
| 68 | `Relation::QueryAttribute.new(…)` |

### `activerecord/lib/active_record/relation/predicate_builder/association_query_value.rb`
| Line | Description |
|------|-------------|
| 14 | `id_list.is_a?(Relation)` |
| 24 | `when Relation` |

### `activerecord/lib/active_record/relation/predicate_builder/polymorphic_array_value.rb`
| Line | Description |
|------|-------------|
| 39 | `value.is_a?(Relation)` (in `#klass`) |
| 47 | `value.is_a?(Relation)` (in `#convert_to_id`) |

### `activerecord/lib/active_record/relation/delegation.rb`
| Line | Description |
|------|-------------|
| 9 | `ActiveRecord::Relation,` (in `delegated_classes`) |
| 18 | `- ActiveRecord::Relation.public_instance_methods` |
| 98 | doc: subclass of Relation note |

### `activerecord/lib/active_record/relation/finder_methods.rb`
| Line | Description |
|------|-------------|
| 649 | error string: `"Relation has no order values …"` |

### `activerecord/lib/active_record/relation/calculations.rb`
| Line | Description |
|------|-------------|
| 63, 70, 77, 82 | doc references to `Relation#group`, `Relation#select` |

### `activerecord/lib/active_record/relation/batches.rb`
| Line | Description |
|------|-------------|
| 176 | doc: `"Yields ActiveRecord::Relation objects"` |

### `activerecord/lib/active_record/relation/batches/batch_enumerator.rb`
| Line | Description |
|------|-------------|
| 74, 83, 94, 105 | docs: `"See Relation#delete_all"` etc. |
| 112 | doc: `"Yields an ActiveRecord::Relation object"` |

### `activerecord/lib/active_record/core.rb`
| Line | Description |
|------|-------------|
| 443 | `relation = Relation.create(self)` (in `ClassMethods#relation`) |

### `activerecord/lib/active_record/scoping/named.rb`
| Line | Description |
|------|-------------|
| 10, 58, 85 | doc references |
| 165 | `method_defined_within?(name, Relation)` |
| 167 | error string with `"ActiveRecord::Relation"` |
| 197 | `!ActiveRecord::Relation.method_defined?(name)` |

### `activerecord/lib/active_record/scoping/default.rb`
| Line | Description |
|------|-------------|
| 132 | `scope.is_a?(Relation)` |

### `activerecord/lib/active_record/reflection.rb`
| Line | Description |
|------|-------------|
| 337 | `Relation.create(klass, …)` |

### `activerecord/lib/active_record/enum.rb`
| Line | Description |
|------|-------------|
| 393 | `method_defined_within?(method_name, Relation)` |
| 394 | `source: Relation.name` |

### `activerecord/lib/active_record/statement_cache.rb`
| Line | Description |
|------|-------------|
| 164 | `when … Relation, Base then true` (in `unsupported_value?`) |

### `activerecord/lib/active_record/sanitization.rb`
| Line | Description |
|------|-------------|
| 214 | `ActiveRecord::Relation === value` |

### `activerecord/lib/active_record/connection_handling.rb`
| Line | Description |
|------|-------------|
| 419 | `return_value.is_a? ActiveRecord::Relation` |

### `activerecord/lib/active_record/connection_adapters/abstract/database_statements.rb`
| Line | Description |
|------|-------------|
| 803 | `relation.is_a?(Relation)` (in `#arel_from_relation`) |

### `activerecord/lib/active_record/encryption/extended_deterministic_queries.rb`
| Line | Description |
|------|-------------|
| 20 | doc: `# * ActiveRecord::Relation` |
| 25 | doc comment |
| 28 | `ActiveRecord::Relation.prepend(RelationQueries)` |
| 44 | `owner.is_a?(Relation)` |

### `activerecord/lib/active_record/persistence.rb`
| Line | Description |
|------|-------------|
| 130, 308, 631 | doc references (`Relation#update_all`, `Relation#destroy`) |

### `activerecord/lib/active_record/associations.rb`
| Line | Description |
|------|-------------|
| 355, 362, 1099, 1160–1161, 1219–1220, 1862–1863, 1902–1903 | doc references |

### `activerecord/lib/active_record/associations/errors.rb`
| Line | Description |
|------|-------------|
| 242 | doc: `ActiveRecord::Relation#preload` |

### `activerecord/lib/active_record/associations/collection_proxy.rb`
| Line | Description |
|------|-------------|
| 952 | doc: `"Returns a Relation object"` |

### `activerecord/lib/active_record.rb`
| Line | Description |
|------|-------------|
| 109 | `autoload :Relation` |

### `activerecord/lib/arel/nodes/node.rb`
| Line | Description |
|------|-------------|
| 39 | doc: `"ActiveRecord::Relation objects"` |
| 86 | doc: `ActiveRecord::Relation::QueryAttribute.new(…)` |

### `railties/lib/rails/commands/query/query_command.rb`
| Line | Description |
|------|-------------|
| 174 | `when ActiveRecord::Relation` |

---

### Test files

| File | Line | Description |
|------|------|-------------|
| `activerecord/test/cases/relation_test.rb` | 15, 22, 27, 37, 53, 56, 65, 70, 81, 88, 94, 100, 109, 114, 120, 131, 143, 148, 153, 159, 166, 172, 180, 184, 188, 204, 212, 224, 226, 230, 298 | `Relation.new(…)`, constant access, `WhereClause`, `HashMerger` |
| `activerecord/test/cases/relations_test.rb` | 73, 2200, 2205, 2224, 2541, 2552 | `assert_kind_of`, `MULTI_VALUE_METHODS`, `Relation.create(…)` |
| `activerecord/test/cases/relation/mutation_test.rb` | 8, 70, 162 | `MULTI/SINGLE_VALUE_METHODS`, `Relation.new(FakeKlass)` |
| `activerecord/test/cases/relation/delegation_test.rb` | 92–94 | `ActiveRecord::Relation.method_defined?` |
| `activerecord/test/cases/relation/or_test.rb` | 70, 78, 104, 141 | error message assertions |
| `activerecord/test/cases/relation/and_test.rb` | 26, 38 | error message assertions |
| `activerecord/test/cases/batches_test.rb` | 343, 351, 477, 494, 513, 530, 545, 595, 677, 681, 710, 719, 728, 749, 781, 794, 991 | `assert_kind_of ActiveRecord::Relation`, `Relation.create(…)` |
| `activerecord/test/cases/collection_cache_key_test.rb` | 86 | `ActiveRecord::Relation.create(…)` |
| `activerecord/test/cases/base_test.rb` | 637–638, 647, 656–657, 1443 | equality + kind_of assertions |
| `activerecord/test/cases/finder_test.rb` | 844, 1116, 1170, 1186 | `assert_kind_of`, error message assertions |
| `activerecord/test/cases/associations_test.rb` | 616 | `scope.is_a?(ActiveRecord::Relation)` |
| `activerecord/test/cases/bind_parameter_test.rb` | 146, 162, 200 | `Relation::QueryAttribute.new(…)` |
| `activerecord/test/cases/adapter_test.rb` | 323 | `Relation::QueryAttribute.new(…)` |
| `activerecord/test/cases/explain_test.rb` | 177 | `ActiveRecord::Relation::QueryAttribute.new(…)` |
| `activerecord/test/cases/sanitize_test.rb` | 49, 52 | doc string assertions |
| `activerecord/test/cases/null_relation_test.rb` | (class) | subclass of `ActiveRecord::TestCase` using `Relation` |
| `activerecord/test/cases/adapters/sqlite3/sqlite3_adapter_test.rb` | 98, 113, 453, 467 | `Relation::QueryAttribute.new(…)` |
| `activerecord/test/cases/adapters/postgresql/connection_test.rb` | 131, 146 | `Relation::QueryAttribute.new(…)` |
| `activerecord/test/cases/adapters/postgresql/schema_authorization_test.rb` | 108 | `ActiveRecord::Relation::QueryAttribute.new(…)` |
| `activerecord/test/cases/adapters/postgresql/schema_test.rb` | 634 | `ActiveRecord::Relation::QueryAttribute.new(…)` |
| `activerecord/test/cases/adapters/postgresql/postgresql_adapter_test.rb` | 773, 788 | `Relation::QueryAttribute.new(…)` |
| `activerecord/test/support/global_config.rb` | 15 | `ActiveRecord::Relation.remove_method(:klass)` |
| `activerecord/test/models/reply.rb` | 21 | comment: `"Methods both on Kernel and Relation"` |
| `actionview/test/activerecord/relation_cache_test.rb` | (class) | `RelationCacheTest` exercises relations |

---

**Summary:** `ActiveRecord::Relation` is defined in `activerecord/lib/active_record/relation.rb:5`, reopened in four companion files under `activerecord/lib/active_record/relation/`, subclassed in three places (`AssociationRelation`, `DisableJoinsAssociationRelation`, `CollectionProxy`), autoloaded at `activerecord/lib/active_record.rb:109`, and structurally or textually referenced across ~35 source and test files spanning query methods, predicate building, scoping, encryption, adapters, associations, and railties.
