---
title: "Threads"
---

(sec-threads)=
## Learning Outcomes

* Define thread, program, and process.
* Differentiate between software thread and hardware threads.
* Explain how (and why!) the OS performs context switches.
* Explain at a high-level how single-core processors can run multithreaded programs, and how multicore processors can speed up execution of such programs.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/86m2GDIlcxA
:width: 100%
:title: "[CS61C FA20] Lecture 33.3 - Thread-Level Parallelism I: Threads"
:::

::::

A **thread** (short for a **thread of execution**) is a single stream of instructions. A **process** is an instance of a currently running program. A process is composed of a single thread's execution, or multiple threads, which execute **concurrently**.

Threads are an easy way to describe/think about parallelism, but their implementation is quite complicated and out of the scope of this course. Nevertheless, we describe some details that will help you understand the **thread model of execution**.

## Thread model of execution

(sec-thread-state)=
### Thread state

Each thread maintains state as shown in @fig-single-multi-thread:

* Values of its own registers (including stack pointer)
* Value of its own program counter (PC)
* Shared memory (heap, global variables) with other threads

:::{figure} images/single-v-multi-thread.png
:label: fig-single-multi-thread
:width: 90%
:alt: "Side-by-side process diagrams: left process box encloses one thread of execution with a single stack and register context; right process box encloses several threads each with its own stack pointer region but shared code and heap segments. Annotations highlight what is duplicated versus shared."

Single-threaded process vs. multi-threaded process.
:::

### Fork-Join Model

We assume that multi-threaded processes run using the **fork-join model** in @fig-fork-join:

:::{figure} images/fork-join-model.png
:label: fig-fork-join
:width: 100%
:alt: "Fork-join timeline: a main thread proceeds serially, then a fork point fans out into several parallel child segments that execute concurrently, each with its own labeled interval, before a join barrier resynchronizes all paths back to a single continuation on the main thread. Vertical synchronization lines mark fork and join events."

Fork-join model over time with multiple parallel tasks off the main thread. **Top**: Parallel Task I is composed of concurrent threads A, B, C; Task II is composed of A, B, C, and D; Task III is composed of A, B. **Bottom**: Main Thread forks into the three threads for Parallel Task I, then joins, then forks into the four threads for Parallel Task II, then joins, then forks into the two threads for Parallel Task III, then joins and finishes execution.
:::

* The "main thread" executes sequentially until the first parallel task region.
* **Fork**: When the first parallel task region is encountered, the main thread then creates a team of parallel subthreads, which execute to completion.
* **Join**: When subthreads complete their parallel task region, they synchronize and terminate, leaving only the main thread. The main thread then executes sequentially until it needs to fork another parallel task region.

::::{warning} Multi-threaded programs can run on single-core _and_ multi-core systems!

A thread is simply a single stream of instructions that must be executed sequentially to peform some task. Up until now, we have effectively called this a "program" or "process." Given the above definition, it is therefore possible to execute a multi-threaded program on **both multi-core and single-core architectures.**

Revisiting our terminology from an [earlier section](#sec-flynns-taxonomy):

:::{embed} #tab-hw-sw-parallelism
:::

Threads enable **concurrent** execution of different parts of a process. Multicore systems enable **parallel** execution of multiple threads.

::::

## A Warning about Threads

From UC Berkeley Professor Emeritus Edward Lee:

> Although threads seem to be a small step from sequential
computation, in fact, they represent a huge step. They discard the most essential and appealing properties of sequential computation: understandability, predictability, and determinism. Threads, as a model of computation, are wildly nondeterministic, and the job of the programmer becomes one of pruning that nondeterminism.
>
> -- "The Problem with Threads." Edward Lee[^lee]

[^lee]: Edward A. Lee. "The Problem with Threads."
[Technical Report No. UCB/EECS-2006-1](http://www.eecs.berkeley.edu/Pubs/TechRpts/2006/EECS-2006-1.html). January 2006.
See also: _Computer_ 39, 5 (May 2006), 33–42. [DOI](https://doi.org/10.1109/MC.2006.180)

As we will see over the next few sections, thread-level programming is **hard**.

## Executing Threads on Hardware

We are so sorry,[^note-terminology] but we will introduce one more set of terms to describe how threading works in hardware:

* A **software thread** is one of the threads that composes a multi-thread process. When we colloquially say "thread," we are usually referring to a software thread.
* Each core provides one (or more) **hardware threads** that actively execute instructions.
* An **active thread** is a software thread that is currently mapped to a hardware thread and executing. All software threads that are not active wait until they are able to execute.

[^note-terminology]: From an [earlier section](#sec-flynns-taxonomy): "Because of the abrupt shift in processor design towards parallelism, there are a LOT of closely related terms when it comes to paralellism."

A special program called the **Operating System** "multiplexes"[^multiplex] multiple software threads onto the available hardware threads. With the OS's help, a single-core CPU can "concurrently" execute many threads by time-sharing the processor between the threads, as shown in @fig-process-v-time-threads.

[^multiplex]: To **multiplex** means to combine multiple channels into one shared channel (e.g., [MUX](#sec-mux)). In this case, think of multiplexing as a way that multiple software threads can "time share" the same hardware thread.

:::{figure} images/process-v-time-threads.png
:label: fig-process-v-time-threads
:width: 40%
:alt: "Stacked timeline comparing one process containing a single thread against another process expanded into multiple threads of control. Vertical time lines show program counters advancing; the multithreaded version duplicates instruction pointer tracks or shows concurrent bursts inside one address space."

Process over time when executing multiple threads on a single-core CPU.
:::

(sec-context-switch)=
## The OS: Thread Context Switch

```{embed} #sec-os-overview
```

On most modern computers, the number of active threads is much larger than the number of available cores, so most (software) threads are idle at any given time. The OS is responsible for (among other tasks) managing which threads get run on which CPU via a process called **context switching**.

The OS performs a **thread context switch** for two main reasons:

* Switch out blocked threads (e.g., cache miss, user input, network access, disk access). The OS switches to another thread to avoid stalling the CPU for an extended amount of time.
* Timer (e.g., switch active thread every 1 ms). The OS switches to another thread to allow multiple threads to execute concurrently, even when hardware threads are limited.

:::{note} The OS enables thread concurrency
The OS uses context switching to give the illusion of many active, concurrently executing threads.
:::

To switch to a different thread in the process, the OS does the following:

1. Removes the old software thread from the hardware thread by interrupting its execution. Save the old software thread's state, e.g., register values (including PC value) and stack pointer to memory. Because threads in the same process share memory, we keep any memory tables.[^vm]
1. Start executing a different software thread. Load its state into the hardware thread's registers (including the thread's PC value). Then, run the hardware thread by reading the value of the PC (which is the address of the next instruction of the newly active thread).

[^vm]: We use the term "memory tables" colloquially here to refer to all extra information to speed up memory access needed for this particular process. We mean caches and [virtual memory page tables](#sec-virtual-memory).

The OS can also perform context switches to multiplex different processes. We leave the description of process context switches to a [later section](#sec-context-switch-process)

## Hardware Multithreading

Up until now we have maintained that **one core** has **one hardware therad** running on it. Some architectures can support **hardware multithreading**—when we run *m*ultiple hardware threads* on the same core.

* **Logical CPUs**: Effectively, the number of hardware threads.
* **Physical CPUs** are the true number of hardware cores, where each core could potentially have multiple logical CPUs due to multithreading.

Intel chips use hardware multithreading[^intel], whereas many modern Apple chips do not. The below `lscpu` command[^hive-lscpu] run on our course hive machines tells us that we have six physical cores and two threads per core for a total of 12 logical CPUs.

```{code} bash
:label: code-hive-lscpu

$ lscpu
CPU(s):                   12
  On-line CPU(s) list:    0-11
Vendor ID:                GenuineIntel
  Model name:             Intel(R) Core(TM) 
                          i7-8700T CPU @ 2.40GHz
    CPU family:           6
    Model:                158
    Thread(s) per core:   2
    Core(s) per socket:   6
    Socket(s):            1
```

[^intel]: Intel uses yet another term to describe hardware multithreading: hyperthreading. Woo terminology!!

[^hive-lscpu]: `lscpu` also lists the extensions available on this machine: `pu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2a pic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb pti ssbd ibrs ibpb stibp tpr_shadow flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt intel_pt xsaveopt xsavec xgetbv1 xsaves dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp vnmimd_clear flush_l1d arch_capabilities ibpb_exit_to_user`

:::{warning} Hardware multithreading is out of scope

Hardware multithreading is out of scope for this course. Just know that it exists so that you can understand your computer's specifications. Watch the lecture video for more information.

:::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/_ZL8Z81yI5w
:width: 100%
:title: "[CS61C FA20] Lecture 33.4 - Thread-Level Parallelism I: Multithreading"
:::

::::

Briefly—the hardware multithreading model is in @fig-hardware-multithreading. Here, each core can run multiple threads at the same time. The two hardware threads share resources like the cache, the ALU unit, etc., but have separate state (PC, registers, etc.) This design leverages "Moore's Law" because transistors are aplenty.

:::{figure} images/hardware-multithreading.png
:label: fig-hardware-multithreading
:width: 70%
:alt: "Block diagram of a core exposing multiple hardware thread contexts with separate PCs and register files while sharing execution units and caches, illustrating simultaneous multithreading or hyper-threading style overlap."

Hardware multithreading: multiple threads *active* in the same processor.
:::

Hardware multithreading reduces the overhead of a context switch. When the active hardware thread encounters a cache miss, the other hardware thread can be swapped in quickly and run until the data for the original hardware thread available.
