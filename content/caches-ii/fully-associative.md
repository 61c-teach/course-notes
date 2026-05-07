---
title: "Fully Associative Cache"
---

(sec-fully-associative)=
## Learning Outcomes

* Using terminology, describe how to find a block in a fully associative cache: address, tag, and offset.
* Explain why a valid bit is needed for cache design.
* Compare different block replacement policies: LRU, FIFO, and random.
* Compare two write policies: write-through and write-back. Optimize the latter with a dirty bit.
* For a given pattern of memory accesses, identify if each memory access is a cache hit or cache miss.

::::{note} 🎥 Lecture Video: Fully Associative
:class: dropdown

:::{iframe} https://www.youtube.com/embed/-7TxNYUeFng
:width: 100%
:title: "[CS61C FA20] Lecture 26.3 - Caches III: Fully Associative Caches"
:::

::::

::::{note} 🎥 Lecture Video: Block  Replacement
:class: dropdown

:::{iframe} https://www.youtube.com/embed/a-ejTer1Ijg
:width: 100%
:title: "[CS61C FA20] Lecture 25.3 - Caches IV: Block Replacement with Example"
:::

Until 7:00. The example assumes familiarity with set associative caches, a placement policy we discuss in a [later section](#sec-set-associative)

::::

::::{note} 🎥 Lecture Video: Writes
:class: dropdown

:::{iframe} https://www.youtube.com/embed/DiH8xtQeCJA
:width: 100%
:title: "[CS61C FA20] Lecture 25.3 - Caches III: Writes, Block Sizes, Misses"
:::

Until 13:00

::::

::::{note} 🎥 Lecture Video: Block Size
:class: dropdown

:::{iframe} https://www.youtube.com/embed/DiH8xtQeCJA
:width: 100%
:title: "[CS61C FA20] Lecture 25.3 - Caches III: Writes, Block Sizes, Misses"
:::

Until 22:45

::::


How do we design a cache? [From earlier](#sec-cache-terminology):

:::{embed} #sec-cache-design-policy
:::

In this section, we introduce the **fully associative cache** and use it as a means to discuss a detailed example and tradeoffs between replacement policies and write policies.

## Placement policy

(sec-fully-associative-policy)=
:::{note} _Fully Associative_ placement policy

A block can be placed in any entry of the cache.

:::

**Associativity** refers to the possible entries that a particular block of data can be associated with.

## Identification

How do we determine a **cache hit** on a memory address? In other words, how do we know if the data at a specific memory address can be accessed from a block in the cache? From _Computer Organization: A Quantitative Approach_ Appendix B.1:

> Caches have an address tag on each block frame that gives the block address. The tag of every cache block that might contain the desired information is checked to see if it matches the block address from the processor. As a rule, all possible tags are searched in parallel because speed is critical.

There is a lot in this paragraph.[^block-description] We first explore the relationship between a memory address and the tag of a cache entry. We then explain how we determine cache hits.

[^block-description]: Here, "block frame" means the cache entry itself, "block" is the data unit, and "block address" is something that indicates the memory address of the least significant byte of this block. We will more formally define "block address" in the [next section](#sec-block-address).

### Tag and Offset

We would like to connect the blocks in to the cache shown in @fig-fa-intro, which is a 16B fully associative cache with 4B blocks, to the 12-bit memory address in @fig-fa-address. We do so by splitting the address into two portions: **tag** and **offset**.

:::{figure} images/fa-intro.png
:label: fig-fa-intro
:width: 50%
:alt: "Cache table showing tag and data for a 16-byte fully associative cache. Each of the four cache lines has a unique tag. Byte 3 of the first cache line is highlighted, showing the result of accessing that tag with an offset of 3."
Cache tag and offset in a 16B fully associative cache for 12-bit memory addresses. The bytes in the first entry's block share the same upper 10 bits of their memory addresses: `0b0100001111`, or `0x10F`, which is the tag. The address of the most significant byte in the first block is therefore `0x43F`.
:::

:::{figure} images/fa-address.png
:label: fig-fa-address
:width: 60%
:alt: "Memory address-field split for fully associative cache into only tag and block offset fields. The tag occupies bits 11 through 2, and the offset occupies bits 1 through 0."
For a fully associative cache, the memory address is split into two fields: the tag and the offset. For the blocks in @fig-fa-intro, a 12-bit memory address is split into a 10-bit tag and a 2-bit offset.

:::

What then, is a **tag**? Recall that all of the bytes in each block of data are from the same area of memory. Their address will share a common set of upper bits. In **fully associative caches** like in @fig-fa-intro, all of these upper bits are placed into the **tag** associated with each block.

What about the **offset**? Memory is byte addressable, so each of the bytes in a given block will have different memory addresses. The memory addresses of bytes in a given block will not vary in the upper bits (the tag) but rather in the lowest bits. The **offset** is the portion of the address needed to describe this variation.


:::{tip} Quick check

Revisit the relationship between the address portions in @fig-fa-address and the 16B fully associative cache (with 4B blocks) in @fig-fa-intro.

1. What is the block size, in bytes?
1. What is the total data capacity across all blocks, in bytes?
1. If our memory space is $2^{12}$ bytes, we have 12-bit addresses. How many bits of this address should be reserved for the offset?
1. Still assuming 12-bit addresses, how many bits of this address should be reserved for the tag?
:::

:::{note} Solution

1. **4 bytes**. Block size (aka line size) is the number of bytes per block. In @fig-fa-intro, each cache entry has a 4-byte "row" of data in its block.
1. **16 bytes.** Data capacity is the number of bytes across all blocks. @fig-fa-intro shows 4 blocks, each of size 4 bytes.
1. The offset identifies the byte offset to access data from a given block. To "index" into each of the 4 bytes in a given block, we need $\log_2{(\text{block size})}$ = **2 bits**.
1. Each cache entry's tag associates the data in that block with a particular (set of) addresses. These set of addresses may vary in offsets (lower 2 bits) but will share the same tag. Because we use a 12-bit memory address in our toy example, for this fully associative cache our tags are (\# address bits) - (\# offset bits) = **10 bits**.
:::

:::{note} More explanation of @fig-fa-intro
:class: dropdown

Consider the addresses of each of the four bytes of the first cache block (with tag `0x10F`):

* Least significant byte (rightmost in first block of @fig-fa-intro cache) has byte offset `0b00`. We reconstrruct the memory address by prepending the 10-bit tag `0x10F` to the offset to get `0b01 0000 1111 00`, or `0x43C`.
* Second least significant byte has offset `0b01`. Prepend the same 10-bit tag `0x10F` to get `0b01 0000 1111 01`, or `0x43D`.
* Second most significant byte has offset `0b10`. Binary address `0b01 0000 1111 10`, or `0x43E`.
* Most significant byte (leftmost and highlighted in first block of @fig-fa-intro cache) has offset `0b11`. Binary address `0b01 0000 1111 11`, or `0x43F`.

::::

(sec-valid-bit)=
### Valid bit

There must be a way to know that a cache block does not have valid information. For example, when starting up a program, the cache necessarily does not have valid information for the program. The most common procedure is to add an indicator (i.e., **flag**) to the tag to tell if each entry in the cache is valid for this particular program.

The **valid bit** indicates if the tag for the block is valid. If the valid bit is set (`1`), the tag refers to a valid memory address. If it is not set (`0`), we should not match to this tag (even if the tag bits match by chance).

:::{figure} images/fa-valid.png
:label: fig-fa-valid
:width: 50%
:alt: "Cold fully associative cache table with all valid bits unset and all 16 bytes of data empty."
A [cold](#sec-cache-temperatures) snapshot of the fully associative cache in @fig-fa-intro, where valid bits for all blocks are unset (i.e., set to `0`). We illustrate the valid bit in our tabular visualization as an additional column of metadata.[^valid-hardware]
:::

[^valid-hardware]: From _Computer Organization: A Quantitative Approach_, Appendix B.1: "...add a _valid bit_ to the tag to say whether or not this entry contains a valid address."

(sec-fa-walkthrough)=
## Walkthrough: Warming up the Fully Associative Cache

The following animation traces through five memory accesses to a 12-bit address space on our 16B fully associative cache with 4B blocks. Assume the cache starts out [cold](#sec-cache-temperatures), like in @fig-fa-valid.

::::{figure}
:label: fig-fa-warmup
:alt: "Embedded slides stepping through five memory accesses on a cold 12-bit-address fully associative cache with 16-byte capacity and 4-byte blocks."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQU9l8AzNd5IkR1OUoqNtUygI4anobQJsrXgAXObfGH_eoSDy3iCIVqHMtZE8p-TvSI06dUoLIb8Y-z/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through a warm up of a fully associative cache from this section. Access [original Google Slides](https://docs.google.com/presentation/d/1NxTminubfgSHzH2S_N7SxTyquI5B4QidA8b6W4mnRlU/edit?usp=sharing)"
:::

Warming up a fully associative cache.
::::

To keep things simple for now, if we encounter a cache miss, we load the new block from memory into an invalid cache entry. We discuss _block replacement policies_ in [the next section](#sec-cache-replacement-policy).

:::{note} 1. Load byte @ `0x43F`. Cache miss.
:class: dropdown

Address `0x43F` in binary: `0b0100 0011 1111`

* Tag: `0b0100001111`, or `0x10F`
* Offset: `0b11`

1. **Cache Miss**. No valid tags in the cache match `0x10F`.
1. **Access lower level of memory hierarchy**. Load into a selected cache entry a block's worth of data from memory starting @ address  @ `0x43C`. Write the tag `0x10F`. Mark valid bit.

    Spatial locality: Even if we only read in one byte, loading from memory will load the full block (here, 4B), where all bytes of data in the block share the same tag because they are from the same region of memory:

    * Least significant byte in block (offset `0b00`) is @ memory address `0x43C` (`0b0100 0011 1100`)
    * Most significant byte in block (offset `0b11`) is @ memory address `0x43F` (`0x0b100 0011 1111`)

1. **Read**. Read byte in cache block at offset `0b11` (i.e., most significant byte in block)	and return to processor.

:::

:::{note} 2. Load byte @ `0x5E2`. Cache miss.
:class: dropdown

Address `0x5E2` in binary: `0b0101 1110 0010`

* Tag: `0b0101111000`, or `0x178`
* Offset: `0b10`

1. **Cache Miss**. No valid tags in the cache match `0x178`.
1. **Access lower level of memory hierarchy**. Load into a selected cache entry a block's worth of data from memory starting @ address `0x5E0` (`0b0101 1110 0000`). Write the tag `0x178`. Mark valid bit.
1. **Read**. Read byte in block at offset `0b10` and return to processor.
:::

:::{note} 3. Load word @ `0x824`. Cache miss.
:class: dropdown

Address `0x824` in binary: `0b1000 0010 0100`

* Tag: `0b1000001001`, or `0x209`
* Offset: `0b00`

1. **Cache Miss**. No valid tags in the cache match `0x209`.
1. **Access lower level of memory hierarchy**. Load into a cache entry the four bytes of data starting @ `0x824` (`0b1000 0010 0100`). Write the tag `0x209`. Mark valid bit.
1. **Read**. Read **word** in cache block at offset `0b00` and return to processor.
:::

:::{note} 4. Load byte @ `0x5E0`. Cache hit.
:class: dropdown

Address `0x5E0` in binary: `0b0101 1110 0000`

* Tag: `0b0101111000`, or `0x178`
* Offset: `0b00`

1. **Cache Hit**. The requested tag `0x178` matches a **valid** cache tag.
1. **Read**. Read byte in cache block at offset `0b00` and return to processor.
:::

:::{note} 5. Load byte @ `0x524`. Cache miss.
:class: dropdown

Address `0x524` in binary: `0b0101 0010 0100`

* Tag: `0b0101001001`, or `0x149`
* Offset: `0b00`

1. **Cache Miss**. No valid tags in the cache match `0x178`.
1. **Access lower level of memory hierarchy**. Load into a selected cache entry a block's worth of data from memory starting @ address `0x524` (`0b0101 0010 0100`). Write the tag `0x149`. Mark valid bit.
1. **Read**. Read byte in cache block at offset `0b00` and return to processor.
:::

Of these **five memory accesses**:

* The first three memory accesses are cache misses, incurring the expensive delay of main memory access.
* The fourth memory access is a cache hit, so no main memory access occurs.
* The last memory access is also a cache miss.

(sec-cache-replacement-policy)=
## Replacement Policy

After the previous five memory accesses, our fully associative cache is at capacity (i.e., "full", because all cache entries are valid), as shown in @fig-fa-full.

:::{figure} images/fa-full.png
:label: fig-fa-full
:width: 60%
:alt: "Fully associative cache state after a sequence of accesses showing all entries occupied. All four rows have their valid bit on and a unique tag."

After the five memory accesses described [above](#sec-fa-walkthrough), our small fully associative cache is full.
:::

A **replacement policy** defines how the cache controller determines which block is replaced on a cache miss. For fully associative caches, there are several options for replacement policies.

A natural replacement policy is called **least recently used**, or **LRU** for short. From _Computer Organization: A Quantitative Approach_ Appendix B.1:

> To reduce the chance of throwing out information that will be needed soon, access to blocks are recorded. Relying on the past to predict the future, the block replaced is the one that has been unused for the longest time. LRU relies on a corollary of locality: If recently used blocks are likely to be used again, then a good candidate for disposal is the least recently used block.

:::{hint} Quick Check

Based on the the five memory access described [above](#sec-fa-walkthrough), which block is the least recently used in @fig-fa-full?

:::

(sec-lru-implementation)=
:::{note} Solution: Possible LRU implementation
:class: dropdown

Answer: Block with tag `0x10F`.

One approach is to stare at the memory accesses until you figure it out. Another possible algorithm is to assign a number to each block that tracks access history. On each memory access, reset the number to zero if the tag is valid and matches (or after a cache miss, the updated tag matches), and increment the number if the tag is valid but not matched.The entry with the _highest_ such number[^ties] is the **least** recently used.

[^ties]: Break ties in some reasonable way, e.g., randomly.

1. Load byte @ `0x43F`. Tag `0x10F` is 0.
2. Load byte @ `0x5E2`. Tag `0x10F` is 1, `0x178` is 0.
3. Load **word** @ `0x824`. Tag `0x10F` is 2, `0x178` is 1, `0x209` is 0.
4. Load byte @ `0x5E0`. Tag `0x10F` is 3, `0x178` is 0, `0x209` is 1.
5. Load byte @ `0x524`. Tag `0x10F` is 4, `0x178` is 1, `0x209` is 2, `0x149` is 0.

The tag with the highest number is `0x10F`.
:::

::::{figure}
:label: fig-fa-lru
:alt: "Embedded slides illustrating LRU replacement in a fully associative cache as additional accesses fill valid entries and evict the least recently used tag."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQZlQhRUK7d3f5-2SHQnPPSsyHFmG2xZ5hgEr5p8PyNZLKBl7zVK8UojiqD6OipYsRVa5v7t-ChQjT7/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through the replacement policy for a fully associative cache in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1vHYBxCYjtFT8vSbVFioz_o1K4T2e0mNykhJ89-yactQ/edit?usp=sharing)"
:::

Fully associative cache with least recently used (LRU) replacement policy.
::::

:::{note} 6. Load byte @ `0x972`. Cache miss.
:class: dropdown

Address `0x972` in binary: `0b1001 0111 0010`

* Tag: `0b100101110010`, or `0x25C`
* Offset: `0b10`

1. **Cache Miss**. No valid tags in the cache match `0x25C`.
1. **Access lower level of memory hierarchy**. Select the least recently used entry (tag `0x10F`). Replace its block with a block's worth of data from memory starting @ address `0x970` (`0b10001 0111 0000`). Write the tag `0x25C`. Mark valid bit.
1. **Read**. Read byte in cache block at offset `0b10` and return to processor.
:::

Common replacement policies:[^lifo]

1. **Least recently used (LRU)**: Select the least recently used block for replacement.
1. **Random**: Select a block randomly for replacement.
1. **First in, first out (FIFO)**: Select the _oldest_ block for replacement (even if the oldest block has been most recently used). A queue (using terminology from Data Structures).

While the implementation of replacement policies is out of the scope of this course, we note the following:

* LRU incurs a significant hardware cost because the cache must track access history.
* FIFO is a reasonable approximation to LRU without adding too much excess hardware.[^fifo]
* Random replacement spreads replacement uniformly across the cache, so this policy works surprisingly fine when a workload has low temporal locality.

[^lifo]: Some of you may be wondering: Why not Most Recently Used (MRU)? Why not last in, first out (LIFO)? While LIFO approximates MRU, both of these policies go entirely against the idea of temporal locality and are consequently a bit silly.

[^fifo]: Again, the implementation of a FIFO replacement policy is out of scope. Read _Computer Organization: A Quantitative Approach_ Appendix B.1 for more details.

:::{table} Comparison of cache replacement policies.
:label: tab-cache-replacement

| Feature | LRU | FIFO | Random |
| :-- | :-- | :-- | :-- |
| **Description** | Replace the entry that has not been used for the longest time | Replace the oldest block in the set (queue) | Replace a random block |
| **Implementation** | Bit counters for each cache block; see [quick check](#sec-lru-implementation) | FIFO queue or similar approximation | Flip a figurative hardware coin |
| **Advantage** | Temporal locality | Reasonable approximation to LRU | Easy to implement |
| **Disadvantage** | Complicated hardware to keep track of access history | – | Terrible if workload leverages high temporal locality |
:::

(sec-cache-write-policy)=
## Write Policy

So far, we have only focused on memory **reads** with load instructions. But what about store instructions, which **write** to data in memory?

Recall that cache blocks are **copies** of data in lower levels:

:::{embed} #sec-memory-hierarchy-copy
:::

With a cache, we need to ensure that our main memory will (eventually) be in sync with our cache if we modify data.
There are two basic options when writing to the cache:

1. **Write-through**: The information is written to both the block in the cache _and_ to the corresponding location in the lower-level main memory.
1. **Write-back**: The information is written only to the cache block. The modified cache block is written to the lower-level main memory **only** when it is replaced.

To implement write-back, we note further that we can only need to write back _modified_ blocks to main memory on replacement. This reduces the miss penalty. To reduce the frequency of writing back blocks on replacement, use a **dirty bit** for each cache entry.

* If the dirty bit is set (`1`), the block has been modified while in the cache. When this block is replaced, on a miss, write back this block to main memory.
* If the dirty bit is not set (`0`), the block has not been modified ("clean"). When this block is replaced on a miss, no write-back is needed, since information identical to the cache is found in the lower-level main memory.

@fig-fa-wb animates our fully associative cache with a write-back policy, using the dirty bit

::::{figure}
:label: fig-fa-wb
:alt: "Embedded slides animating write-back policy and dirty-bit behavior on a fully associative cache during hits, misses, and replacements."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vSBzBoel_J30XSTEfEQJDsk1OjVQ-Jnii6At7ZyqDKed1wADBar24FT5vhoT92bKNfIsKh5XVwz5rqc/pubembed?start=false&loop=false
:width: 100%
:title: "Slides detailing the write policy for a fully associative cache in this section. Access [original Google Slides](https://docs.google.com/presentation/d/15Nz0bRbUMH1EW45UmeayDK5D_D8eLSKCBL-CvlEjvls/edit?usp=sharing)"
:::

Write back, with dirty bit animation.
::::

:::{note} 7. Store byte @ `0x524`. Cache hit.
:class: dropdown

Address `0x524` in binary: `0b0101 0010 0100`

* Tag: `0b0101001001`, or `0x149`
* Offset: `0b00`

1. **Cache Hit**. The requested tag `0x149` matches a **valid** cache tag.
1. **Write**. Write byte in cache block at offset `0b00`. Set dirty bit.

In this write-back cache, this memory access does not incur a block replacement (because it was a cache hit). There is therefore no write to memory.
:::

:::{table} Comparison of cache write policies.
:label: tab-cache-write

| Feature | Write-through | Write-back |
| :-- | :-- | :-- |
| **Description** | Write to the cache and memory at the same time | Write to the cache. Only write back to memory when the block is replaced. |
| **Implementation** | Easy | More complicated |
| **"Synchronized" with memory?**[^coherency] | Yes | No. Sometimes cache will have the most current copy of data. |
| **Optimization** | – | Include a **dirty bit** to only write back modified blocks. |
| **Hit time for writes** | Each write to a cache block also requires a write to memory. Longer. | Multiple writes within a cache block require only one write to memory (the latter happens only on replacement). Faster. |
| **Miss penalty** | "Read" misses are fast and never result in a write to memory. Shorter. | A "read" miss has variable time, since a write to memory may also be needed if the block to be replaced is dirty. Longer on average. |
| **AMAT** | Longer | Shorter |

[^coherency]: Also known as data coherency, or cache coherency.
:::

Which write policy should we use? It depends on the level of memory hierarchy. We discuss this more later with virtual memory.

Final note: Fortunately, most cache accesses are **reads**, not **writes**. reads dominate cache accesses (all instruction accesses are reads; furthermore, most instructions write to registers, not memory). A block can be read from the cache at the same time that the tag is read and compared. Unfortunately, for writes, modifying a block cannot begin until the tag is checked to see if the address is a hit. Nevertheless, processors do not have to wait for writes to complete and can begin executing other instructions during this time (consider the `MEM` stage of our five-stage pipeline).

## Walkthrough Summary

In this section, we traced through a cache design for a 12-bit address space with the following features:

* Block size: 4B
* Capacity: 16B
* Placement policy: Fully associative
* Replacement policy: Least Reecntly Used
* Write policy: Write-back

:::{figure} images/fa-all.png
:label: fig-fa-all
:width: 70%
:alt: "Complete design table showing an example of a fully associative cache. Each of the four rows in the cache has a valid bit, dirty bit, LRU value, tag, and four data bytes."

Design of the fully associative cache described in this section's example.
:::

Cache "metadata":

* Tag: 10 bits
* Valid bit
* LRU hardware (e.g., a counter)
* Dirty bit (to optimize write-back)

### Block size and performance

In our tiny cache with 4B-sized blocks, reading a word is equivalent to reading the entire block, but in practice blocks are composed of multiple words (e.g., 16 or 32 words per block).

From P&H 5.3: "The use of a bigger block takes advantage of spatial locality: it decreases the miss rate and improves the efficiency of cache hardware by reducing the amount of tag storage releative to the amount of data storage in the cache. Although a larger block size decreases the miss rate, it could also increase the miss penalty. If the miss penalty increases linearly with block size, larger blocks can easily lead to lower performance.

## Fully Associative: Hardware and Performance

Fully associative caches employ the most flexible placement policy, which is also the most costly to implement in hardware. From P&H 5.4:

> To make the search [of a block in a fully associative cache] practical, it is done in parallel with a comparator associated with each entry. These comparators significantly increase the hardware cost, effectively making fully associative placement practical only for caches with small numbers of blocks.

As shown in @fig-fa-hardware, the hardware is somewhat straightforward: Obtain the tag from the address (i.e., build a wire bundle for the upper bits), then use one comparator per cache entry to compare the cache entry's tag to the provided tag. OR these comparator results together to determine a cache hit.

:::{figure} images/fa-hardware.png
:label: fig-fa-hardware
:width: 100%
:alt: "Hardware view emphasizing extra parallel tag comparisons required by fully associative placement. Rectangles depict the cache tag, valid bit, and data."
A fully associative placement increases hardware cost.
:::

Fully associative caches are not common in modern processors. Because of the additional hardware needed, higher associativity increases not only hardware but also power.[^power] We will see placement policies with lower associativity in the next section that reduce the number of comparators needed _and_ reduce the complexity of each comparator by reducing the width of the cache tag.

[^power]: Read more in _Computer Organization: A Quantitative Appproach_, 5th edition, Section 2.1.
<!--
## Visuals

:::{figure} images/fully-associative-cache-lru.png
:label: fig-fully-associative-cache-lru
:width: 60%
:alt: "Fully associative cache table with least-recently-used replacement metadata."
A fully associative cache with LRU replacement policy.
:::

:::{figure} images/warmed-up-cache-can-still-miss.png
:label: fig-warmed-up-cache-can-still-miss
:width: 60%
:alt: "Example showing that a warmed-up cache can still miss due to replacement and access pattern."
Even a fully warmed-up cache can still produce a miss.
:::

:::{figure} images/fully-associative-lru-write-back.png
:label: fig-fully-associative-lru-write-back
:width: 60%
:alt: "Fully associative cache state using LRU replacement and write-back dirty tracking."
A fully associative cache using LRU replacement and a write-back policy.
:::

:::{figure} images/placement-policies.png
:label: fig-placement-policies
:width: 75%
:alt: "Placement-policy spectrum from fully associative through set-associative to direct-mapped."
The spectrum of cache placement policies from fully associative to direct mapped.
:::
1-->