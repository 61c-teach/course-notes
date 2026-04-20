---
title: "OpenMP"
subtitle: Coming soon. Thanks for your patience!
---

(sec-openmp)=
## Learning Outcomes

<!--
* TODO
* TODO
-->

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


<!-- ## Visuals

:::{table} OpenMP Software Threads
:label: tab-openmp-threads

| OpenMP Intrinsic | Description |
| :--- | :--- |
| `omp_set_num_threads(x);` | Set number of threads to x. |
| `num_th = omp_get_num_threads();` | Get number of threads. |
| `tid = omp_get_thread_num();` | Get Thread ID number. |

:::

:::{figure} images/openmp-workshare.png
:label: fig-openmp-workshare
:width: 100%
:alt: "TODO"

Equivalent code for OpenMP work-sharing.
:::

:::{figure} images/data-race.png
:label: fig-data-race
:width: 100%
:alt: "TODO"

Data race example with RISC-V Instructions.
:::


@tab-tlp-pros-cons evaluates OpenMP for thread-level parallelism.

:::{table} Thread-level parallelism with OpenMP: pros and cons.
:label: tab-tlp-pros-cons

| Assumption | Pros | Cons | 
| :-- | :-- | :-- |
| Threads are an explicit programming model with full programmer control over parallelization | - Compiler directives are simple and easy to use <br/> - Legacy serial code does not need to be rewritten | - Compiler must support OpenMP (e.g. gcc 4.2)<br/> -Amdahl's law is gonna get you after not too many cores |
| Multiple threads operate in a shared memory environment. | - Reduces memory requirements<br/>- Programmer need not worry (that much) about data placement | - Code can only be run in shared memory environments<br/> -Synchronizing use of shared resources is hard |

::: -->