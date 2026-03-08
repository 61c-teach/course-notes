---
title: "Summary"
---

## And in Conclusion$\dots$

C does not automatically handle memory for you, so it’s up to you, the programmer, to allocate,
use, and free memory correctly. In each program, an address space is set aside, separated into 2
dynamically changing regions and 2 ‘static’ regions.

* **The Stack**: Stores local variables inside of functions. Data on the stack is garbage collected
immediately after the function in which it was defined returns. Each function call creates a stack
frame that holds the function’s arguments and local variables. The stack grows downwards with
nested function calls (LIFO structure), and shrinks upwards as functions return.
* **The Heap**: Stores memory manually allocated by the programmer with malloc, calloc, or
realloc. Used for data that needs to persist after the function returns. Grows upwards in
memory to ‘meet’ the stack. Memory on the heap is only freed when the programmer explicitly
frees it. Careful heap management is necessary to avoid tricky bugs called Heisenbugs!
* **Data (or Static)**: Stores data that is a fixed size, like global variables and string literals. Does not
grow or shrink through function execution.
* **Text (or Code)**: Is loaded at the start of the program and does not change after, contains
executable instructions and any pre-processor macros.

There are a number of functions in C that can be used to dynamically allocate memory on the
heap. The following are the ones we use in this class:

* `malloc(size_t size)` allocates a block of size bytes and returns the start of the block. The time it takes to search for a block is generally not dependent on size.
* `calloc(size_t count, size_t size)` allocates a block of `count * size` bytes, **sets every value in the block to zero**, then returns the start of the block.
* `realloc(void *ptr, size_t size)` "resizes" a previously-allocated block of memory to
`size` bytes, returning the start of the resized block.
* `free(void *ptr)` deallocates a block of memory which starts at `ptr` that was previously
allocated by the three previous functions.

Be careful when allocating buffers on the stack and heap! The heap is the biggest source of subtle bugs in C code.

Take CS 162 for more!

## Textbook Reading

K&R 7.8.5, 8.7

## Additional References

* Professor Emeritus Brian Harvey's [notes on C](https://inst.eecs.berkeley.edu/~cs61c/resources/HarveyNotesC1-3.pdf)
* Professor Emeritus Paul Hilfinger's [notes on memory management](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/pnh.stg.mgmt.pdf)

## Exercises
Check your knowledge!

### Conceptual Review

1. **True/False**: Memory sectors are defined by the hardware, and cannot be altered.

:::{note} Solution
:class: dropdown

**False.** The four major memory sectors, stack, heap, static/data, and text/code for any given process (application) are defined by the operating system and may differ depending on what kind of memory is needed for it to run.
:::

2. What's an example of this process that might need significant stack space, but very little text, static data, and heap space?

:::{note} Solution
:class: dropdown

(Almost any basic deep recursive scheme, since you're making many new function calls on top of each other without closing the previous ones, and thus, stack frames.)

:::

3. What's an example of a text- and static data- heavy process?

:::{note} Solution
:class: dropdown
(Perhaps a process that is incredibly complicated but has efficient stack usage and does not dynamically allocate memory.)
:::

4. What's an example of a heap-heavy process?

:::{note} Solution
:class: dropdown
(Maybe if you're using a lot of dynamic memory that the user attempts to access.)
:::