---
title: "Pipeline Hazards"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/71Mb1OjKwbs
:width: 100%
:title: "[CS61C FA20] Lecture 22.2 - Pipelining II: Pipeline Hazards"
:::

::::

## Visuals

:::::{grid} 4

::::{card}
:::{figure} images/warning-fall.png
:label: fig-warning-fall
:width: 100%
:alt: "TODO"

<!-- Warning: Fall! -->
:::
::::

::::{card}
:::{figure} images/warning-rf.png
:label: fig-warning-rf
:width: 100%
:alt: "TODO"

<!-- Warning: Radio Frequency! -->
:::
::::

::::{card}
:::{figure} images/warning-voltage.png
:label: fig-warning-voltage
:width: 100%
:alt: "TODO"

<!-- Warning: High-Voltage! -->
:::
::::

::::{card}
:::{figure} images/caution-xray.png
:label: fig-caution-xray
:width: 100%
:alt: "TODO"

<!-- Caution: X-Ray! -->
:::
::::

:::::

:::{figure} images/pipelined-hazards.png
:label: fig-pipelined-hazards
:width: 100%
:alt: "TODO"

Diagram of different types of pipelined hazards in datapath.
:::

:::{figure} images/structural-hazard.png
:label: fig-structural-hazard
:width: 100%
:alt: "TODO"

Structural Hazard: multiple instructions competing for single hardware resource.
:::

:::{figure} images/regfile-structural-hazard.png
:label: fig-regfile-hazard
:width: 70%
:alt: "TODO"

Structural Hazard: RegFile without support of simultaneous read/write.
:::

:::{figure} images/regfile-no-structural-hazard.png
:label: fig-regfile-no-hazard
:width: 70%
:alt: "TODO"

RV321 RegFile design preventing structural hazard in RegFile.
:::

:::{figure} images/separate-mem.png
:label: fig-separate-mem
:width: 80%
:alt: "TODO"

RV321 IMEM/DMEM design preventing structural hazard in memory.
:::

:::{figure} images/separate-onchip-mem.png
:label: fig-separate-onchip-mem
:width: 80%
:alt: "TODO"

Processor and Memory diagram of separate IMEM/DMEM in memory.
:::