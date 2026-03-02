---
title: "Canonical Form, CL Design"
---

(sec-cl-practice)=
## Learning Outcomes

* Practice translating between the three representations for a combinational logic block: truth table, boolean expression, and gate diagram.
* Practice using laws of Boolean Algebra.
* Practice modular design: compose complex circuits using smaller circuits.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/aZ6o8dDwgmM
:width: 100%
:title: "[CS61C FA20] Lecture 16.5 - Combinational Logic: Canonical Forms"
:::

::::

Our goal this lecture is to build combinational logic blocks. We can summarize this approach with the following diagram:

:::{figure} images/cl-block-representation.png
:label: fig-cl-block-representation
:width: 60%
:alt: "TODO"

Second equivalent circuit: $y = a + c$.
:::

@fig-cl-block-representation shows the three possible representation for a combinational logic block.

* The **truth table** form is unique—for every combinational logic block, there is only one truth table. The uniqueness of the truth-table makes it a useful way to clearly define the function of a combinational logic block.
* There are multiple **Boolean expressions** possible for any combinational logic block. Boolean expressions are useful for algebraic manipulation, particularly simplification.
* Multiple **gate level** representations for any combinational logic blocks. The gate diagram gives us a prescription for converting to an actual transistor circuit; each gate in the
diagram can be replaced by a small transistor circuit that achieves is respective gate level function.

:::{warning} The truth table is unique
For a given combinational logic block, there is only one truth table. By contrast, a combinational logic block can have multiple Boolean expressions and multiple circuit diagrams.
:::

This section discusses how to translate between the diferent representations of a combinational logic block. This section ends with how to _compose_ circuits from smaller blocks.

(sec-majority-circuit)=
### Example: Majority Circuit

The equation

```{math}
:label: eq-majority-circuit
:enumerated: true
y = ab + bc + ac
```

has the corresponding truth table

| a | b | c | y |
| :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

and has the corresponding gate circuit

:::{figure} images/majority-circuit.png
:label: fig-majority-circuit
:width: 60%
:alt: "TODO"

Circuit corresponding to $y = ab + bc + ac$.
:::

The equation says that the output y is the OR ($+$) of three terms, where each term is the AND of two input variables ($\cdot$ or concatenation). The correspondence between @eq-majority-circuit and the circuit in @fig-majority-circuit should be clear. The three product terms are implemented using AND gates and the final sum by the three input OR gate.

We call this a **three-input majority circuit** because the output y takes on the value that matches the majority of the
input values.

(sec-sum-product)=
## Canonical Form

Let’s go back to the truth table as our definition of a desired function. Starting from a truth table, by inspection, it is possible to write a Boolean expression that matches its behavior. The type of Boolean expression that we will write is called the **"sum-of-products" canonical form**.

The canonical form gets its name from the fact that it is formed by taking the sum (OR) of a set of terms, each term being a product (AND) of input variables or their complements.

* Every place (row) where a 1 appears in the output, we will use a product (AND) term in the Boolean expression.
* Each AND term includes all the input variables in either complemented or uncomplemented form.
* A variable appears in complemented form if it is a 0 in the row of the truth-table, and as a 1 if it appears as a 1 in
the row.

:::{warning} Why does Sum-of-Products work?

In the canonical form, the product terms are all different enumerations of the inputs. The output is 1 if at least one[^input] of the products is one. The output is zero if none of the products are one. Logically, this is the same functionality defined by the truth table!

[^input]:  In fact, "exactly" one, because input combinations are unique. In Sum-of-Products we opt for OR (instead of "XOR") in order to simplify expressions with laws of Boolean Algebra.

Barring associativity and commutativity of terms, the sum-of-products canonical form is unique.
:::

(sec-sum-product-example)=
## Example: Truth Table $\rightarrow$ Boolean Expression $\rightarrow$ Gate Diagram

Any CL circuit that can be practically specified as a truth-table can be represented with a Boolean
expression by writing its **canonical form**. Following that, through algebraic manipulation, it can be simplified, then translated to a circuit of logic gates.

:::{tip} Example
Design a circuit that implements the 3-input function described by the below truth table.

| $a$ | $b$ | $c$ | $y$ |
| :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 1 |
| 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 0 |
:::

**1. Use the truth table to build the canonical form.** The canonical form equation has four product terms, one for each of the 1’s in the output $y$.

$$y = \overline{a} \overline{b} \overline{c} + \overline{a} \overline{b} c + a \overline{b} \overline{c} + a b \overline{c}$$

:::{note} Click to show annotated truth table
:class: dropdown

| $a$ | $b$ | $c$ | $y$ | PRoduct |
| :---: | :---: | :---: | :---: | :--- |
| 0 | 0 | 0 | 1 | $\overline{a} \cdot \overline{b} \cdot \overline{c}$ |
| 0 | 0 | 1 | 1 | $\overline{a} \cdot \overline{b} \cdot c$ |
| 0 | 1 | 0 | 0 | |
| 0 | 1 | 1 | 0 | |
| 1 | 0 | 0 | 1 | $a \cdot \overline{b} \cdot \overline{c}$ |
| 1 | 0 | 1 | 0 | |
| 1 | 1 | 0 | 1 | $a \cdot b \cdot \overline{c}$ |
| 1 | 1 | 1 | 0 | |

:::

**2. Simplify using Boolean Algebra laws, if needed.**

```{math}
\begin{aligned}
    y &= \overline{a} \overline{b} \overline{c} + \overline{a} \overline{b} c + a \overline{b} \overline{c} + a b \overline{c} && \text{Sum of Products} \\
      &= \overline{a} \overline{b} (\overline{c} + c) + a \overline{c} (\overline{b} + b) && \text{Distributivity} \\
      &= \overline{a} \overline{b} (1) + a \overline{c} (1) && \text{Inverse (OR) } x + \overline{x} = 1 \\
      &= \overline{a} \overline{b} + a \overline{c} && \text{Identity (AND) } x \cdot 1 = x
\end{aligned}
```

**3. Draw the gate diagram.** The circuit specified by the canonical form is one of many circuits that implement the original 3-input function.


:::{figure} images/sum-product-example.png
:label: fig-sum-product-example
:width: 50%
:alt: "TODO"

Circuit specified by canonical form in [example](#sec-sum-product-example).
:::

:::{tip} Follow-up
Try designing this circuit with just NOR gates.
:::


## Example: Simplify Circuits

Simplifying circuits involves taking a gate diagram and writing its Boolean expression, simplifying it, then translating back to a gate diagram.

:::{tip} See the circuit simplification in the [previous section](#sec-boolean-algebra).

* [Setup](#sec-or-simplify-setup)
* [Proof](#sec-or-simplify-proof)
:::

## Example: Verify Circuit (Majority Circuit, Revisited)

In our [three-input majority circuit](#sec-majority-circuit), we can use the truth table to build the canonical form:

$$y = \overline{a}bc + a\overline{b}c + ab\overline{c} + abc$$

:::{note} Click to show annotated truth table
:class: dropdown

| $a$ | $b$ | $c$ | $y$ | Product |
| :---: | :---: | :---: | :---: | :--- |
| 0 | 0 | 0 | 0 | |
| 0 | 0 | 1 | 0 | |
| 0 | 1 | 0 | 0 | |
| 0 | 1 | 1 | 1 | $\overline{a} \cdot b \cdot c$ |
| 1 | 0 | 0 | 0 | |
| 1 | 0 | 1 | 1 | $a \cdot \overline{b} \cdot c$ |
| 1 | 1 | 0 | 1 | $a \cdot b \cdot \overline{c}$ |
| 1 | 1 | 1 | 1 | $a \cdot b \cdot c$ |

:::

We can then use Boolean algebra to verify that the canonical form is equivalent to the intuitive [majority circuit equation](#eq-majority-circuit):

```{math}
\begin{aligned}
    y &= \overline{a}bc + a\overline{b}c + ab\overline{c} + abc \\
      &= (\overline{a}bc + abc) + a\overline{b}c + ab\overline{c} + abc && \text{Idempotence: } x = x + x \\
      &= (\overline{a} + a)bc + a\overline{b}c + ab\overline{c} + abc && \text{Distributivity} \\
      &= (1)bc + a\overline{b}c + ab\overline{c} + abc && \text{Inverse (OR)} \\
      &= bc + (a\overline{b}c + abc) + ab\overline{c} + abc && \text{Idempotence (again)} \\
      &= bc + a(\overline{b} + b)c + ab\overline{c} + abc && \text{Distributivity} \\
      &= bc + ac + ab(\overline{c} + c) && \text{Distributivity} \\
      &= bc + ac + ab(1) && \text{Inverse (OR)} \\
      &= bc + ac + ab && \text{Simplified Expression}
\end{aligned}
```

## Example: Gate Diagram $\rightarrow$ Truth Table

To generate a truth table from a given circuit, we just need to evaluate the output for all possible input combinations.

::::{tip} What is the truth table of the below circuit?

:::{figure} images/compare-2-circuit.png
:label: fig-compare-2-circuit
:width: 70%
:alt: "TODO"
Circuit for 2-bit compare block.
:::

::::

Truth Table:

| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

:::{note} Show Explanation
:class: dropdown

* Top AND gate: This gate output is `1` only if `a` and `b` are both `1`.
* Bottom AND gate. Because of the two NOT gates right before input, this gate output is `1` only if NOT `a` and NOT `b` are both `1`, i.e., `a` and `b` are both `0`.[^not-nand]
* OR gate. The output `y` is `1` if at least one of the AND gates is `1`.

[^not-nand]: Notably, this circuit is not a NAND gate; we leave the proof to you. We suggest writing things out with truth tables.
:::

(sec-compare-2)=
### 2-Bit Compare

After some thought, you may have realized that this combinational logic circuit can be described as a **compare**: Take two inputs and returns `1` if the two inputs are equal and `0` otherwise. We use this functionality in a [later example](#sec-compose-circuits).[^compare-xor]

[^compare-xor]: We note that the outputs of the two AND gates will never _both_ be `1`, so we could have replaced the OR gate with an XOR gate.

(sec-compose-circuits)=
## Composing Circuits: 32-Bit Comparator

We would like to a circuit that **compares two 32-bit values**; this 32-bit compare circuit can be used in our processor to implement the equality comparison for the RV32I instruction `beq rs1 rs2 Label`.

:::{figure} images/compare-32-block.png
:label: fig-compare-32-block
:width: 30%
:alt: "TODO"

32-bit compare circuit.
:::

:::{hint} The power of **modular design**

The truth table of the 32-bit comparator is too large for us to write by hand  (it has $2^{64}$ rows, for each combination of the bits of `A` and `B`). This means writing a canonical form, much less building a circuit from it, is intractable.

If truth tables are too big to construct, decompose by defining smaller circuits first, then compose the larger circuit with these smaller circuit blocks. This is the power of **modular design**.
:::

We'd therefore like to use the 2-bit compare circuit we built in [a previous example](#sec-compare-2). We represent the circuit as a **combinational logic block**, as below. This block helps abstraction; any time you see the block in @fig-compare-2-block, know it is implemented as the circuit in @fig-compare-2-circuit.

:::{figure} images/compare-2-block.png
:label: fig-compare-2-block
:width: 30%
:alt: "TODO"

Bitwise compare circuit; a block representation of the mystery circuit in @fig-compare-2-circuit.
:::

By way of comparison, for the 32-bit compare circuit(@fig-compare-32-block):

* The value `A` is a 32-bit value, because of the **wire bundle** (the wire is marked with a notch). Similarly, value `B` is 32-bits.
* The value `z` is a 1-bit value.

Functionally, `z` is `1` only if all of `A`'s bits are equal to all of `B`'s bits. In other words, we can perform 32 bitwise comparisons, then AND them together. The underlying circuit for our compare block is therefore as follows:

:::{figure} images/compare-32-circuit.png
:label: fig-compare-32-circuit
:width: 80%
:alt: "TODO"

32-bit compare circuit diagram, assuming we have implemented the bitwise compare circuit. The 32-input AND gate can be implemented recursively with 2- or 4-input AND gates.
:::