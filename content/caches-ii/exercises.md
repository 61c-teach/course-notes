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

1. **True/False**: Decreasing block size to increase the number of blocks held by the cache improves the program
speed for all programs.

:::{note} Solution
:class: dropdown
**False.** Similar to the previous question, the impact depends on the program. If a program iterates
through contiguous memory (like an array), having larger block sizes with fewer blocks may be
beneficial as each block contains more contiguous data. For instance, if Cache A has 10 blocks
and a block size of 8 bytes while Cache B has 20 block and a block size of 4 bytes, and we loop
through an array of 80 characters, Cache A will experience 10 cache misses and 70 hits, while
Cache B will have 20 misses and 60 hits.
:::
