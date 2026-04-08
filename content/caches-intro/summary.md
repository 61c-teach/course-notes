---
title: "Summary"
---

## And in Conclusion$\dots$

### AMAT (Average Memory Access Time)
Recall that AMAT stands for Average Memory Access Time. This is a way to measure the performance of a cache system. The formula for AMAT is:

$\text{AMAT} = (\text{Hit Time}) + (\text{Miss Rate}) * (\text{Miss Penalty})$

<!--
In a multi-level memory hierarchies (e.g. multi-level caches), we can separate miss rates into two types that we consider for each level.
* **Global**: Calculated as the number of accesses that missed at that level divided by the total number of accesses **to the memory system**.
* **Local**: Calculated as the number of accesses that missed at that level divided by the total number of accesses **to that memory level**.
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

:::{exercise}
:label: caches-01
**True/False**: If a piece of data is both in the cache and in memory, reading it from cache is faster than reading from memory.
:::

:::{solution} caches-01
:label: caches-01-sol
:class: dropdown
**True.** The cache is smaller and faster than memory.
:::