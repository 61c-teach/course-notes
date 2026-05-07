---
title: "Flynn's Taxonomy"
---

(sec-flynns-taxonomy)=
## Learning Outcomes

* Explain what "parallelizing a program" means.
* Identify the four different categories of Flynn's Taxonomy: SISD, SIMD, MISD, and MIMD.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/sbXviUwXRxA
:width: 100%
:title: "[CS61C FA20] Lecture 32.3 - Flynn Taxonomy, SIMD Instructions: Flynn's Taxonomy"
:::

::::

Can we be more efficient in writing sequential C code on a serial processor? We discussed some optimizations in an [earlier section](#sec-dgemm-sequential). We can write assembly code and do better with "micro" optimizations like loop unrolling—but in general, compilers are pretty good nowadays and it's not that easy to beat them. We can rewrite our programs to make better use of the memory hierarchy, like we explored with our cache blocking exercise earlier.

But how do we leverage **hardware** improvements? That is the topic of this section.

## Parallelism: Software vs. Hardware

Because of the abrupt shift in processor design towards parallelism, there are a LOT of closely related terms when it comes to paralellism. @tab-hw-sw-parallelism is an adaptaion of P&H 6.1 to clarify the terms used in software versus hardware. The biggest confusion is often between **concurrency** and **parallelism**.[^stackoverflow]

[^stackoverflow]: For more about concurrency and parallelism, see [StackOverflow](https://stackoverflow.com/questions/1050222/what-is-the-difference-between-concurrency-and-parallelism).

:::{table} Software perspective on concurrency vs. hardware perspective on parallelism.
:label: tab-hw-sw-parallelism

<style>
    .hwsw-table {
        width: 100%;
        border-collapse: collapse;
        text-align: center;
        font-family: sans-serif;
    }
    .hwsw-table th, .hwsw-table td {
        border: 1px solid #ddd;
        padding: 12px;
    }
    .hwsw-table thead tr, .hwsw-table .label-cell {
        background-color: #f2f2f2;
        font-weight: bold;
    }
</style>

<table class="hwsw-table">
    <thead>
        <tr>
            <th></th>
            <th colspan="2">Software</th>
        </tr>
        <tr>
            <th class="label-cell">Hardware</th>
            <th>Sequential</th>
            <th>Concurrent</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td class="label-cell"><b>Serial</b></td>
            <td>Basic matrix multiply running on single-core system</td>
            <td>Operating System running on single-core system</td>
        </tr>
        <tr>
            <td class="label-cell"><b>Parallel</b></td>
            <td>Basic matrix multiply running on modern laptop</td>
            <td>Operating System running on modern laptop</td>
        </tr>
    </tbody>
</table>
:::

Notes:

* Software is inherently sequential or concurrent.
* Hardware is serial or parallel.
* Concurrent software can run on serial and parallel hardware; similarly, sequential software can run on serial and parallel hardware.
* **"Parallelizing" a program** colloquially means figuring out how to write a software program to run efficiently on parallel hardware. This can involve making naturally sequential software have high performance on parallel hardware, or to make concurrent processors have high performance on multicore systems as the number of cores (processors) increases.

The last of these points is the most important.

## Flynn's Taxonomy

Now let's shift towards classifying serial and parallel **hardware** using **Flynn's Taxonomy**.[^flynn] There are four entries in @tab-flynn-taxonomy that classify different levels of parallelism based on **data streams** and **instruction streams**.

[^flynn]: Professor Michael J. Flynn was Professor Emeritus at Stanford University. In 1962, he proposed a taxonomy of computer architectures. Flynn's taxonomy is still used today to describe modern processors. [Wikipedia](https://en.wikipedia.org/wiki/Flynn%27s_taxonomy)

:::{table} [Flynn's taxonomy](https://en.wikipedia.org/wiki/Flynn%27s_taxonomy): A system for classifying parallel hardware.
:label: tab-flynn-taxonomy

<style>
    .flynn-table {
        width: 100%;
        border-collapse: collapse;
        text-align: center;
        font-family: sans-serif;
    }
    .flynn-table th, .flynn-table td {
        border: 1px solid #ddd;
        padding: 12px;
    }
    .flynn-table thead tr, .flynn-table .label-cell {
        background-color: #f2f2f2;
        font-weight: bold;
    }
</style>

<table class="flynn-table">
    <thead>
        <tr>
            <th></th>
            <th colspan="2">Data Streams</th>
        </tr>
        <tr>
            <th class="label-cell">Instruction Streams</th>
            <th>Single</th>
            <th>Multiple</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td class="label-cell"><b>Single</b></td>
            <td>SISD</td>
            <td>SIMD</td>
        </tr>
        <tr>
            <td class="label-cell"><b>Multiple</b></td>
            <td>MISD</td>
            <td>MIMD</td>
        </tr>
    </tbody>
</table>
:::

* [SISD](#fig-sisd) (**Single Instruction, Single Data**, pronounced "SIS-dee"): A serial computer that exploits no parallelism in either the instruction or data streams.
* [SIMD](#fig-simd) (**Single Instruction, Multiple Data**, pronounced "SIM-dee"): Computer that applies a single instruction stream to multiple data streams for operations that may be naturally parallelized. 
* [MISD](#fig-misd) (**Multiple Instruction, Single Data**, pronounced "MIZ-dee"): Exploits multiple instruction streams against a single data stream for data operations that can be naturally parallelized.
* [MIMD](#fig-mimd) (**Multiple Instruction, Multiple Data**, pronounced "MIM-dee"): Multiple autonomous processors simultaneously executing different instructions on different data.

Toggle the tabs below to discover examples of each type of architecture.

<!-- start grid -->
:::::::{grid} 2

::::::{tab-set} <!-- SISD -->

:::::{tab-item} SISD
:::{figure} images/sisd.png
:label: fig-sisd
:width: 100%
:alt: "Flynn taxonomy SISD diagram with a data pool on the left and an instruction pool on the top that both feed into a processor unit box in the center."
SISD: Single Instruction/Single Data Stream
:::
:::::
:::::{tab-item} SISD Uses
A sequential processor steps through the instruction pool, matches it with the data in memory, and processes each instruction-data pair one at a time.

* Our RISC-V processor (single-cycle or five-stage pipeline)
* (out of scope) Superscalar processors because the programming model is sequential
:::::
::::::

::::::{tab-set}

:::::{tab-item} SIMD
:::{figure} images/simd.png
:label: fig-simd
:width: 100%
:alt: "Flynn taxonomy SIMD diagram a data pool on the left that feeds into four parallel processor unit boxes in the center. A single instruction pool at the top similarly feeds into the four parallel processor units."
SIMD: Single Instruction/Multiple Data Stream
:::
:::::
:::::{tab-item} SIMD Uses
Issue one instruction (e.g., "add") that operates on multiple data pairs at the same time. Useful for neural nets, imaging, and scientific applications.

* Intel SIMD instruction extensions (see later section on [Intel intrinsics](#sec-intrinsics))
* NVIDIA Graphics Processing Unit (GPU)[^nvidia]

[^nvidia]: See [NVIDIA Graphics Cards](https://www.nvidia.com/en-us/geforce/graphics-cards/).

:::::
::::::

::::::{tab-set}
:::::{tab-item} MISD
:::{figure} images/misd.png
:label: fig-misd
:width: 100%
:alt: "Flynn taxonomy MISD diagram with a single stream data pool that feeds into one processor unit and then the other, and an instruction pool that feeds into both processor units in parallel."
MISD: Multiple Instruction/Single Data Stream
:::
:::::
:::::{tab-item} MISD Uses

None nowadays.

* Historical significance, e.g., certain kinds of array processors
* Professor Nikolic: "It’s like whether you'd like your eggs scrambled or sunny side up and saying, 'both'."

:::::
::::::

::::::{tab-set}
:::::{tab-item} MIMD
:::{figure} images/mimd.png
:label: fig-mimd
:width: 100%
:alt: "Flynn taxonomy MIMD diagram with a data pool that feeds four streams of data through four parallel processor units and then another four parallel processor units, and an instruction pool that feeds the first set of processor units in parallel and the second set of four processor units in parallel with a second instruction stream."
MIMD: Multiple Instruction/Multiple Data Stream
:::
:::::
:::::{tab-item} MIMD Uses

Anything system involving multiple processors operating concurrently.

* Multicore processors (e.g., modern laptops)
* Warehouse Scale Computers (e.g., datacenters)

:::::
::::::

:::::::
<!-- end grid -->

(#sec-spmd)=
:::{note} What is most common?

SISD is what we have done up to now in CS 61C. However, in modern architectures, **SIMD and MIMD** are the most commonly encountered today—usually both in the same system.[^spmd]
:::

[^spmd]: For what it's worth, most programs written today assume a SPMD (single program, multiple data) model. With SPMD, we write a single program that uses multiple degrees of parallelism across processors of a MIMD computer with some cross-processor coordination.

Over the next few lectures, we will explore these architectures and write programs that exploit the hardware parallelism available. Stay tuned!!!