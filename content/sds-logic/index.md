---
title: "Logic Gates"
---

(sec-logic-gates)=
## Learning Outcomes

* Use truth tables to enumerate the input-output relationships of a basic logic gate and a combinational logic circuit.
* Describe the functionality of N-input logic gates (in particular, the 3-input XOR gate).
* Practice modular design: compose complex circuits using smaller circuits.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/KOXgVikIYi4
:width: 100%
:title: "[CS61C FA20] Lecture 16.1 - Combinational Logic: Truth Tables"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vX8BhDk3qhc
:width: 100%
:title: "[CS61C FA20] Lecture 16.2 - Combinational Logic: Logic Gates"
:::

::::

To design circuits that perform complex operations on binary signals, we must first define primitive operators called **logic gates**. Logic gates are
simple circuits (each with only a handful of transistors) that can be wired together to implement any combinational logic function. In  CS 61C we consider logic gates are primitive elements; they are the basic building blocks for our circuits.


The simplest logic gates are **binary** or **unary** operators that take as input one/two binary variables and output one binary value.

::::::{note} AND logic gate

:::::{grid} 4
:label: fig-test-label
::::{grid-item}

::::{grid-item}
:::{figure}
```{code} bash
y = AND(a,b)
  = a & b
```
1. Function Definition
:::
::::

::::{grid-item}
:::{figure} #tab-and
:width: 70%
2. Truth Table
:::
::::

::::{grid-item}
:::{figure} images/and-gate-mnemonic.png
:width: 70%
3. Graphical Representation[^mnemonic]

[^mnemonic]: Mnemonic: The AND gate is shaped like the "D" in AN**D**.
:::
::::

::::{grid-item}
:::{figure} images/and-transistor.png
:width: 70%
4. Transistor Circuit
:::
::::

:::::

Four different representations:

1. The function definition `y = AND(a, b)`. The second line uses the C bitwise operation `&`.
1. The truth table for `y = AND(a, b)`. Each row enumerates each input combination and the corresponding output value.
1. The logic gate symbol for AND, used as a graphical representation in digital circuit diagrams. 
1. CMOS transistor circuit for  the AND logic gate.[^and-cmos]

[^and-cmos]: Out of scope for this course, but those interested, [read more](https://electronics.stackexchange.com/a/226028) about AND.

::::::

## Common Logic Gates

Here are some common logic gates. For each we define its name and show (left) its graphical representation and (right) a truth table that defines its function.

:::{warning} Review Bitwise Operations

You have already seen many operations of basic logic gates with [C bitwise operations](#sec-c-bitwise-ops)! We recommend reviewing this section before continuing.
:::

:::{warning} Check the Truth Tables

Click on the tabs below to show each gate's graphical representation and its **truth table**.

For each input pattern of 1’s and 0’s, there exists a single output pattern. Truth tables enumerate this input/output relationship. For the 2-input logic gates below, there are four rows. 
:::


<!-- begin grid -->
:::::::{grid} 3

::::::{card}
:header: AND
:::::{tab-set}
::::{tab-item} Gate
:::{figure} images/and-gate.png
:label: fig-and-gate
:width: 100%
:alt: "TODO"
:::
::::
::::{tab-item} Truth Table
:::{figure} #tab-and
:::
::::
:::::
::::::

::::::{card}
:header: OR
:::::{tab-set}
::::{tab-item} Gate
:::{figure} images/or-gate.png
:label: fig-or-gate
:width: 100%
:alt: "TODO"
:::
::::
::::{tab-item} Truth Table
:::{figure} #tab-or
:::
::::
:::::
::::::

::::::{card}
:header: NOT
:::::{tab-set}
::::{tab-item} Gate
:::{figure} images/not-gate.png
:label: fig-not-gate
:width: 100%
:alt: "TODO"
:::
::::
::::{tab-item} Truth Table
:::{figure} #tab-not
:::
::::
:::::
::::::

::::::{card}
:header: NAND
:::::{tab-set}
::::{tab-item} Gate
:::{figure} images/nand-gate.png
:label: fig-nand-gate
:width: 100%
:alt: "TODO"
:::
::::
::::{tab-item} Truth Table
:::{table}
:label: tab-nand
:align: center

| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

:::
::::
:::::
::::::

::::::{card}
:header: NOR
:::::{tab-set}
::::{tab-item} Gate
:::{figure} images/nor-gate.png
:label: fig-nor-gate
:width: 100%
:alt: "TODO"
:::
::::
::::{tab-item} Truth Table
:::{table}
:label: tab-nor
:align: center

| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 0 |

:::
::::
:::::
::::::

::::::{card}
:header: XOR
:::::{tab-set}
::::{tab-item} Gate
:::{figure} images/xor-gate.png
:label: fig-xor-gate
:width: 100%
:alt: "TODO"
:::
::::
::::{tab-item} Truth Table
:::{figure} #tab-xor
:::
::::
:::::
::::::

:::::::
<!-- end grid -->


Notes:

* [AND](#fig-and-gate), [OR](#fig-or-gate), [NOT](#fig-not-gate) and [XOR](#fig-xor-gate) follow from the C bitwise operations you learned eariler.
  * The NOT gate is commonly called an **inverter**. Note the "bubble" (circle).
* [NAND](#fig-nand-gate) is "NOT" AND. Note the bubble on its output.
* [NOR](#fig-nor-gate) is "NOT" OR. Again, note the bubble.

(sec-subset-gates)=
:::{hint} Compose logic gates to build circuits

In general, the complete set of logic gates shown above is not needed.
Select subsets are sufficient, though for simplicity a larger subset is usually employed.

Any combinational logic function can be implemented with:

* Just the set of AND and NOT
* Just the set of OR and NOT
* NAND gates only (NAND is known as a **universal gate**)
* NOR gates only (again, also a universal gate)
* **AND, OR, and NOT** are particularly useful; we will see why when we discuss boolean algebra in a [later section](#sec-boolean-algebra).
:::

## N-Input Logic Gates

Except for NOT (which is a unary operator), we have shown 2-input versions of these common gates. Versions of these gates with more
than two inputs also exist. For performance reasons, the number of inputs to logic gates is usually restricted to around a maximum of four.

:::{figure} images/and-gate-n.png
:label: fig-and-gate-n
:width: 30%
:alt: "TODO"

4-input AND gate. The output `y` is `1` if and only if `a`, `b`, and `c` are all `1`.
:::

The function of these gates with more than two inputs is obvious from the function of the two input version, except in the case of the the exclusive-or gate,

Except for NOT (which is unary), we have shown 2-input versions of these gates. Versions of these gates with more than two inputs also exist. However, for performance reasons, the number of inputs to logic gates is usually restricted to around a maximum of four.

The function of these gates is generally self-evident and can deterined by repeatedly composing the equivalent 2-input gate; for example, `AND(a, b, c, d) = AND(AND(a, AND(b, AND(c, d)))) = AND(AND(a, b), AND(c, d))`, etc. There are a few exceptions; let's try your reasoning with some quick checks.

```{tip} What is an N-input [NAND](#fig-nand-gate)?
:class: dropdown

An N-input NAND is NOT of an (N-input AND).
```

```{tip} What is an N-input [NOR](#fig-nor-gate)?
:class: dropdown

An N-input NOR is NOT of an (N-input OR).
```

```{hint} [Important] What is an N-input [XOR](#fig-xor-gate)?

An N-input XOR is 1 if the number of 1s on all the inputs is **odd**.

Consider the 3-input XOR gate, where `y = XOR(a, b, c) = XOR(a, XOR(b, c))`, etc. Validate with the truth table:

:::{table} 3-input XOR gate.
:label: tab-xor-three

| a | b | c | y |
| :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 |
| 1 | 1 | 1 | 1 |
:::
```

## Combinational Logic Circuit $\rightarrow$ Truth Table

Note that simple logic gates can be wired together to build useful circuits. In fact, any combinational logic block can be implemented with nothing but AND, OR, and NOT logic gates.

However, to understand what a circuit actually does, we need more than just its circuit diagram: we need a concise description of its operation. Let's first try with **truth tables**.

To generate a truth-table from a given circuit, we need to evaluate it for input combinations.

::::{hint} What is the truth table of the below circuit?

:::{figure} images/compare-2-circuit.png
:label: fig-compare-2-circuit
:width: 50%
:alt: "TODO"
Mystery circuit.
:::

::::

:::{note} Truth Table

| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

* Top AND gate: This gate output is `1` only if `a` and `b` are both `1`.
* Bottom AND gate. Because of the two NOT gates right before input, this gate output is `1` only if NOT `a` and NOT `b` are both `1`, i.e., `a` and `b` are both `0`.[^not-nand]
* OR gate. The output `y` is `1` if at least one of the AND gates is `1`.
:::

So...what does this circuit do? Importantly, we note that the outputs of the two AND gates will never _both_ be `1`, so we could have replaced the OR gate with an XOR gate.

After some thought, we may realize that this combinational logic circuit may actually be succinctly described as a **compare**: Take two inputs and returns `1` if the two inputs are equal and `0` otherwise. 

If we wanted to use this compare circuit in other circuits, we can! Just represent it as a **combinational logic block**, as below:

:::{figure} images/compare-2-block.png
:label: fig-compare-2-block
:width: 30%
:alt: "TODO"

Bitwise compare circuit; a block representation of the mystery circuit in @fig-compare-2-circuit.
:::

[^not-nand]: Notably, this circuit is not a NAND gate; we leave the proof to you. We suggest writing things out with truth tables.

## Composing Circuits: 32-Bit Comparator

We would like to a circuit that **compares two 32-bit values**; this 32-bit compare circuit can be used in our processor to implement the equality comparison for the RV32I instruction `beq rs1 rs2 Label`.

:::{figure} images/compare-32-block.png
:label: fig-compare-32-block
:width: 30%
:alt: "TODO"

32-bit compare circuit.
:::

Compare this new 32-bit compare circuit(@fig-compare-32-block) with our previous 1-bit compare circuit (@fig-compare-2-block):

* The value `A` is a 32-bit value, because of the **wire bundle** (the wire is marked with a notch). Similarly, value `B` is 32-bits.
* The value `z` is a 1-bit value.

Functionally, `z` is `1` only if all of `A`'s bits are equal to all of `B`'s bits. In other words, we can perform 32 bitwise comparisons, then AND them together. The underlying circuit for our compare block is therefore as follows:

:::{figure} images/compare-32-circuit.png
:label: fig-compare-32-circuit
:width: 80%
:alt: "TODO"

32-bit compare circuit diagram, assuming we have implemented the bitwise compare circuit. The 32-input AND gate can be implemented recursively with 2- or 4-input AND gates.
:::

:::{hint} The power of **modular design**

The truth table of the 32-bit comparator is too large for us to write by hand  (it has $2^{64}$ rows, for each combination of the bits of `A` and `B`). If truth tables are too big to construct, decompose by defining smaller circuits first, then compose the larger circuit with these smaller circuit blocks. This is the power of **modular design**

In the next section, we introduce [Boolean Algebra](#sec-boolean-algebra) to help us formulaically use truth tables to design circuits.
:::
