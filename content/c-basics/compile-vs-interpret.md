---
title: "Compile vs. Interpret"
---

(compile-vs-interpret-sec)=
## Learning Outcomes

* Be familiar with the high-level process of executing a compilable program.
* Understand the tradeoffs of compilation vs. interpretation.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/cFN0bX8mlmg?si=BRTt2o6rNEY9crMl
:width: 100%
:title: "[CS61C FA20] Lecture 03.2 - C Intro: Basics: Compile v. Interpret"
:::

::::

## Compilation vs. Interpretation

There are two main ways a program gets run by a computer: compilation and interpretation.

C is a compiled language. C **compilers** map C programs directly into architecture-specific **machine code**, or bitstrings of `1`s and `0`s. 
An **executable** is a file composed of this binary machine code that can be executed on your computer. Executables are created by compiling source code.

Languages that can be compiled let us transfer programs more easily between different architectures. For example, in 2020, Apple decided to change the architecture for their Mac computer series. They moved Intel-based x86 processors to an ARM processor,. Even with this huge move, C programs did not change _that_ much. Instead, the change happened in the compilers themselves, which were also programs. They were rewritten to handle the translation from the high-level C language to the new instruction architectures.

How do Python and Java programs compare? They differ mainly in _when_ a program is converted into low-level machine instructions.

* Java: Converts to architecture-independent bytecode, which is then compiled by a just-in-time compiler (JIT)
* Python: **Interpreted**. Converts to byte code at runtime.

### Compilation: Advantages

**1. Reasonable compilation time.** Imagine you have two programs, `foo.c` and `bar.c`. Making changes to `foo.c` will not imply that `bar.c` needs to be recompiled. This process is coordinated via `Makefile`s, which you will see in a future course.

**2. Generally much faster runtime performance.** Compiled C will generally run faster compared to functionally equivalent Java code. After all, the compilation process optimizes code for a given architecture.

Note that depending on your application, you may still prefer Python because (1) there are libraries written for Python that are optimized for GPUs; equivalent usable libraries might not exist for C. Python also has [Cython](https://en.wikipedia.org/wiki/Cython), which you may see in a future class.

## Compilation: Disadvantages

**1. Compiled files, including the executable, are architecture-specific.** The executable depends on the processor type (e.g., MIPS vs. x86 vs. RISC-V) and the operating system (e.g., Windows vs. Linux vs. MacOS). 
"**Porting** your code" to a new architecture means rebuilding your executable: copying the `.c` file, then recompiling using `gcc`.

**2. Slower development cycle**: Unlike Python, C doesn't really have a "read-evaluate-print" loop (REPL). Instead, the cycle is "edit file, compile, link, run, find error", meaning that development may be much slower.

**3. Linking is a bottleneck.** A program executable will need to be recompiled when any part of the program changes. Compilation is a lengthy process! While some parts of the compilation process can be sped up—for example, independent program subparts can be compiled in parallel—other parts remain serial, like the linking stage (which we will talk about much later). This "serial bottleneck" is an example of **Amdahl's Law**; more later.

## "Compiling" as a Colloquial Term

**Compiling** a C program colloquially refers to the full process of using a compiler to translate C programs into executables. We will use this term for now.

In reality, this full process has multiple steps:

1. Compiling `.c` files to `.o` files
1. Automatic assembling
1. Linking the .o files into an executable.

We will discuss this as a four-stage process ("CALL": Compile, Assemble, Link, Load) much later in the course.

## Compile-time Errors vs. Runtime Errors

With this two-step process, when coding in C you can experience two categories of errors.

**Compile-time errors** are often syntax-based, e.g., you forget a semicolon. Because C is a type-based language, compile-time errors will also arise if you use an invalid operation on a particular variable. For example, the division operator (`/`) is not defined for [pointer variable types](#sec-pointers), which store addresses, and a program that tries to do so will trigger an error at compile time.

**Runtime errors** occur during the execution of the program. The most common runtime error is a **segfault**, or a segmentation fault. A segfault occurs when you try to access a piece of memory that "does not belong to you."

When programming in C, there are many ways that segfaults can occur. It is important to note that depending on your exact program, not every case below may cause segfaults!

1. Derefrencing a null pointer. This will  _always_ trigger a segfault. Read more about [pointers](#sec-pointers).
1. Attempting to write to read-only memory. This will _always_ trigger a segfault. Read more about [memory layout](#sec-mem-layout), and see an example when we discuss [strings](#sec-strings).
1. Accessing an out-of-bounds index on an array. The index at which a segfault will occur is somewhat unpredictable, hence the security risks of [buffer overflow](#sec-array).
1. Accessing a pointer to the heap that has previously been `free`'d. This is implementation-dependent; read more about [the heap](#sec-heap).
1. Many other potential cases!

The list above will seem like a disjoint list of facts, particularly for students unfamiliar with C. We recommend you return to this list once you have read more about pointers, arrays, and memory layout.
