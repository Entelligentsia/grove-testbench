# transcript: I'm trying to reason about Redis's per-value memory footprint and how a stored value is tagged and tracked while it lives in the keyspace. I need to understa...


💬 Let me load grove and look up the core value container.
  ▸ ToolSearch(select:mcp__grove__symbols,mcp__grove__source,mcp__grove__definition)
  ▸ mcp__grove__symbols({"dir":"src","name":"robj","kind":"struct"})
  ▸ mcp__grove__symbols({"dir":"src","name":"redisObject"})
  ▸ mcp__grove__source({"id":"c:src/object.h#redisObject@100"})

💬 Good. Now let me pull the key constants that give those bitfields meaning, and the `kvobj` type that builds on this.
  ▸ mcp__grove__symbols({"dir":"src","name":"kvobj"})
  ▸ mcp__grove__symbols({"dir":"src","name":"OBJ_REFCOUNT_BITS"})
  ▸ mcp__grove__symbols({"dir":"src","name":"LRU_BITS"})
  ▸ ToolSearch(select:mcp__grove__outline)
  ▸ mcp__grove__outline({"file":"src/object.h","detail":0})

💬 Now let me read the top section of `object.h` to get the type and encoding constants.
  ▸ Read(/home/bench/repos/redis/src/object.h)

💬 Now let me grab the logical `OBJ_TYPE_*` constants.
  ▸ mcp__grove__symbols({"dir":"src","name":"OBJ_STRING"})
  ▸ Bash(grep -n "^#define OBJ_STRING\|^#define OBJ_LIST\|^#define OBJ_SET\|^#define OBJ_ZSET\|^#define OBJ_HASH\|^#define OBJ_MODULE\|^#define OBJ_STREAM" /home/benc...)

💬 I now have everything needed for a thorough walkthrough.  ---  ## `struct redisObject` — the universal value container  Every value in the Redis keyspace is ...

──────── RESULT (success, 106082ms, 13 turns) ────────
I now have everything needed for a thorough walkthrough.

---

## `struct redisObject` — the universal value container

Every value in the Redis keyspace is wrapped in one of these (`src/object.h:100`):

```c
struct redisObject {
    unsigned type:4;
    unsigned encoding:4;
    unsigned refcount : OBJ_REFCOUNT_BITS;   /* 23 bits */
    unsigned iskvobj : 1;
    unsigned metabits : 8;
    unsigned lru : LRU_BITS;                 /* 24 bits */
    void *ptr;
};
```

`robj` is a typedef alias for it (line 115). On a 64-bit build the bitfields pack into 4 bytes, and `ptr` occupies the next 8, so the header is **16 bytes** before the payload.

---

### `type` — logical data type (4 bits)

This is the field that answers "what Redis type is this?". It takes one of seven values defined in `server.h:856`:

| Constant | Value | Meaning |
|---|---|---|
| `OBJ_STRING` | 0 | string |
| `OBJ_LIST` | 1 | list |
| `OBJ_SET` | 2 | set |
| `OBJ_ZSET` | 3 | sorted set |
| `OBJ_HASH` | 4 | hash |
| `OBJ_MODULE` | 5 | module type |
| `OBJ_STREAM` | 6 | stream |

This is what `TYPE` returns to a client and what command dispatch checks first to reject a type mismatch.

---

### `encoding` — concrete in-memory representation (4 bits)

This answers "how is the value *actually stored right now*?". The same logical type can have multiple encodings, chosen based on size and shape of the data. The full table (`object.h:75`):

| Constant | Value | Used for |
|---|---|---|
| `OBJ_ENCODING_RAW` | 0 | SDS string (generic) |
| `OBJ_ENCODING_INT` | 1 | integer value stored directly in `ptr` (no heap alloc) |
| `OBJ_ENCODING_HT` | 2 | full hash table (`dict`) |
| `OBJ_ENCODING_INTSET` | 6 | compact integer set |
| `OBJ_ENCODING_SKIPLIST` | 7 | sorted set with dict+skiplist |
| `OBJ_ENCODING_EMBSTR` | 8 | short string embedded right after the `robj` header |
| `OBJ_ENCODING_QUICKLIST` | 9 | list as a linked chain of listpacks |
| `OBJ_ENCODING_STREAM` | 10 | radix tree of listpacks |
| `OBJ_ENCODING_LISTPACK` | 11 | compact sequential structure (small hashes/sets/zsets) |
| `OBJ_ENCODING_LISTPACK_EX` | 12 | listpack extended with per-element metadata |
| `OBJ_ENCODING_SLICED_ARRAY` | 13 | sliced array |

The key insight: `type` is stable for the life of the key; `encoding` can change transparently as the object grows (e.g. a set starts as `LISTPACK`, promotes to `HT` once it exceeds `set-max-listpack-size`). `OBJECT ENCODING <key>` exposes this field.

---

### `refcount` — lifetime management (23 bits)

Provides simple **reference counting** so the same `robj` can be pointed to from multiple places without copying. Incremented by `incrRefCount`, decremented by `decrRefCount`; when it reaches zero the object is freed.

Two sentinel values (defined at `object.h:96`) bypass normal freeing:

- `OBJ_SHARED_REFCOUNT` (`(1<<23)-1`) — a permanent "shared object" (e.g. small integers 0–9999, common reply strings) that is never freed.
- `OBJ_STATIC_REFCOUNT` (`(1<<23)-2`) — stack-allocated object that must not be heap-freed.

---

### `iskvobj` — role flag (1 bit)

Marks whether this `robj` is being used as a **`kvobj`** (key-value object). When set, the same allocation also carries the key string inline (and optional expiry/metadata blocks prepended before the struct). `metabits` and `lru` are only meaningful when this bit is set.

---

### `metabits` — metadata presence bitmap (8 bits, kvobj only)

Each bit records whether one of up to 8 metadata classes is attached. Class 0 is reserved for **expiry time**. Metadata blocks are 8 bytes each and live **before** the struct in memory (in reverse class order), so a key with expiry has its `int64_t` expiry timestamp at `kvobjPtr - 8`. `kvobjGetExpire()` / `kvobjMetaRef()` navigate this layout.

---

### `lru` — eviction clock (24 bits, kvobj only)

Stores **LRU or LFU data**, depending on the `maxmemory-policy` in effect:

- **LRU mode**: a 24-bit timestamp relative to the global `lru_clock`, with 1-second resolution (`LRU_CLOCK_RESOLUTION = 1000 ms`, `LRU_CLOCK_MAX = 2²⁴ − 1 ≈ 194 days` before wrap). On access, `objectSetLRUOrLFU()` stamps the current clock value here.
- **LFU mode**: the 24 bits are split — 16 bits of "last decrement time" (in minutes) and 8 bits of a logarithmic access frequency counter. This lets the eviction machinery age out cold keys even if they were historically popular.

The eviction subsystem in `evict.c` walks candidates and compares this field against the current clock to score "how stale" each key is.

---

### `ptr` — payload pointer

Points to the actual data structure: an SDS string, a `dict`, a `quicklist`, a `listpack`, a `zskiplist`+`dict` pair, a `stream`, etc. — whichever the `encoding` field says is in use. For `OBJ_ENCODING_INT`, an integer small enough to fit in a pointer is stored directly in `ptr` itself (cast via `(void *)(long)`), saving a heap allocation entirely.

---

### The `kvobj` layout in memory

When `iskvobj=1` the allocation is a contiguous slab:

```
[meta-class-N] ... [meta-class-0 (expiry)] | redisObject | key-hdr-len | SDS-key | [SDS-value] |
                                            ^
                                     kvobjCreate() returns here
```

The key string lives immediately after the struct (no separate heap allocation), and small string values can be embedded right after the key. This design eliminates two pointer dereferences and two separate allocations for the common case of a short string value.
