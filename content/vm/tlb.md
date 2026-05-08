---
title: "The Translation Lookaside Buffer"
short_title: "The TLB"
---

(sec-tlb)=
## Learning Outcomes

* Identify the two accesses to memory hierarchy systems in virtual memory systems: address translation and data access.
* Describe the TLB and its use. List reasonable parameters for the TLB.
* Define a page table walk.
* Compare address translation performance with the TLB.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/FAonDF1VgUQ
:width: 100%
:title: "[CS61C FA20] Lecture 30.2 - Virtual Memory II: Translation Lookaside Buffers (TLB)"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/eVIsejli9hU
:width: 100%
:title: "[CS61C FA20] Lecture 30.3 - Virtual Memory II: TLBs in Datapath"
:::

::::


Consider the [address translation](#block-address-translation) discussed in an [earlier section](#sec-vm-address-translation). If we have a 1-MiB page table and a 128-KiB L1 cache, the page table must be stored in memory, not in the cache.

:::{warning} Accessing the memory hierarchy
:class: block-vm-two-mem-access

With virtual memory, a single load (or store) instruction requires **two accesses** to the memory hierarchy:

1. **Address translation**. Translate to the virtual address to a physical address by looking up the corresponding physical page number.

1. **Data access**: Read (or write) the physical page in main memory.

**Designing for performance**: A good design of a virtual memory system should be fast (~1 clock cycle) and space efficient. Every instruction/data access needs address translation.

:::

## Page Table Walks

At present, we must perform a **page table walk**, meaning we must access the page table to get the physical page number for address translation.[^page-table-walk] Remember that the current process's page table is located main memory. Because page tables are located in memory (@fig-page-table-process-access, then we must access main memory **twice**. This takes several hundred cycles!

[^page-table-walk]: The "walk" terminology makes more sense with hierarchical page tables, where multiple levels of page tables are accessed on each address translation. Hierarchical page tables are out of scope for this course.

:::{figure} images/page-table-process-access.png
:label: fig-page-table-process-access
:width: 80%

In address translation, there can be two access to memory on every load or store instruction.
:::

To minimize performance penalty, we have two options for speed-up that leverage the **cache**:

1. **Address translation**: Use a cache for frequently or recently used page table entries.
1. **Data access**: Copy blocks from main memory to the cache.

To address the latter, see our unit on [caches](#sec-cache-terminology) and our [next section](#sec-pipt). To address the former, in this section we introduce the **translation lookaside buffer**.

## The Translation Lookaside Buffer

The **translation lookaside buffer** (TLB), or **translation buffer**,  caches address translations, i.e., VPN-PPN mappings. It is usually separate hardware from memory caches and (like memory caches) is stored close to the CPU.

As shown in @fig-tlb-page-table, the TLB stores a subset of address translations for the current process's page table. The TLB leverages locality and stores recently accessed translations.

:::{figure} images/tlb-page-table.png
:label: fig-tlb-page-table
:width: 100%
The Translation Lookaside Buffer (TLB) stores a subset of address translations.
:::

:::{hint} Quick Check

**True or False?** The TLB is a type of cache.

:::

:::{note} Show Explanation
:class: dropdown

**True**. The TLB is (conceptually) a cache because it stores a **subset** of information located in a lower level of the memory hierarchy. Here, the information a TLB stores is a subset of VPN-PPN translations in the page table (unlike memory caches, which store a subset of data in main memory).

:::

The **TLB Reach** is the number of virtual addresses can get immediately translated by the TLB. In other words, it is the size of the largest possible (disjoint) virtual address space that can be determined by the given entries in the TLB:

```{math}
\text{TLB reach} = \text{\# TLB entries} \times \text{Page size}
```

If the TLB "hits," then no page table walk occurs, meaning we avoid accessing memory on address translation. Common TLB design:

* 38-128 entries
* [Fully associative](#sec-fully-associative-policy), [^tlb-tio] which increases TLB reach by minimizing conflicting entries.
* FIFO or random replacement policy

[^tlb-tio]: In this course, we will assume that the TLB is fully associative. However, in practice, some TLB designs are set associative. In these cases, a Virtual Page Number is split into a TLB tag and a TLB index: the latter is used to determine the index of set; the former is used to determine a matching way within the set. This low-associativity TLB design can support other optimizations in address translation; see P&H _Computer Architecture_ and later courses for details.

:::{warning} One TLB per core
:label: block-tlb-flush

There is just one TLB per core ("the" TLB), but there is one page table per process. Recall that multiple processes can run concurrently via OS [context switches](#sec-context-switch). How can the TLB be efficiently used by different processes?

**Simple**: When the OS performs a context switch to run a different process, the OS flushes all of the TLB by invalidating its entries. This approach keeps the TLB hardware simple. However, after a context switch, the currently running process will need to repopulate the TLB, which will incur misses due to address translation.

**More complicated**: The TLB could also keep track of the process ID (PID) corresponding to each TLB entry. During address translation, both the process ID and the virtual page number must be checked against the corresponding values in a TLB entry. This complicates hardware. However, fewer TLB misses may be incurred on a process context switch, since the TLB no longer flushed.
:::

## Address Translation with the TLB



We have now introduced one type of "cache" into our virtual memory system: the TLB. This efficiency speeds up address translation, which is the first of the two accesses to the memory hierarchy.

Let us focus on the performance of the address translation by considering the toy scenario in @fig-tlb-case0-setup. Note that there is **no memory cache**, i.e., all data accesses must go to memory.

:::{figure} images/tlb-case0-setup.png
:label: fig-tlb-case0-setup

Memory hierarchy layout for this scenario. The page tables and a subset of pages for both processes (firefox and intellij) are stored in memory. Other pages are on disk. There is a TLB. There is no memory cache.
:::

Firefox, the currently active process, requests data @ address `0x00004ABC`:

* The virtual page number (VPN) associated with this virtual address is `4`.
* The physical page number (PPN) is `0x8C121D`.
* The physical address of the data is `0x8C121DABC` on the page with base address `0x8C121D000`.
* The data is orange (assume orange fits in, say, a memory word).

Let us compare three cases for translating the requested virtual address.[^tlb-case0] Toggle the tabs.

[^tlb-case0]: The TLB in our scenario keeps track of the PID corresponding to each TLB entry. In @fig-tlb-case1-tlb-hit and related figures, the grayed out entry has the PID of intellij; other entries all have the PID of firefox (the currently running process).

:::::{tab-set}

::::{tab-item} Case 1: TLB Hit
:sync: tlb-case1

1. The requested VPN is in the TLB (e.g., it was recently accessed), so we retrieve the PPN from the TLB entry and translating the resulting physical address.

Address translation accesses just the TLB and is close to instant, [on the order](#fig-3-locality) of a clock cycle.

:::{figure} images/tlb-case1-tlb-hit.png
:label: fig-tlb-case1-tlb-hit

Case 1 is the best-case scenario: A TLB hit. Because the corresponding physical page is available in the TLB, no memory access is needed for address translation.
:::

::::

::::{tab-item} Case 2: TLB Miss, Page in Memory
:sync: tlb-case2

1. The requested VPN is not in the TLB, so we perform a **page table walk** to access the current process's page table.
1. The page table entry for VPN 4 is accessed; it is valid, so we retrieve the PPN from the page table entry and translating the resulting physical address.
1. Before moving to the data access step, update the TLB. The page table entry for VPN 4 is inserted into the TLB (replacing an older entry) and marked with the current process PID.

Address translation accesses the TLB and memory and therefore takes [on the order](#fig-3-locality) of a hundred clock cycles.

:::{figure} images/tlb-case2-tlb-miss.png
:label: fig-tlb-case2-tlb-miss

Case 2 is a slightly worse scenario: A TLB miss. However, because the physical page is in memory, the page table entry is valid. Access to main memory is needed for address translation.

:::

:::{figure} images/tlb-case2-pt-walk.png
:label: fig-tlb-case2-pt-walk

Case 2: Before moving to the data access step, update the TLB with the most recent translation (this one).
:::

::::

::::{tab-item} Case 3: Page Fault
:sync: tlb-case3

1. The requested VPN is not in the TLB, so we perform a **page table walk** to access the current process's page table.
1. The page table entry for VPN 4 is accessed; it is **not valid**. Trigger a **page fault exception**.
1. The OS intervenes and requests the page from disk. It also performs a context switch to the another process while this process waits.
1. The page is loaded from disk into a physical page in memory. The page table entry for VPN 4 is updated with the PPN of the newly updated physical page, and mark the entry valid.
1. The page table entry for VPN 4 is accessed; it is valid, so we retrieve the PPN from the page table entry and translating the resulting physical address.
1. Before moving to the data access step, update the TLB. The page table entry for VPN 4 is inserted into the TLB (replacing an older entry) and marked with the current process PID.[^detail]

[^detail]: Imagine that during the context switch, the other process does not update any pages in the TLB. This is unlikely, but our toy scenario is contrived for simplicity.


Address translation accesses the TLB, memory, and disk and therefore takes [on the order](#fig-3-locality) of a thousand clock cycles.


:::{figure} images/tlb-case3-page-fault.png
:label: fig-tlb-case3-page-fault

Case 3 is the worst-case scenario: A page fault. The physical page is not in memory, the page table walk does not yield a valid page table entry, and disk access is needed. Access to disk is needed for address translation. Access to main memory is needed for address translation.

:::

:::{figure} images/tlb-case3-update.png
:label: fig-tlb-case3-update

Case 3: When the disk is copied in from memory, the corresponding page table entry will be updated with the translation. Before moving to the data access step, update the TLB with the most recent translation (this one).
:::
::::

:::::

:::{table} Three address translation cases.
:label: tab-address-translation-vm

| Case | Performance | TLB | Page Table (in Memory) | Disk |
| :-- | :--- | :--- | :--- | :--- |
| 1 | Best (~1 cycle, TLB) | Hit ✅ | Not visited | Not visited |
| 2 | Worse (~100 cycles, memory) | Miss ❌ | Hit (Page Table Entry Valid) ✅ | Not visited |
| 3 | Worst (~1000 cycles, disk) | Miss ❌ | Miss (Page Fault) ❌ | Visited ✅ |

:::

:::{hint} Quick Check

**True or False**: On a TLB "hit", the data is definitely in main memory.

:::

:::{note} Show Answer
:class: dropdown

**True**. Remember: The TLB caches recent page table entries. If the entry is valid in the TLB, it **must also** be valid in the page table, and the data must therefore be in memory.

:::

Finally, let's put it all together by including memory caches to speed up data access. Let's go!