---
title: "Direct Mapped Caches"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/wF3Ekt-ZHdg
:width: 100%
:title: "[CS61C FA20] Lecture 25.1 - Caches II: Direct Mapped Caches"
:::

::::

## Visuals
:::{figure} images/tio-at-mem-address.png
:label: mem-address-to-cache
:width: 50%
:alt: "TODO"
The relationship between what is at a memory address and how it's stored in the cache.
:::

:::{figure} images/tio-calc-with-cache.png
:label: fig-tio-calc-with-cache
:width: 60%
:alt: "TODO"
Example of deriving tag, index, offset from a memory address.
:::

:::{figure} images/diff-cache-designs.png
:label: fig-diff-cache-designs
:width: 70%
:alt: "TODO"
The spectrum of possible cache implementations and designs.
:::





We illustrate in @fig-tio-address the relationship between block address, tag, index, and offset.

:::{figure} images/tio-address.png
:label: fig-tio-address
:width: 60%
:alt: "TODO"
A (byte-addressed) memory address can be decomposed into a **block address** and a **block offset**. For direct-mapped caches (and [set associative caches](#sec-set-associative)), the block address can be further divided into a tag and an index. Fully associative caches have no index field.
:::

Notes:

* Fully associative caches have no index field; the block address _is_ the tag.
* In direct-mapped caches[^set-assoc], the **index** is the lower bits of the block address used to select the block within the cache.
* In direct-mapped caches[^set-assoc], the **tag** is the upper bits of the address, excluding the bits for the index and the offset. The tag is used to check the cache block.
* 

The tag is used to check all of the blocks in the set, and the index is used to select the set. 

[^set-assoc]: This description applies to [set associative caches](#sec-set-associative), as we shall see in the next section.