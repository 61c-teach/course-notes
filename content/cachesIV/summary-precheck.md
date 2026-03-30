---
title: "Precheck Summary"
---

## To Review$\dots$
6 Replacement Policies
For direct-mapped caches, each block of memory maps to one specific block in our cache. On a
cache miss, if there is data present in that cache block, then we must evict the block to make room
for our new data.
For non-direct-mapped caches, we can choose one of multiple cache blocks to place our new data.
When our cache is full, we will have to decide which block to evict to make space for the new
data. Block Replacement / Eviction policies decide which block should be evicted. Common
ones we may see in this class:
• Least Recently Used (LRU)
– Replace the entry that has not been used for the longest time
– Pro: Temporal Locality
– Con: complicated hardware to keep track of access history
– Implementation: bit counters for each cache block (see lecture slides for example)
• Most Recently Used (MRU)
– Replace the entry that has the newest previous access
– Pro: may support a workload that has less temporal locality
– Implementation: MRU bits to keep track of most recent access
• First-in, First-out (FIFO)
– Replace the oldest block in the set (queue)
– Pro: reasonable approximation to LRU
– Implementation: FIFO queue or similar approximation
• Last-in, First-out (LIFO)
– Replace the newest block in the set (stack)
– Pro: reasonable approximation to MRU
– Implementation: LIFO stack or similar approximation
• Random
– Pro: easy to implement and can work surprisingly well when given workload with low
temporal locality

8 AMAT (Average Memory Access Time)
Recall that AMAT stands for Average Memory Access Time. This is a way to measure the performance of a cache system. The formula for AMAT is:
AMAT = (Hit Time) + (Miss Rate) * (Miss Penalty)
In a multi-level memory hierarchies (e.g. multi-level caches), we can separate miss rates into two
types that we consider for each level.
• Global: Calculated as the number of accesses that missed at that level divided by the total
number of accesses to the memory system.
• Local: Calculated as the number of accesses that missed at that level divided by the total number
of accesses to that memory level.
