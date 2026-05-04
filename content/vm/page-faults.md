---
title: "Page Faults"
subtitle: Coming soon. Thanks for your patience!
---

<!-- ## Learning Outcomes

* TODO
* TODO -->

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Rc73MpGzZuM
:width: 100%
:title: "[CS61C FA20] Lecture 29.5 - Virtual Memory I: Page Faults"
:::

::::
<!-- ## Visuals
<!-- :::{figure} images/paged-memory-1.png
:label: fig-paged-memory
:width: 50%
Physical memory broken into pages.
::: -->

:::{figure} images/page-table.png
:label: fig-page-table-1
:width: 50%
Each process has a page table.
:::

:::{figure} images/address-translation-page-not-in-mem-1.png
:label: fig-address-translation-page-not-in-mem-1
:width: 70%
Example of page table walk (page fault).
:::

:::{figure} images/address-translation-page-not-in-mem-2.png
:label: fig-address-translation-page-not-in-mem-2
:width: 70%
Example of page table walk: get VPN.
:::

:::{figure} images/address-translation-page-not-in-mem-3.png
:label: fig-address-translation-page-not-in-mem-3
:width: 70%
Example of page table walk: look up PPN.
:::

:::{figure} images/address-translation-page-not-in-mem-4.png
:label: fig-address-translation-page-not-in-mem-4
:width: 70%
Example of page table walk: load page from disk.
:::

:::{figure} images/address-translation-page-not-in-mem-5.png
:label: fig-address-translation-page-not-in-mem-5
:width: 70%
Example of page table walk: read memory from newly loaded page.
::: -->