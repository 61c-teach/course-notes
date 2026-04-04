---
title: "Direct Mapped Cache"
subtitle: Full version coming soon!
---

(sec-direct-mapped)=
## Learning Outcomes

<!--* TODO
* TODO-->

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

A block can be placed in any entry of the cache.

:::

## Identification

Consider our visualization for a 16B, direct-mapped cache with 4B blocks in @fig-dm-valid.

:::{figure} images/dm-valid.png
:label: fig-dm-valid
:width: 60%
:alt: "TODO"
A [cold](#sec-cache-temperatures) snapshot of a 16B direct-mapped cache with 4B blocks and a dirty bit for write-back.
:::

On the surface, the direct mapped cache looks very similar to that of our [fully associative cache](#fig-fa-valid). We discuss how the direct mapped placement policy shortens the tag width and impacts the identification procedure to determine a cache hit.

<!-- ## TODO: gotta put in the crazy coloring -->

### Tag, Index, and Offset

The mapping of pretty much all direct-mapped caches is simple:

```{math}
\text{(Block address) modulo (nunber of blocks in cache)}
```

Like before direct-mapped caches copy in data from memory at the granularity of **blocks**.  The **block address** is the address of a cache block and, by definition, is the address of the (lowest significant byte of) block in memory. The lowest bits of the address therefore describe byte addresses _within_ a block and are still defined as the **offset**.

Now, we can connect the direct-mapped cache in @fig-dm-valid to the 12-bit memory address in @fig-dm-address.

:::{figure} images/dm-address.png
:label: fig-dm-address
:width: 60%
:alt: "TODO"
For a direct-mapped cache, the memory address is split into **three** fields: the tag, the index, and the offset. For the blocks in @fig-dm-valid, a 12-bit memory address is split into an 8-bit tag, a 2-bit index, and a 2-bit offset.

:::

* In a direct-mapped cache, the **tag** is the upper bits of the address, excluding the bits for the index and the offset.
* In a direct-mapped cache, the **index** is used to select the block.
* In all caches, the **offset** is the portion of the address needed to describe the byte offset within a block. These are always the lowest bits of the address.
* The **block address** is the tag concatenated with the index, with offset bits set to 0.

:::{tip} Quick check

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

Direct mapped caches use the address to determine the **index** of the _only cache entry_ that can be associated with this memory address. Fully associative caches do not split the address into an index portion because blocks can be placed anywhere.
:::

## Replacement Policy

:::{tip} Quick Check

For direct mapped caches, what replacement policies can be implemented? Select all that apply.

* **A.** Least Recently Used
* **B.** Most Recently Used
* **C.** FIFO
* **D.** Random
* **E.** None of the above
:::

:::{note} Show Answer
:class: dropdown

**E.** None of the above.

In direct mapped caches, there is only ever one block to replace—the existing block with matching index. LRU, most recently used, FIFO, and Random replacement would violate the placement policy of direct mapped caches.
:::

## Write Policy

:::{tip} Quick Check

For direct mapped caches, what write policies can be implemented?

* **A.** Write-through
* **B.** Write-back
* **C.** Both A and B
* **D.** None of the above
:::

:::{note} Show Answer
:class: dropdown

**C**. both A and B.

Direct mapped _placement_ policy does not impact our choice of _when_ writes to memory happen. Both write-through and write-back policies are possible.
:::

## Walkthrough

The following animation traces through four memory accesses to a 12-bit address space on our 16B direct mapped with 4B blocks. Assume a write-back policy. Assume the cache starts out [cold](#sec-cache-temperatures), like in @fig-dm-valid.

::::{figure}
:label: fig-dm-warmup
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vSfQ89lj8_qzjh6yX5lGIOVEzC3909wUDUGC5FRbyT060KMbeTBKLFvUIlPyHIkna968TML6yoBnGbe/pubembed?start=false&loop=false
:width: 100%
:title: "Slides associated with the text of this section. Access [original Google Slides](https://docs.google.com/presentation/d/1SIM8fNAVuRooMmNGsFzuiB2MwlKYi_ZPWQrQYEh0dmE/edit?usp=sharing)"
:::

Warming up a direct mapped cache.
::::

:::{note} 1. Load byte @ `0xFE2`. Cache miss.
:class: dropdown

Address `0xFE2` in binary: `0b1111 1110 0010`

* Tag: `0b11111110`, or `0xFE`
* Index: `0b00`, or `0`
* Offset: `0b10`

1. **Cache Miss**. The entry at index `0` has an invalid tag.
1. **Access lower level of memory hierarchy**. Load into cache entry `0` a block's worth of data from memory starting @ block address `0xFE0` (`0b1111 1110 0000`). Write the tag `0xFE`. Mark valid bit. Unset dirty b it.
1. **Read**. Read byte in cache block at offset `0b10` and return to processor.

:::

:::{note} 2. Store byte @ `0x61C`. Cache miss.
:class: dropdown

Address `0x61C` in binary: `0b0110 0001 1100`

* Tag: `0b01100001`, or `0x61`
* Index: `0b11`, or `3`
* Offset: `0b00`

1. **Cache Miss**. The entry at index `3` has an invalid tag.
1. **Access lower level of memory hierarchy**. Load into cache entry `3` a block's worth of data from memory starting @ block address `0x61C` (`0b0110 0001 1100`). Write the tag `0x61`. Mark valid bit. Unset dirty bit.
1. **Write**. Write byte in cache block at offset `0b00`. Set dirty bit.
:::

:::{note} 3. Load byte @ `0x61B`. Cache miss.
:class: dropdown

Address `0x61B` in binary: `0b0110 0001 1011`

* Tag: `0b01100001`, or `0x61`
* Index: `0b10`, or `2`
* Offset: `0b11`

1. **Cache Miss**. The entry at index `2` has an invalid tag.
1. **Access lower level of memory hierarchy**. Load into cache entry `2` a block's worth of data from memory starting @ block address `0x618` (`0b0110 0001 1000`). Write the tag `0x61`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b11` and return to processor.

:::

:::{note} 4. Load byte @ `0xCAD`. Cache miss.
:class: dropdown

Address `0xCAD` in binary: `0b1100 1010 1101`

* Tag: `0b11001010`, or `0xCA`
* Index: `0b11`, or `3`
* Offset: `0b01`

1. **Cache Miss**. While the entry at index `3` is valid, its tag `0x61` does **not** match the provided tag `0xCA`.
1. **Access lower level of memory hierarchy**. The existing valid block at cache entry `3` must be replaced. Its dirty bit is set, so write this block to memory and replace it with a block's worth of data from memory starting @ block address `0xCAC` (`0b01100 1010 1100`). Write the tag `0xCA`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b01` and return to processor.

:::

Contrast this direct mapped cache walkthrough with the one for [fully associative caches](#sec-fa-walkthrough):

* Identification of a cache hit occurs by checking **exactly one tag**: the tag at the indexed cache entry.
* Memory accesses 2 and 3 create cache entries in cache entries `3` and `2`, respectively; these cache entries share the same tag. However, the blocks in these entries have different **block addresses**.
* Memory access 4 still incurred a cache miss even though the cache was not filled. The cache entry at index `3` was occupied by a block with a different tag.

<!--

## Visuals
:::{figure} images/hardware-direct-mapped-cache.png
:label: fig-hardware-direct-mapped-cache
:width: 70%
:alt: "TODO"
Hardware implementation of a direct-mapped cache.
:::

:::{figure} images/direct-mapped-cache-1.png
:label: fig-direct-mapped-cache-1
:width: 60%
:alt: "TODO"
A direct-mapped cache with four color-coded cache blocks.
:::

:::{figure} images/direct-mapped-cache-2.png
:label: fig-direct-mapped-cache-2
:width: 60%
:alt: "TODO"
A direct-mapped cache example with 4-byte blocks.
:::

:::{figure} images/direct-mapped-cache-address.png
:label: fig-direct-mapped-cache-address
:width: 70%
:alt: "TODO"
How a memory address is split into tag, index, and byte offset fields.
:::

:::{figure} images/direct-mapped-16b-cache.png
:label: fig-direct-mapped-16b-cache
:width: 60%
:alt: "TODO"
A 16-byte direct-mapped cache.
:::

:::{figure} images/memory-direct-mapped-16b-cache.png
:label: fig-memory-direct-mapped-16b-cache
:width: 100%
:alt: "TODO"
Memory layout for a 16-byte direct-mapped cache example.
:::

:::{figure} images/direct-mapped-4b-memory.png
:label: fig-direct-mapped-4b-memory
:width: 100%
:alt: "TODO"
Memory layout for a 4-byte direct-mapped cache example.
:::

:::{figure} images/direct-mapped-8b-cache.png
:label: fig-direct-mapped-8b-cache
:width: 50%
:alt: "TODO"
A direct-mapped cache with 2-byte blocks.
:::

:::{figure} images/memory-direct-mapped-4b-cache.png
:label: fig-memory-direct-mapped-4b-cache
:width: 100%
:alt: "TODO"
Memory layout for a 4-byte direct-mapped cache showing tag groupings.
:::

:::{figure} images/direct-mapped-cache-address.png
:label: fig-direct-mapped-cache-address-2
:width: 70%
:alt: "TODO"
Address fields mapped to tag and data regions of a cache block.
:::

:::{figure} images/memory-direct-mapped-8b-cache.png
:label: fig-memory-direct-mapped-8b-cache
:width: 100%
:alt: "TODO"
Memory layout for an 8-byte direct-mapped cache example.
:::

:::{figure} images/blank-cache-terminology-12b-addresses.png
:label: fig-blank-cache-terminology-12b-addresses
:width: 60%
:alt: "TODO"
A blank cache table for practicing cache terminology with 4-byte blocks.
:::

:::{figure} images/memory-address-terminology-12b-addresses.png
:label: fig-memory-address-terminology-12b-addresses
:width: 70%
:alt: "TODO"
A 12-bit memory address broken into tag, index, and offset fields.
:::

:::{figure} images/tio-example-direct-mapped.png
:label: fig-tio-example-direct-mapped
:width: 60%
:alt: "TODO"
A binary address decomposed into tag (0xFE), index (0x0), and offset (0x2).
:::

:::{figure} images/cache-example-direct-mapped-cache.png
:label: fig-cache-example-direct-mapped-cache
:width: 60%
:alt: "TODO"
A direct-mapped cache with a valid first block (tag 0xFE) and the remaining blocks invalid.
:::

:::{figure} images/memory-example-direct-mapped.png
:label: fig-memory-example-direct-mapped
:width: 50%
:alt: "TODO"
A 12-bit memory address split into tag (bits 11–4), index (bits 3–2), and offset (bits 1–0).
:::
-->