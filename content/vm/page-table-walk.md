---
title: "Page Table Walk"
subtitle: Coming soon. Thanks for your patience!
---

<!-- ## Learning Outcomes

* TODO
* TODO -->

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/eVIsejli9hU
:width: 100%
:title: "[CS61C FA20] Lecture 30.3 - Virtual Memory II: TLBs in Datapath"
:::

::::

<!-- ## Visuals
:::{figure} images/pipt-1.png
:label: fig-pipt-1
:width: 60%
Putting it all together: what is the order in which we access things?
:::

:::{figure} images/memory-access-workflow.png
:label: fig-memory-access-workflow
:width: 60%
Full memory access workflow.
:::

:::{figure} images/address-translation-ex-1.png
:label: address-translation-ex-2
:width: 80%
Example of address translation with TLB.
:::

:::{figure} images/address-translation-page-fault-case-1.png
:label: address-translation-page-fault-case-1
:width: 80%
Example of address translation with TLB (page fault).
:::


:::{figure} images/address-translation-page-fault-case-2.png
:label: address-translation-page-fault-case-2
:width: 80%
Example of address translation with TLB (update TLB and page table).
:::

:::{table} Three address translation cases. Two cache misses may now occur: on the TLB and on the memory access itself.
:label: tab-address-translation-vm

| Case | Performance | TLB | Page Table |
| :-- | :--- | :--- | :--- |
| 1 | Best | Hit ✅ | Not visited |
| 2 | Worse | Miss ❌ | Hit (Page Table Entry Valid) ✅ |
| 3 | Worst | Miss ❌ | Miss (Page Fault) ❌ |
:::

:::{hint} Quick Check

**True or False**: On a TLB data, the data is definitely in main memory.

:::

:::{note} Show Answer

**True**. Remember: The TLB caches recent page table entries. If the entry is valid in the TLB, it **must also** be valid in the page table, and the data must therefore be in memory.

::: -->