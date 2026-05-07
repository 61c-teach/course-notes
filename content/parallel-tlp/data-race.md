---
title: "Data Races, Critical Sections"
---

(sec-data-race-overall)=
## Learning Outcomes

* Define a data race.
* Specify critical sections in OpenMP to synchronize threads.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/tJ9dqPYGb4E
:width: 100%
:title: "[CS61C FA20] Lecture 35.1 - Thread-Level Parallelism III: Hardware Synchronization"
:::
::::

<!-- TODO: find timestamps and break up this section.
atomic operations
RISC-V critical section
openMP critical section
openMP locks
openMP for loop
deadlock
openMP timing
-->

As discussed [earlier](#sec-thread-state), threads operate under a shared memory model, where different threads can read from and write to the same locations in memory.

Consider the below program. What are possible values of `x` after running this program with **four** OpenMP threads?

```{code} c
:label: code-data-race

#include <stdio.h>
#include <omp.h>
int main() {
  int x = 0;                        /* shared variable */
  #pragma omp parallel
  {
    x += 1;
  }
}
```

(sec-data-race)=
## Data Race

Two memory accesses form a **data race** if:

* They are from different threads to the same location;
* At least one is a write; and
* They occur one after another.

In our multi-thread execution model, instructions from different threads have their execution **interleaved** in time, thus causing data races.[^data-hazard]

[^data-hazard]: A data race is **not** a [_data hazard_](#block-def-hazard-data). While _data hazards_ result from instruction-level parallelism on a pipelined processor architecture, **data races** can occur even on single-cycle processors. **Data races** result from not determining instruction execution order _between_ threads—i.e., which thread accesses memory first.

Let us translate the parallel section of our [example code](#code-data-race) into the three RISC-V instructions below. With four OpenMP threads, there are four sets of three sections to execute. Each thread accesses the same variable `x` in (shared) memory but has its copy of register `t0` used in arithmetic, resulting in the data race.


```{code} bash
lw t0 0(sp)   # x @ sp
addi t0 t0 1
sw t0 0(sp)
```

Because of the many possibilities of interleaving the execution of these twelve instructions, the final value of `x` is not always the same.[^correctness] Consider the cases below.

[^correctness]: Formally, a multithreaded program is only considered correct if ANY interlacing of threads yield the same result. Our [example code](#code-data-race) is an incorrect program. For those curious, there are $8!/(2!)4 = 2520$ different possible orders of load and store instruction pairs (or 105 orders if we consider that all threads are identical).

::::{tab-set}
:::{tab-item} Case 1

Case 1: All threads run sequentially.

| Thread | Instruction | `x` memory access |
| :-- | :-- | :-- | 
| 1 | load | read `x`: 0 |
| 1 | store | write `x`: 1 |
| 2 | load | read `x`: 1 |
| 2 | store | write `x`: 2 |
| 3 | load | read `x`: 2 |
| 3 | store | write `x`: 3 |
| 4 | load | read `x`: 3 |
| 4 | store | write `x`: 4 |

Final value of `x`: 4
:::

:::{tab-item} Case 2

Case 2: Threads "perfectly" interleaved.

| Thread | Instruction | `x` memory access |
| :-- | :-- | :-- | 
| 1 | load | read `x`: 0 |
| 2 | load | read `x`: 0 |
| 3 | load | read `x`: 0 |
| 4 | load | read `x`: 0 |
| 1 | store | write `x`: 1 |
| 2 | store | write `x`: 1 |
| 3 | store | write `x`: 1 |
| 4 | store | write `x`: 1 |

Final value of `x`: 1
:::

:::{tab-item} Case 3

Case 3: Thread 1's store is last.

| Thread | Instruction | `x` memory access |
| :-- | :-- | :-- | 
| 1 | load | read `x`: 0 |
| 2 | load | read `x`: 0 |
| 2 | store | write `x`: 1 |
| 3 | load | read `x`: 1 |
| 3 | store | write `x`: 2 |
| 4 | load | read `x`: 2 |
| 4 | store | write `x`: 3 |
| 1 | store | write `x`: 1 |

Final value of `x`: 1
:::
::::

## Critical Sections in OpenMP

To enforce multithreaded program correctness, we often need to **synchronize** threads, i.e., coordinate their execution.
Most commonly, we must identify when one thread is finished writing so that it is safe for another to read.

:::{warning} Synchronization

The hardest part of multithreading is understanding and maintaining program correctness[^correctness] by synchronizing threads.

:::

Synchronization can be specified in user-level routines, i.e., in higher-level languages. A **critical section** is a segment of code that must be executed by a single thread at a time, thereby enforcing synchronization. Once a thread enters a critical section, it can safely execute all code in that critical section, knowing that it is the _only_ thread that can execute that section at that time.

We discuss two OpenMP synchronization constucts:

* `#pragma omp critical`: Creates a critical section within a parallel code segment. [OpenMP docs](https://www.openmp.org/spec-html/5.0/openmpsu89.html)
* `#pragma omp barrier`: Forces all threads to wait until all threads have hit the barrier. [OpenMP docs](https://www.openmp.org/spec-html/5.0/openmpsu90.html)

Returning to our [example code](#code-data-race), we can specify a critical section and prevent any data races:

```{code} c
:label: code-data-race-critical

#include <stdio.h>
#include <omp.h>
int main() {
  int x = 0;                        /* shared variable */
  #pragma omp parallel
  {
    #pragma omp critical    
    {
      x += 1;
    }
  }
}
```

:::{warning} Amdahl's Law

Note that a correct program is one where threads execute a given critical section sequentially. However, in our [modified code](#code-data-race-critical) the entire program is now one big critical section! We have effectively have designed a serial program. If critical sections are too large, Amdahl's Law cuts down any gains due to performance.

Ultimately, OpenMP is most useful for worksharing, e.g., with `for` loops. There are better options for programs that work on a large amount of shared memory.
:::

## Data Race Examples

### OpenMP Hello World: Add


:::{hint} Quick Check

Suppose we modify our [OpenMP Hello World](#code-hello-world-openmp) to the [below code](#code-hello-world-openmp-add). When we run the program with 12 OpenMP threads, will the values of `x` be printed in order? Why or why not?

:::

```{code} c
:linenos:
:label: code-hello-world-openmp-add

#include <stdio.h>
#include <omp.h>
int main() {
  int x = 0;                        /* shared variable */
  #pragma omp parallel
  {
    int tid = omp_get_thread_num(); /* private variable */
    #pragma omp critical    
    {
      x++;
    }
    printf("Hello World from thread = %d, x = %d\n", tid, x);

    #pragma omp barrier
    if (tid == 0) {
      printf("Number of threads = %d\n", omp_get_num_threads());
    }
  }
}
```

:::{note} Show Answer
:class: dropdown

No; it varies. One output run:

```{code} bash
Hello World from thread = 11, x = 10
Hello World from thread = 01, x = 1
Hello World from thread = 06, x = 11
Hello World from thread = 07, x = 7
Hello World from thread = 09, x = 8
Hello World from thread = 03, x = 9
Hello World from thread = 04, x = 5
Hello World from thread = 10, x = 3
Hello World from thread = 08, x = 2
Hello World from thread = 00, x = 12
Number of threads = 12
Hello World from thread = 02, x = 6
Hello World from thread = 05, x = 4
Final value of x: 12
```

Because Line 10 is in a critical section, `x`'s value is updated correctly. However, Line 12's `printf` is _not_ part of the critical section, and a thread with a larger value of `x` can print before a thread with a smaller value.  

:::

:::{hint} Quick Check

Consider the DGEMM OpenMP code discussed in an [earlier section](#sec-dgemm-mimd):

```{embed} #code-dgemm-openmp
```

Why is there no specified critical section, even though each (work-sharing) thread updates elements of `C`?
:::

:::{note} Show Answer
:class: dropdown

First, review the definition of [data race](#sec-data-race). 

Consider all of the memory accesses in the innermost loop (i.e., for all values of `j` and `k`), assuming that two different threads run the `i = 0` and `i = 1` iterations, respectively. Below, we explain that none of these memory accesses will cause races:

* The variable `sum` is declared within the parallel section; it is not shared across threads.
* Read element $A_{ik}$: No data race, because neither thread's access is a write.
* Read element $B_{kj}$: No data race, because neither thread's access is a write.
* Write element $C_{ij}$: No data race. While both threads' accesses are writes, the elements $C_{0j}$ and $C_{1j}$ are different, so writes are to different locations.[^cache-coherency]

[^cache-coherency]: If caches are in the memory hierarchy, it is likely that the two threads will each have their own copy of the same block of `C` in their respective cache. So while there is no data race, these copies will be "out of sync." Read more about **cache coherency** in a [later section](#sec-cache-coherency).

We present the above argument without loss of generality, meaning that it applies for all possible work-sharing configurations in the [DGEMM OpenMP code](#code-dgemm-openmp)

:::
