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

## Textbook Readings

P&H A.3-A.6

## Additional References

These notes would not be possible without Professor John Wawrzynek's CS 61C handouts:

* [Boolean Handout](../resources/boolean.pdf)

