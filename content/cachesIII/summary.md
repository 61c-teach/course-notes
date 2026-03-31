---
title: "Summary"
---

## And in Conclusion$\dots$

### Cache Misses
In order to evaluate cache performance and hit rate, especially with determining how effective our current cache configuration is, it is useful to analyze the misses that do occur, and adjust accordingly. Below, we categorize cache misses into two types:
1. Compulsory: A miss that must occur when you bring in a certain block for the first time, hence “compulsory”. Compulsory misses are cache attempts that would never be a hit regardless of the cache design.
2. Noncompulsory: A cache miss that occurs after the data has already been brought into the cache and then evicted afterwards. If the miss could have been alleviated via increasing the cache size or associativity, then the miss is considered noncompulsory.

### Cache Associativity
Direct-Mapped caches, where each block of memory maps to specifically one slot in our cache, are good for fast searching, simple hardware, and quick replacement, but not so good for spatial locality! This is where we bring associativity into the matter. Associativity is the number of slots a memory block can map to in our cache. Thus, a Fully-Associative cache has the most associativity, meaning one memory block can map to any cache block. Our Direct-Mapped cache, on the other hand, has the least (being only 1-way set associative) because one memory block can only map to a single cache block.

For an N-way set associative cache, the following relationships are true:
* Number of Blocks = 𝑁 × Number of Sets
* Index bits = log2(Number of sets)

:::{note} How many sets and blocks are in a 2-way set associative cache with 4 index bits?
:class: dropdown

For a 2-way set associative cache with 4 index bits, there will be $2^4 = 16$ sets for $2 \times 16 = 32$ blocks in the cache. A single address will map to one of the 16 sets and will be placed in one of the two blocks.
:::

### Write Policies
Store instructions write to memory which change the data. With a cache, we need to ensure that our main memory will eventually be in sync with our cache if we are changing the values. 

There exist two common write policies with different tradeoffs:
* **Write-through**: write to the cache and memory at the same time such that the data in cache and main memory will always be in sync.
    * Simple to implement but…
    * More writes to memory ⇒ longer AMAT
* **Write-back**: only write data to the cache and keep track of “dirty” blocks by setting a dirty bit to 1. When dirty block gets evicted, write changes back to memory.
    * More difficult to implement but…
    * Fewer writes to main memory ⇒ shorter AMAT

:::{note} What happens when we have multiple caches simultaneously reading and writing to/from main memory?
:class: dropdown 
Take CS152 to learn about cache coherency and consistency!
:::

## Textbook Readings

P&H 5.1-5.4, 5.8, 5.9, 5.13

## Additional References

* [Cache Flowchart](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/caches.pdf)

## Exercises

Check your knowledge!

### Short Exercises

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