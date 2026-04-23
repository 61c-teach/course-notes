---
title: "Energy Efficiency"
subtitle: This content is not tested
---

(sec-energy-efficiency)=
## Learning Outcomes

* Develop a working framework for measuring energy efficiency.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/N9pySCtYFHI
:width: 100%
:title: "[CS61C FA20] Lecture 21.3 - Pipelining I: Energy Efficiency"
:::

::::

Energy efficiency is vital for both mobile devices and warehouse-scale computers in data centers.
In a data center, the cost of energy can overshadow the hardware cost after just a year or two.

It is also important to note that power is generally _not_ a good measure of efficiency. Power is merely the rate of exchange, whereas energy is what is actually stored in the battery and what the utility company charges us for.

```{math}
:label: energy-efficiency
\frac{\text{energy}}{\text{program}} = \frac{\text{instructions}}{\text{program}} * \frac{\text{energy}}{\text{instructions}}
```

```{math}
:label: power-eq
\text{power} = \frac{\text{energy (J)}}{\text{second}} = \frac{\text{energy (J)}}{\text{instruction}} * \frac{\text{instructions}}{\text{cycle}} * \frac{\text{cycles}}{\text{second}}
```

Watch the video for more information!

<!--

## Visuals

:::{figure} images/processor-perf-trends.png
:label: fig-processor-trends
:width: 70%
:alt: "Historical processor performance trend chart spanning decades with an overall growth curve over time."

48 years of processor performance trends.
:::

:::{figure} images/inv-symbol.png
:label: fig-inv-symbol
:width: 35%
:alt: "Logic symbol for an inverter gate with one input and one inverted output."

Inverter (INV) symbol.
:::

:::{figure} images/inv-schematic.png
:label: fig-inv-schematic
:width: 35%
:alt: "Transistor-level schematic of an inverter showing complementary pull-up and pull-down devices."

Inverter (INV) schematic.
:::

:::{figure} images/clock-rate-power-trends.png
:label: fig-power-trends
:width: 70%
:alt: "Clock-rate and power trend chart over time illustrating frequency growth and power limits."

36 years of clock rate and power trends.
:::
-->