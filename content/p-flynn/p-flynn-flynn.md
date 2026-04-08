---
title: "Flynn's Taxonomy"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/sbXviUwXRxA
:width: 100%
:title: "[CS61C FA20] Lecture 32.3 - Flynn Taxonomy, SIMD Instructions: Flynn's Taxonomy"
:::

::::

## Visuals

:::{figure} images/flynn-taxonomy.png
:label: fig-flynn-tax
:width: 70%
:alt: "TODO"

Flynn's taxonomy parallel hardware classification system types based on data/instruction streams.
:::

<!-- start grid -->
:::::::{grid} 2

::::::{card}
:header: SISD
:::{figure} images/sisd.png
:label: fig-sisd
:width: 100%
:alt: "TODO"
SISD: Single Instruction/Single Data Stream
:::
::::::

::::::{card}
:header: SIMD
:::{figure} images/simd.png
:label: fig-simd
:width: 100%
:alt: "TODO"
SIMD: Single Instruction/Multiple Data Stream
:::
::::::

::::::{card}
:header: MIMD
:::{figure} images/mimd.png
:label: fig-mimd
:width: 100%
:alt: "TODO"
MIMD: Multiple Instruction/Multiple Data Stream
:::
::::::

::::::{card}
:header: MISD
:::{figure} images/misd.png
:label: fig-misd
:width: 100%
:alt: "TODO"
MISD: Multiple Instruction/Single Data Stream
:::
::::::

:::::::
<!-- end grid -->