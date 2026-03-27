---
title: "Pipelining: Laundry"
subtitle: Coming soon. Thanks for your patience.
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

The concept of **pipelining** will increase our compute throughput. Before we jump into our RISC-V pipeline, let's first start with a real-life example of laundry. Anyone who has done a lot of laundry has intuitively used pipelining. The four steps of laundry are shown in @fig-laundry-setup:
:::{figure} images/laundry-setup.png
:label: fig-laundry-setup
:width: 100%
:alt: "TODO"

Pipelining laundry analogy.
:::

1. **Washer Stage** (30 minutes). Place one dirty load of clothes in the washer.
1. **Dryer Stage** (30 minutes). When the washer is finished, place the wet load in the dryer.
1. **"Folder" Stage** (30 minutes). When the dryer is finished, place the dry load on a table and fold.
1. **"Stasher" Stage** (30 minutes). When folding is finished, put clothes in drawers.

Suppose our laundry **benchmark task** involves four people in a laundromat, or shared laundry room[^laundry-assumptions], who all need to do their laundry on a Sunday evening. In @fig-laundry-setup, each person is denoted by a laundry bag with their number (1 through 4).

[^laundry-assumptions]: The shared laundry room has a single washer, a single dryer, a single folding counter, and infinite but single set of drawers mysteriously located in the room itself.

## Sequential Laundry

Consider a **sequential** approach to using laundry, where only one person can use the room at a time,[^sequential-assumptions] as shown in @fig-laundry-sequential.
Person 1 starts at 6pm and finishes all four steps at 8pm; then, Person 2 starts and finishes 8-10pm, followed by Person 3, and finally Person 4, who doesn't finish until 2am.

[^sequential-assumptions]: Imagine there is a single key for the shared laundry room. At the beginning of the washing stage, you instantaneously obtain the key, unlock the room and enter, and relock the room so no one else can enter. Then right at the end of the folding stage, you instantaneously unlock the room, exit and relock, and put back the key.

:::{figure} images/sequential-laundry.png
:label: fig-laundry-sequential
:width: 100%
:alt: "TODO"

Timeline for sequential laundry.
:::

This implementation takes **8 hours** for just **4 loads** of laundry. If we look closely at the four major resources, they are mostly wasted; after all, each person exclusively uses one of the washer, dryer, counter, and drawers as they are progressing through the four steps. The washer, for example, was only used for 30 minutes of the whole two hours.

We can certainly do better by trying to perform these steps concurrently, where each person performs a different step. This is the intuition behind **pipelining**.

## Pipelined Laundry

Now consider a **pipelined** approach to using laundry,[^pipelined-assumptions] where as soon as Person 1 is done with the washer and takes out their wet clothes to move to the dryer, Person 2 can put their own dirty clothes in the washer, and so on. In @fig-laundry-parallel, Person 1 still starts at 6pm and finishes at 8pm, but now Person 4 can start much earlier at 7:30pm and finish by 9:30pm. Phew!

[^pipelined-assumptions]: Assume the door is unlocked now. The laundromat owner figured it out.

:::{figure} images/parallel-laundry.png
:label: fig-laundry-parallel
:width: 50%
:alt: "TODO"

Timeline for pipelined laundry.
:::

This implementation takes just **3.5 hours** for the same **4 loads** of laundry. At different 30-minute intervals, customers share the four resources because they are completing different steps of their laundry routine (@fig-different-phases). At 7:30-8pm, all four resources are occupied by customers.

:::{figure} images/customers-different-phases.png
:label: fig-different-phases
:width: 100%
:alt: "TODO"

Two views of pipelined laundry: Over time (left) versus the snapshot of the laundry room during a given time interval (e.g., 7-7:30pm).
:::

## Laundry: Latency vs. Throughput

From P&H 4.6:

> The pipelining paradox is that the time from placing a single dirty sock in the washer until it is dried, folded, and put way is not shorter for pipelining; the reason pipelining is faster for many loads is that everything is working in parallel, so more loads are finished per hour. Pipelining improves \*throughput\* of our laundry system. Hence, pipelining would not decrease the time to complete one load of laundry, but when we have many loads of laundry to do, the improvement in throughput decreases the total time to complete the work.

@tab-laundry-compare shows performance measures on our laundry benchmark task:

:::{table} Latency vs. Throughput: Sequential vs. Parallel Laundry.
:label: tab-laundry-compare
:align: center

| Measure | Laundry Analogy | Sequential | Pipelined |
| :--- | :--- | :--- | :--- |
| Program execution time | Time to finish all 4 loads | 8 hours | 3.5 hours |
| Instruction latency | Time to finish a single load | 2 hours | 2 hours |
| Instruction throughput | Average\* number of loads per 30 mins | 0.25 | 1\*|
:::

Note (\*): Throughput is approximate for our tiny 4-customer task. In this case, 4 loads complete in seven 30-minute intervals, or approximately 0.57 loads per 30-minute interval. If we had many customers, though, the pipeline is fully "filled," where exactly 1 customer will finish each 30 minutes. We report this steady-state in the @tab-laundry-compare.

## RISC-V Datapath: Pipelined and Sequential

Coming soon!

<!-- GOT TO HERE
:::{figure} images/ipc-timeline.png
:label: fig-ipc-timeline
:width: 100%
:alt: "TODO"

IPC Timeline diagram showing one customer per "cycle" in laundry analogy.
:::
-->

<!--

## Visuals

:::{figure} images/five-phases.png
:label: fig-five-phases
:width: 100%
:alt: "TODO"

5 Phase instruction timing diagram: IF, ID, EX, MEM, WB.
:::

:::{figure} images/clock-period-table.png
:label: fig-clock-period-table
:width: 100%
:alt: "TODO"

Table of clock periods per instruction to find longest critical path.
:::

:::{figure} images/five-phase-timing.png
:label: fig-five-phase-timing
:width: 100%
:alt: "TODO"

Detailed timing diagram for 5 instruction phases.
:::


-->