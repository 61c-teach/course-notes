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

## Additional References

* [Cache Flowchart](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/caches.pdf)

Amazing Illustrations by Ketrina (Yim) Thompson: [CS Illustrated](https://www2.eecs.berkeley.edu/Pubs/TechRpts/2009/EECS-2009-79.html) Cache Handouts

* [Cache Basics](https://csillustrated.berkeley.edu/PDFs/posters/cache-1-basics-poster.pdf)
* [Cache Associativity](https://csillustrated.berkeley.edu/PDFs/posters/cache-3-associativity-poster.pdf)
* [Cache Misses](https://csillustrated.berkeley.edu/PDFs/posters/cache-2-misses-poster.pdf)

### Benchmark references

The data in this section is from Patterson & Hennessy, _Computer Organization: A General Approach_, Fifth Edition.

* Miss rate by cache size and associativity is Figure B.8 and is aggregated from data measured on SPEC2000 benchmarks on the Alpha architecture, by Cantin and Hill.[^cantin-hill] Block sizes for all caches are 64 bytes.
* Miss rate by cache size and block size is Figure B.11 is from data measured on the SPEC92 benchmark on a DECstation 5000, by Gee et al.[^gee-et-al].

[^cantin-hill]: J.F. Cantin and M.D. Hill [2001]. "Cache PErformance for Selected SPEC CPU2000 Benchmarks." https://doi.org/10.1145/563519.563522 [website](https://research.cs.wisc.edu/multifacet/misc/spec2000cache-data/) Version 2.0.

[^gee-et-al]: J.D. Gee, M.D. Hill, D.N. Pnevmatikatos, and A.J. Smith [1993]. "Cache performance of the SPEC92 benchmark suite." _IEEE Micro_ 13:4 (August), 17-27.https://doi.org/10.1109/40.229711

### Short Exercises

:::{exercise}
:label: caches-05
1. **True/False**: Decreasing block size to increase the number of blocks held by the cache improves the program speed for all programs.
:::

:::{solution} caches-05
:label: caches-05-sol
:class: dropdown
**False.** Similar to the previous question, the impact depends on the program. If a program iterates through contiguous memory (like an array), having larger block sizes with fewer blocks may be beneficial as each block contains more contiguous data. For instance, if Cache A has 10 blocks and a block size of 8 bytes while Cache B has 20 block and a block size of 4 bytes, and we loop through an array of 80 characters, Cache A will experience 10 cache misses and 70 hits, while Cache B will have 20 misses and 60 hits.
:::

:::{exercise}
:label: caches-06
1. **True/False**: Caches see an immediate improvement in memory access time at program execution.
:::

:::{solution} caches-06
:label: caches-06-sol
:class: dropdown
**False.** A cache starts off "cold" and requires loading in values in blocks at first directly from memory, forcing compulsory misses. This can be somewhat alleviated by the use of a hardware prefetcher, which uses the current pattern of misses to predict and prefetch data that may be accessed later on. Prefetchers are out of scope for this course.
:::

:::{exercise}
:label: caches-07
2. **True/False**: Increasing cache size by adding more blocks always improves (increases) hit rate for all programs.
:::

:::{solution} caches-07
:label: caches-07-sol
:class: dropdown
**False.** Whether this improves the hit rate for a given program depends on the characteristics of the program. For example, a program that loops through an array once may have each access be separated by more than one block (e.g., if the block size is 8B but we access every fourth element of an integer array, our accesses are separated by 16B). This results in compulsory misses, which cannot be reduced just by adding more blocks to the cache.
:::


