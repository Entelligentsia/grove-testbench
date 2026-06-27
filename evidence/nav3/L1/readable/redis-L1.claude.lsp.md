# transcript: I'm trying to reason about Redis's per-value memory footprint and how a stored value is tagged and tracked while it lives in the keyspace. I need to understa...


💬 I'll look up the core Redis object struct through the LSP server.
  ▸ ToolSearch(select:mcp__lsp__definition,mcp__lsp__hover,mcp__lsp__references)
  ▸ mcp__lsp__definition({"symbolName":"robj"})
  ▸ mcp__lsp__definition({"symbolName":"redisObject"})

💬 Good. Now let me pull the relevant constants and the type/encoding macros.
  ▸ mcp__lsp__definition({"symbolName":"LRU_BITS"})
  ▸ mcp__lsp__definition({"symbolName":"OBJ_REFCOUNT_BITS"})
  ▸ mcp__lsp__definition({"symbolName":"OBJ_ENCODING_EMBSTR"})
  ▸ Read(/home/bench/repos/redis/src/object.h)

💬 Now let me grab the `OBJ_TYPE_*` constants and the `kvobj` struct layout details.
  ▸ mcp__lsp__definition({"symbolName":"OBJ_STRING"})
  ▸ Bash(grep -n "^#define OBJ_" /home/bench/repos/redis/src/server.h | head -30)

💬 I have everything needed. Here is the full picture.  ---  ## `struct redisObject` — the universal value container  Defined in `src/object.h:100–112`, typedef...

──────── RESULT (success, 74680ms, 10 turns) ────────
I have everything needed. Here is the full picture.

---

## `struct redisObject` — the universal value container

Defined in `src/object.h:100–112`, typedef'd as both `robj` and `kvobj`.

```c
struct redisObject {
    unsigned type     : 4;
    unsigned encoding : 4;
    unsigned refcount : 23;   /* OBJ_REFCOUNT_BITS */
    unsigned iskvobj  : 1;

    unsigned metabits : 8;    /* kvobj-only */
    unsigned lru      : 24;   /* LRU_BITS; kvobj-only */
    void *ptr;
};
```

On a 64-bit host this is exactly **16 bytes**: the first 8 bytes are packed bitfields, the second 8 bytes are `ptr`.

---

### The `type` / `encoding` split — the most important design decision

These two 4-bit fields together answer two completely different questions.

**`type` — the logical Redis type (what the keyspace exposes)**

| Value | Constant | Meaning |
|-------|----------|---------|
| 0 | `OBJ_STRING` | String |
| 1 | `OBJ_LIST` | List |
| 2 | `OBJ_SET` | Set |
| 3 | `OBJ_ZSET` | Sorted set |
| 4 | `OBJ_HASH` | Hash |
| 5 | `OBJ_MODULE` | Module |
| 6 | `OBJ_STREAM` | Stream |

`type` determines which commands are legal on the object (enforced by `checkType` before dispatch).

**`encoding` — the concrete in-memory representation (an implementation detail invisible to callers)**

| Constant | Value | Used by |
|----------|-------|---------|
| `OBJ_ENCODING_INT` | 1 | String: integer fits in a `long`; stored *in* `ptr` itself, no heap alloc |
| `OBJ_ENCODING_EMBSTR` | 8 | String ≤ 44 bytes: SDS header + chars fused into the same allocation as the `robj` |
| `OBJ_ENCODING_RAW` | 0 | String: separate heap SDS |
| `OBJ_ENCODING_LISTPACK` | 11 | Small hash / set / zset |
| `OBJ_ENCODING_HT` | 2 | Hash / set when grown beyond listpack thresholds |
| `OBJ_ENCODING_SKIPLIST` | 7 | Zset when grown beyond listpack thresholds |
| `OBJ_ENCODING_QUICKLIST` | 9 | List: linked list of listpacks |
| `OBJ_ENCODING_INTSET` | 6 | Set of integers only |
| `OBJ_ENCODING_STREAM` | 10 | Stream: radix tree of listpacks |

Redis quietly mutates `encoding` (via `tryObjectEncoding`) as a value grows — a string starts as `INT` or `EMBSTR` and is promoted to `RAW`; a small hash starts as `LISTPACK` and is converted to `HT`. The caller never sees the difference.

---

### Lifetime management — `refcount` (23 bits)

`incrRefCount`/`decrRefCount` in `object.h:128–129` drive this. Two sentinel values bypass normal lifecycle:

- `OBJ_SHARED_REFCOUNT` (all 23 bits set) — globally shared objects (the 0–9999 integer pool, common reply strings). Never freed.
- `OBJ_STATIC_REFCOUNT` (all bits set minus 1) — stack-allocated objects passed transiently into API functions. Also never freed by `decrRefCount`.

When `refcount` hits zero through a normal `decrRefCount`, the type-appropriate free function is called (`freeStringObject`, `freeListObject`, etc.) and the `robj` itself is `zfree`'d.

---

### The `kvobj` extension — co-locating key, value, and metadata

The `iskvobj` bit marks that this `robj` is a **key-value object**: the key string is embedded inline *after* the struct, and for small string values the value payload is also embedded after the key, avoiding a second allocation.

When `iskvobj` is set, two more fields become meaningful:

**`metabits` (8 bits)** — a bitmap of up to 8 optional metadata blocks. Each set bit means one 8-byte `uint64_t` is prepended *before* the struct in memory (in reverse class order). Bit 0 is class 0 = expiry timestamp. So expiry is not a separate hash table lookup; it lives at a fixed negative offset from the `kvobj` pointer.

```
[ class-N meta | ... | class-0 expiry ][ redisObject | key-hdr | key SDS | val SDS ]
                                        ^
                                        kvobjCreate() returns here
```

`kvobjGetAllocPtr` (`object.h:194–198`) recovers the true allocation base by counting set bits in `metabits` and stepping back `popcount(metabits) * 8` bytes.

**`lru` (24 bits)** — LRU or LFU data, also only meaningful on a `kvobj` (a bare `robj` used for a transient value doesn't need eviction tracking). Under LRU policy this holds a server-clock timestamp (resolution 1 s, wraps at ~194 days). Under LFU policy the low 8 bits are an access-frequency counter and the high 16 bits record the last decrement time.

---

### `ptr` — the payload pointer

For all encodings except `INT`, `ptr` points to the actual data structure: an `sds`, a `dict`, a `quicklist`, a `listpack`, a `stream`, etc. For `OBJ_ENCODING_INT`, the integer value is cast directly into `ptr` (no heap allocation at all).

---

### Summary of the whole container

| Field | Bits | Purpose |
|-------|------|---------|
| `type` | 4 | Logical Redis type — which command family owns this value |
| `encoding` | 4 | Concrete representation — which data structure `ptr` points to |
| `refcount` | 23 | Reference-counted lifetime; sentinels for shared/static objects |
| `iskvobj` | 1 | Marks the extended kvobj layout (embedded key + metadata prefix) |
| `metabits` | 8 | Bitmap of prepended metadata blocks; bit 0 = expiry |
| `lru` | 24 | LRU clock stamp or LFU frequency+timestamp for eviction |
| `ptr` | 64 | Payload — or the integer value itself for `OBJ_ENCODING_INT` |

The elegance of the design is that `type` is the public contract (what Redis commands see) and `encoding` is a private implementation detail that the server can change on the fly without any caller knowing. The 16-byte footprint is kept flat by packing everything into a single word of bitfields plus one pointer.
