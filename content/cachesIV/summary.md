---
title: "Summary"
---

## And in Conclusion$\dots$

### Replacement Policies

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