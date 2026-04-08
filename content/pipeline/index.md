---
title: "Performance Metrics"
---

## Learning Outcomes

* Explain the difference between latency and throughput.
* Give examples of latency and throughput measures in computer architecture.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/dTmErM78vD4
:width: 100%
:title: "[CS61C FA20] Lecture 21.1 - Pipelining I: Pipelining"
:::

::::

:::{warning} Review pipelined circuits

We briefly mention throughput and latency when we discuss registers in pipelined circuits, covered in [this section](#sec-pipelining-circuits) of the Synchronous Digital Systems unit. We reocmmend reviewing that section before continuing.

:::

In our discussion of [instruction timing](#sec-instruction-timing), we computed the fastest clock frequency possible for our single-cycle datapath. With [some assumptions](#tab-timing-steps), we determined that the shortest clock period 800 ps was determined by the critical path of load instructions. This resulted in a maximum clock frequency of 1.25 GHz, meaning the CPU could finish 1.25 billion instructions per second.

Consider one of the great ideas of this course: **Performance measurement and improvement**. Can we improve our processor's performance? It's not obvious what we mean by this question. There are many **performance measures** possible:

* Execution time of a single instruction
* Execution time of a single job
* Total number of instructions executed in a given unit of time
* Energy per instruction
* Cost over the lifetime of a chip

## Latency, Throughput, and Energy Efficiency

We consider three performance measures in this course:

* **Latency**: How long end-to-end a computer takes to complete something: an instruction, a program/task, a set of tasks, etc.
* **Throughput**: How efficiently a computer executes tasks, instructions, etc., once it gets going.
* **Energy Efficiency**: How much energy is consumed per task

Depending on the unit of analysis (in the computer architecture context, what we are trying to optimize), our units for these measures may vary. We discuss this tension with a transportation analogy.

## Transportation Analogy

Consider two vehicles: a sports car and a bus, with the features in @tab-transportation-params.

:::{table} Two vehicles with different features.
:label: tab-transportation-params

| Category | Sports Car | Bus |
| :--- | :--- | :--- |
| Passenger Capacity | 2 people | 50 people |
| Travel Speed | 200 mph | 50 mph |
| Gas Mileage | 5 mpg | 2 mpg |

:::

To compare which vehicle performs "better," we must determine a **benchmark task**, such as the following:

> Transport 100 passengers over 50 miles.[^round-trip]

[^round-trip]: Assume 50 miles round trip, or 50 miles one-way where the vehicle immediately warps back upon completion of each trip. Also assume passenger loading/unloading, gas refilling, traffic, etc., all incurs negligible delay.

Next, let's consider how the two vehicles fare on this task across several different performance measures in @tab-transportation-measures:

:::{table} Vehicle performance on a specified benchmark task.
:label: tab-transportation-measures
:align: center

| Measure | Sports Car | Bus |
| :--- | :--- | :--- |
| Time per trip | 15 mins | 60 mins |
| Time for 100 passengers | 750 mins (50 2-person trips) | 120 mins (2 50-person trips) |
| Passengers per hour | 8 passengers/hour | 50 passengers per hour |
| Gallons per passenger | 5 gallons | 0.5 gallons |

:::

The sports car has to take many trips, even though each individual trip time is short. By contrast, the bus completes the overall task faster and with less energy because of its higher capacity. While the sports car has better **latency** per trip, the bus has much better throughput and energy efficiency per passenger.

Let us translate this analogy back to the computer world in @tab-performance-compare.

:::{table} Transportation Analogy vs. Performance Measures in Computers.
:label: tab-performance-compare
:align: center

| Transportation Analogy | Measure | In a Computer |
| :--- | :--- | :--- |
| Time per trip | **Latency** | Instruction latency |
| Time for 100 passengers | **Latency** | **Program execution time** (e.g. time to update display) |
| Passengers/hour | **Throughput** | **Total tasks per unit time** (e.g. # of server requests handled per hour) or **instruction throughput** (e.g., instructions/second) |
| Gallons per passenger | **Energy Efficiency** | **Energy per task** (e.g. how many movies you can watch per battery charge) |

:::

## In This Course

In this unit, we use this discussion of latency and throughput to motivate our RISC-V five-stage pipeline, which increases instruction throughput from the single-cycle case. After describing the details of this architecture, we consider how to fix [pipeline hazards](#sec-pipeline-hazards)—when instructions cannot execute properly.

We then discuss latency with the "iron law of processor performance," which identifies the high-level components that impact program execution time on a given processor, regardless of implementation.

While not the focus of our class, we must also mention real industry metrics like cost over lifetime. The sports car might be \$64,000 with a "life" expectancy of 8 years, whereas the bus may be \$400,000 with an expectancy of 12 years.
