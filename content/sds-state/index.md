---
title: "Signals, Waveforms, and the Clock"
subtitle: By John Wawrzynek, with edits by Lisa Yan
---

(sec-signal-waveform-clock)=
## Learning Outcomes

* Interpret the waveform diagram of the clock signal.
* Identify the propagation delay of a combinational logic circuit.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/EQYtPrBWvrU
:width: 100%
:title: "[CS61C FA20] Lecture 14.3 - Intro to Synchronous Digital Systems: Signals and Waveforms"
:::

::::

In the [previous chapter](#sec-intro-sds), we discussed a chip, which is composed of wires and transistors (among other things):

:::{figure} #fig-apple-a14
Apple A14 Bionic Chip (sources: [Wikipedia](https://en.wikipedia.org/wiki/Apple_A14), [TechInsights]((https://www.techinsights.com/blog/two-new-apple-socs-two-market-events-apple-a14-and-m1)). @fig-apple-a14 in [Intro to SDS](#sec-intro-sds).
:::

Surrounding the inner part of the chip—the core—is a set of connections to the outside world. Usually these connect through some wires in the plastic or ceramic package to the printed circuit board (PCB). In the case of most computers this PCB would be the motherboard. Some of these connections go to the main memory and the system bus. A fair number of the pins are used to connect to the power supply. The power supply takes the 110 Volt AC from the wall socket (provided by PG&E) and converts it to low voltage DC (usually in the range of around 1 to 5 volts, depending on the particular chip used). The DC voltage is measured relative to ground potential (GND). Power connections to the chip from the power supply are of two types; GND, and DC Voltage (labeled "Vdd").

The energy provided by the power supply drives the operation of the processor. The energy is used to move electric charge from place to place in the circuits and in the process is dissipated as heat. These days a processor my use on the order of 10 watts—like a not-so-bright light bulb.

## The Clock

Coming soon. For now, please read Professor John Wawrzynek's notes: [Intro to SDS Handout](../resources/sds.pdf)

<!--
Another special connection to the chip is the **clock input signal**. The clock signal is generated on the motherboard and sent to the chip where it is distributed throughout the processor on internal wires.

:::{tip} The clock signal is the **heartbeat of the system**.

It controls the **timing** of the flow of electric charge (and thus **information**) through out the processor and off-chip to the memory and system bus.
:::

If we had a very small probe we could examine the signal on the clock wires, by looking at the voltage level on the wire.
We would see a blur, because the clock signal is oscillating at a very high frequency (around **1 billion cycles/second or 1GHz**, these days). If we could record it for a brief instant and plot it out we would see something like:
-->

## Signals and Waveforms

Coming soon. For now, please read Professor John Wawrzynek's notes: [Intro to SDS Handout](../resources/sds.pdf)

## Circuit Delay: Propagation Delay

:::{tip} Propagation Delay

A measure of the delay from input to output, in general, is called the **propagation delay**. Propagation delay occurs in all circuits, including combinational logic circuits.

However, the propagation delay of a circuit, like the adder, is always less than the clock period. We discuss this more in a [later section].
:::

## Summary: Synchronous Digital System

@fig-general-model-sds shows the general model for our synchronous systems:

:::{figure} images/general-model-sds.png
:label: fig-general-model-sds
:width: 100%
:alt: "TODO"

General model for SDS.
:::

* Our circuit is a collection of combinational logic blocks (CL blocks) separated by registers.
* Registers may be back-to-back; CL blocks may be back-to-back.
* Feedback is optional.
* Clock signal(s) connects only to clock input of registers. Combinational logic blocks are stateless and not clocked.
