---
title: "Cache Terminology, Locality"
---

(sec-cache-terminology)=
## Learning Outcomes

* Explain how caches leverage temporal and spatial locality.
* Trace memory access with caches.
* Get familiar with key cache terminology: cache hit, cache miss, and cache line (i.e., block).

::::{note} 🎥 Lecture Video: Locality, Design, and Management
:class: dropdown

:::{iframe} https://www.youtube.com/embed/xrCp6DKazuk
:width: 100%
:title: "[CS61C FA20] Lecture 24.4 - Caches I: Locality, Design, Management"
:::

::::


::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/lGp8FK1NW_k
:width: 100%
:title: "[CS61C FA20] Lecture 25.3 - Caches II: Cache Terminology"
:::

::::

## Memory Caches

Caches are the basis of the memory hierarchy.

:::{warning} This caveat discussed [earlier](#sec-library) is worth repeating.

Caches contain **copies of data** from main memory.

:::


How do we create the illusion of a large memory that we can access fast? From P&H 5.1:

> Just as you did not need to access all the books in the library at once with equal probability, a program does not access all of its code or data at once with equal probability. Otherwise, it would be impossible to make most memory accesses fast and still have large memory in computers, just as it would be impossible for you to fit all the library books on your desk and still find what you wanted quickly.

:::{hint} Principle of locality

A cache works on the principles of **temporal and spatial locality**.

* **Temporal locality**: If an item is referenced, it will tend to be referenced soon.
* **Spatial locality**: If an item is referenced, items whose addresses are close by will tend to be referenced soon.

:::

:::{table} Principles of temporal and spatial locality.
:label: tab-locality

| Property | Temporal Locality | Spatial Locality |
| :--- | :--- | :--- |
| Idea | If we use it now, chances are that we’ll want to use it again soon. | If we use a piece of memory, chances are we’ll use the neighboring pieces soon. |
| Library Analogy | We keep a book on the desk while we check out another book. | If we check out volume 1 of a reference book, while we’re at it, we’ll also check out volume 2. Libraries put books on the same topic together on the same shelves to increase spatial locality. |
| Memory | If a memory location is referenced, then it will tend to be referenced again soon. Therefore, keep most recently accessed data items closer to the processor. | If a memory location is referenced, the locations with nearby addresses will tend to be referenced soon. Move **lines** consisting of contiguous words closer to the processor. |

:::

## Memory Access with/without a Cache

Consider how memory access works with a cache, as in @fig-von-neumann-cache.

:::{figure} images/von-neumann-cache.jpg
:label: fig-von-neumann-cache
:width: 100%
:alt: "TODO"

Caches in the [basic computer layout](#fig-von-neumann) (from an [earlier section](#sec-architecture-elements)).
:::

When a load or store instruction is accessed, memory data access is **requested**. There are two situations that can occur:

* **Cache hit**: The data you were looking for is in the cache. Retrieve the data from the cache and bring it to the processor.
* **Cache miss**: The data you were looking for is not in the cache. Go to a lower layer in the memory hierarchy to find the data, put the data in the cache. Then, bring the data to the processor.

:::{note} Example: Memory access with/without caches

Consider the load word instruction `lw t0 0(t1)`. Suppose register `t1` is `0x12F0`, and the word starting at memory address `0x12F0` is `1234`.

Memory access **without cache**:

1. Processor issues address `0x12F0` to memory
1. Memory reads `1234` @ address `0x12F0`
1. Memory sends `1234` to Processor
1. Processor loads `1234` into register `t0`

Memory access **with cache**:

1. Processor issues address `0x12F0` to cache
1. Cache checks for copy of data with address `0x12F0`

    1. (2a) If hit (finds match): cache reads `1234`
    2. (2b) If miss (no match): cache sends address `0x12F0` to Memory

        1. (2b(i)) Memory reads line with `1234` (i.e., line contains data at address `0x12F0`)
        1. (2b(ii)) Memory sends line with `1234` to cache
        1. (2b(iii)) Cache replaces some line to store new line with `1234`
        1. (2b(iv)) Cache reads `1234`
1. Cache sends `1234` to Processor
1. Processor loads `1234` into register `t0`

:::

(sec-cache-address)=
:::{hint} Caches also need "address" information

Memory is **byte-addressable**, meaning each byte in memory has a memory **address**. This is identical to our concept of memory from [earlier](#sec-address-space).

Just like memory, caches need to look up data by memory address. However, now a cache no longer has access to the entire memory address space because of its limited storage capacity. A cache therefore needs to keep track of **two** items:

* The data (already stored in a cache line)
* The address(es) associated with data in a cache line 
:::

We discuss strategies for associating addresses with cache lines in detail ([later](#sec-fully-associative)).

## Key Cache Terminology

(sec-cache-line)=
:::{hint} Cache lines

When we bring data from the main memory into the cache, we do so at the granularity of a **cache line** (or **cache block**). This helps us take advantage of **spatial locality**.
:::

* **Lines** (also called **blocks**) of data are copied from memory to the cache. A cache line is the smallest unit of memory that can be transferred between the main memory and the cache
Each line has its own entry in the cache.

* **Line size** (also called **block size**) is the number of bytes of data stored in this cache line. Each line in a cache has the same line size.[^m1-line]
* **Capacity** is the size of a cache, in bytes.

:::{warning} Course-specific definition

We will soon learn that caches need space for _metadata_[^metadata] necessary to access and update cache lines. This metadata incurs some **overhead**; for a given capacity, the more metadata a cache maintains, the less data it can hold.

For this course, when we say a 32B cache, we mean a cache that can store 32 bytes of **data**, i.e., 32 = (number of lines) x (line size).

[^metadata]: Tag, valid bit, dirty bit, etc. Discussed in the [next chapter](#sec-fully-associative). 

:::

[^m1-line]: For the Apple M1 chip, L1 cache has 64-byte lines, whereas L2 cache has 128-byte lines. [GoFetch](https://gofetch.fail/).

Where we **place** a new line from memory depends on its **placement policy**. Placement policy additionally determines the metadata overhead for this cache. We discuss three types of placement policies in this course:

* [Fully Associative Caches](#sec-fully-associative)
* Set-Associative Caches
*-* Direct Mapped Caches