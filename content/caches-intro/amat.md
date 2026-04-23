---
title: "Average Memory Access Time (AMAT)"
short_title: "Average Memory Access Time"
---

## Learning Outcomes

* Define hit rate, hit time, miss rate, and miss penalty.
* Use the average memory access time (AMAT) formula to compare multi-level cache designs.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/pCZUG0TzwjE
:width: 100%
:title: "[CS61C FA20] Lecture 27.3 - Caches IV: Average Memory Access Time (AMAT)"
:::

::::

Because performance is the major reason for a memory hierarchy, it is important to measure the time to service hits or misses. We therefore define the following terminology in @tab-cache-terminology:

:::{table} Key cache terminology
:label: tab-cache-terminology

| Request Outcome | Rate | Time |
| :-- | :-- | :-- |
| **Cache Hit** | **Hit rate**: fraction of access that hit in the cache. | **Hit time**: time (latency) to access cache memory, including the time needed to determine whether the access is a hit or a miss. |
| **Cache miss** | **Miss rate**: 1 - hit rate. | **Miss penalty**: Time to replace a line with the corresponding line from a lower level of the memory hierarchy.|
:::

Because the cache is smaller and built using faster memory parts, the hit time will be much smaller than the miss penalty, which includes the time to access the next level in the hierarchy.

(sec-amat)=
## Average Memory Access Time

The time to access data for both hits and misses affects performance. Designers sometimes use **average memory access time** (AMAT) as a way to compare cache designs. From P&H 5.4:

> Average memory access time is the average time to access memory considering both hits and misses and the frequency of different accesses.

```{math}
:label: eq-amat
:enumerated: true

\text{AMAT} = \text{Hit Time} + \text{Miss Rate} \times \text{Miss Penalty}
```

We will use the following assumptions in this course:

* On a **cache miss**, the total time to retrieve data is the sum of hit time **plus** miss penalty.
* The miss rate of a lower-level cache (e.g., L2) is the fraction of misses from a higher-level cache (e.g., L1) that _also_ miss in this lower-level cache.

::::{exercise} L1 cache only
:label: ex-amat-l1-only

Consider a memory hierarchy design in @fig-amat-l1-only:

:::{figure} images/amat-l1-only.png
:label: fig-amat-l1-only
:width: 80%
:alt: "Rectangle representing CPU with L1 cache and processor. Blue arrows show the processor accessing L1 cache and the return from L1 cache on a hit. A second rectangle on the right shows DRAM, connected to the L1 cache inside the CPU with a green access arrow when there is a miss from L1 cache, including the return arrow incurring the miss penalty for accessing outside the CPU box."

Memory hierarchy with only one L1 cache.
:::

Cache performance attributes:

* L1 Hit Time = 1 cycle
* L1 Miss rate = 5%
* L1 Miss penalty = 200 cycles

What is the Average Memory Access Time, in cycles?
::::

::::{solution} ex-amat-l1-only
:label: ex-amat-l1-only-sol

Using Equation @eq-amat:

:::{math}
\begin{aligned}
\text{AMAT} &= \text{L1 Hit Time} + \text{L1 Miss Rate} \times \text{L1 Miss Penalty} \\
&= 1 + 0.05 \cdot 200 \\
&= 11 \text{ cycles} \\
\end{aligned}
:::

When the miss penalty is incurred, we _still incur round-trip hit time_. @fig-amat-l1-only-tree illustrates the two cases.

:::{figure} images/amat-l1-only-tree.png
:label: fig-amat-l1-only-tree
:width: 40%
:alt: "Probability tree for L1-only cache with AMAT calculation for both hit and miss branches and their cycle costs."

Single-layer cache performance analysis. 95% of the time, we incur 1 cycle delay to access the L1 cache. 5% of time, we incur 201 cycles of delay (to access the L1 cache and to access memory).
:::

::::

::::{exercise} L1 and L2 cache
:label: ex-amat-l1-l2

Now, consider inserting an L2 cache into the hierarchy, as shown in @fig-amat-l1-l2:

:::{figure} images/amat-l1-l2.png
:label: fig-amat-l1-l2
:width: 100%
:alt: "Two-level memory hierarchy diagram with rectangles for CPU with internal L1 cache, L2 cache, and main memory (DRAM). Access arrows show an access of L1 cache with L1 hit time between processor and L1 cache, an access of L2 cache with L2 hit time between L1 and L2 caches, and an access of DRAM with miss penalty between DRAM and L2 cache."
Memory hierarchy with an L1 cache and an L2 cache.
:::

Cache performance attributes:

* L1 Hit Time = 1 cycle
* L1 Miss rate = 5%
* L2 Hit Time = 5 cycles
* L2 Miss rate = 15%
* L2 Miss penalty = 200 cycles

What is the Average Memory Access Time, in cycles?

::::

::::{solution} ex-amat-l1-l2
:label: ex-amat-l1-l2-sol

Based on [AMAT assumptions](#sec-amat), the miss rate of the L2 cache is the fraction of misses from the L1 cache that _also_ miss in the L2 cache.

We can use Equation @eq-amat recursively:

```{math}
\begin{aligned}
\text{AMAT} &= \text{L1 Hit Time} + \text{L1 Miss Rate} \times \text{L1 Average Miss Penalty} \\
&= \text{L1 Hit Time} + \text{L1 Miss Rate} \times \bigl(\text{L2 Hit Time} + \text{L2 Miss Rate} \times \text{L2 Miss Penalty}\bigr) \\
&= \text{L1 Hit Time} + \text{L1 Miss Rate} \times \bigl(5 + 0.15 \cdot 200\bigr) \\
&= 1 + 0.05 \cdot 35 \\
&= 2.75 \text{ cycles} \\
\end{aligned}
```

Now, L1 miss penalty includes both the L2-hit case and the L2-miss case, as shown in @fig-amat-l1-l2-tree.

:::{figure} images/amat-l1-l2-tree.png
:label: fig-amat-l1-l2-tree
:width: 65%
:alt: "Two-level AMAT probability tree splitting on L1 hit-miss with 95% hit rate, and then L2 hit-miss outcomes with 85% hit rate. The tree also calculates delay times from accessing caches."

Two-layer cache performance analysis. 95% of the time, we incur 1 cycle delay to access the L1 cache. 5% of the time, we miss the L1 cache. Of this L1 miss scenario, 85% of the time we incur 6 cycles of delay (to access both the L1 and L2 cache). 15% of the time we incur 206 cycles of delay (to access the L1 cache, the L2 cache, and memory).
:::
::::

The L1 and L2 cache design is **4 times** as fast as the L1-only cache design!

:::{tip} Why is the L2\$ miss rate (usually) higher than the L1\$ miss rate?

The L2 cache tends to receive only the "hard" memory accesses (the ones that miss in the L1 cache).[^mem-access-patterns] Put another way, L1 caches handle most memory access patterns for temporally local data. L2 caches offer better spatial locality to lower miss rates. However, because L1 cache data are a subset of L2 cache data, L2 caches will still miss if memory access patterns jump between many different addresses.

[^mem-access-patterns]: Hashemi et al. "Learning Memory Access Patterns." 2018 [arXiV:1803.02329](https://arxiv.org/abs/1803.02329)

:::

## Preview: Cache Optimizations

We mentioned that AMAT is used to compare cache designs. The key performance hit to AMAT is **miss rate**. This can be measured over multiple program benchmarks, each with different memory access patterns.

In this section, we have seen one way to optimize cache performance by introducing **multilevel caches** to reduce miss penalty.

In this chapter, we will introduce the key principles of cache design. Then, with these design principles in mind, we revisit basic optimization techniques for improving cache performance.

<!--

To optimize cache performance:

1. Introduce multilevel caches to reduce miss penalty. We just saw this.
1. Get a larger cache. This is limited by cost and physical technology capabilities. Furthermore, bigger caches are slower. We would love for higher caches (like L1 cache) to have a hit time of less than the cycle time.
1. Place lines of the cache in a way that maximizes temporal and spatial locality as needed for the average program.
    1. Larger cache line size to reduce miss rate, but can increase the miss penalty.
    1. Higher associativity to reduce miss rate, but can increase hit time.¡ 

The last group of techniques is the core of **cache design** and placement policies. Up next!
-->