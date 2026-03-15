---
title: "Superscalar"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/M95RT-gqah8
:width: 100%
:title: "[CS61C FA20] Lecture 23.3 - Pipelining III: Superscalar"
:::

::::

## Visuals

:::{figure} images/superscalar-processors.png
:label: fig-superscalar
:width: 100%
:alt: "TODO"

Superscalar processors start multiple instructions per clock cycle.
:::

<!-- reprint of iron-law -->
<!-- ```{math} :label: superscalar-law
\frac{\text{time}}{\text{program}} = \frac{\text{instructions}}{\text{program}} * \frac{\text{cycles}}{\text{instructions}} * \frac{\text{time}}{\text{cycles}}
``` -->

:::{figure} images/arm-a53-benchmark.png
:label: fig-arm-a53-benchmark
:width: 70%
:alt: "TODO"

ARM A53 Benchmark (horizontal yellow line where $\text{CPI}=1$).
:::