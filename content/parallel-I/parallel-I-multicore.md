---
title: "Multicore"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Fern5BEcdlg
:width: 100%
:title: "[CS61C FA20] Lecture 33.2 - Thread-Level Parallelism I: Multicore"
:::

::::

## Visuals

:::{figure} images/multicore.png
:label: fig-multicore
:width: 65%
:alt: "System-level block diagram of a multicore computer: several processor cores on one die or module share on-chip interconnect, caches, and memory controllers leading to DRAM or I/O. Buses or mesh links show how multiple cores access shared resources compared to a single-core drawing."

Multicore Computer Architecture.
:::

:::{figure} images/multicore-model.png
:label: fig-multicore-model
:width: 90%
:alt: "Closer view of a multicore processor floorplan: two or more labeled cores, private L1 caches, shared last-level cache or system agent, and clock/power domains as simplified boxes. Inter-core communication paths illustrate hardware threads sharing silicon versus separate chips."

Model of Multicore Processor.
:::