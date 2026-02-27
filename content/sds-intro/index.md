---
title: "Synchronous Digital Systems"
---

## Learning Outcomes

* Define a synchronous digital system.
* Identify that transistors and wires are key to digital circuits.
* Identify two types of digital circuits: combinational logic circuits and memory circuits.

::::{note} 🎥 Lecture Video: Introduction
:class: dropdown

:::{iframe} https://www.youtube.com/embed/fbtUreUJxR4
:width: 100%
:title: "[CS61C FA20] Lecture 14.1 - Intro to Synchronous Digital Systems: Switches"
:::

until 5:35

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/EQYtPrBWvrU
:width: 100%
:title: "[CS61C FA20] Lecture 14.3 - Intro to Synchronous Digital Systems: Signals and Waveforms"
:::

::::

Now, we move **below** the orange line of our Great Idea #1. **How do we design the hardware needed to execute machine code?** In the next part of this course, we will implement a RISC-V processor as a **synchronous digital system**, which should have the capabilities to execute RISC-V instructions.

:::{figure} #fig-great-idea-1
:width: 100%
:alt: "TODO"

Great Idea #1: Abstraction.
:::

:::{hint} Why study hardware design?

To really understand how computers work, we need to understand the complete stack, including the physical level. This unit will give you intuition of oft-asked questions:

* Why is my computer so slow?
* Why does my battery run down?

There is only so much you can do with standard processors! We hope this unit will help you understand the capabilities and limitations of hardware in general–and processors in particular–so you can determine when you need to move to custom hardware.

The principles we teach in CS 61C will likely still apply in 30 years, even if and when the base technology changes. To learn about advanced, modern hardware, take in-depth upper-division courses like EECS 151: Digital Logic Design and CS 152: Computer Architecture.
:::

Core (heh) to the modern computer are many types of **integrated circuits**, which themselves are composed of many interconnected synchronous digital systems (among other things). For example, the [Apple A14 Bionic chip](#fig-apple-a14) is used in many of Apple's iPad and iPhone devices in the early 2020s.

:::{figure} images/apple-a14.jpg
:label: fig-apple-a14
:width: 70%
:alt: "TODO"

Apple A14 Bionic Chip (sources: [Wikipedia](https://en.wikipedia.org/wiki/Apple_A14), [TechInsights]((https://www.techinsights.com/blog/two-new-apple-socs-two-market-events-apple-a14-and-m1))
:::

Notice the various blocks labeled on the photograph. We will be discussing these later this semester. Here are the specifications for this particular processor:

* 11.8 billion transistors
* 5W power consumption
* Six cores (ARM v8.5a) up to 3.0 GHz:
* Two high-performance, Four energy-efficient
* CPU supports 64-bit data
* GPU for working with graphical data
* NPU “Neural Engine” dedicated neural net HW
* AMX matrix scalar multiplication accelerators
* L2 cache: 4-8MB


In this class, we focus on the **central processing unit** (CPU), or processor (the left side of our [computer layout figure](#fig-von-neumann)). To understand how a modern processor is built, we start with definitions of the basic building blocks.

## Wires and Transistors

All circuits are made from
**wires** and **transistors**.[^others]

[^others]: Circuits can additionally include **analog** "parasitic" resistors, capacitors, inductors, etc. However, wires and transistors are core to the design of **digital** circuits.

* **Wires** (i.e., electrical nodes) provide electrical signals and are used to represent variables. 
* **Transistors** are semiconductor devices to amplify or **switch** signals.

### Wires

In digital circuits, each wire can take on one of two values via a binary representation of voltage levels to signal `0` or `1`. At a high-level, wires that have ample current running through them will be pulled to a "high" voltage and represent `1`; wires pulled to "low" voltage represent `0`.

:::{figure} images/bin-wire.jpg
:label: fig-bin-wire
:width: 60%
:alt: "TODO"

Low voltage is `0`; high voltage is `1`.
:::

For digital circuits, we keep signals **simple** (i.e., binary values only) and push complexity later into how we combine signals. **Bundles** of wires represent multi-bit variables (@fig-bin-rep-signals).

:::{figure} images/binary-rep-signals.png
:label: fig-bin-rep-signals
:width: 60%
:alt: "TODO"

(left) eight wires, each representing binary variables $x_0$ to $x_7$; (right) one bundle of wires representing an 8-bit variable $X$.
:::

:::{note} Why not go beyond a binary signal representation?
:class: dropdown

Early computers represented signals as decimals–not binary. However, all wires subject to interference/non-idealities, which grows worse at smaller sizes. 

As chips get more complex, wires get smaller. Circuits to discriminate between _two_ possible inputs are simple to implement and have scaled well with Moore’s Law. **Binary representations** for signals therefore produce reliability via good noise immunity.

:::

A wire can take different (binary) values at different points in time. Wires are pulled to low and high voltages by **transistors**.

### Transistors, briefly

Transistors are in all modern electronics: **integrated circuits** and **microprocessors**.
The evolution and design of the transistor is discussed in [Great Idea #2: Moore's Law](#fig-great-idea-2), which shows the growth over time of (micro)processor transistor density. 

:::{figure} ../great-ideas/images/2-moores-law.png
:label: fig-great-idea-2
:width: 100%
:alt: "TODO"

Visual of Moore's Law over time.
:::

Intel Cofounder Gordon Moore[^go-bears]:

> “Reduced cost is one of the big attractions of integrated electronics, and the cost advantage continues to increase as the technology evolves toward the production of larger and larger circuit functions on a single semiconductor substrate.”
> 
> -- _Electronics_, Volume 38, Number 8, April 19, 1965

[^go-bears]: B.S. Cal 1950!

Understanding the transistor is beyond the scope of our course. For those curious, we have included a [bonus section](#sec-transistors) on transistors and switches, though we recommend you take advanced coursework like EE 105: Microelectronic Devices and Circuits.

We will focus on remembering that transistors are critical to composing _building blocks_ used for designing processor logic.  Because of their switching and amplifying behavior, they can be composed together to design circuits that perform **logic** on binary variables (again, wires) and store **state** of specific binary values.

### Example digital circuit: NAND

Consider NAND, which takes two binary inputs and produces a binary output that is `0` (low) only if both the two inputs are high (`1`).

:::{figure} images/equivalence-nand.png
:label: fig-equivalence-nand
:width: 100%
:alt: "TODO"

NAND gate. We will mostly use the representations on the right-hand-side.
:::

There are five NAND representations shown in @fig-equivalence-nand. In this course, we focus on the four rightmost representations.

* (leftmost): Transistor circuit diagram of a NAND gate with inputs `a` and `b` and output `c`
* (immediately left of arrow): Block diagram of NAND, again with inputs `a` and `b` and output `c`
* (immediately right of arrow) Functional description of NAND, where `y = NAND(a, b)`
* (second from the right) NAND logic gate, with inputs `a` and `b` and output `y`
* (rightmost): Truth table for NAND, with inputs `a` and `b` and output `y`

:::{hint} Circuit Delay

An important property of digital circuits is that they cannot produce a result instantaneously.
If we examine any digital circuit's input and output
waveforms, we would notice a small delay from when the inputs change to when the output has the new
result. The delay is present because it takes time for the electrical charge to move through the wires
and the transistors.

A measure of the delay from input to output, in general, is called the **propagation
delay**. Read the [SDS handout](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/sds.pdf) for more information.
:::

## Synchronous Digital Systems

The hardware underlying almost every processor is a **Synchronous Digital System**.

:::{note} Synchronous Digital System

* **Synchronous**: All operations coordinated by a central clock. A processor clock is the a "heartbeat" for the system. A **cycle** is the duration between heartbeats.
* **Digital**: Represent all values by discrete values, i.e., binary digits `1` and `0`.

A synchronous digital system composes **circuits** together to create complex digital logic systems. At their core, these circuits are themselves composed of **wires** and **transistors**, which we briefly discuss below.

:::

We discuss the clock later. For now, know that a clock can also be represented via a digital "square wave" signal, oscillating between `1` and `0` periodically. Nowadays, clocks operate in the 3-4GHz range, meaning there are four billion periods of this square wave per second. We will see later how a clock supports **state**.


:::{note} Click to show alternatives to SDS
:class: dropdown

* **Asynchronous systems** must locally coordinate actions and communications b/t components; much harder to design/debug.
* **Analog circuits** use voltage/current to represent continuous ranges of values. These days, even a lot of analog circuitry uses synchronous digital design by using analog-to-digital converters, and vice versa. Take EE 105 for more information!

:::

## Types of Digital Circuits

Synchronous Digital Systems consist of two basic types of circuits: combinational logic circuits and stateful circuits.

**Combinational logic circuits** take their inputs and combine them to produce a new output after some small delay. The core components of combinational logic circuits are **logic gates**.

Combinational logic circuits have **no memory** of their previous inputs or outputs. The output is a function of nothing other than the inputs—like a mathematical function, e.g., $y = f(x)$. Combinational logic circuits have no way to store information from one invocation to the next and do not generate any side effects.

Combinational logic circuits are used throughout processor implementations. They provide all the necessary functions needed to execute instructions, including all the arithmetic and logic operations,
incrementing the program counter value, determining when to branch, calculation of new PC target values, etc. Not counting the area consumed by caches, _most of the area on microprocessor chip_s is used for combinational logic blocks.

**State elements**, or memory circuits, are circuits that store information. Unlike combinational logic circuits, these circuits remember their inputs (in CL, inputs are only used to generate outputs, but never remembered). The core component of stateful circuits are **state elements**. We discuss one such state element, the **register**, in detail in a later section.