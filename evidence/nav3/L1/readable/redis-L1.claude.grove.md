# transcript: I'm trying to reason about Redis's per-value memory footprint and how a stored value is tagged and tracked while it lives in the keyspace. I need to understa...


💬 I'll look up the core Redis value container using grove.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__source,mcp__grove__definition)
  ▸ mcp__grove__symbols({"dir":"src","name":"robj","kind":"struct"})
  ▸ mcp__grove__symbols({"dir":"src","name":"redisObject"})
  ▸ mcp__grove__source({"id":"c:src/object.h#redisObject@100"})

💬 Now let me pull the type and encoding constants, plus the `kvobj` typedef and `LRU_BITS` / `OBJ_REFCOUNT_BITS` to complete the picture.
  ▸ mcp__grove__symbols({"dir":"src","name":"OBJ_REFCOUNT_BITS"})
  ▸ mcp__grove__symbols({"dir":"src","name":"LRU_BITS"})
  ▸ mcp__grove__symbols({"dir":"src","name":"kvobj"})
  ▸ mcp__grove__outline({"file":"src/object.h","detail":0})

💬 Let me read the surrounding constants in `object.h` to get the full picture.
  ▸ Read(/home/bench/repos/redis/src/object.h)

💬 Let me also grab the `OBJ_TYPE_*` constants.
  ▸ mcp__grove__symbols({"dir":"src","name":"OBJ_STRING"})
  ▸ Bash(grep -n '#define OBJ_' /home/bench/repos/redis/src/server.h | grep -E 'OBJ_(STRING|LIST|SET|ZSET|HASH|STREAM|MODULE)' | head -20)

💬 I now have everything needed. Here's the full breakdown.  ---  ## `struct redisObject` — the universal Redis value container  Defined in `src/object.h:100`, ...

──────── RESULT (success, 69060ms, 12 turns) ────────
I now have everything needed. Here's the full breakdown.

---

## `struct redisObject` — the universal Redis value container

Defined in `src/object.h:100`, typedefed as both `robj` (general) and `kvobj` (key-embedded form). The struct packs everything into **16 bytes** (on 64-bit: four words of bit-fields plus one pointer).

```c
struct redisObject {
    unsigned type:4;
    unsigned encoding:4;
    unsigned refcount : OBJ_REFCOUNT_BITS;  // 23 bits
    unsigned iskvobj : 1;

    unsigned metabits : 8;   // kvobj only
    unsigned lru : LRU_BITS; // 24 bits; kvobj only (but field exists in all)
    void *ptr;
};
```

---

### Field-by-field

**`type` (4 bits)** — the *logical* data type. This is what the `TYPE` command returns and what the command dispatch checks with `checkType()`. Values:

| Constant | Value | Meaning |
|---|---|---|
| `OBJ_STRING` | 0 | String |
| `OBJ_LIST` | 1 | List |
| `OBJ_SET` | 2 | Set |
| `OBJ_ZSET` | 3 | Sorted set |
| `OBJ_HASH` | 4 | Hash |
| `OBJ_MODULE` | 5 | Module |
| `OBJ_STREAM` | 6 | Stream |

**`encoding` (4 bits)** — the *concrete in-memory representation* of that type. This is the field that distinguishes logical type from physical layout. A single logical type can transition between encodings as it grows (e.g. a small set starts as `INTSET` or `LISTPACK`, then converts to `HT`). Current encoding constants (`src/object.h:75–88`):

| Constant | Value | Used by |
|---|---|---|
| `OBJ_ENCODING_RAW` | 0 | String (SDS heap allocation) |
| `OBJ_ENCODING_INT` | 1 | String (integer stored in `ptr` itself) |
| `OBJ_ENCODING_HT` | 2 | Hash, Set |
| `OBJ_ENCODING_INTSET` | 6 | Set |
| `OBJ_ENCODING_SKIPLIST` | 7 | Sorted set |
| `OBJ_ENCODING_EMBSTR` | 8 | String (SDS embedded in the `robj` allocation) |
| `OBJ_ENCODING_QUICKLIST` | 9 | List |
| `OBJ_ENCODING_STREAM` | 10 | Stream |
| `OBJ_ENCODING_LISTPACK` | 11 | Hash, Set, ZSet, List (compact form) |
| `OBJ_ENCODING_LISTPACK_EX` | 12 | Extended listpack (with per-element metadata) |
| `OBJ_ENCODING_SLICED_ARRAY` | 13 | Newer set/hash encoding |

**`refcount` (23 bits)** — reference count for lifetime management. `incrRefCount`/`decrRefCount` (`src/object.h:129–130`) govern this. Two sentinel values: `OBJ_SHARED_REFCOUNT` (all 23 bits set) marks permanently shared objects (small integers, common strings) that are never freed; `OBJ_STATIC_REFCOUNT` marks stack-allocated objects.

**`iskvobj` (1 bit)** — distinguishes a plain `robj` (value-only) from a `kvobj` (key-embedded form). When set, the struct is the header of a larger allocation that lays out: optional metadata blocks *before* the struct, then an inline key SDS immediately after, then optionally an embedded value SDS after that. Plain `robj`s leave `metabits` and `lru` meaningful only when `iskvobj=1`.

**`metabits` (8 bits, kvobj only)** — a bitmap of which metadata slots are active. Up to 8 classes (64-bit slots each), stored *before* the struct in reverse class order. Class 0 is reserved for expiration time. `kvobjMetaRef()` navigates to a slot by counting set bits below the requested class index.

**`lru` (24 bits, kvobj only)** — the eviction/LRU field. Dual-purpose depending on server policy:
- **LRU mode**: stores a relative timestamp in seconds, sampled from the global `lru_clock` (1-second resolution, wraps every ~194 days). Eviction picks the key with the largest clock delta.
- **LFU mode**: the 24 bits split as 16 bits of "last decrement time" (minute granularity) + 8 bits of access frequency counter. The Morris counter in the low byte is bumped probabilistically on access and decays over time.

**`ptr` (pointer)** — payload. For most types this is a heap allocation (`SDS`, `dict *`, `quicklist *`, etc.) through `zmalloc`. Exception: when `encoding == OBJ_ENCODING_INT`, the pointer field is cast directly to `long` and stores the integer value inline, saving an allocation entirely.

---

### The `kvobj` extension

`kvobj` is the same struct (`typedef struct redisObject kvobj`) but with `iskvobj=1` and a specific allocation layout. `kvobjCreate()` (`src/object.h:120`) allocates a single contiguous block that holds all metadata blocks, the `redisObject` header, a 1-byte key-header-size hint, the SDS key, and optionally an embedded SDS value. This packs key + value + expiry into one allocation instead of three, reducing allocator overhead and pointer chasing for the common case.
