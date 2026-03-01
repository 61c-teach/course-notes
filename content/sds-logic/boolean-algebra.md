---
title: "Boolean Algebra"
subtitle: TODO
---

(sec-boolean-algebra)=
## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/W_WJXNfXBJU
:width: 100%
:title: "[CS61C FA20] Lecture 16.3 - Combinational Logic: Boolean Algebra"
:::

::::

In the [previous section](#sec-logic-gates) we explained how to generate a truth-table from a given circuit (we simply need to evaluate it for input combinations). The big question is: How do we go _the other way_? How do we derive a circuit of logic gates from a truth-table?

We also [discussed](#sec-subset-gates) how any combinational logic circuit can be implemented with a subset of gates. A particularly nice subset of logic gates is the set of AND, OR, and NOT. This set has a directly relationship to Boolean algebra, a mathematical system that we can use to manipulate and structure our combinational logic circuits.

## George Boole and Claude Shannon

In the 19th Century, the mathematician George Boole (1815-1864), developed a mathematical system (algebra) involving logic, later becoming known as **Boolean Algebra**. His variables took on the values of TRUE and FALSE. Later, Claude Shannon (the father of information theory, 1916–2001) wrote his Master’s thesis on how to map Boolean algebra to digital circuits. There is a one-to-one correspondence between circuits composed of AND, OR, NOT gates and Boolean Algebra equations. Because of boolean algebra, we can now apply math to give theory to hardware design, minimization, and more.

The three basic operations (i.e., primitive functions) of Boolean algebra are AND, OR, and NOT. They operate identically to how we defined them in a [previous section](#sec-logic-gates).

:::{table} Boolean Algebra basic operations: AND, OR, and NOT.
:label: tab-boolean-operations

| Operation | Boolean Algebra Notation | Notes |
| :-- | :--: | :-- |
| AND(a, b) | $a \cdot b$, $ab$ | Basic operation. The $\cdot$ is often dropped, as in the second notation. |
| OR(a, b) | $a + b$ | Basic operation. |
| NOT(a) | $\overline{a}$ | Basic operation. |
:::

:::{warning} Boolean Algebra has neither multiplication nor addition!

In Boolean Algebra operations $\cdot$ and $+$ _do not represent multiplication nor addition of integer values_! Rather, these operator symbols represent AND and NOT, respectively, on boolean variables $a$ and $b$.
:::

We can also define operations for NAND, NOR, and XOR.

:::{table} Boolean Algebra NAND, NOR, XOR.
:label: tab-boolean-operations-advanced

| Operation | Boolean Algebra Notation | Notes |
| :-- | :--: | :-- |
| NAND(a, b) | $\overline{a \cdot b}$ </br>$\overline{ab}$ | "Not AND" |
| NOR(a, b) | $\overline{a + b}$ | "Not OR" |
| XOR(a, b) | $a \oplus b$ | Not a basic operation, but common <br/>enough to have its own symbol. |
:::



GOT TO HERE

The power of Boolean algebra comes from the fact that there is a one-to-one correspondence between
circuits made up of AND, OR, and NOT gates and equations in Boolean algebra.


from the 
is obvious from the function of the two input version, except in the case of the the exclusive-or gate,


:::{figure} images/circuit-example.png
:label: fig-circuit-ex
:width: 100%
:alt: "TODO"

Example mystery circuit to create truth table.
:::

:::{figure} images/modular-gates.png
:label: fig-modular-gates
:width: 100%
:alt: "TODO"

Modular design of truth tables and AND gate.
:::