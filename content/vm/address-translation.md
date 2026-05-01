---
title: "Address Translation"
subtitle: Coming soon. Thanks for your patience!
---

<!-- ## Learning Outcomes

* TODO
* TODO -->
(sec-memory-manager)=
::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/jpMigarDfh4
:width: 100%
:title: "[CS61C FA20] Lecture 29.3 - Virtual Memory I: Memory Manager"
:::

::::

<!-- to facilitate **demand paging**.


## Revisiting the Library Analogy

Book title like virtual address
Library of Congress call number like physical address
Card catalogue like page table, mapping from book title to call number
On card for book, in local library vs. in another branch like valid bit indicating in main memory vs. on disk (storage)
On card, available for 2-hour in library use (vs. 2-week checkout) like access rights

## Visuals

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

(sec-memory-manager)=
## The OS: Virtual Memory

asdf

:::{hint} About the Operating System
:label: sec-os-overview

The **operating system (OS)** is likely the single largest piece of software on your system. It loads, manages, and runs programs (i.e., **processes**), providing

1. Isolation between processes, and
1. Interaction between processes and the outside world via I/O devices.

Most of the details of the operating system (OS) are out of scope for this course. Here are the sections that describe the key OS functions you should know:

* [Heap Memory Management](#sec-heap-allocator)
* [Context Switches](#sec-context-switch)
* [Virtual Memory Management](#sec-memory-manager)

We hope a future version of these course notes will discuss the operating system in more detail. To learn more about the OS, please check out [CS 61C Spring 2025 slides](https://docs.google.com/presentation/d/1sh0iTDWdZiH3dxVoeOs4Yxb4Kt369x80Sj3Y7Nnluwk/edit?usp=drive_link) and [the CS 61C Fall 2020 YouTube playlist](https://youtube.com/playlist?list=PLnvUoC1Ghb7ziIlgNnQ24Gb6HBmLQO4T4&si=fJiBnfbzKuOouZ8F).

:::


:::{warning} What manages the memory hierarchy?

The below text is from an [earlier section](#sec-memory-hierarchy). The "later section" mentioned is this one. :-)

```{embed} #block-hierarchy-management
```
:::


Virtual memory manages the two levels of the memory hierarchy represented by main memory and disk.
 -->
