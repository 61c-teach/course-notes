---
title: "Synchronization"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Eumrdr9Oqys
:width: 100%
:title: "[CS61C FA20] Lecture 34.4 - Thread-Level Parallelism II: Synchronization"
:::

::::

## Visuals

:::{figure} images/deadlock.png
:label: fig-deadlock
:width: 65%
:alt: "Photograph or stylized aerial diagram of vehicles gridlocked at an intersection, each lane waiting on another in a cycle so no car can proceed—mirroring circular wait in locking. Caption ties the visual metaphor to threads holding locks while waiting on peers."

Real life deadlock example with traffic jam.
:::

:::{figure} images/imp-locks.png
:label: fig-imp-locks
:width: 100%
:alt: "Hardware or pseudocode schematic of lock primitives: atomic read-modify-write or test-and-set block, queue of waiting threads, and state bits indicating locked versus unlocked. Arrows show a thread acquiring the lock before entering a critical section and releasing afterward."

Implementation of locks for thread synchronization.
:::