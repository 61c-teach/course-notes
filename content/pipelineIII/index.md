---
title: "Load Data Hazard"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/VWCAqieFkHI
:width: 100%
:title: "[CS61C FA20] Lecture 23.1 - Pipelining III: Load Data Hazard"
:::

::::

## Visuals

:::{figure} images/load-hazard-q.png
:label: fig-load-hazard-q
:width: 100%
:alt: "TODO"

Waterfall diagram: Which data hazards can forwarding fix?
:::

:::{figure} images/load-hazard-ans.png
:label: fig-load-hazard-ans
:width: 100%
:alt: "TODO"

Waterfall diagram: Forwarding can fix EX $\rightarrow$ EX and MEM $\rightarrow$ EX data hazards.
:::

:::{figure} images/load-hazard-prob-mem.png
:label: fig-load-hazard-mem
:width: 100%
:alt: "TODO"

Waterfall diagram: Forwarding **cannot** fix MEM $\rightarrow$ EX for `lw`.
:::

:::{figure} images/load-delay-slot.png
:label: fig-load-delay-slot
:width: 100%
:alt: "TODO"

Waterfall diagram with **load delay slot** after a load instruction.
:::

:::{figure} images/code-scheduling.png
:label: fig-simple-compilation
:width: 100%
:alt: "TODO"

Simple compilation for 7 instructions (9 clock cycles).
:::

:::{figure} images/code-scheduling-sol.png
:label: fig-code-scheduling
:width: 100%
:alt: "TODO"

Code compilation with **code scheduling** for 7 instructions (7 clock cycles).
:::