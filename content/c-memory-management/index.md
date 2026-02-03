---
title: "Introduction"
subtitle: "What is the C Memory Model?"
---

(sec-mem-layout)=
## Learning Outcomes

* Learn characteristics of the C memory layout.
* Differentiate between storage allocation and variable declaration.
* Know where variables are stored in C, i.e., which memory segment data is allocated in.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Keducx5bp-g?si=tat-NaUsgv7fdlRy
:width: 100%
:title: "
:enumerated: false

[CS61C FA20] Lecture 05.3 - C Memory Management: Memory Locations"
:::

until 8:37
::::

## C Memory Layout

So far, we have discussed how different data types occupy space (i.e., how the compile-time operator `sizeof` works with different declarations of local variables), but we haven't discussed where all C things live in memory.

### Memory allocation

In C, there are three ways of allocating storage space in memory:

* **Local variable declaration**: To specify a local variable, declare it inside a function, e.g., in `main()`. Local variables are accessible within the function they are declared in; put another way, a C compiler will only recognize a local variable in its function's **namespace**. These are declared and allocated at compile-time (hence why `sizeof` works).
* **Global variable declaration**: Global variables are declared outside a function. Variables declared in the global **namespace** are accessible to every subroutine (`main()`, `foo()`, etc.). Warning: Do not overuse global variables! While they are useful for accessing shared constants or big tables, you can write the worst code in the world by having a billion globals: you risk accidental edits by different routines, and you remove the power of abstraction between functions. Global variables are declared and allocated at compile-time.
* **Dynamic memory allocation**: Sometimes we won't know how much space we need until we start running a program. For example, we may need to load in data from a file, and we only know how much data is in the file until we read all of its bytes. In this case, we can dynamically allocate memory storage at runtime by calling allocation functions: `malloc` is a common one. Read more [when we discuss heaps](#sec-heap).

Based on the descriptions above, note that **storage allocation** involves setting aside a block of memory to put data in. **Variable declaration** means allocating a block of memory and also specifying a name with which to refer to that memory. Because variables are typed, variable declaration implicitly specifies the size of the memory block to allocate. While variable declaration always implies storage allocation, the converse is not true (e.g., with dynamic memory allocation).

### Four regions of memory layout

A C program’s address space contains 4 regions as shown in @fig-c-mem-layout.

:::{figure} images/c-mem-layout.png
:label: fig-c-mem-layout
:width: 50%
:alt: "TODO"

C program memory layout.
:::

| Memory Segment | Contents | Memory Management |
| :--- | :--- | :--- |
| **Stack** | local variables, parameters, and return addresses [^stack-info] | automatic; grows _downward_[^stack-sec] |
| **Heap** | dynamically allocated storage | resizes on demand (e.g. `malloc` to allocate storage, `free` to free storage); grows _upward_[^heap-sec] |
| **Data** (aka **Static**)[^data-rodata] | global variables | size is fixed ("static") throughout the whole program |
| **Text** (aka **Code**)[^text] | program code | size is fixed throughout the whole program; data is loaded when program starts |

The names of these four memory segments are hard to memorize at first, so we apologize on behalf of all computer scientists. While the **stack** operates very much like the stack data structure you learned in a Data Structures course, the **heap** is NOT a heap data structure; it is just a "heap of memory." Also, everything is technically data, but the **data** segment specifically refers to global data[^data-rodata]. Finally, the **text** can be remembered because program code should be read-only data, just like how many texts you read in real life are read-only.

Programming in C requires knowing where data is in memory[^java-python-mem]. Otherwise things don’t work as expected. In particular, memory in each of the four regions is **managed** differently. The biggest source of bugs in C is from incorrect assumptions about memory. This lecture is all about learning how memory is managed in order to avoid common bugs. We focus our discussion on the stack and the heap.

[^stack-info]: Because parameters and return addresses are critical to function call and return, they are often stored directly in the CPU where possible—on special hardware called registers (which we talk about later). Because there are only a limited number of such registers, additional parameters and return addresses are stored in memory on the stack until they are needed.
[^stack-sec]: Read more about [the stack](#sec-stack).

[^heap-sec]: Read more about [the heap](#sec-heap).

[^data-rodata]: We refer only to the `.data` segment in this course and ignore read-only data. Read more on [Wikipedia](https://en.wikipedia.org/wiki/Data_segment).

[^text]: Read more on [Wikipedia](https://en.wikipedia.org/wiki/Code_segment).

[^java-python-mem]: By contrast, Java and Python both hide locations of objects.
