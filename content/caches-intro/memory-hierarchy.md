---
title: "Memory Hierarchy, Principle of Locality"
---

## Learning Outcomes

* Define key components of the memory hierarchy: processor, caches, memory, disk.
* Explain how caches leverage temporal and spatial locality.
* Trace memory access with caches.
* Get familiar with key cache terminology: cache hit, cache miss, and cache line (i.e., block).

::::{note} 🎥 Lecture Video: Locality, Design, and Management
:class: dropdown

:::{iframe} https://www.youtube.com/embed/xrCp6DKazuk
:width: 100%
:title: "[CS61C FA20] Lecture 24.4 - Caches I: Locality, Design, Management"
:::

::::

::::{note} 🎥 Lecture Video: Memory Hierarchy
:class: dropdown

:::{iframe} https://www.youtube.com/embed/7Lk5UacJeYA
:width: 100%
:title: "[CS61C FA20] Lecture 24.3 - Caches I: Memory Hierarchy"
:::

::::

::::{note} 🎥 Lecture Video: Actual CPUs
:class: dropdown

:::{iframe} https://www.youtube.com/embed/isEHXkkPtE4
:width: 100%
:title: "[CS61C FA20] Lecture 27.4 - Caches IV: Actual CPUs"
:::

::::

(sec-memory-hierarchy-revisited)=
## The Memory Hierarchy, Revisited

We now continue our [earlier discussion](#sec-memory-hierarchy) of memory hierarchy. Earlier, we assumed there were only **two** layers of our memory hierarchy: registers (on the CPU) and memory (DRAM is close, but on a separate chip).

:::{embed} #fig-3-memory-hierarchy
:::

The mismatch between processor and memory speeds (the "careful tango" described [earlier](#sec-memory-hierarchy) leads us to add a new level: The **memory cache**, or cache for short. Caches are usually on the same chip as the CPU and fit into the memory hierarchy as follows:

* **Size**: Smaller than memory, but certainly larger than the 32 registers on our RISC-V processor.
* **Speed**: Use hardware that is much faster than DRAM (used for main memory), but slower than registers.
* **Cost**: Use hardware that is more expensive than DRAM.

There are additional levels lower than main memory: disk is a huge one (literally). Just as the cache contains a **copy** of a subset of data in main memory, main memory contains **copies** of data on disk.

Data moves differently between different levels of the memory hierarchy:

* **Registers and memory**: Managed by the compiler. Loads and stores move data in and out.
* **Cache and memory**: Managed by cache controller hardware. We will describe the high-level operation, but leave the implementation to a later course.
* **Memory and disk**: Managed by the operating system  and special hardware via **virtual memory**, a concept that we will discuss later.[^vm-details] Additionally managed by the programer/user via files and file streams.

[^vm-details]: For now, know that virtual memory is a virtual to physical address mapping assisted by the hardware (translation lookaside buffer, or TLB).


If useful, we revisit [Jim Gray's analogy](#sec-memory-hierarchy) of data access time on registers, on the cache, in main memory, and on disk.

:::{embed} #fig-3-locality
:::



(sec-multi-level-caches)=
### Multi-Level Caches

You may have noticed that the [memory hierarchy diagram](#fig-3-memory-hierarchy) contains multiple caches labeled Level 1, Level 2, and Level 3.  A computer can have multiple caches, where each cache is a **copy** of data from lower in the memory hierarchy.

Consider Apple's A14 bionic chip, which we introduced [earlier](#sec-intro-sds):

:::{embed} #fig-apple-a14
:::

The L1 cache is  The L2 cache is located on the integrated circuit, often adjacent to the CPU. The System Level Cache labeled in the diagram is likely a Level 3 cache, shared across multiple CPU cores.[^system-level-cache]

[^system-level-cache]: We don't discuss L3 caches much in this course. See [Wikipedia](https://en.wikipedia.org/wiki/CPU_cache).

:::{hint} IMEM and DMEM are caches!

The L1 cache is often embedded into two parts: **L1i** (instruction memory) and **L1d** (data memory). These are **precisely** the IMEM and DMEM blocks on our [RISC-V datapath](#sec-state-elements)!
:::

1. **L1 cache** (L1$[^cash-money]): Usually directly embedded on the CPU, hence why it is not labeled in the above diagram.  
    * Size: Tens or hundreds of [KiB](#sec-iec-prefixes).
    * Hit Tim (see [below](#sec-cache-terminology)): Complete in one clock cycle or less.
    * Miss rate (see [below](#sec-cache-terminology)): 1-5%
2. **L2 cache** (L2$): Located on the integrated circuit, often adjacent to the CPU.
    * Size: Tens or hundreds of MiB.
    * Hit Time: Few clock cycles
    * Miss rate: 10-20%

[^cash-money]: The notation `$` for cache is a Berkeley innovation. Not me :-)

### Demo

To find out the sizes of different components of the memory hierarchy on a Linux-based machine, we can use `df` and `sysctl`. The following commands were run on a Mac OS X machine.

To determine **disk size**, use `df`. The default display is in blocks (e.g., lines); use the `-h` option for IEC prefixes (base-two), and the `-H` option for base-10 prefixes.

```bash
$ df -h
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s1s1   460Gi    17Gi    38Gi    31%    427k  395M    0%   /
devfs            215Ki   215Ki     0Bi   100%     744     0  100%   /dev
...
$ df -H 
Filesystem        Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/disk3s1s1    494G     18G     40G    31%    427k  395M    0%   /
devfs             220k    220k      0B   100%     744     0  100%   /dev
...
```

To determine **cache size** and **memory size**, use `sysctl`. Because this command lists all attributes of the system kernel, we pipe the output through `grep` to get what we want. The default unit is bytes for memory and caches.

```bash
$ sysctl -a | grep hw.memsize
hw.memsize: 25769803776
hw.memsize_usable: 25143640064
$ sysctl -a | grep "hw.l.*size"
hw.l1icachesize: 131072
hw.l1dcachesize: 65536
hw.l2cachesize: 4194304
```

:::{exercise} Refresher on [binary and base-10 prefixes](#sec-iec-prefixes)
:label: ex-cache-size

In the above demo, what is the L2 cache size, in bytes?
* **A.** 2 MB
* **B.** 2 MiB
* **C.** 4 MB
* **D.** 4 MiB
* **E.** 4 GB
* **F.** 4 GiB
* **G.** Something else
:::

:::{solution} ex-cache-size
:label: ex-cache-size-sol
:class: dropdown

**D**.

```{math}
\begin{aligned}
4193402 \text{ B} &= 2^{(\log_2{4193402})} \text{ B} = 2^{22} \text{ B} \\
&= 4 \cdot 2^{20} \text{ B} = 4 \text{ MiB}
\end{aligned}
```
:::

## Memory Caches

Caches are the basis of the memory hierarchy.

:::{warning} Caches contain copies of data from main memory

This caveat discussed [earlier](#sec-library) is worth repeating.
:::


How do we create the illusion of a large memory that we can access fast? From P&H 5.1:

> Just as you did not need to access all the books in the library at once with equal probability, a program does not access all of its code or data at once with equal probability. Otherwise, it would be impossible to make most memory accesses fast and still have large memory in computers, just as it would be impossible for you to fit all the library books on your desk and still find what you wanted quickly.

:::{hint} Principle of locality

A cache works on the principles of **temporal and spatial locality**.

* **Temporal locality**: If an item is referenced, it will tend to be referenced soon.
* **Spatial locality**: If an item is referenced, items whose addresses are close by will tend to be referenced soon.

:::

:::{table} Principles of temporal and spatial locality.
:label: tab-locality

| Property | Temporal Locality | Spatial Locality |
| :--- | :--- | :--- |
| Idea | If we use it now, chances are that we’ll want to use it again soon. | If we use a piece of memory, chances are we’ll use the neighboring pieces soon. |
| Library Analogy | We keep a book on the desk while we check out another book. | If we check out volume 1 of a reference book, while we’re at it, we’ll also check out volume 2. Libraries put books on the same topic together on the same shelves to increase spatial locality. |
| Memory | If a memory location is referenced, then it will tend to be referenced again soon. Therefore, keep most recently accessed data items closer to the processor. | If a memory location is referenced, the locations with nearby addresses will tend to be referenced soon. Move lines consisting of contiguous words closer to the processor. |

:::

(sec-cache-terminology)=
## Key Cache Terminology

**Lines** (also called **blocks**) of data are copied from memory to the cache.

Memory is **byte-addressable**, meaning each byte in memory has a memory **address**. This is identical to our concept of memory from [earlier](#sec-address-space).

Consider how memory access works with a cache, as in @fig-von-neumann-cache.

:::{figure} images/von-neumann-cache.jpg
:label: fig-von-neumann-cache
:width: 100%
:alt: "TODO"

Caches in the [basic computer layout](#fig-von-neumann) (from an [earlier section](#sec-architecture-elements)).
:::

When a load or store instruction is accessed, memory data access is **requested**. There are two situations that can occur:

* **Cache hit**: The data you were looking for is in the cache. Retrieve the data from the cache and bring it to the processor.
* **Cache miss**: The data you were looking for is not in the cache. Go to a lower layer in the memory hierarchy to find the data, put the data in the cache. Then, bring the data to the processor.

:::{note} Example: Memory access with/without caches

Consider the load word instruction `lw t0 0(t1)`. Suppose register `t1` is `0x12F0`, and the word starting at memory address `0x12F0` is `1234`.

Memory access **without cache**:

1. Processor issues address `0x12F0` to memory
1. Memory reads `1234` @ address `0x12F0`
1. Memory sends `1234` to Processor
1. Processor loads `1234` into register `t0`

Memory access **with cache**:

1. Processor issues address `0x12F0` to cache
1. Cache checks for copy of data with address `0x12F0`

    1. (2a) If hit (finds match): cache reads `1234`
    2. (2b) If miss (no match): cache sends address `0x12F0` to Memory

        1. (2b(i)) Memory reads `1234` @ address `0x12F0`
        1. (2b(ii)) Memory sends `1234` to cache
        1. (2b(iii)) Cache replaces some line to store `1234` address `0x12F0`
1. Cache sends `1234` to Processor
1. Processor loads `1234` into register `t0`

:::


(sec-storage)=
## Storage

:::{warning} This content is not tested, but...

Understanding this section is useful for understanding your computer.
:::


::::{note} 🎥 Lecture Video: Storage
:class: dropdown

:::{iframe} https://www.youtube.com/embed/wyIVDnsG8g0
:width: 100%
:title: "[CS61C FA20] Lecture 28.1 - OS & Virtual Memory Intro: Intro"
:::

::::

Written version coming soon!

## Visuals: Locality, Design, Management
:::{figure} images/principle-of-locality-memory-hierarchy-pyramid.png
:label: fig-principle-of-locality-memory-hierarchy-pyramid-1
:width: 50%
:alt: "TODO"
The memory hierarchy.
:::

:::{figure} images/old-school-machine-diagram-layered.png
:label: fig-old-school-machine-diagram-layered
:width: 50%
:alt: "TODO"
Layers seen in machine structures.
:::

:::{figure} images/memory-access-example-q.png
:label: fig-memory-access-example-q
:width: 70%
:alt: "TODO"
Example of a memory access instruction.
:::

:::{figure} images/memory-access-q-w-cache.png
:label: fig-memory-access-q-w-cache
:width: 70%
:alt: "TODO"
Example of a memory access process with a cache.
:::

:::{figure} images/memory-access-q-wo-cache.png
:label: fig-memory-access-q-wo-cache
:width: 70%
:alt: "TODO"
Example of memory access process without cache.
:::

:::{figure} images/prefixes-for-storage.png
:label: fig-prefixes-for-storage.png
:width: 90%
:alt: "TODO"
Table depicting the prefixes we use to measure storage.
:::

:::{figure} images/temporal-vs-spatial-table.png
:label: fig-temporal-vs-spatial-table
:width: 80%
:alt: "TODO"
Different types of localities.
:::

:::{figure} images/amat-one-level.png
:label: fig-amat-one-level
:width: 60%
:alt: "TODO"
Diagram of one-level cache.
:::

:::{figure} images/amat-two-levels.png
:label: fig-amat-two-levels
:width: 60%
:alt: "TODO"
Diagram of two-level cache.
:::



<!-- 
:::{figure} images/amat-one-level.png
:label: fig-amat-one-level
:width: 60%
:alt: "TODO"
Diagram of one-level cache.
:::

:::{figure} images/amat-two-levels.png
:label: fig-amat-two-levels
:width: 60%
:alt: "TODO"
Diagram of two-level cache.
:::

:::{figure} images/apple-a14-bionic.png
:label: fig-apple-a14-bionic
:width: 50%
:alt: "TODO"
Apple A14 Bionic.
:::

:::{figure} images/comp-wo-cache.png
:label: fig-comp-wo-cache
:width: 40%
:alt: "TODO"
Memory access without cache.
:::

:::{figure} images/desktop-dimm.png
:label: fig-desktop-dimm
:width: 30%
:alt: "TODO"
Desktop/server DIMM.
:::

:::{figure} images/hdd-1.png
:label: fig-hdd-1
:width: 30%
:alt: "TODO"
Example of an HDD.
:::

:::{figure} images/hdd-2.png
:label: fig-hdd-2
:width: 30%
:alt: "TODO"
Example of an HDD.
:::
 -->

## Visuals: Memory Hierarchy
:::{figure} images/principle-of-locality-memory-hierarchy-pyramid.png
:label: fig-principle-of-locality-memory-hierarchy-pyramid-2
:width: 50%
:alt: "TODO"
The memory hierarchy.
:::