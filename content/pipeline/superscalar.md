---
title: "Superscalar"
subtitle: This content is out of scope
---

(sec-superscalar)=
## Learning Outcomes

* Understand that a superscalar processor has CPI < 1.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/M95RT-gqah8
:width: 100%
:title: "[CS61C FA20] Lecture 23.3 - Pipelining III: Superscalar"
:::

::::

We can try multiple strategies to further increase performance:

1. **Increase clock rate.** Limited by technology and power dissipation.
2. **Increase pipeline depth.** "Overlap" instruction execution through deeper pipeline, e.g., 10 or 15 stages. Less work per stage means shorter clock cycle/lower power. But there is **more potential** for all three types of hazards. And more stalling means that our average CPI will be greater than 1.
3. Design a **superscalar processor**. Desktops, laptops, cell phones, etc. often have a few of these, combined with simpler 5-stage pipeline processors.

At a high-level, superscalar processors are **multiple-issue**, meaning they start multiple instructions per clock cycle. In a superscalar processor, multiple execution units execute instructions in parallel, where each execution unit has its own pipeline.

:::{figure} images/superscalar-processors.png
:label: fig-superscalar
:width: 100%
:alt: "Superscalar timeline showing multiple instructions beginning execution in the same clock cycle using parallel issue slots."

Superscalar processors start multiple instructions per clock cycle.
:::

The processor hardware must also have some sort of dynamic "out-of-order" execution, where it reorders instructions dynamically to reduce impact of hazards.

We note that superscalar processors, where multiple instructions are executed on multiple pipelines in a single processor, should be contrasted with multicore processors, which have separate threads per core.
\
Superscalar processors start multiple instructions per clock cycle. In our [Iron Law of Processor Performance](#sec-iron-law), superscalar processors have average CPI < 1 because IPC > 1 (multiple instructions completed per clock cycle).

<!-- reprint of iron-law -->
<!-- ```{math} :label: superscalar-law
\frac{\text{time}}{\text{program}} = \frac{\text{instructions}}{\text{program}} * \frac{\text{cycles}}{\text{instructions}} * \frac{\text{time}}{\text{cycles}}
``` -->

:::{figure} images/arm-a53-benchmark.png
:label: fig-arm-a53-benchmark
:width: 70%
:alt: "ARM Cortex-A53 benchmark plot with CPI on the y-axis and a highlighted horizontal reference line at CPI equals one."

ARM A53 Benchmark (horizontal yellow line where $\text{CPI}=1$).
:::