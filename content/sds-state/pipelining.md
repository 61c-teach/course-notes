---
title: "Pipelining for Performance"
subtitle: "By John Wawrzynek, with edits by Lisa Yan"
---

:::{warning} This content is out of scope for the midterm exam.

This content is covered when we discuss pipelining in the [five-stage RISC-V datapath](#sec-five-stage-pipeline).
:::

(sec-pipelining-circuits)=
## Learning Outcomes

* Explain how registers can be used to improve **throughput** performance of a circuit.
* Compare how input data is fed through a *pipelined* circuit and a *non-pipelined* circuit.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/fxjbBygDzBo
:width: 100%
:title: "[CS61C FA20] Lecture 15.4 - State, State Machines: Pipelining for Performance"
:::

::::

In a [previous section](#sec-use-register), we saw an example of where a register was needed to ensure correct circuit behavior. Now, we'll see how registers can also be used to increase the achievable clock frequency and, thus, improve the performance of the circuit through pipelining [^state-handout].

[^state-handout]: These notes are adapted from Professor John Wawrzynek's notes: [State Handout](../resources/state.pdf).

## Non-Pipelined Circuit

Suppose we had the need to cascade two combinational logic circuits, an adder and a shifter. The idea of this circuit is that, when input values arrive, they are added together and then shifted by some amount. We can imagine that this circuit composition is part of a processor. @fig-non-pipelined-adder illustrates this example circuit on the left and timing diagram on the right.

:::{figure} images/non-pipelined-adder.png
:label: fig-non-pipelined-adder
:width: 100%
:alt: "On the left, a non-pipelined-adder, comprised of a register, adder logic, shifter, and a second register. On the right, timing diagrams showing the common clock and how input and shifter output values change to result in one full add-then-shift completed per clock cycle."

Diagram of a *non-pipelined* add/shift circuit and the associated timing diagram.
:::

We assume that the input values come from a register (shown in @fig-non-pipelined-adder as one combined register block) and the output goes into a register. On each clock cycle, we simultaneously capture a new pair of input values in the input register and the previous result in the output register. The waveforms for the operation of this circuit are shown on the right in @fig-non-pipelined-adder. There is a delay of one clock cycle from input (output of the input register) to output (output of the output register $R_{i-1}$).

## Pipelined Circuit

The maximum clock frequency (minimum clock period) is limited by the propagation delay of the add/shift operation. If we try to make the clock period too short, then the add/shift logic would not have sufficient time to generate its output. Consequently, the output register would capture an incorrect value.

If we felt that the clock period for the correctly functioning circuit was too long, we could choose to split up the add/shift operation into two cycles, performing the *add* operation on the first cycle and the *shift* operation on the second cycle. We can implement this idea by introducing a new register between the two blocks, as shown on the left in @fig-pipelined-adder.

:::{figure} images/pipelined-adder.png
:label: fig-pipelined-adder
:width: 100%
:alt: "On the left, a pipelined-adder, comprised of a register, adder logic, additional pipeline register, shifter, and a third register. On the right, timing diagrams showing the common clock and how inputs and all intermediate output values change to result in a two-stage overlap so each stage works every cycle at a shorter period."

Diagram of a *pipelined* add/shift circuit and the associated timing diagram.
:::

On each clock cycle, data moves from the output of `reg1`, through the adder, to the input of `reg2`, or moves from the output of `reg2`, through the shifter, to the input of `reg3`. Since the data no longer needs to move through both blocks in a single clock cycle, the clock frequency can be increased. The waveforms for this pipelined add/shift operation are shown on the right in @fig-pipelined-adder.

:::{note} Can this circuit take new input values on each clock cycle?

**Yes!** An interesting observation about this new pipelined circuit is that, after the data moves through the adder and gets captured in `reg2`, on the next clock cycle, when the data moves into the shifter, new data can simultaneously move into the adder since the adder is now free. Therefore, new input data values can be fed into the circuit on each clock cycle.
:::

## Adding Registers to Improve Performance

As illustrated by the equations below, there will now be a **two** clock cycle delay from the insertion of a set of data into the circuit until when it appears at the output. However, the new clock period is shorter, so in absolute time, the delay from data insertion until output (i.e., **latency**) is not significantly worse. More importantly, because of the tranformation and the new higher clock rate, results will be generated at a higher rate (more outputs per second, i.e., **throughput**).

::::{card}
:header: Non-pipelined circuit (@fig-non-pipelined-adder)

```{math}
\begin{aligned}
\text{Critical path delay} &= t_{\texttt{clk-to-q}} + t_{\texttt{add}} + t_{\texttt{shift}} + t_{\texttt{setup}} \\
\text{latency} &= t_{\texttt{clk-to-q}} + t_{\texttt{add}} + t_{\texttt{shift}} + t_{\texttt{setup}} \\
\end{aligned}
```
::::


::::{card}
:header: Pipelined circuit (@fig-pipelined-adder)

```{math}
\begin{aligned}
\text{Critical path delay} &= \max \{ t_{\texttt{clk-to-q}} + t_{\texttt{add}} + t_{\texttt{setup}}, t_{\texttt{clk-to-q}} + t_{\texttt{shift}} + t_{\texttt{setup}} \} \\
\\
\text{Latency} &= t_{\texttt{clk-to-q}} + t_{\texttt{add}} + t_{\texttt{setup}} + t_{\texttt{clk-to-q}} + t_{\texttt{shift}} + t_{\texttt{setup}}
\end{aligned}
```
::::

Pipelining is a good transformation if you are evaluating on results/time, or **throughput**. If you are more interested in **latency** (or delay) for any one set of input values, then this transformation is less ideal.

<!-- ## Visuals

:::{figure} #fig-general-model-sds
:width: 100%
:alt: "Synchronous system sketch: combinational logic blocks interleaved with registers, optional feedback, and a clock distribution that connects only to register clock pins."

General model for SDS. @fig-general-model-sds in [a previous section](#sec-signal-waveform-clock).
:::

:::{figure} images/general-model-sds-pipeline.png
:label: fig-general-model-pipeline
:width: 100%
:alt: "Same SDS structure with extra pipeline registers slicing long combinational paths to raise clock frequency."

Example diagram of pipelined general SDS model.
::: -->