---
title: "Summary"
---

## And in Conclusion$\dots$

* C pointers and arrays are **pretty much the same**[^huge-caveat], except with function calls.
* C knows how to **increment pointers**.
* C is an efficient language, but with **little protection**:
  * Array bounds **not checked**
  * Variables **not automatically initialized**
* Use handles to change pointers.
* Strings are arrays of characters with a null terminator. The length is the # of characters, but memory needs 1 more for \0
* **Beware**: The cost of efficiency is more overhead for the programmer. "C gives you a lot of extra rope, don’t hang yourself with it!"

[^huge-caveat]: The biggest difference between arrays and pointers comes down to where they are located in memory; this difference leads to the many details you saw in this chapter. See the [next chapter](#sec-mem-layout) for an overarching framework of memory layout that will help you understand the distinction.

## Textbook Reading

K&R: Chapters 5-6

## Additional References

* Professor Emeritus Brian Harvey's [notes on C](https://inst.eecs.berkeley.edu/~cs61c/resources/HarveyNotesC1-3.pdf)