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

## Visuals

:::{figure} images/thread-ordering.png
:label: fig-thread-order
:width: 65%
:alt: "Timeline with horizontal time axis and several rows of labeled thread or task segments showing different legal interleavings of the same instructions on one CPU. Shaded blocks illustrate context switches versus back-to-back execution so students see nondeterministic scheduling visually."

Possible CPU task ordering while using multiple threads.
:::

:::{figure} images/process-v-time-threads.png
:label: fig-process-v-time-threads
:width: 65%
:alt: "Stacked timeline comparing one process containing a single thread against another process expanded into multiple threads of control. Vertical time lines show program counters advancing; the multithreaded version duplicates instruction pointer tracks or shows concurrent bursts inside one address space."

Process over time when using multiple threads.
:::

:::{figure} images/single-v-multi-thread.png
:label: fig-single-multi-thread
:width: 90%
:alt: "Side-by-side process diagrams: left process box encloses one thread of execution with a single stack and register context; right process box encloses several threads each with its own stack pointer region but shared code and heap segments. Annotations highlight what is duplicated versus shared."

Single-threaded process vs. multi-threaded process.
:::

:::{figure} images/concurrency-parallelism.png
:label: fig-concurr-parallel
:width: 90%
:alt: "Two-part flowchart: concurrency path shows interleaved tasks on one processor core with rapid context switches making independent tasks appear simultaneous; parallelism path shows tasks assigned to separate hardware resources executing at the same wall-clock time. Distinct icons for one CPU versus many cores reinforce the definitions."

Concurrency vs. Parallelism process flow chart.
:::