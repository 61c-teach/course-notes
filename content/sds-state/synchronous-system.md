---
title: "Timing a Synchronous System"
subtitle: By John Wawrzynek, with edits by Lisa Yan
---

## Learning Outcomes

* Explain why registers help stabilize synchronous systems.
* Compute the delay of a circuit's critical path.
* Determine the maximum clock frequency for a given circuit.
* Explain a hold time violation and how to avoid it.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/NJp8PSGsV9U
:width: 100%
:title: "[CS61C FA20] Lecture 15.1 - State, State Machines: Accumulator"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Q8jlosmglo0
:width: 100%
:title: "[CS61C FA20] Lecture 15.3 - State, State Machines: Accumulator revisited"
:::
::::

Combination logic circuits produce outputs based purely on their
input signals. They are used for a wide variety of functions. State elements, on the other hand, have a small number of very specific uses. These are circuits that remember their input signal values.

:::{tip} Registers can be used to control the flow of signals between combination logic circuits.

The accumulator example in this section should convince you that there are places were state elements are necessary for correct circuit function.

Nevertheless, introducing state elements will impact how much can occur in a given clock period. We discuss this below.

:::

:::{tip} Registers can be used to increase the achievable clock frequency.

With the concept of pipeline registers, we can add registers to a circuit to actually improve performance. We discuss this idea in the [next section](#sec-pipelining).
:::

## Accumulator Example

Consider the design of a circuit whose job is to form the sum of a list of integers, $X_0, X_1, X_2, \dots, X_{n-1}$. Assume that some other circuit applies the numbers from the list one at a time—one per clock cycle. Below is a graphical depiction of an abstraction of our circuit used to form the sum–we’ll call the block "sum". The $X$ values are applied, one per cycle, and after  $n$ cycles the sum is present at the output, S.

:::{figure} images/accumulator-block.png
:label: fig-acc-block
:width: 45%
:alt: "TODO"

Block diagram for accumulator.
:::

What should we put inside the sum block to achieve the desired function? Obviously the circuit involves an adder. Also, on each step we need to take the current sum and pass it back to the adder so that it can add another X value to it.

### Strawman: Unstable Circuit

@fig-accumulator-circuit-unstable is our first try:

:::{figure} images/accumulator-circuit-unstable.png
:label: fig-accumulator-circuit-unstable
:width: 55%
:alt: "TODO"

Circuit diagram for accumulator.
:::

Let’s examine the operation of this circuit in detail to see if it does the job. Assume that $S$ begins at $0$. We then apply $X_0$. After a short delay (the adder propagation delay, $\tau_{add}$)  $S$ will change to $X_0$. Then after another $\tau_{add}$ of delay, S will change to $X_0 + X_0$, then after another $\tau_{add}$ of delay, S will change to $X_0 + X_0 + X_0$, etc. Because $\tau_{add}$ is typically less than the clock period, **all of these adds of $X_0$ will
happen before $X_1$ is applied.**

This is clearly not the correct operation of "sum". The circuit is out of control! We need some way to control the computation, **one step at a time**.

(sec-use-register)=
### Use a Register

The way to control the computation is to put a register in the **feedback path** (the connection from the output of the adder to its input), as shown in @fig-accumulator-circuit-register.

:::{figure} images/accumulator-circuit-register.png
:label: fig-accumulator-circuit-register
:width: 55%
:alt: "TODO"

Circuit diagram for accumulator with reset.
:::

The register holds the current value of $S$ while the next one is being formed. After we are happy with the next $S$, we load it into the register and apply the new $X$ value, then wait for a new $S$ to appear at the output of the adder. The process is repeated for all $n$ $X$ values.

**Reset signals** are a common feature of register circuits. In the [circuit diagram](#fig-accumulator-circuit-register), this is the "reset" input signal to the register. This is a signal that can be used to clear the register value, and thus gives us a way to initialize the circuit.

:::{note} More on Reset Signals
:class: dropdown

The "reset" input to the register is a special input that clears the register so that it holds all 0’s.

The most common type of reset input is a called a **synchronous reset**: If the reset input signal has the value 1 on the _rising edge_ of the clock signal, then the register is cleared, regardless of the value of the input D. In other words, the reset signal has priority over the data input and forces the register to all 0’s.
:::

### Waveform diagram

@fig-accumulator-timing shows the waveforms demonstrating the **rough** operation of the [accumulator circuit](#fig-accumulator-circuit-register), for a few iterations. Results are generated nicely one at time. In this example, the register is used to hold up the transfer of data from
one place to another in the circuit.

The output of the circuit is labeled $S_i$, and the output of the register is labeled $S_{i-1}$ to remind us that the register delays the signal for 1 cycle. So if the output of the circuit is holding the result of the i{sup}`th` iteration, then the register holds the result of the (i − 1){sup}`th` iteration.

:::{figure} images/accumulator-timing.png
:label: fig-accumulator-timing
:width: 100%
:alt: "TODO"

Rough timing diagram for accumulator, now with the waveform for the register output $S_{i-1}$.
:::

:::{note} Show explanation of @fig-accumulator-timing
:class: dropdown

Start by looking at the timing of the change on the output of the register $S_{i−1}$. This follows the positive-edge of the clock after a small delay (the clk-to-q time of the flip-flops used to implement the register). We assume that the input $X$ is applied at precisely the same time. The two values move through the adder together and after a small delay (the adder propagation delay $\tau_{add}$) a new result appears at the output of the adder, $S_i$. Then all is quiet until the rising edge of the clock. At that time the output value is transferred to the register and the whole process repeats.
:::

### Different signal arrival times

In practice $X_i$ may not necessarily arrive at the same time as the feedback value, $S_{i−1}$. The waveforms below in @fig-accumulator-timing-realistic show $X$ arriving **a little bit later** than $S_{i−1}$.

:::{figure} images/accumulator-timing-realistic.png
:label: fig-accumulator-timing-realistic
:width: 100%
Even though $X_i$ and $S_{i-1}$ arrive at different times to the accumulator, the clock period is long enough that $S_i$ is stable before the next rising edge of the clock.
:::

:::{note} Show explanation of @fig-accumulator-timing-realistic
:class: dropdown
When the register first captures $X_0$, for a small time period the $X$ input still has $X_0$, therefore
the adder begins to compute $X_0 + X_0$! However, this erroneous calculation is quickly aborted when the $X$ input changes to $X_1$. Unfortunately, the aborted computation will probably make it through the adder, creating a sort of instability at the output. However, the instability in $S_i$ has no effect on $S_{i−1}$, as it captures its value from $S{i}$ before it goes bad.
:::

As seen above, on each cycle there is a small time period where the adder has inconsistent inputs. This sort of arrival mismatch and subsequent output instability is common in many circuits. In properly designed circuits, this instability never happens around the rising-edge of the clock and therefore gets ignored by the registers and downstream circuitry.

## Computing Maximum Clock Frequency

Notice that the maximum clock frequency (minimum clock period) is limited by the propagation delay of the add/shift operation. If we try to make the clock period too short, then the add/shift logic
would not have sufficient time to generate its output and the output register would capture an incorrect value.

At the same time, we seek to create high-bandwidth circuits, which produce many outputs per second. We'd like to find an ideal balance between a high-frequency clock and stable outputs.

:::{hint} The minimum clock period (T) is the delay on the critical path.

**Critical path of a circuit**: The path between input(s) and output(s) that incurs worst-case (maximum) delay. Typically this is determined by identifying the longest delay from any register (flip-flop) output to any register (flip-flop) input.
:::

:::{hint} The maximum clock frequency (f) is the inverse of the minimum clock period.

$T$ is clock period (in seconds, or nanoseconds), and $f$ is clock frequency (in cycles/second, or s{sup}`-1`, or Hz, or GHz). 

Relationship: $f = 1/T$.
:::

@fig-critical-path shows a typical circuit.

:::{figure} images/critical-path.png
:label: fig-critical-path
:width: 55%
:alt: "TODO"

To determine the minimum clock period, compute the delay on the critical path.
:::

In this circuit, the critical path is:

$$\text{critical path} = \text{clk-to-q delay} + \text{CL delay} + \text{setup time}$$

where clk-to-q delay and setup time are properties of the register (e.g., internal flip flops), and CL delay is the delay through the combinational logic block.

::::{tip} Quick Check

What is the maximum clock frequency for the circuit shown in @fig-critical-path-practice?

* **A.** 5 GHz
* **B.** 200 MHz
* **C.** 500 MHz
* **D.** 1/7 GHz
* **E.** 1/6 GHz
* **F.** Something else

Assume all registers have 1 ns clk-to-q delay, setup time, and hold time; AND gates have 1 ns propagation delay; and all unconnected inputs come from registers.

:::{figure} images/critical-path-practice.png
:label: fig-critical-path-practice
:width: 55%
:alt: "TODO"

Example circuit.
:::
::::

::::{note} Show Answer
:class: dropdown

* **C.** 500 MHz

The critical path is highlighted in @fig-critical-path-answer.

:::{figure} images/critical-path-answer.png
:label: fig-critical-path-answer
:width: 55%
:alt: "TODO"

Example circuit, with highlighted critical path.
:::

$$
\begin{align}
\text{critical path}
  &= \text{clk-to-q delay} + \text{delay of 3 AND gates} + \text{setup time} \\
  &= 1 \text{ns} + 3 \text{ns} + 1 \text{ns} \\
  &= 5 \text{ns}
\end{align}
$$

The minimum clock period is 5 ns = $10^{-9}$ seconds per cycle. The maximum frequency is therefore $1/(5 \times 10^{-9} \text{s}) = (0.2 \times 10^9) \text{s}^{-1} = (200 \times 10^6) \text{Hz}$, or 200 MHz.

::::

## Hold Time Violations

Above, the critical path determins the maximum clock frequency we can use to ensure a stable input to our register elements. We next present a different problem: **hold time violations**.

Recall from [earlier](#sec-registers) that the **hold time** is the duration during which a register's input d must be stable _after_ the rising edge of the clock. There are some cases where data propagates through the circuit is so fast that the input to registers become unstable during the hold time.

While rare[^hold-time-violation], this may occur if the _best-case_ delay between clocked elements is _shorter_ than the hold time. To mitigate this, we could add arbitrary delay to combinational logic the circuit to increase the best-case delay.

[^hold-time-violation]: See the relevant footnote in a [previous section](#sec-registers).