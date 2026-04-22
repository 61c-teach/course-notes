---
title: "VM Performance"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/TO_oTALe3KM
:width: 100%
:title: "[CS61C FA20] Lecture 30.4 - Virtual Memory II: VM Performance"
:::

::::

## Visuals
:::{figure} images/cache-vs-vm.png
:label: fig-cache-vs-vm
:width: 80%
Cache vs VM.
:::

:::{table} Terminology for caches and virtual memory.

| Feature | Caches (SRAM to DRAM) | Virtual Memory (DRAM to Disk) |
| :--- | :--- | :--- |
| **In Memory Hierarchy** | Caches ↔ Memory | Memory ↔ Disk |
| **Memory Unit** | Line or Block (~64 bytes) | Page (~4096 bytes) |
| **Miss Event** | Cache Miss | Page Fault |
| **Associativity** | Direct-mapped, N-way set associative, fully associative | Fully associative (pages can go anywhere in memory) |
| **Replacement Policy** | Least-recently-used (LRU) or random | LRU (most common), FIFO, or random |
| **Write Policy** | Write-through or write-back | Write-back |

:::

:::{figure} images/wasteful-paging.png
:label: fig-wasteful-paging
:width: 60%
How do we deal with unused pages?
:::

:::{figure} images/demand-paging-less-wasteful.png
:label: fig-demand-paging-less-wasteful
:width: 60%
We use demand paging.
:::



:::{table} Extending @tab-address-translation-vm to include data in the cache.
:label: tab-address-translation-vm-cache

| Case | Performance | TLB | Page Table | Cache |
| :-- | :--- | :--- | :--- |
| 1 | Best | Hit ✅ | Not visited | Hit |
| 1 | OK | Hit | Not visited | Miss |
| 2 | Worse | Miss ❌ | Hit (Page Table Entry Valid) ✅ | Hit |
| 2 | Worse | Miss ❌ | Hit (Page Table Entry Valid) ✅ | Hit |
| 3 | Worst | Miss ❌ | Miss (Page Fault) ❌ |
:::