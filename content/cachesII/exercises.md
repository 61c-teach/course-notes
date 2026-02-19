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

1. **True/False**: Increasing cache size by adding more blocks always improves (increases) hit rate for all programs

:::{note} Solution
:class: dropdown
**False.** Whether this improves the hit rate for a given program depends on the characteristics of
the program. For example, a program that loops through an array once may have each access be
separated by more than one block (e.g., if the block size is 8B but we access every fourth element
of an integer array, our accesses are separated by 16B). This results in compulsory misses, which
cannot be reduced just by adding more blocks to the cache.
:::
