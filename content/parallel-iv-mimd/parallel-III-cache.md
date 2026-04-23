---
title: "Cache Coherency"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/tf3rSHDsevM
:width: 100%
:title: "[CS61C FA20] Lecture 35.3 - Thread-Level Parallelism III: Cache Coherency"
:::

::::

## Visuals

:::{figure} images/multiprocessor-cache.png
:label: fig-mp-cache
:width: 65%
:alt: "Multiprocessor memory system where each CPU has private caches that satisfy most loads locally, cutting traffic on the shared bus or interconnect to DRAM. Read and write arrows show hits staying on-chip while misses escalate to memory."

Multi-processor Cache to reduce bandwidth demands on main memory.
:::

:::{figure} images/cache-incoherence-read-write.png
:label: fig-cache-inco-read-write
:width: 65%
:alt: "Two-processor diagram with separate private caches referencing the same memory address but holding different values after unsynchronized writes. Directed arrows show each CPU’s read and write paths without a coherence protocol reconciling the copies, leading to inconsistent global memory order."

Read/write flow of incoherent caches between two processors.
:::

:::{figure} images/cache-incoherence-result.png
:label: fig-cache-inco-result
:width: 65%
:alt: "Outcome table illustrating values observed by each processor after conflicting writes when caches are incoherent: possible stale reads, divergent copies per core, and lack of a single serial order unless software flushes or barriers are used."

Read/write result with cache incoherence.
:::

:::{figure} images/moesi.png
:label: fig-moesi
:width: 90%
:alt: "Message-flow diagram for the MOESI protocol showing cache line states Modified, Owned, Exclusive, Shared, and Invalid, with labeled transitions for read misses, write hits, invalidations, and write-backs between processors and memory."

MOESI Cache Protocol.
:::