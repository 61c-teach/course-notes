---
title: "Cache Terminology"
---

(sec-cache-terminology)=
## Learning Outcomes

* Explain how caches leverage temporal and spatial locality.
* Trace memory access with caches.
* Get familiar with key cache terminology: cache hit, cache miss, block (cache line), tag.

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

https://www.youtube.com/watch?v=DiH8xtQeCJA

## Principle of Locality


How do we create the illusion of a large memory that we can access fast? From P&H 5.1:

> Just as you did not need to access all the books in the library at once with equal probability, a program does not access all of its code or data at once with equal probability. Otherwise, it would be impossible to make most memory accesses fast and still have large memory in computers, just as it would be impossible for you to fit all the library books on your desk and still find what you wanted quickly.

Caches are the basis of the memory hierarchy. They contain **copies of a subset of data** from main memory.[^earlier]

[^earlier]: This detail was discussed [earlier](#sec-library) but is always worth repeating.

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
| Memory | If a memory location is referenced, then it will tend to be referenced again soon. Therefore, keep most recently accessed data items closer to the processor. | If a memory location is referenced, the locations with nearby addresses will tend to be referenced soon. Move **blocks** consisting of contiguous words closer to the processor. |

:::


## Key Cache Terminology

From [Wikipedia](https://en.wikipedia.org/wiki/CPU_cache):

> Data is transferred between memory and cache in blocks of fixed size, called cache lines or cache blocks. When a cache line is copied from memory into the cache, a cache entry is created. The cache entry will include the copied data as well as the requested memory location (called a tag).

Memory is **byte-addressable**, meaning each byte in memory has a memory **address**. This is identical to our concept of memory from [earlier](#sec-address-space). Just like memory, caches need to look up data by memory address (see [below](#sec-cache-memory-access)). However, now a cache no longer has access to the entire memory address space because of its limited storage capacity.

Each entry in the cache therefore needs to track (at least) **two** pieces of information:

1. **Cache blocks** (also called **blocks**, or **cache lines**)[^block-vs-line] are the unit of data are copied from memory to the cache. A block is the smallest unit of memory that can be transferred between the main memory and the cache. Copying over a _line_ of data (instead of simply a word, or a byte) helps us take advantage of **spatial locality**.

    Each block has its own entry in the cache.

1. **Tag**: The address(es) associated with data in a block.

    From P&H 5.3: "A **tag** is a field in a table used for a memory hierarchy that contains the address information required to identify whether the associated [line] in the hierarchy corresponds to a requested [word or byte]."

    Each cache entry has its own tag. Each block is therefore associated with one tag.

[^block-vs-line]: The literature is inconsistent on whether to refer to the unit of data transferred between a cache and main memory as a "block" or a "line." You will see both. We will try to stick to "block" where possible, except when quoting sources.

Size-related terminology:

* **Block size** (also called **line size**) is the number of bytes of data stored in this block. Each block in a cache has the same block size. To take advantage of spatial locality, caches usually have a block size larger than one word.
* **Capacity** is the size of a cache, in bytes.

:::{warning} Cache size/capacity
:label: block-cache-size

From [Wikipedia](https://en.wikipedia.org/wiki/CPU_cache):
> The "size" of the cache is the amount of main memory data it can hold. This size can be calculated as the number of bytes stored in each data block times the number of blocks stored in the cache. (The tag, [and other metadata] bits are not included in the size[^practice], although they do affect the physical area of a cache.)

For the Apple M1 chip[^m1-line]:

* The L1 cache is 128 KiB, 8-way [set-associative](#sec-set-associative) with 64-byte blocks.
* The L2 cache is 12 MiB, 12-way [set-associative](#sec-set-associative) with 128-byte blocks.

[^m1-line]: Source: [GoFetch](https://gofetch.fail/).

[^practice]: See size comparisons in Sadler et al., ICCD 2006. DOI: [10.1109/ICCD.2006.4380862](https://doi.org/10.1109/ICCD.2006.4380862)

For this course, when we say a 32B cache, we mean a cache that can store 32 bytes of **data** from memory, i.e., 32 = (number of blocks) x (line size).

[^metadata]: Tag, valid bit, dirty bit, etc. Discussed in the [next chapter](#sec-fully-associative). 

:::

(sec-cache-memory-access)=
## Memory Access with/without a Cache

When a load or store instruction is accessed, the processor **requests** data at a particular address from the memory hierarchy. In this subsection we contrast how this memory access works—with and without a cache. Toggle between the two cards below.

:::::{tab-set}
::::{tab-item} Computer Layout with cache
:sync: tab-with-cache

:::{figure} images/von-neumann-cache.jpg
:label: fig-von-neumann-cache
:width: 100%
:alt: "Von Neumann-style computer layout with processor block connected through read/write signals and address to a cache and then to full memory. The memory block is also connected on the right to a separate input and output through I/O memory interfaces."

A cache inserted into the basic computer layout from an [earlier section](#sec-architecture-elements).
:::

::::

::::{tab-item} Computer Layout without cache
:sync: tab-without-cache

:::{embed} #fig-von-neumann
:::

::::
:::::

Consider the load word instruction `lw t0 0(t1)`. Suppose register `t1` holds `0x12F0`, and the word starting at memory address `0x12F0` is `1234`.

:::::{tab-set}
::::{tab-item} Memory access with cache
:sync: tab-with-cache

Memory access **with cache**:

1. Processor issues address `0x12F0` to cache
1. Cache checks for copy of data with address `0x12F0`

    1. (2a) If **cache hit** (finds match): cache reads `1234`
    2. (2b) If **cache miss** (no match): cache sends address `0x12F0` to Memory

        1. (2b(i)) Memory reads block with `1234` (i.e., block contains data at address `0x12F0`)
        1. (2b(ii)) Memory sends block with `1234` to cache
        1. (2b(iii)) Cache replaces some block to store new block with `1234`
        1. (2b(iv)) Cache reads `1234`
1. Cache sends `1234` to Processor
1. Processor loads `1234` into register `t0`
::::

::::{tab-item} Memory access without cache
:sync: tab-without-cache

Memory access **without cache**:

1. Processor issues address `0x12F0` to memory
1. Memory reads `1234` @ address `0x12F0`
1. Memory sends `1234` to Processor
1. Processor loads `1234` into register `t0`
::::
::::: 

When a cache is in the picture, there are two situations that can occur on a memory access:

* **Cache hit**: The data you were looking for is in the cache. Retrieve the data from the cache and bring it to the processor.
* **Cache miss**: The data you were looking for is not in the cache. Go to a lower layer in the memory hierarchy to find the data, put the data in the cache. Then, bring the data to the processor.

(sec-cache-temperatures)=
## Cache Temperatures

Our goal for cache design is temporal and spatial locality for a range of workloads. We borrow climate terminology to describe cache performance:

* **Cold**: The cache is "empty".[^empty-analogy]
* **Warming**: The cache is filling with values we will hopefully access again.
* **Warm**: The cache is doing its job, with a fair percentage of hits.
* **Hot**: The cache is doing very well with a high percentage of hits.

[^empty-analogy]: Caches can never truly be "empty." Instead, blocks may sometimes contain garbage data with respect to the currently running program. We discuss this in the [next section](#sec-valid-bit).

## Four Memory Hierarchy Questions

This section is adapted from Patterson and Hennessy. _Computer Architecture: A Quantitative Approach_, Fifth Edition. 2012. Appendix B.

(sec-cache-design-policy)=
:::{note} Cache design policies

There are four high-level questions for cache design. We will call three of these **policies**:

1. **Placement policy**: Where can a block (i.e., line) be placed in the cache? Which cache entry can this block (i.e., line) be associated with?
1. **Identification**: How is a block (i.e., line) found if it is in the cache? Identification is closely tied with placement policy.
1. **Replacement policy**: Which block (i.e., line) should be replaced on a miss?
1. **Write policy**: What happens on a write?
:::

The answers to these questions help us understand the different tradeoffs of caches (and even of other levels of the memory hierarchy, as we will see in a later section). We will ask these four questions with every example. We start by introducing placement policies:

* [Fully Associative Cache](#sec-fully-associative)
* [Set-Associative Cache](#sec-set-associative)
* [Direct Mapped Cache](#sec-direct-mapped)