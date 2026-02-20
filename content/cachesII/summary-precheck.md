---
title: "Precheck Summary"
---

## To Review$\dots$
Understanding T/I/O

We use caches to make our access to data faster. When working with main memory (RAM), the
main problem faced is the fact that access to the main memory is very slow. In fact, modern
processors take about 100 instruction cycles or more to access the main memory, meaning
memory accesses become the bottleneck of our programs. Caches help fix this problem for us -
they hold a portion of the data in main memory that we might access again later on. They are
closer to the processor in the memory hierarchy, and thus accessing a cache is much faster than
accessing the main memory.

#Cache path diagram

As seen above, the access to cache is the middle step between the CPU asking for a memory bit,
and the actual main memory access - if the data is not found in the cache, only then is main
memory accessed. This way unnecessary trips to main memory are avoided. One important detail
is that caches are much smaller in size than main memory - this is why we have to be efficient in
what we hold in caches.
When we are saving data in caches, we need to be as efficient as possible. In order to do this, we
make use of locality. We have two different kinds of locality to consider.
• Temporal Locality: If we have accessed a piece of information recently, it is possible that we
will access it again. So, we hold this data in the cache.
• Spatial Locality: If we have accessed a memory location recently, it is probable that we will
access the neighboring addresses as well. So, we also keep the neighboring addresses within
the cache. An example is array accesses - if we access the 0th element of an array, it is probable
we will also access the 1st one.
Note that caches hold the data in blocks that have a size equal to the block size of the cache. When
working with caches, we have to be able to break down the memory addresses we work with to
understand where they fit into our caches. There are three fields:
• Tag: Used to distinguish different blocks that use the same index.
Number of Tag Bits = (# bits in memory address) - Index Bits - Offset Bits
• Index: The set that this piece of memory will be placed in.
Number of Index Bits = log2
(# of Indices)
• Offset: The location of the byte in the block.
Number of Offset Bits = log2
(Block Size)
Given these definitions, the following is true:
4
Precheck: Caches 5
log2
(memory size) = # memory address bits = # tag bits + # index bits + # offset bits
Another useful equality to remember is:
cache size = block size ∗ num b

#TAG INDEX OFFSET LAYOUT

As seen above, the tag bits are to the left (most significant), the index bits are in the middle, and
the offset bits are to the right (least significant).
