---
title: "Data Multiplexors"
subtitle: By John Wawrzynek, with edits by Lisa Yan
---

(sec-mux)=
## Learning Outcomes

* Draw an n-bit wide, k-to-1 mux circuit.
* Explain how the mux uses its control signal to select its output from a set of data inputs.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/iaJVhHQN0ys
:width: 100%
:title: "[CS61C FA20] Lecture 17.1 - Combinational Logic Blocks: Data Multiplexors"
:::

::::

Last time we saw how to represent and design **combinational logic blocks**. In this section we will study a few special logic blocks; data multiplexors, a adder/subtractor circuit, and an arithmetic/logic unit.

## The Mux

A data **multiplexor**, commonly called a **mux** or a **selector**, is a circuit that selects its output value from a set of input values. Below are two mux circuits.

:::::{grid} 2

::::{grid-item}
:::{figure} images/mux-2.png
:label: fig-mux-2
:width: 50%
:alt: "TODO"

A 1-bit wide, 2-to-1 MUX.
:::
::::
::::{grid-item}
:::{figure} images/mux-n.png
:label: fig-mux-n
:width: 57%
:alt: "TODO"

An n-bit wide, 2-to-1 MUX.
:::
:::::
<!-- end grid -->

Both of these muxes have two **data** inputs and one output. Additionally, each mux has a special **control signal** labeled s, for **select**. The s signal is also input, but it is used to control which of the two input values is directed to the output.

@fig-mux-2 shows a **1-bit wide**, **2-to-1** mux circuit:

* 2-to-1 because it takes two data inputs `a` and `b` and outputs one of them.
* It is 1-bit wide because all data signals (`a` and `b`) are 1-bit in width.
* Notice, however, that the `s` signal is a single bit wide. This is because it must choose between the 2 inputs.

@fig-mux-n shows an **n-bit wide**, **2-to-1** mux circuit:

* 2-to-1 because it takes two data inputs `A` and `B` and outputs one of them.
* It is 1-bit wide because all data signals (`A` and `B`) are 1-bit in width.
* The `s` signal is still a single bit wide because it must choose between the 2 inputs.

The function of, say, the [1-bit wide 2-to-1 mux](#fig-mux-2) can be described with two rules:

```{math}
\texttt{y} = 
\begin{cases}
\texttt{a} & \text{when } \texttt{s} = 0 \\
\texttt{b} & \text{when } \texttt{s} = 1 \\
\end{cases}
```

To remind us of which value of s corresponds to which input, within the mux symbol we commonly label each input with its corresponding s value.

:::{hint} Use muxes to select data!
A mux is used whenever a circuit must choose data from multiple sources.

An n-bit wide N-to-1 MUX has N data inputs, 1 control input, and 1 output. The control input S selects between the other N inputs.

:::

:::{tip} Quick Check: Fill in the blanks

> A 32-bit wide 4-to-1 MUX selects between `__(1)__` input signals, each of which is `__(2)__` bits wide. This mux circuit has `__(3)__` selector bits.

:::

::::{note} Show Answer
:class: dropdown

:::{figure} images/mux-4.png
:label: fig-mux-4
:width: 30%
:alt: "TODO"

32-bit 4-to-1 mux circuit.
:::

1. 4 input signals
2. 32 bits wide
3. 2 selector bits

::::

Muxes find common use within the design of microprocessors, e.g., those that implement RISC-V.

## MUX: Implementation

In most applications, you will have access to a mux; you will not need to build your own from scratch. Nevertheless, it is good to remember that like all combinational logic blocks, the function of muxes can be described using a truth table and thereby implemented as a logic gate circuit.

Click to show the gate diagrams of two muxes: a 1-bit wide, 2-to-1 mux, and a 1-bit wide, 4-to-1 mux.

::::{note} 1-bit wide 2-to-1 mux

:::{table} Truth table for the 1-bit 2-to-1 mux in @fig-mux-2. Note that because there are three 1-bit inputs (`a`, `b`, and control `s`), the truth table has $3^2 = 8$ rows.
:label: tab-mux-2

| s | ab | y |
| :--: | :--: | :--: |
| 0 | 00 | 0 |
| 0 | 01 | 0 |
| 0 | 10 | 1 |
| 0 | 11 | 1 |
| 1 | 00 | 0 |
| 1 | 00 | 0 |
| 1 | 01 | 1 |
| 1 | 10 | 0 |
| 1 | 11 | 1 |
:::

To come up with the logic equation and the associated gate-level circuit diagram we can apply
the technique that we studied [last chapter](#sec-boolean-algebra). We write the sum-of-products canonical form and simplify through algebraic manipulation:

```{math}
\begin{aligned}
    y &= \overline{a} \overline{b} \overline{c} + \overline{a} \overline{b} c + a \overline{b} \overline{c} + a b \overline{c} && \text{Sum of Products} \\
      &= \overline{a} \overline{b} (\overline{c} + c) + a \overline{c} (\overline{b} + b) && \text{Distributivity} \\
      &= \overline{a} \overline{b} (1) + a \overline{c} (1) && \text{Inverse (OR) } x + \overline{x} = 1 \\
      &= \overline{a} \overline{b} + a \overline{c} && \text{Identity (AND) } x \cdot 1 = x
\end{aligned}
```

Intuitively this result makes sense; When the control input, s, is a 0, the right hand side of the equation reduces to a, and when it is a 1, the expression reduces to b.

:::{figure} images/mux-2-circuit.png
:label: fig-mux-2-circuit
:width: 80%
:alt: "TODO"

Gate diagram for a 1-bit 2-to-1 mux.
:::
::::

::::{note} 1-bit wide 4-to-1 mux

Often times we find the need to extend the number of data inputs of a multiplexor. For instance
consider a 4-to-1 multiplexor in @fig-mux-4-bits:

:::{figure} images/mux-4-bits.png
:label: fig-mux-4-bits
:width: 55%
:alt: "TODO"

A 1-bit wide 4-to-1 MUX.
:::

```{math}
\texttt{e} = 
\begin{cases}
\texttt{a} & \text{when } \texttt{S} = 00 \\
\texttt{b} & \text{when } \texttt{S} = 01 \\
\texttt{c} & \text{when } \texttt{S} = 10 \\
\texttt{d} & \text{when } \texttt{S} = 11 \\
\end{cases}
```

How would we come up with the circuit for this mux?

**Approach 1**. We could start by enumerating the truth-
table—in this case the function has 4 single bit data inputs and one 2-bit wide control input, for a total of 6 single bit inputs. The truth table would have 26, or 64 rows. Certainly, a feasible approach. If we where to do this, we would end up with the following logic equation:

$$e = \overline{s_1 s_0} a
     + \overline{s_1} s_0 b
     + s_1 \overline{s_0} c
     + s_1 s_0 d$$

**Approach 2**. Another way to design the circuit is to base it on the hierarchical nature of multiplexing. We can build a 4-to-1 mux from three 2-to-1 muxes as shown in @fig-mux-4-block. The first layer of muxes uses the $s_0$ input to narrow the four inputs down to two, then the second
layer uses $s_1$ to choose the final output.

:::{figure} images/mux-4-block.png
:label: fig-mux-4-block
:width: 60%
:alt: "TODO"

4-to-1 multiplexor (MUX) circuit diagram.
:::