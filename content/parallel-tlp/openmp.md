---
title: "OpenMP"
---

(sec-openmp)=
## Learning Outcomes

* Define an OpenMP thread.
* Write C code that leverages OpenMP parallelization with the pragma `#pragma omp parallel`.
* Write C code that leverages OpenMP for-loop worksharing with the pragma `#pragma omp parallel for`. Explain what worksharing means.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/--GhW3gvalE
:width: 100%
:title: "[CS61C FA20] Lecture 34.2 - Thread-Level Parallelism II: OpenMP"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vyTwKNWKpLw
:width: 100%
:title: "[CS61C FA20] Lecture 34.1 - Thread-Level Parallelism II: Parallel Programming Languages"
:::

::::

**OpenMP** stands for "Open Multi-Processing" and is an API[^api] with language extensions for C, C++, and Fortran. OpenMP stands for "Open Multi-Processing" and enables **multi-threaded, shared memory parallelism** with the [fork-join model](#fig-fork-join).

[^api]: Application Programming Interface

OpenMP is a portable, standardized API supported on many compilers, including GCC. We can write parallel programs in high-level code then compile easily:

* Include the `<omp.h>` library in your C code: `#include <omp.h>`
* Provide an additional flag to your `gcc` compiler: `gcc -fopenmp foo.c`

In C, OpenMP uses compiler directives called **pragmas**. Pragmas are a [C preprocessor mechanism](#sec-preprocessor) provided for language extension.[^pragmas] OpenMP uses this mechanism because compilers that don't recognize a pragma are supposed to ignore them, meaning that C code with embedded OpenMP pragmas can still feasibly compile and run on a sequential computer.

[^pragmas]: Commonly implemented pragmas not covered in this course: structure packing, symbol aliasing, floating point exception modes.

## OpenMP Hello World

:::{card}
OpenMP C program: `hello_world.c`
^^^
```{code} c
:label: code-hello-world-openmp
:linenos:

#include <stdio.h>
#include <omp.h>
int main() {
  /* Fork team of threads with private variable tid */
  #pragma omp parallel
  {
    int tid = omp_get_thread_num(); /* get thread id */
    printf("Hello World from thread = %d\n", tid);
    /* Only main thread does this */
    if (tid == 0) {
      printf("Number of threads = %d\n",
             omp_get_num_threads());
    }
  } /* All threads join main and terminate */
  return 0;
}
```

Output:

```{code} bash
$ ./hello_world
Hello World from thread = 0
Number of threads = 12
Hello World from thread = 2
Hello World from thread = 7
Hello World from thread = 1
Hello World from thread = 9
Hello World from thread = 5
Hello World from thread = 8
Hello World from thread = 3
Hello World from thread = 11
Hello World from thread = 10
Hello World from thread = 4
Hello World from thread = 6
```
:::

In the above code, the main thread forks into a team of parallel subthreads. Each subthread executes the parallel region (delineated by the `parallel` directive) concurrently, before control returns to the main thread.

## OpenMP Constructs

### Parallel region

A **parallel region** is a code section executed in parallel and is delineated by the `parallel` construct. In the [above code](#code-hello-world-openmp), the parallel region spans Lines 6 to 14.

### OpenMP Thread

OpenMP creates as many **software threads** as specified in the environment variable `OMP_NUM_THREADS`. During execution, each OpenMP (software) thread is multiplexed onto the available hardware threads.

To specify the number of threads, use `omp_set_num_threads(x);` outside the parallel region. Otherwise, by default, the number of OpenMP threads is set to the maximum number of hardware threads on the machine. We saw [earlier](#code-hive-lscpu) that the course hive machines have 12 hardware threads.

:::{table} OpenMP Software Threads
:label: tab-openmp-threads

| OpenMP Intrinsic | Description |
| :--- | :--- |
| `omp_set_num_threads(x);` | Set number of threads to x. |
| `num_th = omp_get_num_threads();` | Get number of threads. |
| `tid = omp_get_thread_num();` | Get Thread ID number. |

:::

It is certainly possible to specify more OpenMP threads than hardware threads. There are likely other concurrent tasks running on the same machine. If your OpenMP parallel regions has significant I/O or memory accesses, multiplexing is somewhat inevitable. Be wary of too much context switching on a shared machine: during peak times, timing OpenMP programs may inadvertently measure shared machine workload, and not the benchmark target. Read more about OpenMP timing when we build our [OpenMP DGEMM benchmark](#sec-dgemm-benchmark-mimd)

### Shared and Private Variables

OpenMP has both shared and private variables.

* **Shared variables**, where all threads read/write the same variable. Shared variables are those declared outside of the parallel region, heap-allocated variables, and static variables.
* **Private variables**, where each thread has its own copy of the variable. Private variables are those declared inside the parallel region; they will be allocated to the thread's own stack frame (review thread state in [this section](#sec-thread-state)).

```{code} c
  int var1, var2;
  char *var3 = malloc(…);
  #pragma omp parallel private(var2)
  {
    int var4;
    // var1 shared (default)
    // var2 private
    // var3 shared (heap)
    // var4 private (thread’s stack)
    …
  }
```

(sec-openmp-for)=
## OpenMP Worksharing with `for`

In our [hello world example](#code-hello-world-openmp), the parallel region work was replicated across all OpenMP threads. In practice, we may want to write multi-threaded programs for **worksharing**, where we _split/partition_ and _distribute_ the work across OpenMP threads.

The OpenMP `for` construct can be associated with a parallel region's `for` loop within a parallel region. Given this construct, the run-time system determines which chunk of loop iterations to assign to each thread. At a high-level, the code

```{code} c
#include <omp.h>

omp_set_num_threads(4);
#pragma omp parallel for
for (int i=0; i<100; i++) { 
    ...
}
```

will generate four subthreads:

1. `for (int i=0; i<25; i++) { … }`
1. `for (int i=25; i<50; i++) { … }`
1. `for (int i=50; i<75; i++) { … }`
1. `for (int i=75; i<100; i++) { … }`

The above example of the `#pragma omp parallel for` directive is sufficient for most workloads in this class. For those curious, there are two directives at play:

* `#pragma omp parallel` declares a parallel region
* `#pragma omp for` declares a worksharing for-loop within a parallel region

If a parallel region is one giant `for` loop, we can combine the two declarations with `#pragma omp parallel for`. For those curious, check out the [related example](#sec-openmp-for-ex).

## Beyond OpenMP

There is no universal solution to parallel programming. OpenMP assumes a fork-join model, though different models are needed for different applications. @tab-tlp-pros-cons lists the benefits of the OpenMP parallel programming model.

:::{table} Thread-level parallelism with OpenMP: pros and cons.
:label: tab-tlp-pros-cons

| Assumption | Pros | Cons |
| :-- | :-- | :-- |
| Threads are an explicit programming model with full programmer control over parallelization | - Compiler directives are simple and easy to use <br/> - Legacy serial code does not need to be rewritten | - Compiler must support OpenMP (e.g. gcc 4.2)<br/> -Amdahl's law is gonna get you after not too many cores |
| Multiple threads operate in a shared memory environment. | - Reduces memory requirements<br/>- Programmer need not worry (that much) about data placement | - Code can only be run in shared memory environments<br/> -Synchronizing use of shared resources is hard |

:::

Parallel programming needs can be very-problem specific—scientific computing, machine learning, web servers, I/O-heavy applications, etc. As a result, other models—e.g, message passing for process-level parallelism, with concurrent independent tasks—may be needed.

:::{note} Show some parallel programming languages
:class: dropdown

* ActorScript
* Ada
* Afnix
* Alef
* Alice
* APL
* Axum
* Chapel
* Cilk
* Clean
* Clojure
* Concurrent C
* Concurrent Haskell
* Concurrent ML
* Concurrent Pascal
* CUDA
* Curry
* E
* Eiffel
* Erlang
* Fortran 90
* Go
* Io
* Janus
* Java
* JoCaml
* Join
* Joule
* Joyce
* LabVIEW
* Limbo
* Linda
* Modula-3
* MultiLisp
* Occam
* occam-π
* Orc
* Oz
* Pict
* Reia
* SALSA
* Scala
* SISAL
* SR
* Stackless Python
* SuperPascal
* VHDL
* XC
:::
