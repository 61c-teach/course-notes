---
title: "Adder/Subtractor"
subtitle: By John Wawrzynek, with edits by Lisa Yan
---

(sec-adder-subtractor)=
## Learning Outcomes

* Implement an n-bit adder as a cascade of 1-bit adders.
* Recall that XOR is a conditional inverter and can be used with SUB to augment the adder block into an adder/subtractor block.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/NkgFywLV65U
:width: 100%
:title: "[CS61C FA20] Lecture 17.3 - Combinational Logic Blocks: Adder/Subtractor"
:::

:::{iframe} https://www.youtube.com/embed/QFPvVUKTCFk
:width: 100%
:title: "[CS61C FA20] Lecture 17.4 - Combinational Logic Blocks: Subtractor Design"
:::

::::

@fig-add-sub-block shows the add/subtract block used in our [basic ALU](#sec-alu):

:::{figure} images/adder-sub-block.png
:label: fig-add-sub-block
:width: 55%
:alt: "TODO"

Adder/Subtractor block.
:::

This single circuit is capable of addition and subtraction:

* two 32-bit wide data inputs `A` and `B`
* a 1-bit wide control input `SUB`.
* a 32-bit wide data output `Y`
* a 1-bit wide output `overflow`.

When SUB=1, the circuit performs the subtraction `A - B`. When SUB=0 the circuit performs the addition `A + B`.

The "special" output, labeled **overflow** signals for [integer overflow](#sec-integer-overflow). Upon performing an addition or subtraction, this output will be a 1 if the result is too large to fit in 32 bits. We return to this fact [later](#sec-adder-overflow).

To design our adder/subtractor circuit, we will start out by studying the design of an adder circuit, then later augment it to also perform subtraction.

## Cascading Intuition

One strawman[^strawman] method for arriving at the detailed gate-level circuit for the adder would be to follow the procedure we learned in the previous chapter[^cl-practice]. Unfortunately, that technique is only effective for very narrow adders (e.g., 1-bit or 2-bit wide), because the size of the truth table is too large for wider adders.

Therefore, we turn to **modular design**: Find a way to break the design up into smaller more manageable pieces. We will design the smaller
pieces individually, then wire them together to create the entire wide adder.

[^strawman]: Wikipedia: [Straw Man](https://en.wikipedia.org/wiki/Straw_man)
[^cl-practice]: As discussed in the [previous chapter](#sec-cl-practice): Start with a truth table, write the canonical Boolean equation, then simplify.

:::{warning} Cascade 1-bit adders
Instead of computing canonical form for a truth table, deconstruct an n-bit adder into a **cascade** of 1-bit adders.

**Long-hand addition** gives us a good guide on how to break up the adder into pieces.
:::

Consider adding two 4-bit numbers `A`= a{sub}`3`a{sub}`2`a{sub}`1`a{sub}`0` and `B`= b{sub}`3`b{sub}`2`b{sub}`1`b{sub}`0`:

```{math}
:label: eq-add-4
:enumerated: true
\begin{array}{c c c c c}
    & \texttt{c}_{\texttt{3}} & \texttt{c}_{\texttt{2}} & \texttt{c}_{\texttt{1}} & \\
    & \texttt{a}_{\texttt{3}} & \texttt{a}_{\texttt{2}} & \texttt{a}_{\texttt{1}} & \texttt{a}_{\texttt{0}} \\
    + & \texttt{b}_{\texttt{3}} & \texttt{b}_{\texttt{2}} & \texttt{b}_{\texttt{1}} & \texttt{b}_{\texttt{0}} \\
    \hline
    & \texttt{y}_{\texttt{3}} & \texttt{y}_{\texttt{2}} & \texttt{y}_{\texttt{1}} & \texttt{y}_{\texttt{0}}
\end{array}
```

Example, where `A` is `1011` and `B` is `0001`:

```{math}
\begin{array}{c c c c c}
    & \texttt{0} & \texttt{1} & \texttt{1} & \\
    & \texttt{1} & \texttt{0} & \texttt{1} & \texttt{1} \\
    + & \texttt{0} & \texttt{0} & \texttt{0} & \texttt{1} \\
    \hline
    & \texttt{1} & \texttt{1} & \texttt{0} & \texttt{0}
\end{array}
```

:::{note} Explanation

When we add by hand:

* Begin by adding together the two least significant bits of A and B, a{sub}`0` and b{sub}`0`, respectively (call this the zero-th spot). From that addition, we generate a **result bit**, y{sub}`0`, and possibly a **carry out** bit c{sub}`1`.
* Then we move over to the next more significant column (the first spot), adding the **carry in** bit c{sub}`1` from the previous stage along with the next two bits of `A` and `B`, a{sub}`1` and b{sub}`1`, respectively.
* We then continue the process by moving left one column at a time until we have finished all n columns. In Equation @eq-add-4, n is 4.
:::

## 1-bit Adder

Addition in the i{sup}`th` spot produces two outputs:

* **Result bit**, i.e., y{sub}`i`
* **Carry bit** (e.g., c{sub}`i+1` which feeds into the addition in the (i+1){sup}`th` spot addition. We name a carry bit according to the stage to which it is an input.

### Zero-th spot

We build our intuition for implementing a 1-bit adder by considering the adder in the zero-th spot (least significant stage). This computes the least significant result bit, $\texttt{y}_{\texttt{0}}$, and the **carry-out** bit of the least significant stage, $\texttt{c}_{\texttt{1}}$.

:::{figure} images/adder-1-zero.png
:label: fig-adder-1-zero
:width: 70%
:alt: "TODO"

1-bit adder in zero-th spot, _without_ carry-in bit.
:::

By inspection of the truth table in @tab-adder-1-zero, we can directly write the logic equations for this stage[^xor-and].

[^xor-and]: `^`: XOR, `&`: AND

:::::{grid} 2
::::{grid-item}
:::{table} Truth table for 1-bit adder in zero-th spot.
:label: tab-adder-1-zero

| $\texttt{a}_{\texttt{0}}$ | $\texttt{b}_{\texttt{0}}$ | $\texttt{y}_{\texttt{0}}$ | $\texttt{c}_{\texttt{1}}$ |
| :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

:::
::::
::::{grid-item}
```{math}
\begin{aligned}
\\ \\ \\
    \texttt{s}_{\texttt{0}} &= \texttt{a}_{\texttt{0}} \texttt{ \^ \ } \texttt{b}_{\texttt{0}} \\
    \texttt{c}_{\texttt{1}} &= \texttt{a}_{\texttt{0}} \texttt{ \& } \texttt{b}_{\texttt{0}}
\end{aligned}
```
::::
:::::
<!-- end grid -->

### First spot

Next, consider the logic for the next significant stage (and all subsequent stages):

:::{figure} images/adder-1-one.png
:label: fig-adder-1-one
:width: 70%
:alt: "TODO"

1-bit adder in first spot, _with_ carry-in bit.
:::

Even though the truth table is larger, the logic equations are still straightforward to write—at least, if we remember what we learned from previous sections.

:::::{grid} 2
::::{grid-item}
:::{table} Truth table for 1-bit adder in first spot.
:label: tab-adder-1-one

| $\texttt{a}_{\texttt{1}}$ | $\texttt{b}_{\texttt{1}}$ | $\texttt{c}_{\texttt{1}}$ | $\texttt{y}_{\texttt{1}}$ | $\texttt{c}_{\texttt{2}}$ |
| :---: | :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 |
| 0 | 1 | 0 | 1 | 0 |
| 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 |
| 1 | 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 1 | 1 |

:::
::::
::::{grid-item}
```{math}
\begin{aligned}
\\ \\ \\ \\ \\ 
\begin{aligned}
    \texttt{y}_{\texttt{1}} &= \texttt{XOR}(\texttt{a}_{\texttt{1}}, \texttt{b}_{\texttt{1}}, \texttt{c}_{\texttt{1}}) \\
    \texttt{c}_{\texttt{2}} &= \texttt{MAJ}(\texttt{a}_{\texttt{1}}, \texttt{b}_{\texttt{1}}, \texttt{c}_{\texttt{1}}) \\
    &= \texttt{a}_{\texttt{1}}\texttt{b}_{\texttt{1}} + \texttt{a}_{\texttt{1}}\texttt{c}_{\texttt{1}} + \texttt{b}_{\texttt{1}}\texttt{c}_{\texttt{1}}
\end{aligned}
\end{aligned}
```
::::
:::::
<!-- end grid -->

:::{tip} Why does the truth table have 8 rows?
:class: dropdown

The truth table now has
8 rows, because there are three inputs into this stage:

* a bit from each of A and B, along with
* the **carry-in** bit for this current stage, which is also the carry-out from the previous stage.
:::

:::{tip} Why XOR for result bit, and MAJ (Majority) for carry bit?
:class: dropdown

By carefully inspecting the truth-table you will notice:

* **Result bit** $\texttt{y}_{\texttt{1}}$: The sum output is the **XOR of the three inputs**. Recall that an [N-bit XOR](#sec-n-xor) is a 1 when the number of 1’s in the input is odd.
* **Carry-out bit** $\texttt{c}_{\texttt{2}}$: The carry-out function is the **majority function**. Recall that a [3-way majority circuit](#sec-majority-circuit) is a 1 when the number of 1’s in its input is greater than the number of 0
:::

### General case

Let us finally consider the logic for the i{sup}`th` spot, where $i = 0, ..., n-1$ for an $n$-bit wide addition. We will encapsulate the operations of one stage, or column, of the add operation into a small block, shown in @fig-adder-1-i:

:::{figure} images/adder-1-i.png
:label: fig-adder-1-i
:width: 70%
:alt: "TODO"

1-bit adder in i{sup}`th` spot, _with_ carry-in bit.
:::

You can think of this block as a **1-bit adder**. It’s official name is a full-adder cell, but most people confuse this with an n-bit adder, which it certainly is not.

The 1-bit adder's gate-level circuit diagrams for its internals are in @fig-adder-1-i-circuit. The logic equation can be pattern-matched from our earlier discussion and is Equation @eq-adder-1-i.

:::::{grid} 2
::::{grid-item}
:::{figure} images/adder-1-i-circuit.png
:label: fig-adder-1-i-circuit
:width: 100%
:alt: "TODO"

1-bit-adder circuit.
:::
::::
::::{grid-item}
```{math}
:label: eq-adder-1-i
:enumerated: true

\begin{aligned}
\\ \\ \\
\begin{aligned}
    \texttt{y}_{\texttt{i}} &= \texttt{XOR}(\texttt{a}_{\texttt{i}}, \texttt{b}_{\texttt{i}}, \texttt{c}_{\texttt{i}}) \\
    \texttt{c}_{\texttt{i+1}} &= \texttt{MAJ}(\texttt{a}_{\texttt{i}}, \texttt{b}_{\texttt{i}}, \texttt{c}_{\texttt{i}}) \\
    &= \texttt{a}_{\texttt{i}}\texttt{b}_{\texttt{i}} + \texttt{a}_{\texttt{i}}\texttt{c}_{\texttt{i}} + \texttt{b}_{\texttt{i}}\texttt{c}_{\texttt{i}}
\end{aligned}
\\ \\ \\
\end{aligned}
```
::::
:::::

:::{warning} What about the zero-th spot?
We will not bother creating a special block for the first column of the adder, because anything it can do the 1-bit adder block can do as well. We just need to figure out where to attach the carry-in (i.e., $\texttt{c}_{\texttt{0}}$). More on this later.
:::

## N-bit Adder

The next step in the design of our adder circuit is to wire together a collection of our 1-bit adders to create an **n-bit adder**. All we need to do is to wire the carry-out output of one stage into the carry-in input of the next, from least significant to most, as shown in @fig-cascade-add:

:::{figure} images/cascade-add.png
:label: fig-cascade-add
:width: 100%
:alt: "TODO"

(Incomplete) Cascading n-bit adder. The carry-in bit c{sub}`0` is set to GND, but the carry-out bit c{sub}`n` is currently unused.
:::

Inputs are applied at the top and _after some delay_, associated with the delay through the logic gates for the blocks, and the delay of the carry from stage to stage, the final result appears at the bottom.

**What to do with carry-in bit c{sub}`0`?** For the adder to produce the correct result, convince yourself that c{sub}`0` must be connected to a source of logic 0 (GND in the circuit). But we will find something more interesting to do for c{sub}`0` when we discuss the [subtractor](#sec-subtractor) below.

**What to do with carry-out bit c{sub}`n`?** The carry-out from the most significant stage, c{sub}`n`, can be used as the (n+1){sup}`th` bit of the result (remember, adding two n-bit numbers could result in a (n+1)-bit result). However, in most uses for an adder, we must generate an n bit result. For instance, RV32I registers can only store 32 bits, so the result of the add instruction must be a 32-bit number. In this case, we must signal **overflow**, which we discuss next.

(sec-adder-overflow)=
### Overflow

As discussed in our initial [adder/subtractor design](#fig-add-sub-block), an overflow output must be generated to indicate when the result cannot fit into n bits. Recall from an [earlier section](#sec-integer-overflow) that overflow can occur when adding a pair of negative numbers or when adding a pair of positive numbers.

We can make the following observations about adds in this circuit. Remember, the most significant stage is the stage associated with the sign bit, i.e., stage n-1.

* If there was a **carry in** to the most significant stage, **but no carry out** of that stage, then A and B were both _positive_ and the result of the addition **overflowed**, erroneously generating a 1 in the sign bit position.
* If there was a **carry out** of the most significant stage and **no carry out** that stage, then A and B were both _negative_ and the result of addition **overflowed**.
* In all other cases the value of the carry in to the most significant stage matches the carry out, then there was **no overflow**.

We demonstrate this intuition in @fig-2bit-add-overflow-table for a 2-bit adder.

:::{figure} images/2bit-add-overflow-table.png
:label: fig-2bit-add-overflow-table
:width: 70%
:alt: "TODO"

2-bit adder overflow table diagram. Overflow occurs when adding $1 + (-2) = -1$, $1 + 1$, and $(-1) + (-2)$. Notably, the first is a valid addition, where the latter two produce incorrect results.
:::

::::{note} Show Explanation of @fig-2bit-add-overflow-table
:class: dropdown

@fig-2bit-add-overflow-overview provides a high-level idea of addition with 2-bit numbers `A` and `B`. Keep the integer wheel on the left in mind when adding integers. Keep the integer wheel in mind when adding integers.

:::{figure} images/2bit-add-overflow-overview.png
:label: fig-2bit-add-overflow-overview
:width: 100%
:alt: "TODO"

High-level 2-bit adder overflow table diagram.
:::

Three overflow results are boxed in @fig-2bit-add-overflow-table:

* $1 + 1 = -2$, not $2$
* $-2 + (-2) = 0$, not $-4$
* $-1 + (-2) = 1$, not $-3$

The original @fig-2bit-add-overflow-table shows the bit patterns of these three additions (among others), resulting in the three observations in this section.

::::

Based on these observations, we can design a simple circuit that generates the overflow output signal by **comparing** the carry-in and carry-out of stage n-1. A simple
circuit that indicates when two signals are different in value is the **XOR gate**.

$$ \texttt{overflow} = \texttt{c}_{\texttt{n}} XOR \texttt{c}_{\texttt{n-1}} $$

@fig-cascade-add-overflow shows our full n-bit adder:

:::{figure} images/cascade-add-overflow.png
:label: fig-cascade-add-overflow
:width: 100%
:alt: "TODO"

Cascading n-bit adder with overflow.
:::

(sec-subtractor)=
## Subtractor

We mentioned earlier that addition and subtraction are closely related, and therefore we would expect that their respective circuits are similar and could serve dual both purposes.

As discussed in our initial [adder/subtractor design](#fig-add-sub-block), a control bit SUB signals if the add/subtract block should perform subtraction. We note the following holds, due to two's complement:

* When SUB=0 the circuit performs the addition `A + B`.
* When SUB=1, the circuit performs the subtraction `A - B`. The following statements are erquivalent:
  * Compute `A + (-B)`, where `B` is the two's complement.
  * Compute `A + ~B + 1`. This is the definition of two's complement: invert bits and add 1.

This last observation gives us a very clean way to augment our adder circuit to be a combined adder and subtractor:

1. Add 1 to the result.
1. Invert the bits of `B`.

:::{hint} Wire SUB to c{sub}`0`

We don’t really need a second adder to perform the +1, because we have the unused input c{sub}`0` (the carry in bit for the zero-th spot).

  * When SUB=1, connect c{sub}`0` to 0.
  * When SUB=1, connect c{sub}`0` to 1 to add an extra 1 in with the least significant column, achieving the extra +1. 

In other words, wire SUB to c{sub}`0`.

:::

:::{hint} XOR SUB with the bits of B
The other augmentation needed for subtraction is to invert all the bits of B before feeding them into the top of the adder. Of course, we want the inversion to be **conditional** on which operation we wish the circuit to perform: ADD or SUB.

Once again, we turn to our old friend the XOR gate. If looked at the right way, an XOR gate is an conditional inverter (review your [properties of bitwise operations](#sec-bitwise-props)!).

* If one of the inputs to an XOR gate is a 0, then the output takes on the value of the other input.
* On the other hand, if one of the inputs to an XOR gate is a 1, then the other input passes through, **inverted**.

We can therefore conditionally invert B, by passing each of its bits through an XOR gate with SUB on the way to the input of the adder!
:::

The augmented adder design is shown below. When the input SUB is 1 the block performs subtraction, when SUB=0 the block performs addition.

:::{figure} images/nbit-add-sub.png
:label: fig-nbit-sub-design
:width: 100%
:alt: "TODO"

N-bit adder/substractor design circuit diagram.
:::
