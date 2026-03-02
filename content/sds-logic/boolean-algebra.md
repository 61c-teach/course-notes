---
title: "Boolean Algebra"
---

(sec-boolean-algebra)=
## Learning Outcomes

* Identify the AND, OR, and NOT operations in Boolean Algebra.
* Simplify Boolean Algebra expressions using laws of Boolean Algebra.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/W_WJXNfXBJU
:width: 100%
:title: "[CS61C FA20] Lecture 16.3 - Combinational Logic: Boolean Algebra"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/8ORLlBY2E7Q
:width: 100%
:title: "[CS61C FA20] Lecture 16.4 - Combinational Logic: Laws of Boolean Algebra"
:::

::::

In the [previous section](#sec-logic-gates) we explained how to generate a truth-table from a given circuit (we simply need to evaluate it for input combinations). The big question is: How do we go _the other way_? How do we derive a circuit of logic gates from a truth-table?

:::{hint} There is a one-to-one correspondence between circuits composed of AND, OR, NOT gates and Boolean Algebra equations.

The basic operations (i.e., primitive functions) of **Boolean algebra** are also AND, OR, and NOT–defined with the exact truth tables we saw in the [logic gate section](#sec-common-logic-gates). Boolean algebra is a mathematical system (i.e., algebra) with theorems and equations. Because of Boolean algebra we can apply math to give theory to hardware design, minimization, and more.
:::

:::{note} History: George Boole and Claude Shannon
:class: dropdown

In the 19th Century, the mathematician George Boole (1815-1864), developed a mathematical system (algebra) involving logic, later becoming known as **Boolean algebra**. His variables took on the values of TRUE and FALSE. Later, Claude Shannon (the father of information theory, 1916–2001) wrote his Master’s thesis on how to map Boolean algebra to digital circuits.
:::

## Boolean Algebra Operations

:::{table} Boolean algebra basic operations: AND, OR, and NOT. See the [logic gate section](#sec-common-logic-gates) for truth tables.
:label: tab-boolean-operations

| Operation | Boolean Algebra Notation | Notes |
| :-- | :--: | :-- |
| AND(a, b) | $a \cdot b$, $ab$ | Basic operation. The $\cdot$ is often dropped, as in the second notation. |
| OR(a, b) | $a + b$ | Basic operation. |
| NOT(a) | $\overline{a}$ | Basic operation. |
:::

:::{warning} Boolean algebra has neither multiplication nor addition!

In Boolean algebra, operations $\cdot$ and $+$ **do not represent multiplication nor addition of integer values**! Rather, these operator symbols represent AND and NOT, respectively, on **Boolean** variables $a$ and $b$.
:::

We can also define operations for NAND, NOR, and XOR (though these are not considered basic operations).

:::{table} Boolean algebra NAND, NOR, XOR.
:label: tab-boolean-operations-advanced

| Operation | Boolean Algebra Notation | Notes |
| :-- | :--: | :-- |
| NAND(a, b) | $\overline{a \cdot b}$ </br>$\overline{ab}$ | "Not AND" |
| NOR(a, b) | $\overline{a + b}$ | "Not OR" |
| XOR(a, b) | $a \oplus b$ | Not a basic operation, but common <br/>enough to have its own symbol.[^xor-bool] |

[^xor-bool]: $a \oplus b = (a + b)\overline{ab} = a\overline{b}+\overline{a}b$
:::



## Why use Boolean Algebra

The value of Boolean algebra for circuit design comes from the fact that Boolean expressions can be manipulated mathematically. In general, it is _much easier_ to manipulate equations than it is to directly manipulate circuits.


1. **Simplify Circuits.** A Boolean algebra expression can be simplified. This simplification will lead directly to a circuit simplification. Using fewer gates means using fewer transistors—cheaper and more energy-efficient!

2. **Verify circuits.** Another use for Boolean algebra is in circuit verification. Given a circuit and a Boolean equation, we can ask the question, "Do the two different representations represent the same function?" The first step
would be to derive a new Boolean expression based on the circuit. Then through algebraic manipulation we could manipulate the expressions until they match, thereby “proving” the eqivalence of the two.

(sec-or-simplify-setup)=
### Example

We can use Boolean algebra to verify the below simplification. The [first circuit](#fig-equivalent-circuit) ($y = ab + a + c$), which uses three gates, is **equivalent** to the [second circuit](#fig-equivalent-circuit-or) ($y = a + c$), which uses just one OR gate. We describe this approach at the [end of this section](#sec-or-simplify-proof).

:::::{grid} 2

::::{grid-item}
:::{figure} images/equivalent-circuit.png
:label: fig-equivalent-circuit
:width: 100%
:alt: "TODO"

First circuit: $y = ab + a + c$.
:::
::::

::::{grid-item}
:::{figure} images/equivalent-circuit-or.png
:label: fig-equivalent-circuit-or
:width: 100%
:alt: "TODO"

Second equivalent circuit: $y = a + c$.
:::
::::
:::::

 We will revisit this example.

## Laws of Boolean Algebra

Along with Boolean algebra comes a collection of laws that apply to Boolean expressions. These
are simple algebraic equalities that are known to be true. We can
manipulate other Boolean expressions through successive application of these laws.

@tab-boolean-laws lists the
most important of the common Boolean laws.

:::{table} Laws of Boolean Algebra.
:label: tab-boolean-laws

| AND Form | OR Form | |
| :---: | :---: | :--- |
| $x \cdot y = y \cdot x$ | $x + y = y + x$ | Commutativity |
| $(xy)z = x(yz)$ | $(x + y) + z = x + (y + z)$ | Associativity |
| $x \cdot 1 = x$ | $x + 0 = x$ | Identity |
| $x \cdot 0 = 0$ | $x + 1 = 1$ | Laws of 0's and 1's |
| $xy + x = x$ | $(x + y)x = x$ | Uniting Theorem |
| $x(y + z) = xy + xz$ | $x + yz = (x + y)(x + z)$ | Distributivity |
| $x \cdot x = x$ | $x + x = x$ | Idempotence |
| $x \cdot \overline{x} = 0$ | $x + \overline{x} = 1$ | Inverse (Complement) |
| $\overline{xy} = \overline{x} + \overline{y}$ | $\overline{x + y} = \overline{x} \cdot \overline{y}$ | DeMorgan's Laws |

:::

Some laws are similar to ordinary (non-Boolean) algebra, but many are specific to Boolean algebra and rely on variables taking on precisely **two** truth values: 1 (true) and 0(false).

Because of the symmetry of Boolean algebra all these laws come in two versions (the two columns
above), one being called the dual version of the other. Practically speaking, this means you only need
to remember one version of the law, and the other one can be naturally derived.

:::{hint} Use the reference card

Know how to use these formulas for simplifying and verifying circuits, but no need to memorize. See the CS 61C reference card!

:::

### Proofs

Analyze the proofs below, which fall into two categories:

* Exhaustive proof, i.e., making truth tables (where again, truth tables enumerate the input/output relationship for all possible input values) then identifying the columns that represent the left-hand and/or right-hand sides of the equation.
* Algebraic manipulation by using other laws.

::::::{note} Law of 0's, Law of 1's
:class: dropdown
:::::{grid} 2
::::{grid-item}
:::{card}
:header: $x \cdot 0 = 0$
| $x$ | $x \cdot 0$ |
| :---: | :---: |
| 0 | 0 |
| 1 | 0 |
:::
::::
::::{grid-item}
:::{card}
:header: $x + 1 = 1$
| $x$ | $x + 1$ |
| :---: | :---: |
| 0 | 1 |
| 1 | 1 |
:::
::::
::::::
<!-- note -->

::::::{note} Distributivity
:class: dropdown

:::{card}
:header: $x(y + z) = xy + xz$
Coming soon...
:::

:::{card}
:header: $x + yz = (x + y)(x + z)$
```{math}
\begin{aligned}
    (x + y)(x + z) &= x \cdot x + xz + xy + yz && \text{Distributivity} \\
    &= x + xy + xz + yz && \text{Idempotence (AND)} \\
    &= x + x(y + z) + yz && \text{Distributivity (Prop. 1)} \\
    &= x + yz && \text{Uniting Theorem (AND)}
\end{aligned}
```
:::
::::::
<!-- note -->

::::::{note} Idempotence
:class: dropdown
:::::{grid} 2
::::{grid-item}
:::{card}
:header: $x \cdot x = x$
| $x$ | $x \cdot x$ |
| :---: | :---: |
| 0 | 0 |
| 1 | 1 |
:::
::::
::::{grid-item}
:::{card}
:header: $x + x = x$
| $x$ | $x + x$ |
| :---: | :---: |
| 0 | 0 |
| 1 | 1 |
:::
::::
::::::
<!-- note -->

::::::{note} DeMorgan's Laws
:class: dropdown

At a high-level: “distribute” the inversion (e.g., dual) over x, y and operator.

:::::{grid} 2
::::{grid-item}
:::{card}
:header: $\overline{xy} = \overline{x} + \overline{y}$
| $x$ | $y$ | $xy$ | $\overline{xy}$ | $\overline{x}$ | $\overline{y}$ | $\overline{x} + \overline{y}$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 1 | 1 | 1 | 1 |
| 0 | 1 | 0 | 1 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 | 0 | 1 | 1 |
| 1 | 1 | 1 | 0 | 0 | 0 | 0 |
:::
::::
::::{grid-item}
:::{card}
:header: $\overline{x + y} = \overline{x} \cdot \overline{y}$
| $x$ | $y$ | $x + y$ | $\overline{x + y}$ | $\overline{x}$ | $\overline{y}$ | $\overline{x} \cdot \overline{y}$ |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | 1 | 1 | 1 | 1 |
| 0 | 1 | 1 | 0 | 1 | 0 | 0 |
| 1 | 0 | 1 | 0 | 0 | 1 | 0 |
| 1 | 1 | 1 | 0 | 0 | 0 | 0 |
:::
::::
::::::
<!-- note -->

(sec-or-simplify-proof)=
### Example, revisited

Let us return to the example described [above](#sec-or-simplify-setup) and prove that the [first circuit](#fig-equivalent-circuit) is equivalent to the [second circuit](#fig-equivalent-circuit-or).

```{math}
\begin{aligned}
    y &= ab + a + c  && \text{Equation derived from original circuit} \\
      &= a(b + 1) + c && \text{Distributivity} \\
      &= a(1) + c     && \text{Law of 1's} \\
      &= a + c        && \text{Identity (AND)}
\end{aligned}
```
