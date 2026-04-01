---
title: "Fully Associative Caches"
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

:::{note} _Fully Associative_ cache placement policy

The data can be stored anywhere in the cache.

:::

## Tag and Offset

Recall from earlier:

:::{embed} #sec-cache-address
:::

How do we keep track of address(es) associated with data in a cache line? We note that because the bytes in each line of data are from the same part of memory, their address will share a common set of upper bits (called a **tag**) and vary in their lower bits (called the byte **offset**). We therefore store **tag**s with each line in our fully associative cache. In @fig-fully-associative-intro, the bytes in the first cache line share the same upper `0x10F` tag as the byte with address `0x43F`.

:::{figure} images/fully-associative-intro.png
:label: fig-fully-associative-intro
:width: 60%
:alt: "TODO"
Cache tag and offset. Different addressable bytes in the same cache line share the same tag.
:::

For all caches:

* P&H 5.3: A **tag** is a field in a table used for a memory hierarchy that contains the address information required to identify whether the associated block in the hierarchy correpsonds to a requested word.
* All bytes in a line (typically sized to a power of two) should be "addressable" by the bits in the offset.

For fully associative caches, the process of referring to memory by addresses tags effectively organizes memory into chunks equivalent to the line size. We discuss alternatives later.

To check if a cache line has data at a given address, say, `0x43F`:

1. Build tag and offset from the memory address by splitting it into two fields:
    * **Tag**: upper bits of address
    * **Offset**: byte offset within cache line
1. Check the tag
1. If the tag matches, retrieve the byte with the given offset.

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