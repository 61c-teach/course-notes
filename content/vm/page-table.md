---
title: "Page Table Design"
---

(sec-page-table)=
## Learning Outcomes

* Describe virtual memory system design: placement policy, replacement policy, and write policy.
* Describe how virtual memory implements protection.
* Describe status bits tracked for page table entries.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Rc73MpGzZuM
:width: 100%
:title: "[CS61C FA20] Lecture 29.5 - Virtual Memory I: Page Faults"
:::

::::

## Virtual Memory System Design

Recall that when we introduced caches in an [earlier section](#sec-cache-terminology), we extensively discussed design tradeoffs. Physical memory is just another layer of the memory hierarchy—where now, memory is a "cache" for disk. We revisit therefore revisit the design questions below, now for our virtual memory system:

(sec-vm-design-policy)=
:::{note} Virtual Memory design policies

We update the [cache design questions](#sec-cache-design-policy) below with the terminology for virtual memory.

1. **Placement policy**: Where can a {del}`block` _page_ be placed in {del}`the cache` _memory_? Which {del}`cache entry` _physical page number_ can this {del}`block` _page_ be associated with?
1. **Identification**: How is a {del}`block` _page_ found if it is in {del}`the cache` _memory_? {del}`Identification is closely tied with placement policy.`
1. **Replacement policy**: Which {del}`block` _page_ should be replaced on a {del}`miss` _page fault_?
1. **Write policy**: What happens on a write?
:::

:::{warning} Minimize page faults

We can calculate a "miss rate" for virtual memory: the rate of page faults per memory access. The most expensive cost to a page fault is time: the cost of one disk access.

The overarching goal of virtual memory design is to minimize page faults.

:::

:::{tip} Try It Yourself

Review design tradeoffs for caches:

* [Associativity](#sec-cache-associativity) (placement policy)
* [Replacement policy](#tab-cache-replacement)
* [Write policy](#tab-cache-write)

Then, expand the explanations below.

:::

:::{note} Page Placement Policy
:class: dropdown
Most virtual memory systems opt for minimizing this cost and thus allow pages to be placed _anywhere_ in main memory.

Using the terminology of [cache associativity](#sec-cache-associativity), this page placement strategy is fully associative. The cost of this policy is minimal compared to the cost of a page fault becuase (1) disk access dominates the penalty of time, and (2) the placement algorithm is determined in software, not hardware (see the ["memory manager"](#sec-memory-manager)).

:::

:::{note} Page Identification
:class: dropdown

A page's location is determined by accessing the page table for the physical page number. See the two cases discussed in this section.
:::

:::{note} Page Replacement Policy
:class: dropdown
Almost all virtual memory systems try to replace the **least recently (LRU)**[^lru] page to maximize temporal locality. As mentioned earlier, the overriding guideline is to minimize page faults. Relative to the cost of a page fault, the cost of software and hardware to maintaining data for least recently used pages is small.

[^lru]: To be precise, from _Computer Architecture_, Appendix B: "many processors provide a _use bit_ or _reference bit_, which is logically set whenever a page is accessed. ... The operating system periodically clears the use bits and later records them so it caan determine which pages were touched during a time period. By keeping track in this way, the operating system can select a page that is among the least recently reference."
:::

:::{note} Write Policy
:class: dropdown

The write strategy for virtual memory systems is always **write-back**. We probably sound like a broken {del}`disk` record at this point, but just once more for good measure: disk accesses are _expensive_. Write-through policies, which access disk on every write, are infeasible.

:::

## Page Table Details

In this section, we expand on the brief description of the page table from an [earlier section](#sec-vm-address-translation) on address translation:

:::{note} Page Tables, in Brief
:label: block-page-table-brief

A page table keeps tracks of the VPN-to-PPN mappings for a given process. There is one page table per process.

* Each entry in a page table corresponds to a virtual page number (VPN) for this process.
* If a page is in memory, the entry is valid and has the corresponding physical page number. Otherwise, it may have garbage, and accessing this entry should trigger a page fault.

In this course, the number of entries in a process's page table is equivalent to the total number of virtual pages for the process.[^hierarchical-pt]

[^hierarchical-pt]: We assume a single-level page table hierarchy in this course. In practice, multi-level (hierarchical) page tables are used to reduce the size of the page table. Read more in the [extra section](#sec-hierarchical-page-table).
:::

Consider the page table layout in @fig-page-table. The page table is effectively "one giant array" with **one entry per virtual page number**. A **valid** entry means that the page is in memory, and each valid entry has a physical page number that can be used to construct a physical address on memory access. Each entry also has status bits, which we discuss below.

:::{figure} images/page-table.png
:label: fig-page-table
:width: 65%
Each process has a page table.
:::

:::{warning} Page Table Sizes

In this course, the number of entries in a process's page table is equivalent to the total number of virtual pages for the process.

:::

:::{hint} Quick Check

**True or False?** A page table is a type of cache.

:::

:::{note} Show Answer
:class: dropdown

**False**. A page table is a lookup table, **not** a cache.

Recall from an [earlier section](#sec-memory-hierarchy) that caches contain **copies of a subset of data** from a lower layer of the memory hierarchy. A page table does not satisfy this definition for multiple reasons.

* An entry in the page table contains an **address** translation; it does **not** contain (program) data.
* There is one entry in the page table for every single virtual page number. The page table is the set of possible translations itself; it is not a strict subset.

:::

:::{hint} Quick Check

Suppose that a process has a 32-bit address space. If pages are 16 KiB in size, and page table entries are 4 B (i.e., to store a physical page number and status bits):

1. What is the total size of the page table?
1. If the L1 cache is 128 KiB, can the page table fit in the cache?

:::

:::{note} Show Answer
:class: dropdown

1. If pages are 16 KiB = $2^{4}2^{10}$ B in size, then the virtual page number and page offset occupy the upper 18 bits and lower 14 bits, respectively, of the virtual address.

    Our assumption in this course is that there is one page table entry for each and every virtual page number. The total page table size is then $2^{18} \cdot 4 B$ = $2^{20}$ B = 1 MiB.

1. The page table is too big, so it cannot fit in the cache. The page table must be stored in memory!
:::

:::{warning} Page Table Sizes, in Practice

The size of a page table can be quite costly. In our previous example, a 1 MiB page table would occupy 64 pages of size 16 KiB—even if the process is just starting out and no data pages have been loaded!

In practice, **multi-level (hierarchical) page tables** are used to reduce the size of the page table. Read more in the [extra section](#sec-hierarchical-page-table).
:::

## Implementing Protection with Virtual Memory

Each running process has a dedicated page table. In @fig-page-table-process-share, there are three processes that are currently running (either currently running on the processor, or waiting to be run and completed). Each process has a separate page table, and each valid page table entry maps a virtual page from the process to a physical page in memory.

:::{figure} images/page-table-process-share.png
:label: fig-page-table-process-share
:width: 100%

Three processes each have a page table, where valid entries in the page table map to different pages in physical memory. Processes can share physical pages using a [write protection](#sec-vm-write-protection) mechanism.
:::

Remember that a key motivation for virtual memory is to allow **safe** sharing of a single main memory by multiple processes. We highlight key mechanisms of memory protection:[^wiki]

1. The flexible placement policy of virtual memory systems means that physical pages allocated to a process do not have to be allocated in order on memory. The mapping is intentionally determined by the "memory manager" (i.e., [OS](#sec-memory-manager)), which organizes page tables so that all virtual pages that should _not_ be shared between processes are mapped to disjoint physical pages.
1. We also see in @fig-page-table-process-share that some processes can share physical pages. The [write protection bit](#sec-vm-write-protection) (write access bit) in page table entries can enable limited sharing of data between two processes.
1. Portions of physical memory can be marked as _protected_ address space, accessible only by the supervisor mode of the [OS](#sec-memory-manager). Page tables are placed in this protected address space to ensure that user processes cannot modify any page tables (including its own).

[^wiki]: Read more about memory protection on [Wikipedia](https://en.wikipedia.org/wiki/Memory_protection).

:::{warning} There is one page table per process
:label: block-ptbr

Multiple page tables can be stored in memory (in protected address space), but only one process can run on a core at any given time. To determine the current page table, the CPU has a special register called the **page table base register**[^rv-sptbr-satp] that stores the starting physical address of the current process's page table.

[^rv-sptbr-satp]: In earlier versions of RISC-V, the page table base register was called the SPTBR ("S" for "Supervisor"). V1.10 updates the name to SATP (Supervisor Address Translation and Protection). See [Volume II: RISC-V Privileged ISA Specification](https://docs.riscv.org/reference/isa/priv/priv-preface.html).

:::

## Status Bits

Page table status bits (1) implement various choices in virtual memory design, and (2) provide process isolation.

### Valid Bit

Page table entries track a **valid bit** to indicate if the page is in memory (DRAM) or only on disk. On each memory access, first check if page table entry is valid.

* If the valid bit is **set** (on), then the page is in memory. The entry's physical page number can be read and used in address translation.
* If the valid bit is **not set** (off), then the page is on disk. A [page fault exception](#sec-memory-manager) is triggered. After some time, the page is copied from disk into in memory. Because the page is now in physical memory, the corresponding page table entry (for the page's virtual page number) is updated with the physical page number and valid bit set.

### Dirty Bit

Virtual systems implement a write-back policy, and most do so by tracking a dirty bit. When a page is replaced, check the dirty bit in its page table entry.

* If the dirty bit is **set**, write the outgoing page back to disk.
* If the dirty bit is **not set**, do not perform a disk write.

In a [demand paging](#sec-demand-paging) system, newly created page tables have all valid bits unset (off).

(sec-vm-write-protection)=
### Write Protection Bit

Address translation is a feature that allows multiple programs to easily share memory, e.g., if they have the same `<stdlib.h>` library code. To do so, direct two processes to the same physical page by setting the corresponding entry in each page table.

An example is shown in @fig-page-table-process-share. The first entry in the orange page table and the last entry in the green page table share entries. In this way, the two processes can have different virtual page numbers for the same physical page in memory.

The **write protection bit**, also known as **write access bit**, can protect a page from being written. This enables processes to share information in a limited way. From P&H 5.7: "To allow another process, say, P1, to read a page owned by process P2, P2 would ask the OS to crate a page table entry for a virtual page in P1's address space that points to the same physical page that P2 wants to share. The OS could use the write protection bit to proevent P1 from writing the data, if that was P2's wish." Common write-protection applications are library code, system data, etc.

If a process violates the write protection policy by attempting to write to a protected page, an OS exception is triggered. Read more about the "memory manager" in [this section](#sec-memory-manager).

(sec-hierarchical-page-table)=
## Hierarchical Page Tables

:::{warning} This content is not tested

Watch the lecture video below. See CS 152 and CS 152 for more details, or these [Cornell CS4410 Summer 2017 lecture notes](https://www.cs.cornell.edu/courses/cs4410/2017su/):

* [Hierarchical page tables](https://www.cs.cornell.edu/courses/cs4410/2017su/lectures/lec11-pagetable.html), where we page the page table
* [Inverted page tables](https://www.cs.cornell.edu/courses/cs4410/2017su/lectures/lec12-ipt.html). The name is a bit of a misnomer, but each entry corresponds to a physical page location (and thereby the size of the inverted page table is the total possible number of physical pages in memory). Hash the virtual page number and process ID to determine the possible set of physical pages.
:::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/GProRp1gjj0
:width: 100%
:title: "[CS61C FA20] Lecture 30.1 - Virtual Memory II: Hierarchical Page Tables"
:::

::::