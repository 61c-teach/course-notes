---
title: "Translation Lookaside Buffers (TLB)"
subtitle: TODO
---

(sec-tlb)=
## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/FAonDF1VgUQ
:width: 100%
:title: "[CS61C FA20] Lecture 30.2 - Virtual Memory II: Translation Lookaside Buffers (TLB)"
:::

::::

## Visuals
:::{figure} images/just-tlb.png
:label: fig-just-tlb
:width: 50%
The Translation Lookaside Buffer (TLB).
:::

:::{figure} images/page-table-walk-necessary.png
:label: fig-page-table-walk-necessary
:width: 50%
Page table walk is inefficient.
:::

:::{figure} images/tlb-cuts-page-table-walk.png
:label: tlb-cuts-page-table-walk
:width: 70%
The TLB helps decrease amount of page table walks necessary.
:::

:::{figure} images/address-translation-ex-1.png
:label: address-translation-ex-1
:width: 80%
Example of address translation with TLB.
:::

:::{figure} images/address-translation-tlb-hit-case.png
:label: address-translation-tlb-hit-case
:width: 80%
Example of address translation with TLB (hit).
:::

:::{figure} images/address-translation-tlb-miss-case-1.png
:label: address-translation-tlb-miss-case-1
:width: 80%
Example of address translation with TLB (miss).
:::

:::{figure} images/address-translation-tlb-miss-case-2.png
:label: address-translation-tlb-miss-case-2
:width: 80%
Example of address translation with TLB (miss).
:::


For now, know that virtual memory is a virtual to physical address mapping assisted by the hardware (translation lookaside buffer, or TLB).