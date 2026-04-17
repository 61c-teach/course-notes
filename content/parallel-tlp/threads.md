---
title: "Threads"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/86m2GDIlcxA
:width: 100%
:title: "[CS61C FA20] Lecture 33.3 - Thread-Level Parallelism I: Threads"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/_ZL8Z81yI5w
:width: 100%
:title: "[CS61C FA20] Lecture 33.4 - Thread-Level Parallelism I: Multithreading"
:::

::::

## Visuals

:::{figure} images/fork-join-model.png
:label: fig-fork-join
:width: 100%
:alt: "TODO"

Fork-join model over time with multiple parallel tasks off the main thread.
:::

## Visuals

:::{figure} images/thread-ordering.png
:label: fig-thread-order
:width: 65%
:alt: "TODO"

Possible CPU task ordering while using multiple threads.
:::

:::{figure} images/process-v-time-threads.png
:label: fig-process-v-time-threads
:width: 65%
:alt: "TODO"

Process over time when using multiple threads.
:::

:::{figure} images/single-v-multi-thread.png
:label: fig-single-multi-thread
:width: 90%
:alt: "TODO"

Single-threaded process vs. multi-threaded process.
:::

:::{figure} images/concurrency-parallelism.png
:label: fig-concurr-parallel
:width: 90%
:alt: "TODO"

Concurrency vs. Parallelism process flow chart.
:::

From UC Berkeley Professor Emeritus Edward Lee:

> Although threads seem to be a small step from sequential
computation, in fact, they represent a huge step. They discard the most essential and appealing properties of sequential computation: understandability, predictability, and determinism. Threads, as a model of computation, are wildly nondeterministic, and the job of the programmer becomes one of pruning that nondeterminism.
>
> -- "The Problem with Threads." Edward Lee[^lee]

[^lee]: Edward A. Lee. "The Problem with Threads."
[Technical Report No. UCB/EECS-2006-1](http://www.eecs.berkeley.edu/Pubs/TechRpts/2006/EECS-2006-1.html). January 2006.
See also: Computer 39, 5 (May 2006), 33–42. [DOI](https://doi.org/10.1109/MC.2006.180)

As we will see over the next few sections, thread-level programming is **hard**. Let's try it out!