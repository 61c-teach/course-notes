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
:alt: "TODO"

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

::::

::::{exercise} L1 and L2 cache
:label: ex-amat-l1-l2

Now, consider inserting an L2 cache into the hierarchy, as shown in @fig-amat-l1-l2:

:::{figure} images/amat-l1-l2.png
:label: fig-amat-l1-l2
:width: 100%
:alt: "TODO"
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
::::

The L1 and L2 cache design is **4 times** as fast as the L1-only cache design!


## Reducing Miss Rate

We mentioned that AMAT is used to compare cache designs. The key performance hit to AMAT is **miss rate**. To reduce miss rate:

* Get a larger cache. This is limited by cost and physical technology capabilities. Furthermore, bigger caches are slower. We would love for higher caches (like L1 cache) to have a hit time of less than the cycle time.
* Place lines of the cache in a way that maximizes temporal and spatial locality as needed for the average program.

The latter technique is the core of **cache design**. Up next!