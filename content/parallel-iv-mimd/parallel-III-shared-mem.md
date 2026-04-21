---
title: "Shared Memory and Caches"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/zSONGMSsMgM
:width: 100%
:title: "[CS61C FA20] Lecture 35.2 - Thread-Level Parallelism III: Shared Memory and Caches"
:::

::::

## Visuals

:::{figure} images/smp.png
:label: fig-smp
:width: 65%
:alt: "Symmetric multiprocessing diagram: several cores or sockets connect through an interconnect or crossbar to a unified physical memory and optionally a shared last-level cache. Coherence control blocks or snoop filters appear on the path to show one address space visible to all processors."

Shared-memory Multiprocessor (SMP) with multiple cores and a single, coherent memory.
:::