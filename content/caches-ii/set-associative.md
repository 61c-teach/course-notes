---
title: "Set-Associative Cache"
---

(sec-set-associative)=
## Learning Outcomes

* Using address terminology, describe how to find a block in a set-associative cache: tag, index, and offset.
* For a given pattern of memory accesses to a set-associative cache, identify if each memory access is a cache hit or cache miss.
* Contrast set-associative caches with direct-mapped and fully associative caches.

::::{note} 🎥 Lecture Video: Set-Associative Caches
:class: dropdown

:::{iframe} https://www.youtube.com/embed/B4XiuH0kdEk
:width: 100%
:title: "[CS61C FA20] Lecture 27.1 - Caches IV: Set-Associative Caches"
:::

::::

::::{note} 🎥 Lecture Video: Set-Associative, Line Replacement
:class: dropdown

:::{iframe} https://www.youtube.com/embed/a-ejTer1Ijg
:width: 100%
:title: "[CS61C FA20] Lecture 25.3 - Caches IV: Block Replacement with Example"
:::

7:00 onwards

::::

## Placement Policy

(sec-set-associative-policy)=
:::{note} _Set Associative_ placement policy

A block can be placed in a restricted set of locations in the cache.

:::

A **set** is a group of blocks in the cache. A block is first mapped onto a set, and then the block can be placed anywhere within that set.

A cache is **N-Way Set Associative** if sets of N cache blocks are assigned a unique index. The **associativity** of a cache is therefore the number of slots (i.e., **ways**) assigned to each indexed set. @fig-sa-2way-small is a 16-byte, 2-way set-associative cache with 4B blocks.

:::{figure} images/sa-2way-small.png
:label: fig-sa-2way-small
:width: 80%
:alt: "Small 2-way set-associative cache table showing set 0 as the first two cache lines and set 1 as the second two cache lines."

A 16-byte, 2-way set-associative cache with 4B blocks.
:::

::::{tip} Quick check

In @fig-sa-2way-choice, which mapping represents a 32B **2-way** SA Cache with 4B blocks?

:::{figure} images/sa-2way-choice.png
:label: fig-sa-2way-choice
:width: 80%
:alt: "Set-associative cache table with 8 cache lines and 2 sets (labeled A). The example highlights two candidate ways within one indexed set for placement choice (labeled B)."

A 16-byte, 2-way set-associative cache with 4B blocks.
:::

* **A.** Two sets of four blocks
* **B.** Four sets of two blocks

::::

:::{note} Show Answer
:class: dropdown

**B.** Four sets of two blocks.

* "2-way" means there are **two blocks** per set.
* If the cache is 32B in capacity with 4B blocks, then there are eight blocks total.
* If each set has two blocks, then there are **four sets** total.
:::

:::{tip} Quick Check
Do blocks in set-associative caches need a valid bit? Do sets in set-associative caches need a valid bit?
:::

:::{note} Show Answer
:class: dropdown

In all cache types, the valid bit is used to check if the **tag** of a block is valid (and therefore that the block contains valid data for this program). Since there is one tag per block, all **blocks** need a valid bit. Setting a valid bit at the set level wouldn't tell us if the individual blocks (ways) within the set are valid.
:::

## Identification

Determining a cache hit in a set-associative cache works similarly to the process in direct-mapped caches, because the data can only be stored at one **index**. However, now the index has multiple slots (i.e., **ways**).

As an example, we can connect the 12-bit memory address in @fig-sa-2way-address to the set-associative cache in @fig-sa-2way-valid (below).

:::{figure} images/sa-2way-address.png
:label: fig-sa-2way-address
:width: 60%
:alt: "Memory address split for 2-way set-associative cache into fields: tag at bits 11 through 4, index at bits 3 through 2, and block offset at bits 1 through 0."
For a set-associative cache, the memory address is split into **three** fields: the tag, the index, and the offset. For the cache in @fig-sa-2way-valid, a 12-bit memory address is split into an 8-bit tag, a 2-bit index, and a 2-bit offset.

:::

Notes:

* In a set-associative cache, the **index** is used to select the **set**.
* In a set-associative cache, the **tag** is the upper bits of the address, excluding the bits for the index and the offset. The tag is used to check the cache block.
* As with all caches, the **offset** is the portion of the address needed to describe the byte offset within a block. These are always the lowest bits of the memory byte address.
* The **block address** is the tag concatenated with the index.
* While this memory address may seem identical to the [address figure](#fig-dm-address) discussed in our [direct-mapped cache section](#sec-direct-mapped), we note that the cache in @fig-sa-2way-valid is **twice** as large as the [direct-mapped cache figure](#fig-dm-valid).

## Replacement Policy

:::{tip} Quick Check

For set-associative caches, what replacement policies can be implemented? Select all that apply.

* **A.** Least Recently Used
* **B.** Most Recently Used
* **C.** FIFO
* **D.** Random
* **E.** None of the above
:::

:::{note} Show Answer
:class: dropdown

**A, B, C, D**.

On a cache miss, set-associative caches must determine which block to replace **within the set**. All replacement policies now occur within each set of blocks.

Like with fully associative caches, most set-associative caches implement LRU, FIFO, or random replacement (within the set). "Most recently used" is possible, but since it contradicts temporal locality, such a policy is not useful in practice.
:::

## Write Policy

:::{tip} Quick Check

For set-associative caches, what write policies can be implemented?

* **A.** Write-through
* **B.** Write-back
* **C.** Both A and B
* **D.** None of the above
:::

:::{note} Show Answer
:class: dropdown

**C**. both A and B.

All cache associativities can support either write-through or write-back policies. Again, _placement_ policy does not impact our choice of _when_ writes to memory happen.
:::

## Walkthrough

The following animation traces through four memory accesses to a 12-bit address space on our 32B, 2-way set-associative cache with 4B blocks. Assume a write-back policy. Assume the cache starts out [cold](#sec-cache-temperatures), like in @fig-sa-2way-valid.

:::{figure} images/sa-2way-valid.png
:label: fig-sa-2way-valid
:width: 60%
:alt: "Table showing cold 2-way set-associative cache with 4 sets. Each cache line has a valid and dirty bit."
A [cold](#sec-cache-temperatures) snapshot of a 32B, 2-way set-associative cache with 4B blocks and a dirty bit for write-back.
:::

::::{figure}
:label: fig-sa-2way-warmup
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQwW0AI7yiWfn0L5EVQQOVNbs6ke7nQDHkKwM7CHQ-IRMSnOn-88QXC9LCTtORDQmWLXp9wK_Vd_U0b/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through four memory accesses with a 2-way set associative cache in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1Wi_d703PYdJgahH0bjxTKVvwT6KQ0dCFLZF7q6O0e9o/edit?usp=sharing)"
:::

::::

:::{note} 1. Load byte @ `0xFE2`. Cache miss.
:class: dropdown

Address `0xFE2` in binary: `0b1111 1110 0010`

* Tag: `0b11111110`, or `0xFE`
* Index: `0b00`, or `0`
* Offset: `0b10`

1. **Cache Miss**. No valid tags in the set with index `0` match `0xFE`.
1. **Access lower level of memory hierarchy**. Replace the least recently used block in the set with index `0` (here, could be either since cache is cold). Load in a block's worth of data from memory starting @ address `0xFE0` (`0b1111 1110 0000`). Write the tag `0xFE`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b10` and return to processor.

:::

:::{note} 2. Store byte @ `0x61C`. Cache miss.
:class: dropdown

Address `0x61C` in binary: `0b0110 0001 1100`

* Tag: `0b01100001`, or `0x61`
* Index: `0b11`, or `3`
* Offset: `0b00`

1. **Cache Miss**. No valid tags in the set with index `3` match `0x61`.
1. **Access lower level of memory hierarchy**. Replace the least recently used block in the set with index `3` (here, could be either since cache is cold). Load into cache entry `3` a block's worth of data from memory starting @ address `0x61C` (`0b0110 0001 1100`). Write the tag `0x61`. Mark valid bit. Unset dirty bit.
1. **Write**. Write byte in cache block at offset `0b00`. Set dirty bit.
:::

:::{note} 3. Load byte @ `0x61B`. Cache miss.
:class: dropdown

Address `0x61B` in binary: `0b0110 0001 1011`

* Tag: `0b01100001`, or `0x61`
* Index: `0b10`, or `2`
* Offset: `0b11`

1. **Cache Miss**. No valid tags in the set with index `2` match `0x61`.
1. **Access lower level of memory hierarchy**. Replace the least recently used block in the set with index `2` (here, could be either since cache is cold). Load into cache entry `2` a block's worth of data from memory starting @ address `0x618` (`0b0110 0001 1000`). Write the tag `0x61`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b11` and return to processor.

:::

:::{note} 4. Load byte @ `0xCAD`. Cache miss.
:class: dropdown

Address `0xCAD` in binary: `0b1100 1010 1101`

* Tag: `0b11001010`, or `0xCA`
* Index: `0b11`, or `3`
* Offset: `0b01`

1. **Cache Miss**. No valid tags in the set with index `3` match `0x61`..
1. **Access lower level of memory hierarchy**. Replace the least recently used block in the set with index `3`; here, it is the **invalid** block. Replace the invalid block with a block's worth of data from memory starting @ address `0xCAC` (`0b01100 1010 1100`). Write the tag `0xCA`. Mark valid bit. Unset dirty bit.
1. **Read**. Read byte in cache block at offset `0b01` and return to processor.

:::

Contrast this set-associative cache walkthrough with the one for [direct-mapped caches](#sec-fa-walkthrough):

* Identification of a cache hit occurs by checking **M tags** in an M-way set associative cache: each of the tags for the M blocks in the set.
* Memory accesses 2 and 3 create cache entries in cache entries `3` and `2`, respectively; these cache entries share the same tag. However, the blocks in these entries have different **block addresses**.
* Memory access 4 did **not** incur a block replacement/memory write. Because there are two ways in a set, the existing block in the set with index `3` was not replaced. At the end of memory access 4, the set with index `3` is full.

(sec-cache-associativity)=
## Associativity: A Discussion

We illustrate in @fig-tio-address the relationship between block address, tag, index, and offset.

:::{figure} images/tio-address.png
:label: fig-tio-address
:width: 60%
:alt: "Address decomposition table showing memory address in bytes. The block address is split into tag and index, and the remaining part of the address is the block offset. Tag is used to connect cache to memory, index is used to select the cache block for placement in cache, and the byte offset specifies the byte within the cache block."
A (byte-addressed) memory address can be decomposed into a **block address** and a **block offset**. For direct-mapped caches and set-associative caches, the block address can be further divided into a tag and an index. Fully associative caches have no index field.
:::

Notes:

* Fully associative caches have no index field; the block address _is_ the tag.
* In direct-mapped caches and set-associative caches, the **index** is the lower bits of the block address used to select the set.
* The tag is compared against every block's tag in the set.
* The **offset** is the address of the desired data within the block.

:::{tip} Quick check

Using set-associativity terminology, what is a fully associative cache with M blocks?
:::

:::{note} Show Answer
:class: dropdown

A fully associative cache can have blocks placed anywhere in the cache. Put another way, an M-block fully associative cache is an **M-way** set-associative cache, where M is the number of blocks in the cache.
:::

:::{tip} Quick check

Using set-associativity terminology, what is a direct-mapped cache with M blocks?
:::

:::{note} Show Answer
:class: dropdown

A direct-mapped cache can have each block placed exactly in one location in the cache. Put another way, an M-block direct-mapped cache is a **one-way** set-associative cache, where M is the number of sets in the cache, and each set has one block.
:::

:::{figure} images/placement-policies.png
:label: fig-placement-policies
:width: 75%
:alt: "Placement-policy spectrum chart from fully-associative cache to direct mapped cache with set-associative cache in between. Fully associative cache is labeled as putting a new block anywhere in the cache. Set-associative cache is labeled as putting a new block in one of N places, called sets. Direct mapped cache is labeled as putting a new block in one specific place."
The spectrum of cache placement policies, with set-associative as the in-between approach.
:::

We are finally ready to revisit the tradeoffs of design choices. Below, placement policy is determined by choice of associativity.

```{embed} #sec-cache-design-policy
```

:::{hint} Set-associative caches

Set-associative caches are a good middle ground for placement policies.

* A small degree of associativity balances the good parts of fully associative caches (i.e., better performance by reducing [conflict misses](#sec-cache-misses)) with good parts of direct-mapped caches (simpler hardware). 8-way set associative caches are used in first-level caches in modern hardware.
* Higher associativity reduces the [miss rate](#sec-cache-misses); see measurements in a [later section](#sec-higher-associativity).

:::