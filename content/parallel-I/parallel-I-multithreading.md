---
title: "Multithreading"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

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
:alt: "Fork-join timeline: a main thread proceeds serially, then a fork point fans out into several parallel child segments that execute concurrently, each with its own labeled interval, before a join barrier resynchronizes all paths back to a single continuation on the main thread. Vertical synchronization lines mark fork and join events."

Fork-join model over time with multiple parallel tasks off the main thread.
:::