---
title: "Summary"
---

## And in Summary$\dots$

* We represent “things” in computers as particular bit patterns:
  * With N bits, you can represent at most 2N things.
* Today, we discussed five different encodings for integers:
  * Unsigned integers
  * Signed integers:
    * Sign-Magnitude
    * Ones’ Complement
    * Two’s Complement
  * Bias Encoding
* Computer architects make design decisions to make HW simple
  * Unsigned and Two’s complement are C standard. Learn them!!
* Integer overflow: The result of an arithmetic operation is outside the representable range of integers.
  * Numbers have infinite digits, but computers have finite precision. This can lead to arithmetic errors. More later!

Meta takeaway: We make design decisions to make the **hardware simple**. We threw out **sign magnitude** and **ones' complement** because the hardware would be hard. But here's a secret: it's the same hardware for mathematics on **unsigned and two's complement numbers**. The only difference is how you calculate overflow.

<!--For you to consider:
How could we represent -12.75?-->

## Textbook readings

* P&H: 2.4

## Useful Links

* [Fall 25 Slides](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g3292f1ea280_3_0#slide=id.g3292f1ea280_3_0)
* [Fall 25 Precheck](https://cs61c.org/fa25/pdfs/discussions/disc01/disc01-pre.pdf)
* [Precheck Solutions](https://cs61c.org/fa25/pdfs/discussions/disc01/disc01-pre-sols.pdf)

## Amazing Illustrations by Ketrina (Yim) Thompson

* [Comparing Binary Integer Representations](https://csillustrated.berkeley.edu/PDFs/handouts/integer-representations-1-handout.pdf)
* [Negation and Zeroes](https://csillustrated.berkeley.edu/PDFs/handouts/integer-representations-2-comparing-handout.pdf)
* [Increments and Monotonicity](https://csillustrated.berkeley.edu/PDFs/handouts/integer-representations-3-comparing-handout.pdf)
* [The Thrilling Conclusion!](https://csillustrated.berkeley.edu/PDFs/handouts/integer-representations-4-comparing-handout.pdf)
