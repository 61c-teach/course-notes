---
title: "OpenMP"
subtitle: TODO
---

(sec-openmp)=
## Learning Outcomes

* TODO
* TODO

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


## Visuals

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