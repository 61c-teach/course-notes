---
title: "OpenMP"
subtitle: TODO
---

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
:alt: "Side-by-side code comparing a serial loop with an OpenMP-parallel version using pragma directives for parallel for, reduction, or scheduling clauses. Color or callouts map each pragma to the team of threads and shared versus private variables."

Equivalent code for OpenMP work-sharing.
:::