---
title: "Summary"
---

## And in Conclusion$\dots$

* Generic functions (i.e., generics), use void * pointers to operate on memory.
  * Generics are widely present in the C standard library! (`malloc`, ...)
  * Generics require a solid understanding of memory; by manipulating arbitrary bytes, you risk violating data boundaries, e.g., “Frankenstein”-ing two halves of ints.

* When writing generics:
  * Generic pointers do not support dereferencing.
  * Instead, use byte handling functions (`memcpy`, `memmove`).
  * Pointer arithmetic: first cast to byte arrays with (`char *`).

* Function pointers enable higher-order functions in C.
map, filter, sorting, etc.

## Textbook Readings

K&R 7.8.5, 8.7
