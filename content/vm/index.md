---
title: "Virtual Memory and Pages"
---

(sec-virtual-memory)=
## Learning Outcomes

* Explain the two motivations for virtual memory.
* Define virtual memory terminology: virtual address space, physical address space, virtual page number, physical page number, page offset.
* Describe the two key features of virtual memory: address translation and paged memory.
* Explain why protection between processes is needed to allow safe sharing of memory across processes.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/GxVWKgQsNBU
:width: 100%
:title: "[CS61C FA20] Lecture 29.1 - Virtual Memory I: Virtual Memory Concepts"
:::

::::


::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/0VQu0e8A8e4
:width: 100%
:title: "[CS61C FA20] Lecture 29.4 - Virtual Memory I: Paged Memory"
:::

::::

:::{warning} Review the memory hierarchy

We have defined the memory hierarchy across two sections so far:

* [Registers and Memory](#sec-memory-hierarchy-early): Assumes the CPU (with registers) accesses memory (primary storage) directly.
* [Memory Hierarchy, Revisited](#sec-memory-hierarchy): Inserts caches into the hiarchy, between the CPU and memory.

:::

In earlier sections, we have seen that caches provide fast access to recently-used portions of a program code and data. The main memory can similarly act as a "cache" for secondary storage, or lower layers of the memory hierarchy like disk (nowadays, SSD). This concept is **virtual memory**: a means of giving each process[^process] the _illusion_ of access to a full memory address space that it has completely for itself.

[^process]: A process is a currently running program.

There are two core components of virtual memory discussed in this unit. We will define the terminology as we go.

* **Translation** between **virtual addresses** and **physical addresses**.
* **Pages** as a memory unit in both virtual and physical address spaces.

## Motivations

There are two major motivations for virtual memory, which was conceived in the 1950s ([Wikipedia](https://en.wikipedia.org/wiki/Virtual_memory)). Historically, Motivation 1 below was more important. Memory has since become relatively cheap, and Motivation 2 is much more relevant today. Toggle between the tabs below.

:::::{tab-set}

::::{tab-item} Motivation 1: Limited Memory
:sync: vm-motivation-1

Virtual memory removes programming burdens of a small, limited amount of main memory. Without virtual memory, we run into situations like @fig-physical-mem-too-small.

:::{figure} images/physical-mem-too-small.png
:label: fig-physical-mem-too-small
:width: 100%
What happens if physical memory is too small?
:::

In @fig-physical-mem-too-small, main memory is 1 GiB = $2^{30}$ bytes, which is smaller than an RV32I's program address space (a 32-bit architecture, meaning $2^{32}$ bytes = 4 GiB of addressable memory). We consider a scenario where we map each of the  lower $2^{30}$ bytes of the address space onto the available $2^{30}$ bytes of physical RAM. However, accesses to higher parts of the address space (addresses above `0x0FFFFFFF`) would crash because they refer to locations that don't exist.
::::

::::{tab-item} Motivation 2: Sharing Memory
:sync: vm-motivation-2

Virtual memory allows for efficient and safe sharing of memory among several programs. Without virtual memory, we run into situations like @fig-two-programs-same-mem.

:::{figure} images/two-programs-same-mem.png
:label: fig-two-programs-same-mem
:width: 100%
:alt: "TODO"
How do two programs share the same memory?

<!-- TODO make these diagrams better. kind of light coloring-->
:::

If Program 1 stores your bank account balance @ address `0x400`, and Program 2 stores your video game score @ address `0x400`, we may optimistically hope that getting a high score of 10000 will suddenly overwrite your account balance. Virtual memory provides **protection and isolation** between processes, so that both programs can read and write to overlapping addresses without impacting each other. While getting rich quick sounds awesome, if all processes could access data at shared addresses, they could corrupt other processes and cause crashes.
::::

:::::

## Translation: Virtual Addresses and Physical Addresses

This section defines important terminology for virtual memory.

::::{warning} Assume no caches for now

Virtual memory is much easier to understand if we assume there are no caches in the memory hierarchy. This means there are at most two copies of data in the memory hierarchy: in **main memory** (primary storage) and on **disk** (secondaty storage). We will reintroduce caches in a [later section](#sec-tlb).

:::{figure} images/ignore-caches-in-hierarchy.png
:label: fig-ignore-caches-in-hierarchy
:width: 70%
:alt: "TODO"
For now, assume we have no caches between the CPU and memory.

::::

In a [previous section](#sec-address-space), we have defined the **address space** as the hypothetical range of addressable memory locations on a particular machine. Now, we update this definition to differentiate between **virtual addresses** and **physical addresses**.

* A **virtual address space** is the address space that a program uses for their memory access instructions (loads, stores, and instruction-fetching). It is the set of addresses that a user program knows about.
* The **physical address space** is the set of addresses that map to actual physical locations in main memory.
* We will call main memory **physical memory** to differentiate it from virtual memory.

Virtual memory means that when run, 32-bit programs will all use the same 4GiB address space (addresses `0x00000000` to `0xFFFFFFFF`), as shown in @fig-illusion-of-virtual-address-space. This means that virtual addresses used by separate processes may conflict and overlap (i.e., three separate processes may try to write to the virtual address `0x50000000`).

:::{figure} images/illusion-of-virtual-address-space.png
:label: fig-illusion-of-virtual-address-space
:width: 70%
:alt: "TODO"
Each 32-bit process uses **virtual addresses** to address a 32-bit **virtual address space**.
:::

**Address translation** supports protection between processes (Motivation 2). When a process provides a virtual address, a "memory manager"[^memory-manager] translates it into a **physical address**, which can then be used to access the data at a physical location in main memory. In this way, the virtual address `0x50000000` for three separate processes will map to three separate locations in physical memory.

[^memory-manager]: The "memory manager" cloud shown in @fig-translate-to-physical-address is implemented with a combination of hardware (memory controller) and software (operating system). We discuss this more in the [next section](#sec-memory-manager).

Address translation is the key to mapping virtual address spaces from different processes to the singular physical address space provided by physical memory, as shown in @fig-translate-to-physical-address.

:::{figure} images/translate-to-physical-address.png
:label: fig-translate-to-physical-address
:width: 70%
**Physical addresses** are used for the **physical address space** available on memory. For a processor to access a location in memory, a memory manager[^memory-manager] translates virtual addresses to physical addresses.
:::

(sec-paged-memory)=
## Paged Memory

To run programs larger than main memory (Motivation 1), most of the data needed for a program must live somewhere other than main memory. The address space needed to run a program is therefore stored across two layers of the memory hierarchy: **main memory** and **disk**.

Recall Jim Gray's space-time analogy of [locality](#fig-3-locality). Accessing disk is four orders of magnitude slower than accessing memory (1 ms vs. 100 ns). Any reasonable virtual memory implementation should use main memory to store temporally or spatially local data, then fetch from disk as frequently as possible. Furthermore, when disk access is needed, a sizeable chunk of data is transferred in order to reduce repeated expensive disk accesses.

The concept of **paged memory** dominates. A disk access loads an entire page into memory. The _size_ of a page should be large enough to amortize high access time (i.e., much larger than the ~128 B cache blocks and 4-8 B words). A typical page size ranges from 4-16 KiB.

There is one page size per system; this page size is used to break up both physical memory and virtual memory into pages.

:::{figure} images/paged-memory.png
:label: fig-paged-memory
:width: 70%
The virtual address space is broken up into pages. Each virtual page has a **virtual** page number, indexed from low to high.
:::

The course hive machines have 4 KiB pages, a 48-bit virtual address space,[^why-48-bit] and a 39-bit physical address space.[^why-39-bit]

```{code} bash
:label: code-hive-memory

$ cat /proc/cpuinfo
processor	: 0
...
address sizes	: 39 bits physical, 48 bits virtual

$ getconf PAGESIZE
4096
```

On the Apple M4 Chip:

```{code} bash
:label: code-m4-memory
$ sysctl -a | grep virtual    
machdep.virtual_address_size: 47

$ getconf PAGESIZE
16384
```

[^why-39-bit]: Why 39 bits physical? Based on the [Intel specifications](https://www.intel.com/content/www/us/en/products/sku/129948/intel-core-i78700t-processor-12m-cache-up-to-4-00-ghz/specifications.html), course hive machines have 128 GiB of memory, which should mean 34-bit-wide physical addresses. In practice, the physical address space does not always exactly map to the amount of physical memory because of the memory controller. Read more on [StackOverflow](https://superuser.com/questions/944080/why-does-my-cpu-only-support-32gb-ram-when-it-has-39-address-bits).

[^why-48-bit]: Why 48 bits virtual? The course hive machines are Intel x86-64, which should mean 64-bit-wide virtual addresses. Put simply 64-bit is huge, and 48-bit is good enough (address space of 256 TiB). When 64-bit pointers are used, the CPU just reads the lower 48 bits. Read more on [StackOverflow](https://stackoverflow.com/questions/6716946/why-do-x86-64-systems-have-only-a-48-bit-virtual-address-space).

Memory translation maps a Virtual Page Number (VPN) to a Physical Page Number (PPN). @fig-vpn-to-ppn illustrates the translation of 32-bit virtual addresses to 48-bit physical addresses, where the page size is 4 KiB ($= 2^{12}$ B).

:::{figure} images/vpn-to-ppn.png
:label: fig-vpn-to-ppn
:width: 80%
Each VPN maps to a PPN. Virtual pages and physical pages are the same size, so the page offset is the same.
:::

* A virtual address is decomposed into a **virtual page number (VPN)** and a **page offset**. For a 32-bit virtual address with 4 KiB pages, the VPN is the upper 20 bits and the page offset is the lower 12 bits.
* A physical address is decomposed into a **physical page number (PPN)** and a **page offset**. For a 48-bit physical address with 4 KiB pages, the PPN is the upper 28 bits and the page offset is the lower 12 bits.
* As shown in @fig-vpn-to-ppn, the address translation mechanism of virtual memory works regardless of whether physical memory is smaller _or_ larger than the virtual address space capacity.

:::{hint} Quick Check

Assume a 32-bit machine with 8GiB of RAM and 16KiB pages.
How many bits would there be for each of the following?

1. Page offset
1. Virtual page number (VPN)
1. Physical page number (PPN)

:::

:::{note} Show Answer
:class: dropdown

1. Page offset: = $\log_2$(16 KiB) = $\log_2(2^4 \times 2^{10})$ = 14 bits

1. VPN = 32 - 14 = 18 bits

1. PPN = $\log_2$(8 GiB) - 14 = $\log_2(2^3 \times 2^{30}) - 14$ = 33 - 14 = 19 bits

:::

:::{hint} Quick Check

Suppose we have a 32-bit virtual address space with 16 GiB DRAM and 4 KiB pages. True or False?

1. There are $2^{32}$ / $2^{12}$ = $2^{20}$ Virtual Page Numbers.
2. There are $2^{4} \times 2^{30} / 2^{12} = 2^{22}$ Physical Page Numbers.
3. Virtual addresses are 32-bits, where the bottom 12 bits are used to reference page offset.
4. Both the virtual page size and the physical page size are 4 KiB.
:::

:::{note} Show Answers
:class: dropdown

1. True
1. True
1. True
1. True
:::

:::{warning} Pages are the memory unit of virtual memory

On a given machine, virtual pages and physical pages are the **same size**. For a given virtual-physical address mapping, the virtual page number and physical page numbers may be different, but the virtual page offset and physical page offset are **identical**.

:::

We discuss this virtual-to-physical address translation in the [next section](#sec-vm-address-translation).
