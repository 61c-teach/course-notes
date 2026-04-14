---
title: "Paged Memory"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/0VQu0e8A8e4
:width: 100%
:title: "[CS61C FA20] Lecture 29.4 - Virtual Memory I: Paged Memory"
:::

::::
## Visuals
:::{figure} images/paged-memory-1.png
:label: fig-paged-memory-1
:width: 50%
Physical memory broken into pages.
:::

:::{figure} images/page-table.png
:label: fig-page-table
:width: 50%
Each process has a page table.
:::

:::{figure} images/page-tables-are-in-memory.png
:label: fig-page-tables-are-in-memory
:width: 60%
Page tables are stored in memory.
:::

:::{figure} images/address-translation-1.png
:label: fig-address-translation-1
:width: 70%
Example of page table walk (no page fault).
:::

:::{figure} images/address-translation-2.png
:label: fig-address-translation-2
:width: 70%
Example of page table walk: get VPN.
:::

:::{figure} images/address-translation-3.png
:label: fig-address-translation-3
:width: 70%
Example of page table walk: look up PPN.
:::

:::{figure} images/address-translation-4.png
:label: fig-address-translation-4
:width: 70%
Example of page table walk: look up page.
:::

:::{figure} images/address-translation-5.png
:label: fig-address-translation-5
:width: 70%
Example of page table walk: read data from page.
:::