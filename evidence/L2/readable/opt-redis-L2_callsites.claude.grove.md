# transcript: Where is `dictAdd` defined, and list every place it is referenced or called across the source tree, with file and line.


💬 Loading grove tool schemas first.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__definition,mcp__grove__callers)

💬 Now I'll look up the definition and all callers in parallel.
  ▸ mcp__grove__definition({"name":"dictAdd","dir":"/home/bench/repos/redis"})
  ▸ mcp__grove__callers({"name":"dictAdd","dir":"/home/bench/repos/redis"})

💬 ## `dictAdd` — Definition  | File | Line | Kind | |------|------|------| | `src/dict.h` | 258 | Declaration (prototype) | | `src/dict.c` | 493 | **Implementa...

──────── RESULT (success, 59340ms, 4 turns) ────────
## `dictAdd` — Definition

| File | Line | Kind |
|------|------|------|
| `src/dict.h` | 258 | Declaration (prototype) |
| `src/dict.c` | 493 | **Implementation** |
| `deps/hiredis/dict.h` | 117 | Declaration (hiredis copy, `static`) |
| `deps/hiredis/dict.c` | 141 | Implementation (hiredis copy, `static`) |

---

## Call sites (structural — actual call expressions)

### `src/sentinel.c`
| Line | Enclosing function |
|------|--------------------|
| 1375 | `createSentinelRedisInstance` |
| 1977 | `sentinelHandleConfiguration` |
| 3192 | `populateDict` |
| 3246 | `sentinelConfigSetCommand` |
| 3355, 3361, 3367, 3373, 3379, 3385, 3391 | `sentinelConfigGetCommand` |
| 4169 | `sentinelCommand` |
| 4515 | `sentinelSetCommand` |

### `src/t_hash.c`
| Line | Enclosing function |
|------|--------------------|
| 1669 | `hashTypeConvertListpack` |
| 1722 | `hashTypeConvertListpackEx` |
| 1841 | `hashTypeDup` |
| 3552 | `hrandfieldWithCountCommand` |

### `src/t_set.c`
| Line | Enclosing function |
|------|--------------------|
| 181, 227 | `setTypeAddAux` |
| 543 | `setTypeConvertAndExpand` |
| 1274, 1276, 1313 | `srandmemberWithCountCommand` |

### `src/t_zset.c`
| Line | Enclosing function |
|------|--------------------|
| 1483 | `zsetConvertAndExpand` |
| 1904 | `zsetDup` |
| 2752 | `zdiffAlgorithm1` |
| 2793 | `zdiffAlgorithm2` |
| 3064 | `zunionInterDiffGenericCommand` |
| 4697 | `zrandmemberWithCountCommand` |

### `src/t_stream.c`
| Line | Enclosing function |
|------|--------------------|
| 260 | `streamDup` |
| 5928 | `idmpInsertEntry` |

### `src/rdb.c`
| Line | Enclosing function |
|------|--------------------|
| 957 | `rdbLoadStreamIdmpEntries` |
| 2243 | `_ziplistPairsEntryConvertAndValidate` |
| 2344 | `_lpEntryValidation` |
| 2540, 2606, 2672, 2688, 2744, 2868, 2906, 3066 | `rdbLoadObject` |

### `src/server.c`
| Line | Enclosing function |
|------|--------------------|
| 3409 | `commandAddSubcommand` |
| 3496, 3499 | `populateCommandTable` |
| 6231 | `addInfoSectionsToDict` |
| 6280 | `genInfoSectionDict` |

### `src/module.c`
| Line | Enclosing function |
|------|--------------------|
| 1354, 1355 | `RM_CreateCommand` |
| 11751 | `RM_ExportSharedAPI` |
| 13247 | `moduleRegisterApi` |
| 13638 | `moduleOnLoad` |

### `src/config.c`
| Line | Enclosing function |
|------|--------------------|
| 562 | `loadServerConfigFromString` |
| 985, 998 | `configGetCommand` |
| 1095 | `rewriteConfigAddLineNumberToOption` |
| 1107 | `rewriteConfigMarkAsProcessed` |
| 3416 | `registerConfigValue` |

### `src/functions.c`
| Line | Enclosing function |
|------|--------------------|
| 228 | `functionsLibCtxCreate` |
| 264 | `functionLibCreateFunction` |
| 310, 315 | `libraryLink` |
| 420 | `functionsRegisterEngine` |

### `src/pubsub.c`
| Line | Enclosing function |
|------|--------------------|
| 272 | `pubsubSubscribeChannel` |
| 359, 366, 371 | `pubsubSubscribePattern` |

### `src/eval.c`
| Line | Enclosing function |
|------|--------------------|
| 483 | `luaCreateFunction` |

### `src/cluster.c`
| Line | Enclosing function |
|------|--------------------|
| 406 | `migrateGetSocket` |

### `src/cluster_legacy.c`
| Line | Enclosing function |
|------|--------------------|
| 1538 | `clusterAddNode` |
| 1646 | `clusterAddNodeToShard` |
| 1859 | `clusterBlacklistAddNode` |

### `src/geo.c`
| Line | Enclosing function |
|------|--------------------|
| 826 | `georadiusGeneric` |

### `src/latency.c`
| Line | Enclosing function |
|------|--------------------|
| 74 | `latencyAddSample` |

### `src/multi.c`
| Line | Enclosing function |
|------|--------------------|
| 321 | `watchForKey` |

### `src/redis-cli.c`
| Line | Enclosing function |
|------|--------------------|
| 657 | `cliInitCommandHelpEntry` |
| 819 | `cliLegacyInitCommandHelpEntry` |
| 5979 | `clusterManagerGetLinkStatus` |
| 6172 | `clusterManagerFixSlotsCoverage` |
| 8738 | `vsetRecallMode` |
| 9390 | `typeinfo_add` |

### `src/dict.c` (self-test)
| Line | Enclosing function |
|------|--------------------|
| 2027, 2041, 2050, 2102, 2167, 2248, 2267, 2303 | `dictTest` |

### `deps/hiredis/dict.c`
| Line | Enclosing function |
|------|--------------------|
| 174 | `dictReplace` |

---

**Summary:** `dictAdd` is defined in `src/dict.c:493` (declaration at `src/dict.h:258`). There is an independent copy in `deps/hiredis/`. Across the main source tree it is called from **~85 call sites** spanning 17 files — essentially every subsystem that inserts into a `dict`: keyspace/command tables, type implementations (hash, set, zset, stream), persistence (RDB), pub/sub, cluster, config, modules, functions, Lua eval, sentinel, and redis-cli.
