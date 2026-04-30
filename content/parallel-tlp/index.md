---
title: "MIMD Architectures"
---

(sec-mimd)=
## Learning Outcomes

* Identify the key components of a multicore processor: cores that execute streams of instructions independently but share memory.
* Know that in a multicore processor, cores have separate L1/L2 caches but often share an L3 cache.
* Give examples of different parallel computing systems, e.g., multicore, datacenter, supercomputer.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/iPRzpX4MKj8
:width: 100%
:title: "[CS61C FA20] Lecture 33.1 - Thread-Level Parallelism I: Parallel Computer Architectures"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Fern5BEcdlg
:width: 100%
:title: "[CS61C FA20] Lecture 33.2 - Thread-Level Parallelism I: Multicore"
:::

::::

One of the goals of this course is to teach you how to program a computer well enough to increase performance. We recommend reviewing the [Iron Law of Processor Performance](#sec-iron-law), which identifies the different components to reducing program execution time:

```{embed} #eq-iron-law
```

To improve performance, we could design our architecture as follows:

1. **Increase clock rate**, $f_s$, thereby reducing the time per cycle. If you were a computer engineer building a system, the first thing you might do to increase performance is change the "heart rate" by turning the crank on the clock speed.

    For today's technology, we've reached the practical maximum—about 5GHz for general-purpose computers. We have essentially stopped there because of power dissipation and the **power wall**, i.e., we simply cannot keep these chips cool enough to go much faster. See @fig-moores-multicore.
1. **Lower CPI**, or cycles per instruction. Since we cannot increase the speed at which we complete single instructions, we look at completing multiple instructions in the same cycle. We have briefly discussed **instruction-level parallelism**[^ilp]; in this unit, we have also introduced [SIMD architectures](#sec-simd), where one instruction operates on multiple streams of data. SIMD can be seen as one way of completing multiple instructions in one cycle.

1. **Perform multiple tasks simultaneously**. Beyond the iron law, we could leverage **multiple CPUs** to execute related or unrelated tasks (see [below](#sec-task-plp)).

1. **Do all of the above**: High clock frequency, SIMD, and multiple parallel tasks.

[^ilp]: ILP architectures: [Superscalar processors](#sec-superscalar) have CPI < 1. Pipelining will not increase CPI but will drastically increase clock speed.

:::{figure} images/moores-multicore.png
:label: fig-moores-multicore
:width: 100%
:alt: "Multi-line time-series chart titled 50 Years of Microprocessor Data comparing transistor counts, single-thread performance, clock frequency, and core counts over decades, sourced from Karl Rupp microprocessor trend data."

50 Years of Microprocessor Data. Source: [Karl Rupp: 42 Years of Microprocessor Trend Data](https://www.karlrupp.net/2018/02/42-years-of-microprocessor-trend-data/), 2018. [GitHub source](https://github.com/karlrupp/microprocessor-trend-data/tree/master/50yrs).
:::

In this section, we discuss how to divide a single program and its data into a parallel space. We introduce two closely related concepts:

* (This section) **Multicore** systems, where a system has multiple processors (i.e., **cores**) that can run simultaneously; and
* (Next section) **Multiple threads**, i.e., where a program has multiple streams of instructions that can run simultaneously.

Let's not get ahead of ourselves. Let's focus just on the **hardware** for now: multicore.

```{embed} #fig-great-idea-new-school
```

## Multicore Processors

In this course, we will focus on **multicore machines** located in our phones, watches and computers. A **multicore processor** contains multiple processors ("**cores**") in a single integrated circuit. The Apple A14 chip used in iPads and iPhones in the early 2020s is one such multicore system. In the figure below, we see that each core is labeled a CPU (central processing unit).

```{embed} #fig-apple-a14
```

(sec-task-plp)=
### Multicore processor use cases

There are two common uses of a multicore processor:

* **Partition work** of a single task between several cores. For example, each core performs part of a big matrix multiplication. We focus on this application in this course.
* **Job-level parallelism**, where cores work on unrelated problems and there is minimal to no communication between processes running on different cores. For example, HTTP web requests are distributed across different cores, and one core runs Google Slides while another runs Twitch.[^cs162]

[^cs162]: To explore job-level parallelism (also known as **process-level parallelism**), check out our upper-division Operating Systems course.

(sec-multiprocessor)=
### Multicore Execution Model

There are two components to a **multicore execution model** (sometimes known as the multiprocessor execution model):

1. Each processor (core) executes a **stream of instructions**, or **thread**, independently from other processors (cores). We discuss threads in [a later section](#sec-threads).

    * Each core has its own datapath: PC, registers, ALU, etc.
    * Each core has its own set of higher-level cahces: L1 and L2 caches.
1. **Shared memory model**: All processors (cores) access the same shared memory. We discuss cache coherency in a [later section](#sec-cache-coherency).

    * All cores share primary memory (DRAM) and sometimes the L3 cache.
    * Advantages: Processors (cores) can coordinate and communicate by storing to/loading from common locations in shared memory.  There can also be just one DRAM unit on the chip.
    * Disadvantages: Communication between processors must use the slower DRAM medium; recalling our [latency analogy](#fig-3-locality), this bottleneck is like "going to Sacramento" on each inter-core communication. Synchronization between cores[^synchronization] enforces some serialization of execution, and [Amdahl's Law](#sec-amdahls-law) will eventually be the downfall of any multicore performance gain.

[^synchronization]: Synchronization is when multiple threads of execution (often on different cores)try to coordinate how to read/write to the same spot at the same time. As we will see in a [later section](#sec-data-race), synchronization enforces some serialization of execution.

[^multicore-terminology]: (Pedantic footnote) A microprocessor is a processor on a single integrated circuit. A multiprocessor is the described execution model [above](#sec-multiprocessor). A **multicore processor** should therefore really be called a "multiprocessor microprocessor", but nowadays most people use the former as the the latter has naming redundancy. Why is multiprocessor terminology so confusing? Because many related ideas for parallel processing were pursued concurrently, and all of them are now used.

This model is illustrated in @fig-multicore-model. Processor 0 and Processor 1 are the two cores in this two-core multicore processor.

:::{figure} images/multicore-model.png
:label: fig-multicore-model
:width: 90%
:alt: "Closer view of a multicore processor floorplan: two or more labeled cores, private L1 caches, shared last-level cache or system agent, and clock or power domains as simplified boxes. Inter-core communication paths illustrate hardware threads sharing silicon versus separate chips."

The multicore processor execution model enforces a shared memory model.
:::

:::{note} Show Explanation of @fig-multicore-model
:class: dropdown

* Each core has its own datapath, along with its own control unit, its own program counter, and its own register file. Each core can therefore operate fully autonomously; one can perform an `add` while the other performs a `sub` instruction using completely separate registers.
* The two cores access the same memory (i.e., we do not double the memory hardware requirement).[^vm] This is the **shared memory model.**
* The two cores also access the same I/O interface.

[^vm]:  We did not illustrate caches in @fig-multicore-model, but each core would have its own L1 and L2 caches. We discuss [virtual memory](#sec-virtual-memory) in a later section.
:::

This chapter explores design of a multicore system:

1. How many processors (cores) should be supported in this multiprocessor?

    * Depends on the target workload.
    * Most systems: Multiple "best available single core within constraints"
    * Power-critical systems (e.g., phones): "some of the best available single cores" and "some of the most power efficient single cores", both on the same chip. The Apple M4 chip for 2026 MacBooks is designed this way:[^apple-m4]

    ```{code} bash
    $ sysctl -a | grep "physicalcpu:"
    hw.perflevel0.physicalcpu: 4
    hw.perflevel1.physicalcpu: 6
    hw.physicalcpu: 10
    ```

1. How do different processors (cores) share data? Via a shared-memory multiprocessor, as discussed [above](#sec-multiprocessor).

1. How do different processors coordinate/communicate? We will discuss this more when we cover [synchronization](#sec-locks). At a high-level:

    * Shared variables in memory and load/store instructions
    * Coordinated access to shared data through synchronization primitives (e.g., locks) that restrict access to one processor at a time

[^apple-m4]: Read more about Apple's performance and efficiency cores on [Wikipedia](https://en.wikipedia.org/wiki/Apple_M4) and the 2024 Apple press release, ["Apple introduces M4 Pro and M4 Max"](https://www.apple.com/newsroom/2024/10/apple-introduces-m4-pro-and-m4-max/).

## More Parallel Computing Systems

Parallelism exists at different scales—beyond the multicore systems we discuss in this course.

Historically, **parallel computing systems** primarily referred to **distributed computing systems** where multiple machines were wired via Ethernet to work on pieces of a pre-divided job. Nowadays, distributed computing systems refer to **supercomputers** and **datacenters**. The former are massive server racks found in national labs and crunch through floating-point data for climate simulations, neural networks and more.[^savio] The latter are the systems that power our cloud computing frameworks today.

[^savio]: Read about the [Savio supercomputer](https://research-it.berkeley.edu/services-projects/high-performance-computing-savio) at UC Berkeley.

:::{figure} images/datacenter-google.jpg
:label: fig-datacenter-google
:width: 80%
:alt: "Wide interior photograph of a Google data center aisle with rows of server racks, cable trays, and overhead lighting in Council Bluffs, Iowa."

Google Datacenter, in Council Bluffs, Iowa. [Google Europe Blog 2012](https://europe.googleblog.com/2012/10/googles-data-centres-inside-look.html), [Data Center Photo Gallery](https://datacenters.google/discover-more/photo-gallery/).
:::

To learn more about **warehouse-scale computing**, check out the bonus lectures in this course.
