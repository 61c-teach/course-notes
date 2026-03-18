---
title: "Data Hazards"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/iOKJ-oW1urY
:width: 100%
:title: "[CS61C FA20] Lecture 22.4 - Pipelining II: Data Hazards"
:::

::::

## Visuals

:::{figure} images/read-write-data-hazard.png
:label: fig-data-hazard
:width: 100%
:alt: "TODO"

Waterfall diagram for read-write data hazard.
:::

:::{figure} images/alu-hazard-result.png
:label: fig-alu-hazard
:width: 100%
:alt: "TODO"

Waterfall diagram for ALU problem: WB in `inst1` must happen before EX in `inst2`.
:::

:::{figure} images/stalling.png
:label: fig-stalling
:width: 100%
:alt: "TODO"

Solution 1: Stalling pipeline with `nop`.
:::

:::{figure} images/forwarding.png
:label: fig-forwarding
:width: 100%
:alt: "TODO"

Solution 2: Forwarding (bypassing) to use result when it is computed.
:::

:::{figure} images/forwarding-pipeline-diagram.png
:label: fig-forwarding-pipeline
:width: 100%
:alt: "TODO"

Pipeline diagram for forwarding with EX hazard.
:::

:::{figure} images/forwarding-pipeline-table.png
:label: fig-forwarding-table
:width: 100%
:alt: "TODO"

Waterfall diagram for forwarding with EX hazard.
:::