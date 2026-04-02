---
title: "Tag and Offset"
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

Given a cache, where do we place new lines from memory? We first discuss the most flexible policy, which is also the most challenging to implement in hardware.

(sec-fully-associative-policy)=
:::{note} _Fully Associative_ cache placement policy

The data can be associated with any line of the cache.

:::

## Tag and Offset

Recall from earlier:

:::{embed} #sec-cache-address
:::

How do we keep track of address(es) associated with data in a cache line? We note that because the bytes in each line of data are from the same part of memory, their address will share a common set of upper bits (called a **tag**) and vary in their lower bits.

We therefore store **tag**s with each line in our fully associative cache. In @fig-fully-associative-intro, the bytes in the first cache line share the same upper `0x10F` tag as the byte with address `0x43F`.

:::{figure} images/fully-associative-intro.png
:label: fig-fully-associative-intro
:width: 50%
:alt: "TODO"
Cache tag and offset in a fully associative cache. Different addressable bytes in the same cache line share the same tag.
:::

For all caches:

* P&H 5.3: "A **tag** is a field in a table used for a memory hierarchy that contains the address information required to identify whether the associated [line] in the hierarchy corresponds to a requested [word or byte]."
* All bytes in a cache line have different memory addresses (because memory is byte-addressable) that share the same tag associated with the line. They vary in the lower bits of the address, called an **offset**.
* All bytes in a line (typically sized to a power of two) should be "addressable" by the bits in the offset.

## Fully Associative Caches: Determining Cache Hit

For **fully associative caches**[^later]:

* The process of referring to memory by addresses tags effectively organizes memory into chunks equivalent to the **line size**.
* The line size and cache size are sufficient to determine how an address can be split into two bitfields representing the tag and offset, respectively.

[^later]: We discuss alternatives later.


:::{note} Fully Associative Cache Example: Load byte `0x43F`

Memory address `0x43F` is `0b1000 0011 1111`. To process this memory access request assuming the fully associative cache in @fig-fully-associative-intro:

1. Split the memory address into tag and offset.
  1. Tag: `0b1000001111`, or `0x10F`.
  1. Offset: `0b11` (or `0x3`).
1. Determine which of the cache lines, if any, share the `0x3F` tag. In @fig-fully-associative-intro, the first line has this tag, so this access is a **cache hit**.
1. Read the byte of the line at the correct offset. In @fig-fully-associative-intro, the byte with offset `0b11` is the most significant byte (leftmost) byte of the line.
:::

To summarize, for fully associative caches, we can check for a cache hit for a given address as follows:

1. Build tag and offset from the memory address by splitting it into two fields:
    * **Tag**: upper bits of address
    * **Offset**: byte offset within cache line
1. In a fully associative cache, check the tag of every line.
1. **Cache Hit** If a cache tag matches the provided tag, retrieve the byte with the given offset.

:::{tip} Quick check

Suppose we have the fully associative cache in @fig-fully-associative-intro.

1. What is the line size, in bytes?
1. What is the total data capacity across all lines, in bytes?
1. If our memory space is $2^{12}$ bytes, we have 12-bit addresses. How many bits of this address should be reserved for the offset?
1. Still assuming 12-bit addresses, how many bits of this address should be reserved for the tag?
:::

:::{note} Solution

1. **4 bytes**. Line size (aka block size) is the number of bytes per cache line. In @fig-fully-associative-intro, each cache line has a 4-byte "row" of data.
1. **16 bytes.** Data capacity is the number of bytes across all cache lines. @fig-fully-associative-intro shows 4 lines, each of size 4 bytes.
1. The offset identifies the byte address of data stored at a given cache line. To index into each of the line size = 4 bytes in a given line, we need $\log_2{(\text{line size})}$ = **2 bits**.
1. The tag identifies a particular cache line as associated with a particular (set of) addresses. These set of addresses may vary in offsets (lower 2 bits) but will share the same tag. Because there are 12 bits in the address, for this fully associative cache our tags are (\# address bits) - (\# offset bits) = **10 bits**.
:::



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
-->