---
title: "Summary"
---

## And in Conclusion$\dots$

Our goal this lecture was to build combinational logic blocks. We can summarize this approach with the following diagram:

:::{figure} #fig-cl-block-representation
:width: 60%
:alt: "TODO"

@fig-cl-block-representation in [previous section](#sec-cl-practice).
:::

We discussed how to convert among these three representations, as represented by the arcs in the
diagram. Here is a summary:

* **Truth table to Boolean Expression.** Write the canonical form (Sum-of-Products) and follow with algebraic simplification if desired.
* **Boolean Expression to Truth table.** Evaluate expression for all input combinations and record output values.
* **Boolean Expression to Gates.** Use AND gates for the AND operators, OR gates for the OR operators, and inverters for the NOT operator. Wire up the gates the match the structure of the expression.
* **Gates to Boolean Expression.** Reverse the above process.
* **Gates to Truth table.** Pass through all input combination and evaluate output.
* **Truth table to Gates.** Map to Boolean expression then to gates.

There are two basic types of circuits: **combinational logic** circuits and state elements.
Combinational logic circuits simply change based on their inputs after whatever propagation
delay is associated with them. For example, if an AND gate (pictured below) has an associated
propagation delay of 2ps, its output will change based on its input as follows:

:::{figure} images/SDS_Precheck_Disc8.png
:width: 60%
:alt: "TODO"
:::

You should notice that the output of this AND gate always changes 2ps after its inputs change.
**State elements**, on the other hand, can remember their inputs even after the inputs change. State
elements change value based on a clock signal. A rising edge-triggered register, for example,
samples its input at the rising edge of the clock (when the clock signal goes from 0 to 1).

## Textbook Readings

P&H A.3-A.6

## Additional References

These notes would not be possible without Professor John Wawrzynek's CS 61C handouts:

* [Boolean Handout](../resources/boolean.pdf)

