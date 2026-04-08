---
title: "Summary"
---

## And in Conclusion$\dots$

**Replacement policies**:

* For direct-mapped caches, each block of memory maps to one specific block in our cache. On a cache miss, if there is data present in that cache block, then we must evict the block to make room for our new data.
* For non-direct-mapped caches, we can choose one of multiple cache blocks to place our new data. When our cache is full, we will have to decide which block to evict to make space for the new data. Block Replacement policies decide which block should be replaced.
    * Least recenty used (LRU)
    * First-in, first-out (FIFO)
    * Random

:::{embed} #tab-cache-replacement
:::

**Write policies**:

:::{embed} #tab-cache-write
:::

<!--
## And in Conclusion$\dots$

We use caches to make our access to data faster. When working with main memory (RAM), the
main problem faced is the fact that access to the main memory is very slow. In fact, modern
processors take about 100 instruction cycles or more to access the main memory, meaning
memory accesses become the bottleneck of our programs. Caches help fix this problem for us–
they hold a portion of the data in main memory that we might access again later on. They are
closer to the processor in the memory hierarchy, and thus accessing a cache is much faster than
accessing the main memory.

:::{embed} #fig-von-neumann-cache
:::

As seen above, the access to cache is the middle step between the CPU asking for a memory bit,
and the actual main memory access - if the data is not found in the cache, only then is main
memory accessed. This way unnecessary trips to main memory are avoided. One important detail
is that caches are much smaller in size than main memory - this is why we have to be efficient in
what we hold in caches.

When we are saving data in caches, we need to be as efficient as possible. In order to do this, we
make use of locality. We have two different kinds of locality to consider.

* **Temporal Locality**: If we have accessed a piece of information recently, it is possible that we
will access it again. So, we hold this data in the cache.
* **Spatial Locality**: If we have accessed a memory location recently, it is probable that we will
access the neighboring addresses as well. So, we also keep the neighboring addresses within
the cache. An example is array accesses - if we access the 0th element of an array, it is probable
we will also access the 1st one.

### Understanding T/I/O

Note that caches hold the data in blocks that have a size equal to the block size of the cache. When
working with caches, we have to be able to break down the memory addresses we work with to
understand where they fit into our caches. There are three fields:
* **Tag**: Used to distinguish different blocks that use the same index.

Number of Tag Bits = (# bits in memory address) - Index Bits - Offset Bits

* **Index**: The set that this piece of memory will be placed in.
Number of Index Bits = log2
(# of Indices)
* **Offset**: The location of the byte in the block.
Number of Offset Bits = log2
(Block Size)

Given these definitions, the following is true:
log2
(memory size) = # memory address bits = # tag bits + # index bits + # offset bits
Another useful equality to remember is:
cache size = block size ∗ num b

#TAG INDEX OFFSET LAYOUT

As seen above, the tag bits are to the left (most significant), the index bits are in the middle, and
the offset bits are to the right (least significant).
-->

## Textbook Readings

P&H 5.1-5.4, 5.8, 5.9, 5.13

## Additional References

* [Cache Flowchart](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/caches.pdf)

Amazing Illustrations by Ketrina (Yim) Thompson: [CS Illustrated](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-79.html) Cache Handouts

* [Cache Basics](https://csillustrated.berkeley.edu/PDFs/posters/cache-1-basics-poster.pdf)
* [Cache Associativity](https://csillustrated.berkeley.edu/PDFs/posters/cache-3-associativity-poster.pdf)
* [Cache Misses](https://csillustrated.berkeley.edu/PDFs/posters/cache-2-misses-poster.pdf)

## Exercises

Check your knowledge!

### Short Exercises

:::{exercise}
:label: caches-02
**True/False**: We cannot use a 1KB cache in a 32-bit system because it is too small and cannot contain all possible addresses.
:::

:::{solution} caches-02
:label: caches-02-sol
:class: dropdown
**False.**
:::

:::{exercise}
:label: caches-03
1. **True/False**: For the same cache size and block size, a 4-way set associative cache will have fewer index bits than a direct-mapped cache.
:::

:::{solution} caches-03
:label: caches-03-sol
:class: dropdown
**True.** A direct-mapped cache needs to index every block of the cache, whereas a 4-way set associative cache needs to index every set of 4 blocks. The 4-way set associative cache will have 2 fewer index bits than the direct-mapped cache.
:::

:::{exercise}
:label: caches-04
2. **True/False**: Decreasing block size to increase the number of blocks held by the cache improves the program speed for all programs.
:::

:::{solution} caches-04
:label: caches-04-sol
:class: dropdown
**False.** Similar to the previous question, the impact depends on the program. If a program iterates through contiguous memory (like an array), having larger block sizes with fewer blocks may be beneficial as each block contains more contiguous data. For instance, if Cache A has 10 blocks and a block size of 8 bytes while Cache B has 20 block and a block size of 4 bytes, and we loop through an array of 80 characters, Cache A will experience 10 cache misses and 70 hits, while Cache B will have 20 misses and 60 hits.
:::