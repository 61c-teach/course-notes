---
title: "Intro to Hazards"
---

(sec-pipeline-hazards)=
## Learning Outcomes

* Identify the three types of hazards encountered in the RISC-V pipeline.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/71Mb1OjKwbs
:width: 100%
:title: "[CS61C FA20] Lecture 22.2 - Pipelining II: Pipeline Hazards"
:::

::::

One of the costs of pipelining is that it introduces **pipeline hazards**. A pipeline hazard, or simply **hazard**, is a situation in which a planned instruction cannot execute in the “proper” clock cycle. In other words, a hazard is when executing a combination of instructions would be impossible or would lead to incorrect program execution.

There are three types of hazards:

+++ {"label": "block-def-hazard-structural"}
[**Structural hazard**](#sec-structural-hazards): The hardware in the processor cannot support the combination of instructions that we want to execute in the same clock cycle.
+++ {"label": "block-def-hazard-data"}
[**Data hazard**](#sec-data-hazards): Instructions have data dependencies, and some instructions must wait for previous instructions to complete—otherwise outdated values would be used in computation.
+++ {"label": "block-def-hazard-control"}
[**Control hazard**](#sec-control-hazards): The flow of execution depends on previous instructions. The wrong instructions are executed.
+++

We discuss how to resolve hazards through various solutions in hardware, during execution time, or in the program code:

* **Stalling** is one inefficient solution to resolving any type of hazard, where we delay instructions until we can execute them without incurring hazards. Because performance suffers with stalling, we will discuss ways to avoid stalling where possible (though it is always a good last resort). See [this section](#sec-data-hazards-stall).
* Specify **hardware requirements**, i.e., on specific hardware units within the pipeline.
* **Forwarding**, also known as bypassing, is when we wire more connections in the datapath and instead use results when computed. See [this section](#sec-data-hazards-forward).
* **Code scheduling**, where we rearrange instructions at compile-time to avoid hazards.

In practice, computers use a combination of the above techniques to maximize throughput and maintain the benefits of **instruction-level parallelism** that pipelining provides.
