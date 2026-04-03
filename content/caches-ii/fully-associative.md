---
title: "Fully Associative"
subtitle: Full version coming soon!
---

(sec-fully-associative)=
## Learning Outcomes

<!--* TODO
-->

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/-7TxNYUeFng
:width: 100%
:title: "[CS61C FA20] Lecture 26.3 - Caches III: Fully Associative Caches"
:::

::::

How do we design a cache? [From earlier](#sec-cache-terminology):

:::{embed} #sec-cache-design-policy
:::

In this section, we introduce the **fully associative** placement policy and use it as a means to discuss a detailed example and tradeoffs between replacement policies and write policies.

## Placement policy

(sec-fully-associative-policy)=
:::{note} _Fully Associative_ placement policy

A line can be placed in any entry of the cache.

:::

In other words, **associativity** refers to the possible entries that a particular line of data can be associated with.

## Identification

How do we determine a **cache hit** on a memory address? In other words, how do we know if the data at a specific memory address is in a line of the cache? From _Computer Organization: A Quantitative Approach_ Appendix B.1:

> Caches have an address tag on each block frame that gives the block address. The tag of every cache block that might contain the desired information is checked to see if it matches the block address from the processor. As a rule, all possible tags are searched in parallel because speed is critical.

There is a lot in this paragraph (not least of which is the block vs. line terminology[^block-vs-line]). We first explore the relationship between a memory address and the tag of a cache entry. We then explain how we determine cache hits.

[^block-vs-line]: Here, "block frame" means the cache entry itself, "block" is the data unit, and "block address" is something that indicates the memory address of the least significant byte of this block.

### Tag and Offset

We would like to connect the 12-bit memory address in @fig-fa-address to the cache shown in @fig-fa-intro, which is a 16B fully associative cache with 4B cache lines. We do so by splitting the address into two portions: **tag** and **offset**.

:::{figure} images/fa-address.png
:label: fig-fa-address
:width: 60%
:alt: "TODO"
For a fully associative cache, the memory address is split into two fields: the tag and the offset. If cache lines are 4 bytes, then a 12-bit memory address is split into a 10-bit tag and a 2-bit offset.

:::

:::{figure} images/fa-intro.png
:label: fig-fa-intro
:width: 50%
:alt: "TODO"
Cache tag and offset in a 16B fully associative cache for 12-bit memory addresses. The bytes in the first entry's line share the same upper 10 bits of their memory addresses: `0b0100001111`, or `0x10F`, which is the tag. The address of the most significant byte in the first line is therefore `0x43F`.
:::

What then, is a **tag**? Recall that all of the bytes in each line of data are from the same area of memory. Their address will share a common set of upper bits. In **fully associative caches** like in @fig-fa-intro, all of these upper bits are placed into the **tag** associated with each line.

What about the **offset**? Memory is byte addressable, so each of the bytes in a given line will have different memory addresses. The memory addresses of bytes in a given line will not vary in the upper bits (the tag) but rather in the lowest bits. The **offset** is the portion of the address needed to describe this variation.


:::{tip} Quick check

Revisit the connection between the address portions in @fig-fa-address and the 16B fully associative cache (with 4B lines) in @fig-fa-intro.

1. What is the line size, in bytes?
1. What is the total data capacity across all lines, in bytes?
1. If our memory space is $2^{12}$ bytes, we have 12-bit addresses. How many bits of this address should be reserved for the offset?
1. Still assuming 12-bit addresses, how many bits of this address should be reserved for the tag?
:::

:::{note} Solution

1. **4 bytes**. Line size (aka block size) is the number of bytes per line. In @fig-fa-intro, each cache entry has a 4-byte "row" of data in its line.
1. **16 bytes.** Data capacity is the number of bytes across all cache lines. @fig-fa-intro shows 4 lines, each of size 4 bytes.
1. The offset identifies the byte offset to access data from a given line. To index into each of the line size = 4 bytes in a given line, we need $\log_2{(\text{line size})}$ = **2 bits**.
1. Each cache entry's tag associates the data in that line with a particular (set of) addresses. These set of addresses may vary in offsets (lower 2 bits) but will share the same tag. Because we use a 12-bit memory address in our toy example, for this fully associative cache our tags are (\# address bits) - (\# offset bits) = **10 bits**.
:::

:::{note} More explanation of @fig-fa-intro
:class: dropdown

Consider the addresses of each of the four bytes of the first cache line (with tag `0x10F`):

* Least significant byte (rightmost in first line of @fig-fa-intro cache) has byte offset `0b00`. We reconstrruct the memory address by prepending the 10-bit tag `0x10F` to the offset to get `0b01 0000 1111 00`, or `0x43C`.
* Second least significant byte has offset `0b01`. Prepend the same 10-bit tag `0x10F` to get `0b01 0000 1111 01`, or `0x43D`.
* Second most significant byte has offset `0b10`. Binary address `0b01 0000 1111 10`, or `0x43E`.
* Most significant byte (leftmost and highlighted in first line of @fig-fa-intro cache) has offset `0b11`. Binary address `0b01 0000 1111 11`, or `0x43F`.

::::

(sec-valid-bit)=
### Valid bit

There must be a way to know that a cache block does not have valid information. For example, when starting up a program, the cache necessarily does not have valid information for the program. The most common procedure is to add an indicator (i.e., **flag**) to the tag to tell if each entry in the cache is valid for this particular program.

The **valid bit** indicates if the tag for the line is valid. If the valid bit is set (`1`), the tag refers to a valid memory address. If it is not set (`0`), we should not match to this tag (even if the tag bits match by chance).

:::{figure} images/fa-valid.png
:label: fig-fa-valid
:width: 50%
:alt: "TODO"
A [cold](#sec-cache-temperatures) snapshot of the fully associative cache in @fig-fa-intro, where valid bits for all cache lines are unset (i.e., set to `0`). While not precisely true to hardware, [^valid-hardware] we illustrate the valid bit in our tabular visualization as an additional column of metadata.
:::

[^valid-hardware]: From _Computer Organization: A Quantitative Approach_, Appendix B.1: "...add a _valid bit_ to the tag to say whether or not this entry contains a valid address."

(sec-fa-walkthrough)=
## Walkthrough: Warming up the Fully Associative Cache

The following animation traces through five memory accesses to a 12-bit address space on our 16B fully associative cache with 4B lines. Assume the cache starts out [cold](#sec-cache-temperatures), like in @fig-fa-valid.

::::{figure}
:label: fig-fa-warmup
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQU9l8AzNd5IkR1OUoqNtUygI4anobQJsrXgAXObfGH_eoSDy3iCIVqHMtZE8p-TvSI06dUoLIb8Y-z/pubembed?start=false&loop=false
:width: 100%
:title: "Slides associated with the text of this section. Access [original Google Slides](https://docs.google.com/presentation/d/1NxTminubfgSHzH2S_N7SxTyquI5B4QidA8b6W4mnRlU/edit?usp=sharing)"
:::

Warming up a fully associative cache.[^replacement-policy]
::::

:::{note} 1. Load byte @ `0x43F`. Cache miss.
:class: dropdown

Address `0x43F` in binary: `0b0100 0011 1111`

* Tag: `0b0100001111`, or `0x10F`
* Offset: `0b11`

1. **Cache Miss**. No valid tags in the cache match `0x10F`.
1. **Access lower level of memory hierarchy**. Load into a cache entry[^replacement-policy] the four bytes of data starting @ `0x43C`. Mark valid bit.

    Spatial locality: Even if we only read in one byte, loading from memory will load the full line (here, 4B), where all bytes of data in the line share the same tag because they are from the same region of memory:
    * Least significant byte in line (offset `0b00`) is @ memory address `0x43C` (`0b0100 0011 1100`)
    * Most significant byte in line (offset `0b11`) is @ memory address `0x43F` (`0x0b100 0011 1111`)

1. **Read**. Read byte in cache line at offset `0b11` (i.e., most significant byte in line)	and return to processor.

[^replacement-policy]: To keep things simple for now, if we encounter a cache miss, we load the new line from memory into an invalid cache entry. This is consistent with most replacement policies, which we discuss in [this section](#sec-replacement-policy).

:::

:::{note} 2. Load byte @ `0x5E2`. Cache miss.
:class: dropdown

Address `0x5E2` in binary: `0b0101 1110 0010`

* Tag: `0b0101111000`, or `0x178`
* Offset: `0b10`

1. **Cache Miss**. No valid tags in the cache match `0x178`.
1. **Access lower level of memory hierarchy**. Load into a cache entry[^replacement-policy] the four bytes of data starting @ `0x5E0` (`0b0101 1110 0000`). Mark valid bit.
1. **Read**. Read byte in cache line at offset `0b10` and return to processor.
:::

:::{note} 3. Load_ word_ @ `0x824`. Cache miss.
:class: dropdown

Address `0x824` in binary: `0b1000 0010 0100`

* Tag: `0b1000001001`, or `0x209`
* Offset: `0b00`

1. **Cache Miss**. No valid tags in the cache match `0x209`.
1. **Access lower level of memory hierarchy**. Load into a cache entry[^replacement-policy] the four bytes of data starting @ `0x824` (`0b1000 0010 0100`). Mark valid bit.
1. **Read**. Read **word**[^word-vs-line] in cache line at offset `0b00` and return to processor.

[^word-vs-line]: In our tiny cache with 4B-sized lines, reading a word is equivalent to reading the entire cache line, but in practice cache lines are composed of multiple words (e.g., 16 or 32 words per line).
:::

:::{note} 4. Load byte @ `0x5E0`. Cache hit.
:class: dropdown

Address `0x5E0` in binary: `0b0101 1110 0000`

* Tag: `0b0101111000`, or `0x178`
* Offset: `0b00`

1. **Cache Hit**. The first cache line has tag `0x178` **and is a valid tag**.
1. **Read**. Read byte in cache line at offset `0b00` and return to processor.
:::


Of these **five memory accesses**:

* The first three memory accesses are cache misses, incurring the expensive delay of main memory access.
* The fourth memory access is a cache hit, so no main memory access occurs.
* The last memory access is also a cache miss.

(sec-replacement-policy)=
## Replacement Policy

After the previous five memory accesses, our fully associative cache is at capacity (i.e., "full", because all cache entries are valid), as shown in @fig-fa-full.

:::{figure} images/fa-full.png
:label: fig-fa-full
:width: 60%
:alt: "TODO"

After the five memory accesses described [above](#sec-fa-walkthrough), our small fully associative cache is full.
:::

Because our 16-byte cache can only ever contain a subset of the 2{sup}`16` bytes of main memory data, our _full cache can still miss_. Consider a **sixth** memory access that does not match any valid tags, triggering a cache miss. On this cache miss, we must again go to memory and retrieve a cache line, but now we must replace one of our valid cache entries.[^replacement-policy-continued]

[^replacement-policy-continued]: To be precise, we still encountered the "replacement" policy question when we replaced invalid entries. Assume a consistent replacement policy for all cache misses, no matter the cache temperature.

A **replacement policy** defines how the cache controller determines which line is replaced on a cache miss. For fully associative caches, there are several options for replacement policies.

A natural replacement policy is called **least recently used**, or **LRU** for short. From _Computer Organization: A Quantitative Approach_ Appendix B.1:

> To reduce the chance of throwing out information that will be needed soon, access to blocks are recorded. Relying on the past to predict the future, the block replaced is the one that has been unused for the longest time. LRU relies on a corollary of locality: If recently used blocks are likely to be used again, then a good candidate for disposal is the least recently used block.

:::{hint} Quick Check

Based on the the five memory access described [above](#sec-fa-walkthrough), which line is the least recently used in @fig-fa-full? Assign each entry to a number from 0 (**most** recently used) to 3 (**least** recently used).

:::

:::{note} Solution
:class: dropdown

Coming soon!
:::

::::{figure}
:label: fig-fa-lru
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQZlQhRUK7d3f5-2SHQnPPSsyHFmG2xZ5hgEr5p8PyNZLKBl7zVK8UojiqD6OipYsRVa5v7t-ChQjT7/pubembed?start=false&loop=false
:width: 100%
:title: "Slides associated with the text of this section. Access [original Google Slides](https://docs.google.com/presentation/d/1vHYBxCYjtFT8vSbVFioz_o1K4T2e0mNykhJ89-yactQ/edit?usp=sharing)"
:::

Fully associative cache with least recently used (LRU) replacement policy.
::::

We summarize some common replacement policies:[^lifo]

1. **Least recently used (LRU)**: Select the most recently used line for replacement.
1. **Random**: Select a line randomly for replacement.
1. **First in, first out (FIFO)**: Select the _oldest_ line for replacement (even if the oldest block has been most recently used).[^fifo]

The implementation of replacement policies is out of the scope. However, we note the following:

* LRU incurs a significant hardware cost, because now we must keep track of access history.
* FIFO is a reasonable approximation to LRU without adding too much excess hardware.[^fifo]
* Random replacement works surprisingly okay when a workload has low temporal locality because it spreads replacement uniformly across the cache.

[^lifo]: Some of you may be wondering: Why not Most Recently Used (MRU)? Why not last in, first out (LIFO)? While LIFO approximates MRU, both of these policies go entirely against the idea of temporal locality. :-)

[^fifo]: The implementation of a FIFO replacement policy is out of scope. Read _Computer Organization: A Quantitative Approach_ Appendix B.1 for more details.

## Write Policy

::::{figure}
:label: fig-fa-wb
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vSBzBoel_J30XSTEfEQJDsk1OjVQ-Jnii6At7ZyqDKed1wADBar24FT5vhoT92bKNfIsKh5XVwz5rqc/pubembed?start=false&loop=false
:width: 100%
:title: "Slides associated with the text of this section. Access [original Google Slides](https://docs.google.com/presentation/d/15Nz0bRbUMH1EW45UmeayDK5D_D8eLSKCBL-CvlEjvls/edit?usp=sharing)"
:::

Write back, with dirty bit animation.
::::



Coming soon!

* Write-through: Write to the cache and memory at the same time. (more writes to memory → longer AMAT)
* Write data in cache and set a dirty bit to 1.
When this line gets replaced from the cache
(and “back” to memory), write to memory.

## Hardware and Performance

Fully associative caches employ the most flexible placement policy, which is also the most costly to implement in hardware. From P&H 5.4:

> To make the search [of a block in a fully associative cache] practical, it is done in parallel with a comparator associated with each entry. These comparators significantly increase the hardware cost, effectively making fully associative placement practical only for caches with small numbers of blocks.

As shown in @fig-fa-hardware, the hardware is somewhat straightforward: Obtain the tag from the address (i.e., build a wire bundle for the upper bits), then use one comparator per cache entry to compare the cache entry's tag to the provided tag. OR these comparator results together to determine a cache hit.

:::{figure} images/fa-hardware.png
:label: fig-fa-hardware
:width: 100%
:alt: "TODO"
A fully associative placement increases hardware cost.
:::

Because of the additional hardware needed, higher associativity increases not only hardware but also power.[^power] We will see placement policies with lower associativity in the next section that reduce the number of comparators needed _and_ reduce the complexity of each comparator by reducing the width of the cache tag.

[^power]: Read more in _Computer Organization: A Quantitative Appproach_, 5th edition, Section 2.1.
<!--
## Visuals

:::{figure} images/fully-associative-cache-lru.png
:label: fig-fully-associative-cache-lru
:width: 60%
:alt: "TODO"
A fully associative cache with LRU replacement policy.
:::

:::{figure} images/warmed-up-cache-can-still-miss.png
:label: fig-warmed-up-cache-can-still-miss
:width: 60%
:alt: "TODO"
Even a fully warmed-up cache can still produce a miss.
:::

:::{figure} images/fully-associative-lru-write-back.png
:label: fig-fully-associative-lru-write-back
:width: 60%
:alt: "TODO"
A fully associative cache using LRU replacement and a write-back policy.
:::

:::{figure} images/placement-policies.png
:label: fig-placement-policies
:width: 75%
:alt: "TODO"
The spectrum of cache placement policies from fully associative to direct mapped.
:::
1-->