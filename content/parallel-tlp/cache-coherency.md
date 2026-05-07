---
title: "Cache Coherence"
---

(sec-cache-coherency)=
## Learning Outcomes

* Illustrate a shared memory multiprocessor architecture with caches.
* Define cache coherence misses.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/zSONGMSsMgM
:width: 100%
:title: "[CS61C FA20] Lecture 35.2 - Thread-Level Parallelism III: Shared Memory and Caches"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/zSONGMSsMgM
:width: 100%
:title: "[CS61C FA20] Lecture 35.2 - Thread-Level Parallelism III: Shared Memory and Caches"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/tf3rSHDsevM
:width: 100%
:title: "[CS61C FA20] Lecture 35.3 - Thread-Level Parallelism III: Cache Coherency"
:::

::::

## Shared memory multiprocessor (SMP)

Recall that in our [multicore processor architecture](#sec-mimd) we assume a shared memory model to enable multithreaded processing. This model is called a **shared memory multiprocessor** (SMP), which assume a single physical address space across all processors.[^sap]

[^sap]: Given the shared address space, a more accurate term for shared memory multiprocessor might be shared-_address_ multiprocessor. You may also see the term symmetric multiprocessor, but we digress.

Given our understanding of the [memory hierarchy](#fig-3-memory-hierarchy) and Jim Gray's space-time analogy of [locality](#fig-3-locality), memory is a performance bottleneck even with one processor. Shared memory multiprocessors use caches to reduce bandwidths on main memory, as shown in @fig-smp.

:::{figure} images/smp.png
:label: fig-smp
:width: 65%
:alt: "Shared memory multiprocessor diagram: several cores or sockets connect through a bus to a unified physical memory and optionally a shared last-level cache. One physical address space visible to all processors."

Shared-memory Multiprocessor (SMP) with multiple cores and a single, coherent memory.
:::


```{exercise}
:label: dp-05-b
5. **True/False**: Stores and loads are the only instructions that require input/output from DMEM.
```


:::{solution} dp-05-b
:label: dp-05-sol-b
:class: dropdown
**True** For all other instructions, we don’t need to read the data that is read out from DMEM, and thus don’t need to wait for the output of the MEM stage.
:::


Notes about @fig-smp:

* Each CPU has its own cache(s), e.g., an L1 cache.
* All CPUs communicate with each other and memory through a communication **bus**.
* One bank of memory (DRAM) is shared by all CPUs.

## Cache Coherence Problem

In a [different section](#sec-locks), we discuss how threads running on multiple processors can use locks to synchronize access to shared data across processors. In this section, we discuss an additional problem that arises when we introduce caching: **cache coherence**.

Consider three example memory accesses on a dual-core system. Assume the word `20` is initially in memory @ address `0x5000` , and we perform three memory accesses:

1. CPU 1 **reads** word @ address `0x5000`.
1. CPU 2 **reads** word @ address `0x5000`.
1. CPU 1 **writes** word `40` @ address `0x5000`

@fig-cache-coherence-1 shows that accesses 1 and 2, which are reads, trigger compulsory cache misses in both CPU 1's and CPU 2's caches. The two caches must request the corresponding block from memory, via the communication bus. Each processor gets a copy of this block (and therefore a copy of the word @ address `0x5000`) and stores the block on their own cache.

CPU 2 reads Mem[0x5000]
:::{figure} images/cache-coherence-1.png
:label: fig-cache-coherence-1
:width: 70%
:alt: "Visual description of a dual-core SMP system. The SMP system diagram illustrates several cores or sockets connect through a shared bus to a unified physical memory and to I/O. There are four directed arrows between each CPU's cache and the shared memory unit to show the bus access for the two memory accesses: (1) CPU 1 **reads** word @ address `0x5000`, and (2) CPU 2 **reads** word @ address `0x5000`. One set of arrows is labeled request (cache via bus to memory); the other set is labeled response (memory via bus to cache). CPU Each CPU cache has a copy of the word `20` at memory address `0x5000`.

CPU 1 and CPU 2 both read a word @ address `0x5000`. If both caches are cold, these two memory accesses are compulsory cache misses, and the value must be retrieved from shared memory via the shared bus.
:::

The issue is revealed with @fig-cache-coherence-2, which illustrates access 3, which is a write. When CPU 1 performed a write, CPU 1’s cache was up-to-date, but CPU 2’s cache is now stale, and it doesn’t know.

:::{figure} images/cache-coherence-2.png
:label: fig-cache-coherence-2
:width: 70%
:alt: "Dual-core SMP system, continued. Next, CPU 1 performs a memory write to word `40` @ address `0x5000`. Now, CPU 1's cache has a copy of the word `40` at memory address `0x5000`, but CPU 2's cache still has the word `20` at memory address `0x5000`."

CPU 1 performs a memory write to word `40` @ address `0x5000`. In a non-cache coherent system, CPU 1 and CPU 2 now have different copies of the same region of memory.
:::

The last access in our example illustrates that this system is **not cache coherent**. From [Wikipedia](https://en.wikipedia.org/wiki/Cache_coherence):

> In a cache coherent system, if multiple clients have a cached copy of the same region of a shared memory resource, all copies are the same.

P&H defines cache coherence as the aspect that defines _what values_ can be returned by a read. There must be a way of enforcing the "coherency" implied by the phrase: "all copies are the same." We do so using an additional type of cache miss.

## Coherence Miss

:::{note} Review [cache misses](#sec-cache-misses)

So far, we have discussed three types of cache misses: compulsory miss, capacity miss, and conflict miss.
:::

To enforce cache coherence, we introduce a _fourth_ type of cache miss: a **coherence miss**, e.g., a communication miss caused by writes to shared data made by other processors.

Such misses are commonly part of **cache coherence protocols**, which are means of maintaining coherence for multiple processors. For example, a protocol can ensure that a processor has "exclusive access" to a data item by invalidating copies in other caches on a write. Subsequently, a processor that reads (or writes) to an invalidated copy then misses in the cache; this miss is categorized as a coherence miss.

## Snooping Protocols

:::{warning} This section is out of scope

For more information, read P&H 5.10.

:::

One version of the _write invalidate_ cache coherence protocol described above is a **snooping protocol**. When any processor accesses memory, use the bus to "snoop"[^snoop] and notify other processors.

[^snoop]: From [Merriam-Webster](https://www.merriam-webster.com/dictionary/snoop): to look or pry especially in a sneaking or meddlesome manner.

Each cache controller “snoops” for write transactions on the common bus.
On another processor's block request to the bus, check if one's own cache has a copy.

* If a copy exists, and the request is a read, do nothing.
* If a copy exists and the request is a write, then invalidate one's own cache's copy.
* If a copy does not exist, do nothing.

This snooping protocol permits many processors to have copies of data that are only read, and permits a processor that is writing to have an exclusive copy of the data (because other copies are invalidated).

### Details

:::{warning} This section is really out of scope

For more information, take an advanced computer architecture course.

:::

**MOESI** is a full cache coherence protocol that describes the states in other cache protocols: Modified Owned Exclusive Shared Invalid.

For each block in a cache, track state:

* **Shared**:  up-to-date data, other caches may have a copy
* **Modified**: up-to-date data, changed (dirty), no other cache has a copy, OK to write, memory out-of-date (i.e., write back)
* **Invalid**: not in cache (from before: valid flag)

Two enhancements:

* **Exclusive**: up-to-date data, no other cache has a copy, OK to write, memory up-to-date. Avoids writing to memory if block replaced, and supplies data on read instead of going to memory.

* **Owner**:  up-to-date data, other caches may have a copy (they must be in Shared state). This cache is one of several with a valid copy of the cache line, but has the exclusive right to make changes to it. It must broadcast those changes to all other caches sharing the line. The introduction of owned state allows dirty sharing of data, i.e., a modified cache block can be moved around various caches without updating main memory. The cache line may be changed to the Modified state after invalidating all shared copies, or changed to the Shared state by writing the modifications back to main memory. Owned cache lines must respond to a snoop request with data.

UC Berkeley has explored various snooping[^snoopy] protocols; see an advanced computer architecture course for more information.

[^snoopy]: Sometimes you will see snooping protocols called Snoopy Protocols and snooping buses called Snoopy Buses, like the [Peanuts](https://en.wikipedia.org/wiki/Peanuts) character. [source](https://people.eecs.berkeley.edu/~pattrsn/252F96/Lecture18.pdf)