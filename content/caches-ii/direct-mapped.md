---
title: "Direct Mapped Cache"
---

(sec-direct-mapped)=
## Learning Outcomes

* Using address terminology, describe how to find a block in a direct-mapped cache: tag, index, and offset.
* For a given pattern of memory accesses to a direct-mapped cache, identify if each memory access is a cache hit or cache miss.
* Contrast direct-mapped caches with fully associative caches.

::::{note} 🎥 Lecture Video: Direct Mapped Caches
:class: dropdown

:::{iframe} https://www.youtube.com/embed/wF3Ekt-ZHdg
:width: 100%
:title: "[CS61C FA20] Lecture 26.1 - Caches II: Direct Mapped"
:::

::::

::::{note} 🎥 Lecture Video: Direct Mapped Example
:class: dropdown

:::{iframe} https://www.youtube.com/embed/-OtUM6j6_xE
:width: 100%
:title: "[CS61C FA20] Lecture 26.2 - Caches II: Direct Mapped Example"
:::

::::

In an [earlier section](#sec-fully-associative), we explained why hardware costs make fully associative caches rather uncommon in modern processors. We now introduce the other end of the spectrum policy: a **direct mapped cache**. With this new cache, we consider again the cache design policies and walk through an example.

:::{embed} #sec-cache-design-policy
:::

## Placement Policy

(sec-direct-mapped-policy)=
:::{note} _Direct Mapped_ placement policy

A block can be placed in exactly one location of the cache.

:::

## Identification

Consider our visualization for a 16B, direct-mapped cache with 4B blocks in @fig-dm-valid.

:::{figure} images/dm-valid.png
:label: fig-dm-valid
:width: 60%
:alt: "Cold direct-mapped cache table with valid and dirty bits and empty data contents."
A [cold](#sec-cache-temperatures) snapshot of a 16B direct-mapped cache with 4B blocks and a dirty bit for write-back.
:::

On the surface, the direct mapped cache looks very similar to that of our [fully associative cache](#fig-fa-valid). We discuss how the direct mapped placement policy shortens the tag width and impacts the identification procedure to determine a cache hit.

<!-- ## TODO: gotta put in the crazy coloring with indices, etc.-->

### Tag, Index, and Offset

The mapping of pretty much all direct-mapped caches is simple:

```{math}
\text{(Block address) modulo (number of blocks in cache)}
```

Like before direct-mapped caches copy in data from memory at the granularity of **blocks**. We can then translate from **byte address** to **block addresses**.

(sec-block-address)=
:::{note} Block address vs. byte address

By definition, we say that the **block address** is the "index" of a block in memory, if we had chunked memory into blocks, not bytes. In other words, the **block address** of a cache block is the upper bits of the _byte address_ of this block in memory, excluding the lower bits reserved for the byte offset.

We discuss this more in a [later section](#fig-tio-address) after we have covered [set associative caches](#sec-set-associative).
:::

As an example, we can connect the direct-mapped cache in @fig-dm-valid to the 12-bit memory address in @fig-dm-address.

:::{figure} images/dm-address.png
:label: fig-dm-address
:width: 60%
:alt: "Direct-mapped address decomposition into fields: tag at bits 11 through 4, index at bits 3 through 2, and block-offset at bits 1 through 0."
For a direct-mapped cache, the memory address is split into **three** fields: the tag, the index, and the offset. For the cache in @fig-dm-valid, a 12-bit memory address is split into an 8-bit tag, a 2-bit index, and a 2-bit offset.

:::

* In a direct-mapped cache, the **index** is used to select the block.
* In direct-mapped caches, the **tag** is the upper bits of the address, excluding the bits for the index and the offset. The tag is used to check the cache block.
* As with all caches, the **offset** is the portion of the address needed to describe the byte offset within a block. These are always the lowest bits of the memory byte address.
* The **block address** is the tag concatenated with the index.

:::{tip} Quick Check

Revisit the relationship between the address portions in @fig-dm-address and the 16B direct-mapped cache (with 4B blocks) in @fig-dm-valid.

1. What is the block size, in bytes?
1. What is the total data capacity across all blocks, in bytes?
1. If our memory space is $2^{12}$ bytes, we have 12-bit addresses. How many bits of this address should be reserved for the offset?
1. Still assuming 12-bit addresses, how many bits of this address should be reserved for the index?
1. Still assuming 12-bit addresses, how many bits of this address should be reserved for the tag?
:::

:::{note} Solution
:class: dropdown

1. **4 bytes**.
1. **16 bytes.** Remember, data capacity.
1. The offset is still with respect to the block size. $\log_2{(\text{block size})}$ = **2 bits**.
1. The index selects the entry of the cache. To index into each of the 4 entries of this cache, we need $\log_2{(\text{number of blocks})} = **2 bits**.
1. The tag, like before, is the upper bits of the address—but now, it is the upper bits that are _not_ captured by the index and the offset. Because we use a 12-bit memory address in our toy example, for this direct-mapped cache our tags are (\# address bits) - (\# index bits) - (\# offset bits) = **8 bits**.
:::

:::{warning} Direct Mapped: Tag, Index, Offset

Direct-mapped caches use the address to determine the **index** of the _only cache entry_ that can be associated with this memory address. Fully associative caches do _not_ split the address into an index portion because blocks can be placed anywhere.
:::

## Replacement Policy

:::{tip} Quick Check

For direct-mapped caches, what replacement policies can be implemented? Select all that apply.

* **A.** Least Recently Used
* **B.** Most Recently Used
* **C.** FIFO
* **D.** Random
* **E.** None of the above
:::

:::{note} Show Answer
:class: dropdown

**E.** None of the above.

In direct mapped caches, there is only ever one block to replace—the existing block with matching index. LRU, most recently used, FIFO, and Random replacement would violate the placement policy of direct-mapped caches.
:::

## Write Policy

:::{tip} Quick Check

For direct-mapped caches, what write policies can be implemented?

* **A.** Write-through
* **B.** Write-back
* **C.** Both A and B
* **D.** None of the above
:::

:::{note} Show Answer
:class: dropdown

**C**. both A and B.

Direct-mapped _placement_ policy does not impact our choice of _when_ writes to memory happen. Both write-through and write-back policies are possible.
:::

## Walkthrough

The following animation traces through four memory accesses to a 12-bit address space on our 16B direct-mapped cache with 4B blocks. Assume a write-back policy. Assume the cache starts out [cold](#sec-cache-temperatures), like in @fig-dm-valid.

::::{figure}
:label: fig-dm-warmup
:alt: "Embedded slides stepping through four memory accesses on a cold 12-bit-address direct-mapped cache with 16-byte capacity, 4-byte blocks, and write-back policy."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vSfQ89lj8_qzjh6yX5lGIOVEzC3909wUDUGC5FRbyT060KMbeTBKLFvUIlPyHIkna968TML6yoBnGbe/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through the write policy of a direct-mapped cache from this section. Access [original Google Slides](https://docs.google.com/presentation/d/1SIM8fNAVuRooMmNGsFzuiB2MwlKYi_ZPWQrQYEh0dmE/edit?usp=sharing)"
:::

Warming up a direct-mapped cache.
::::

:::{note} 1. Load byte @ `0xFE2`. Cache miss.
:class: dropdown

Address `0xFE2` in binary: `0b1111 1110 0010`

* Tag: `0b11111110`, or `0xFE`
* Index: `0b00`, or `0`
* Offset: `0b10`

1. **Cache Miss**. The entry at index `0` has an invalid tag.
1. **Access lower level of memory hierarchy**. Load into cache entry `0` a block's worth of data from memory starting @ address `0xFE0` (`0b1111 1110 0000`). Write the tag `0xFE`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b10` and return to processor.

:::

:::{note} 2. Store byte @ `0x61C`. Cache miss.
:class: dropdown

Address `0x61C` in binary: `0b0110 0001 1100`

* Tag: `0b01100001`, or `0x61`
* Index: `0b11`, or `3`
* Offset: `0b00`

1. **Cache Miss**. The entry at index `3` has an invalid tag.
1. **Access lower level of memory hierarchy**. Load into cache entry `3` a block's worth of data from memory starting @ address `0x61C` (`0b0110 0001 1100`). Write the tag `0x61`. Mark valid bit. Unset dirty bit.
1. **Write**. Write byte in cache block at offset `0b00`. Set dirty bit.
:::

:::{note} 3. Load byte @ `0x61B`. Cache miss.
:class: dropdown

Address `0x61B` in binary: `0b0110 0001 1011`

* Tag: `0b01100001`, or `0x61`
* Index: `0b10`, or `2`
* Offset: `0b11`

1. **Cache Miss**. The entry at index `2` has an invalid tag.
1. **Access lower level of memory hierarchy**. Load into cache entry `2` a block's worth of data from memory starting @ address `0x618` (`0b0110 0001 1000`). Write the tag `0x61`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b11` and return to processor.

:::

:::{note} 4. Load byte @ `0xCAD`. Cache miss.
:class: dropdown

Address `0xCAD` in binary: `0b1100 1010 1101`

* Tag: `0b11001010`, or `0xCA`
* Index: `0b11`, or `3`
* Offset: `0b01`

1. **Cache Miss**. While the entry at index `3` is valid, its tag `0x61` does **not** match the provided tag `0xCA`.
1. **Access lower level of memory hierarchy**. The existing valid block at cache entry `3` must be replaced. Its dirty bit is set, so write this block to memory and replace it with a block's worth of data from memory starting @ address `0xCAC` (`0b01100 1010 1100`). Write the tag `0xCA`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b01` and return to processor.

:::

Contrast this direct-mapped cache walkthrough with the one for [fully associative caches](#sec-fa-walkthrough):

* Identification of a cache hit occurs by checking **exactly one tag**: the tag at the indexed cache entry.
* Memory accesses 2 and 3 create cache entries in cache entries `3` and `2`, respectively; these cache entries share the same tag. However, the blocks in these entries have different **block addresses**.
* Memory access 4 still incurred a block replacement (and a cache write-back) even though the cache was not filled. The cache entry at index `3` was occupied by a block with a different tag.

## Direct Mapped: Hardware and Performance

Implementing a direct-mapped cache in hardware is much simpler than the fully associative cache.

* Because the block can only be in one location, on a cache hit we need just one comparator to check the tag in the target line (and one mux to get said tag). We no longer need one comparator per cache block/entry.
* Because the index is now used to select the location of the block in the cache, it is not encoded into the bits of the tag. This reduces the width of each tag, thereby reducing the overhead per cache entry.

:::{figure} images/hardware-direct-mapped-cache.png
:label: fig-hardware-direct-mapped-cache
:width: 70%
:alt: "Hardware block diagram of a direct-mapped cache. A 32-bit address is broken into tag, index, and offset. Arrows connect the three fields of the address to where they are used in the memory space diagram to depict index selection, tag check, and data output path."
Hardware implementation of a direct-mapped cache.
:::
