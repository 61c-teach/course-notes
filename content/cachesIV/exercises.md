---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. Question

:::{note} Solution
:class: dropdown

Solution

<!--See: [Lecture 2 Slide 13](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_154#slide=id.g2af3b38b3e2_1_154)-->
:::

## Short Exercises

1. **True/False**: For the same cache size and block size, a 4-way set associative cache will have fewer index bits
than a direct-mapped cache.

:::{note} Solution
:class: dropdown
**True.** A direct-mapped cache needs to index every block of the cache, whereas a 4-way set
associative cache needs to index every set of 4 blocks. The 4-way set associative cache will have
2 fewer index bits than the direct-mapped cache.
:::

2. **True/False**: Caches see an immediate improvement in memory access time at program execution

:::{note} Solution
:class: dropdown
**False.** A cache starts off ‘cold’ and requires loading in values in blocks at first directly from
memory, forcing compulsory misses. This can be somewhat alleviated by the use of a hardware
prefetcher, which uses the current pattern of misses to predict and prefetch data that may be
accessed later on
:::
