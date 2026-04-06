---
title: "Summary"
---

## And in Conclusion$\dots$


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
