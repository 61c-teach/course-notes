---
title: "Processor Performance Iron Law"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/4vLGgSuP27E
:width: 100%
:title: "[CS61C FA20] Lecture 21.2 - Pipelining I: Processor Performance Iron Law"
:::

::::

## Visuals

```{math} :label: iron-law
\frac{\text{time}}{\text{program}} = \frac{\text{instructions}}{\text{program}} * \frac{\text{cycles}}{\text{instructions}} * \frac{\text{time}}{\text{cycles}}
```

::::{exercise}
:label: processor-speed
Which processor, A or B, will execute this program faster?

:::{table} Processor Performance Comparison Example.
:label: tab-processor-example
:align: center

|  | Processor A | Processor B |
| :--- | :--- | :--- |
| # Instructions | 1 million | 1.5 million |
| Average CPI | 2.5 | 1 |
| Clock rate, `f` | 2.5 GHz | 2 GHz |
:::

::::

::::{solution} processor-speed
:label: processor-speed-sol
:class: dropdown
**Processor B is faster for this task!**

:::{table} Processor Performance Comparison Example.
:label: tab-processor-example
:align: center

|  | Processor A | Processor B |
| :--- | :--- | :--- |
| # Instructions | 1 million | 1.5 million |
| Average CPI | 2.5 | 1 |
| Clock rate, `f` | 2.5 GHz | 2 GHz |
| **Program execution time** | **1 ms** | **0.75 ms** |
| **Instruction throughput (per ns)** | **1 inst/ns** | **2 inst/ns** |
:::

::::