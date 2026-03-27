---
title: "Set-Associative Caches"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/B4XiuH0kdEk
:width: 100%
:title: "[CS61C FA20] Lecture 27.1 - Caches IV: Set-Associative Caches"
:::

::::

## Visuals

:::{figure} images/placement-policies-so-far.png
:label: fig-placement-policies-so-far
:width: 75%
:alt: "TODO"
The placement policies spectrum, highlighting where set-associative caches fit.
:::

:::{figure} images/2-way-set-associative.png
:label: fig-2-way-set-associative
:width: 60%
:alt: "TODO"
A 2-way set-associative cache with two sets and 4-byte blocks.
:::

:::{figure} images/set-associative-memory-address.png
:label: fig-set-associative-memory-address
:width: 50%
:alt: "TODO"
A memory address broken into tag, index, and offset fields for a set-associative cache.
:::

:::{figure} images/4-way-set-associative.png
:label: fig-4-way-set-associative
:width: 75%
:alt: "TODO"
A 4-way set-associative cache structure alongside its memory address breakdown.
:::

:::{figure} images/memory-example.png
:label: fig-memory-example
:width: 100%
:alt: "TODO"
Memory represented as numbered lines, with line 12 highlighted.
:::

:::{figure} images/cache-placement-example.png
:label: fig-cache-placement-example
:width: 75%
:alt: "TODO"
Where line 12 can be placed in a fully associative, 2-way set-associative, and direct-mapped cache.
:::

:::{figure} images/placement-policies-summary-1.png
:label: fig-placement-policies-summary-1
:width: 75%
:alt: "TODO"
Summary of cache placement policies from fully associative to direct mapped.
:::

:::{figure} images/placement-policies-summary-2.png
:label: fig-placement-policies-summary-2
:width: 75%
:alt: "TODO"
Placement policies summary showing N-way set-associative as the general case.
:::