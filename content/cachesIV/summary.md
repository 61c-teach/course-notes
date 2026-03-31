---
title: "Summary"
---

## And in Conclusion$\dots$

### Replacement Policies
For direct-mapped caches, each block of memory maps to one specific block in our cache. On a cache miss, if there is data present in that cache block, then we must evict the block to make room for our new data.

For non-direct-mapped caches, we can choose one of multiple cache blocks to place our new data. When our cache is full, we will have to decide which block to evict to make space for the new data. Block Replacement / Eviction policies decide which block should be evicted. 

Common ones we may see in this class:
* **Least Recently Used (LRU)**
    * Replace the entry that has not been used for the longest time
    * Pro: Temporal Locality
    * Con: complicated hardware to keep track of access history
    * **Implementation**: bit counters for each cache block (see lecture slides for example)
* **Most Recently Used (MRU)**
    * Replace the entry that has the newest previous access
    * Pro: may support a workload that has less temporal locality
    * **Implementation**: MRU bits to keep track of most recent access
* **First-in, First-out (FIFO)**
    * Replace the oldest block in the set (queue)
    * Pro: reasonable approximation to LRU
    * **Implementation**: FIFO queue or similar approximation
* **Last-in, First-out (LIFO)**
    * Replace the newest block in the set (stack)
    * Pro: reasonable approximation to MRU
    * **Implementation**: LIFO stack or similar approximation
* **Random**
    * Pro: easy to implement and can work surprisingly well when given workload with low temporal locality

## Textbook Readings

P&H 5.2, 5.5, 5.11

## Additional References

## Exercises

Check your knowledge!

### Short Exercises

1. **True/False**: For the same cache size and block size, a 4-way set associative cache will have fewer index bits than a direct-mapped cache.

:::{note} Solution
:class: dropdown
**True.** A direct-mapped cache needs to index every block of the cache, whereas a 4-way set associative cache needs to index every set of 4 blocks. The 4-way set associative cache will have 2 fewer index bits than the direct-mapped cache.
:::

2. **True/False**: Caches see an immediate improvement in memory access time at program execution

:::{note} Solution
:class: dropdown
**False.** A cache starts off ‘cold’ and requires loading in values in blocks at first directly from memory, forcing compulsory misses. This can be somewhat alleviated by the use of a hardware prefetcher, which uses the current pattern of misses to predict and prefetch data that may be accessed later on
:::