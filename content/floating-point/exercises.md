---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. **True or False**: The idea of floating point is to use the ability to move the radix (decimal) point wherever to represent a large range of real numbers as exact as possible.

:::{note} Solution
:class: dropdown

**True.** Floating point:

* Provides support for a wide range of values. (Both very small and very large)
* Helps programmers deal with errors in real arithmetic because floating point can represent $+\infty$, $-\infty$, $\text{NaN}$ (Not a Number)
* Keeps high precision. Recall that precision is a count of the number of bits in a computer word
used to represent a value. IEEE 754 allocates a majority of bits for the significand, allowing for
the use of a combination of negative powers of two to represent fractions.

<!--See: [Lecture 2 Slide 13](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_154#slide=id.g2af3b38b3e2_1_154)-->
:::

2. **True or False**: Floating Point and Two’s Complement can represent the same total amount of numbers (any reals, integer, etc.) given the same number of bits.

:::{note} Solution
:class: dropdown
**False.** Floating Point can represent infinities as well as NaNs, so the total amount of representable
numbers is lower than Two’s Complement, where every bit combination maps to a unique
integer value.
:::

3. **True or False**: The distance between floating point numbers increases as the absolute value of the numbers increase.

:::{note} Solution
:class: dropdown

**True.** The uneven spacing is due to the exponent representation of floating point numbers. There are a fixed number of bits in the significand. In IEEE $32$-bit storage there are $23 $ bits for the significand, which means the LSB represents $2^{−23}$ times 2 to the exponent. For example, if the exponent is zero (after allowing for the offset) the difference between two neighboring floats will be $2^{−23}$. If the exponent is $8 $, the difference between two neighboring floats will be $2^{−15}$ because the mantissa is multiplied by $2 ^{8}$. Limited precision makes binary floating-point numbersdiscontinuous; there are gaps between them.

:::

4. **True or False**: Floating Point addition is associative.

:::{note} Solution
:class: dropdown
**False.** Because of rounding errors, you can find Big and Small numbers such that: `(Small + Big) + Big != Small + (Big + Big)`

FP approximates results because it only has 23 bits for the significand.
:::

5. Why does normalized scientific notation always start with a 1 in base-2?

:::{note} Solution
:class: dropdown
A non-zero digit is required prior to the radix in scientific notation, and since the only non-zero
digit in base-2 is 1, the normalized value will always start with a 1.
:::