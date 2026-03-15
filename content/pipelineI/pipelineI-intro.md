---
title: "Introduction to Pipelining"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/y52uRSQGYms
:width: 100%
:title: "[CS61C FA20] Lecture 21.4 - Pipelining I: Introduction to Pipelining"
:::

::::

## Visuals

:::{figure} images/laundry-setup.png
:label: fig-laundry-setup
:width: 100%
:alt: "TODO"

Pipelining laundry analogy.
:::

:::{figure} images/sequential-laundry.png
:label: fig-laundry-sequential
:width: 100%
:alt: "TODO"

Pipelining laundry analogy: sequential laundry.
:::

:::{figure} images/parallel-laundry.png
:label: fig-laundry-parallel
:width: 70%
:alt: "TODO"

Pipelining laundry analogy: parallel laundry.
:::

:::{table} Latency vs. Throughput: Sequential vs. Parallel Laundry.
:label: tab-seq-parallel-compare
:align: center

|  |  | Sequential | Pipelined |
| :--- | :--- | :--- | :--- |
| Program execution time | Time to finish all 4 loads | 8 hours | 3.5 hours |
| Instruction latency | Time to finish a single load | 2 hours | 2 hours |
| Instruction throughput | Avg number of loads per 30 mins | 0.25 | 1 |
| Clock period |   | 2 hours | 30 mins |
| CPI |   | 1 | 1 |
:::

:::{figure} images/customers-different-phases.png
:label: fig-different-phases
:width: 100%
:alt: "TODO"

Two views of pipelined laundry task: per customer vs. per time increment (30 mins).
:::

:::{figure} images/ipc-timeline.png
:label: fig-ipc-timeline
:width: 100%
:alt: "TODO"

IPC Timeline diagram showing one customer per "cycle" in laundry analogy.
:::