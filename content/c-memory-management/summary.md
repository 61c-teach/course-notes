---
title: "Memory Management"
---

## And in Conclusion$\dots$

C has 3 pools of memory.

* Static storage (aka the `data` segment): global variable storage, basically permanent, entire program run
* The Stack: local variable storage, parameters, return address
* The Heap (dynamic storage): malloc() grabs space from here, free() returns it.

A fourth area of the program's address space stores the program itself. This section is often in a read-only `text` segment.

Be careful when allocating buffers on the stack and heap! The heap is the biggest source of subtle bugs in C code.

Take CS 162 for more!

## Extra References

* Professor Emeritus Brian Harvey's [notes on C](https://inst.eecs.berkeley.edu/~cs61c/resources/HarveyNotesC1-3.pdf)
* Professor Emeritus Paul Hilfinger's [notes on memory management](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/pnh.stg.mgmt.pdf)