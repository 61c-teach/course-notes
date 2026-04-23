---
title: "The Register"
subtitle: "Adapted from John Wawrzynek"
---

(sec-registers)=
## Learning Outcomes

* Identify properties of a memory circuit.
* Describe the behavior of a positive edge-triggered d-type flip-flop.
* Identify setup time, hold time, and clk-to-q delay in a FF timing diagram.
* Explain the importance of setup time and hold time for sampling an input.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/OPj9eUw5O_M
:width: 100%
:title: "[CS61C FA20] Lecture 15.2 - State, State Machines: Register Details Flip-flops"
:::

::::

As we've seen in a [previous section](#sec-cl-practice), combinational logic circuits provide all the necessary functions needed to execute instructions, including all the arithmetic and logic operations, incrementing the program counter value, determining when to branch,calculating the new PC target values, etc, but they have no memory of their previous inputs or outputs. The **memory circuit**[^sds-handout] is an example of another type of circuit used to make processors that does remember its inputs. This memory circuit is used to implement the general purpose register, as shown in @fig-reg-circuit.

[^sds-handout]: These notes are adapted from Professor John Wawrzynek's notes: [SDS Handout](../resources/sds.pdf).

:::{figure} images/register-circuit.png
:label: fig-reg-circuit
:width: 70%
:alt: "Register symbol with n-bit data input D, stored n-bit output Q, and LOAD control that determines when a new value is captured."

Diagram of a register implemented through a memory circuit.
:::

## The General Register: A Memory Circuit

Under the control of a special input, called **LOAD**, the register captures the value of the input signal and holds onto it indefinitely, or until another value is loaded. The value stored by the register appears at the output of the register (a very short time after it gets loaded). If the processor loads a value in a register at one point in time, it can come back later and read that same value back. Even if different values appear at the input to the register in the interim, the output value of the register will not change unless instructed to do so by signaling with the **LOAD** input. So, as long as the processor has control over the signaling of the **LOAD** input, it has total control over what gets saved and when.

Often the system clock signal **CLK** (see [The Clock](#sec-clock)), is used as the LOAD signal on a register, as shown in @fig-clk-reg. This configuration means that, for this register, a new value is loaded on each clock cycle. This is a valuable configuration we will explore in a [future section].

:::{figure} images/clocked-register.png
:label: fig-clk-reg
:width: 70%
:alt: "Clocked register, whose capture is determined by CLK instead of an explicit LOAD line, updating stored n-bit inputs to n-bit outputs on each active clock edge."

Diagram of a clocked register implemented through a memory circuit.
:::


(sec-flip-flops)=
## What's inside a register? Flip-Flops

As shown in @fig-reg-comps, an `n`-bit wide register is nothing other than `n` instances of a simpler circuit[^state-handout].

[^state-handout]: These notes are adapted from Professor John Wawrzynek's notes: [State Handout](../resources/state.pdf).

:::{figure} images/register-components.png
:label: fig-reg-comps
:width: 100%
:alt: "n-bit register drawn as n parallel D flip-flops sharing a common clock and producing a bundled n-bit Q output."

Diagram of a register built from `n` instances of simpler circuits called **flip-flops**.
:::

We call these simple circuits **flip-flops** (FF), which are 1-bit wide registers named from the fact that when in operation, it flips (and flops) between holding a `0` or a `1`. The `CLK` (or `LOAD`) signal is sent to the `CLK` (or `LOAD`) input of all `n` FFs. Each FF is responsible for storing one bit of the `n`-bit data stored by the register. By register convention, the input is labeled `D` and the output is labeled `Q`. In the case of a single bit, the input is labeled `d` and the output is labeled `q`.

### Edge-Triggered D-Type Flip Flop

The most common type of FF is called the **edge-triggered d-type flip flop**. Internally, each FF comprises around 10 transistors. The operation of the FF is illustrated as a waveform diagram in @fig-ff-waveform. The figure shows the operation of a **positive** edge-triggered d-type flip-flop, one of two types of edge-triggered d-type flip-flops. Negative edge-triggered d-type flip-flops is the other type, but for CS 61C, we will focus on positive edge flip-flops.

:::{figure} images/ff-waveform.png
:label: fig-ff-waveform
:width: 100%
:alt: "Clock, data d, and output q waveforms for a D flipflop, showing the output q being updated to match input d only after a rising clock edge."

Waveform diagram of the operation of an edge-triggered d-type FF.
:::

### Positive Edge-Triggered D-Type Flip-Flops

For positive edge-triggered d-type FFs, on each positive (rising) clock edge, the `d` input is sampled and transferred to the `q` output. At all other times, the `d` input is ignored.

:::{tip} How do we verify the behavior of a positive edge-triggered d-type FF?

We leave the verification of this process as an exercise for you! Start by looking at the waveforms of positive edge-triggered d-type FFs. You should see that the only time the `q` output changes is right after the rising edge of the clock. The `d` input can go up and down many times within a single clock cycle, but only its value right at the rising edge of the clock is important. This is when the input is sampled.

You may also notice times when the FF output doesn't change in response to the rising clock edge. This happens only when the `d` input and the `q` output are already the same value!
:::

::::{note} Click to see an example simulator wavefrom diagram!
:class: dropdown

:::{figure} images/waveform-diagram.png
:label: fig-waveform-ff
:width: 100%
:alt: "Example waveform diagram produced through a digital tool depicting timing rails for clk, d, and q showing edge-triggered sampling consistent with a Verilog or simulator trace."

Simulator waveform diagram for a positive d-type FF.
:::
::::

### FF Timing Diagram

A detailed FF timing diagram for a positive edge-triggered d-type FF is shown in @fig-ff-timing. Like combinational logic circuits, FFs cannot change their outputs instantaneously. Additionally, time is needed to transfer inputs internally. Therefore, the `d` input must be stable for a short amount of time before the rising clock edge (called the **setup time**) and remain stable for a short amount of time after the edge (called the **hold time**). Together, the setup and hold times create a time window when the `d` input cannot change. If it changes in this window, the FF will not reliably capture the new input. Note that, once the FF captures the new input in response to the rising clock edge, it also takes a small amount of time to transfer the new value to the output (called the **clk-to-q delay**)[^hold-time-clk-to-q].

:::{figure} images/timing-diagram.png
:label: fig-ff-timing
:width: 55%
:alt: "Annotated timing diagram focused on the CLK rising clock edge. The diagram labels intervals around the rising clock edge for setup time before the edge (A), hold time after the edge (B), and clk-to-q delay until output q is stable following the edge (C); d must stay stable across the setup-hold window."

Timing diagram of a positive edge-triggered d-type FF.
:::

Looking at @fig-ff-timing above:

* `A` illustrates the **setup time**.
* `B` illustrates the **hold time**.
* `C` illustrates the **clk-to-q delay**.
* The vertically dashed yellow lines illustrate the time window during which the input `d` must be stable (from the start of the setup time until the end of the hold time).

[^hold-time-clk-to-q]: There is no particular relation between hold time and clk-to-q delay, because the former describes the input and the latter describes the output. However, in practice hold time is less than clk-to-q delay.