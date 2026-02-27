---
title: "Logic Gates"
---

(sec-logic-gates)=
## Learning Outcomes

* Use truth tables to enumerate the input-output relationships of a basic logic gate.
* Describe the functionality of N-input logic gates (in particular, the 3-input XOR gate).
* Compose logic gates together to build more complex combinational logic circuits.

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

<!-- begin grid -->
:::::::{grid} 3

::::::{card}
:header: AND
:label: card-and-gate
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
  * We can implement any (stateless) discrete function with just three gates AND, OR, and NOT.
  * The NOT gate is commonly called an **inverter**. Note the "bubble" (circle).
* [NAND](#fig-nand-gate) is "NOT" AND. Note the bubble on its output.
  * NAND is known as a **universal gate**—NANDs can be wired together to create any of the other gates. So we can implement any (stateless) discrete function with just one gate: NAND. Try it out at home.
* [NOR](#fig-nor-gate) is "NOT" OR. Again, note the bubble.
  * NOR is also a universal gate.

## N-Input Logic Gates

Except for NOT (which is a unary operator), we have shown 2-input versions of these common gates. Versions of these gates with more
than two inputs also exist. For performance reasons, the number of inputs to logic gates is usually restricted to around a maximum of four. 

:::{figure} images/and-gate-n.png
:label: fig-and-gate-n
:width: 30%
:alt: "TODO"

4-input AND gate. The output `y` is `1` if and only if `a`, `b`, and `c` are all `1`.
:::

The function of these gates with more than two inputs
is obvious from the function of the two input version, except in the case of the the exclusive-or gate,

Except for NOT (which is unary), we have shown 2-input versions of these gates. Versions of these gates with more
than two inputs also exist. However, for performance reasons, the number of inputs to logic gates is
usually restricted to around a maximum of four.

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

## Designing Combinational Logic Circuits

These simple logic gates can be wired together to build useful circuits. In fact, any combinational logic block can be implemented with nothing but logic gates.

Suppose we want to implement the combinational logic block **compare**, which takes two inputs and returns `1` if the two inputs are equal and `0` otherwise. Validate that the [truth table below](#tab-compare-2) enumerates the possible input/output values of this [compare block](#fig-compare-2-block).

:::::{grid} 2
::::{grid-item} Gate
:::{figure} images/compare-2-block.png
:label: fig-compare-2-block
:width: 50%
:alt: "TODO"
:::
::::
::::{grid-item} Truth Table
:::{table}
:label: tab-compare-2
:align: center

| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

:::
::::
:::::

With some thought, we can design compare as a composition of AND, OR, and NOT blocks. The filled in dot represents a **junction**, where the signal splits and is held on both wires.

:::{figure} images/compare-2-circuit.png
:label: fig-compare-2-circuit
:width: 50%
:alt: "TODO"
:::

:::{note} Show Explanation
:class: dropdown

* Top AND gate: This gate output is `1` only if `a` and `b` are both `1`.
* Bottom AND gate. Because of the two NOT gates right before input, this gate output is `1` only if NOT `a` and NOT `b` are both `1`, i.e., `a` and `b` are both `0`.[^not-nand]
* OR gate. The output `y` is `1` if at least one of the AND gates is `1`.[^mutually-exclusive]

[^not-nand]: Notably, this circuit is not a NAND gate; we leave the proof to you. We suggest writing things out with truth tables.

[^mutually-exclusive]: In this case, note the outputs of the two AND gates will never _both_ be `1`. We could have replaced the OR gate with an XOR gate.
:::

This approach will be challenging for more complex block descriptions. We introduce **boolean algebra** next to structure our approach. Stay tuned!
