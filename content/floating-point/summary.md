---
title: "Summary"
---

## And in Conclusion$\dots$


The IEEE 754 standard defines a binary representation for floating point values using three fields.

* The *sign* determines the sign of the number ($0 $ for positive, $1 $ for negative).
* The *exponent* is in biased notation. For instance, the bias is $−127$, which comes from $-(2^{(8−1)} −1)$ for single-precision floating point numbers. For double-precision floating point numbers, the bias is $−1023$. An exponent of `00000000` represents a *denormalized number* and an exponent of `11111111` represents either *NaN*, if there is a non-zero mantissa, or *infinity*, if there is a zero mantissa.
* The *significand* is used to store a **fraction** instead of an integer and refers to the bits to the right of the leading "`1`" when normalized. For example, if a mantissa is `1.010011`, its significand is `010011`.

@fig-float shows the bit breakdown for the single-precision (32-bit) representation. The leftmost bit is the MSB, and the rightmost bit is the LSB.


* For [normalized floats](#sec-normalized):

$$\text{Value} = (−1)^{\text{Sign}} × 2^{\text{Exp}+\text{Bias}} × 1.\text{Significand}_2$$

* For [denormalized floats](#sec-denorms), including [zero](#sec-zero):

$$\text{Value} = (−1)^{\text{Sign}} × 2^{\text{Exp}+\text{Bias}+1} × 0.\text{Significand}_2$$

@tab-float-exp-fields shows that the IEEE 754 exponent field has values from $0$ to $255$. When translating between binary and decimal floating point values, we must remember that there is a bias for the exponent.

## Textbook Readings

P&H 3.5, 3.9

## Additional References

* [IEEE 754 Simulator](https://www.h-schmidt.net/FloatConverter/IEEE754.html)

## Exercises
Check your knowledge!

### Conceptual Review

:::{exercise}
:label: fp-01
**True or False**: The idea of floating point is to use the ability to move the radix (decimal) point wherever to represent a large range of real numbers as exact as possible.
:::

:::{solution} fp-01
:label: fp-01-sol
:class: dropdown

**True.** Floating point:

* Provides support for a wide range of values. (Both very small and very large)
* Helps programmers deal with errors in real arithmetic because floating point can represent $+\infty$, $-\infty$, $\text{NaN}$ (Not a Number)
* Keeps high precision. Recall that precision is a count of the number of bits in a computer word
used to represent a value. IEEE 754 allocates a majority of bits for the significand, allowing for
the use of a combination of negative powers of two to represent fractions.

<!--See: [Lecture 2 Slide 13](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_154#slide=id.g2af3b38b3e2_1_154)-->
:::

:::{exercise}
:label: fp-02
**True or False**: Floating Point and Two’s Complement can represent the same total amount of numbers (any reals, integer, etc.) given the same number of bits.
:::

:::{solution} fp-02
:label: fp-02-sol
:class: dropdown

**False.** Floating Point can represent infinities as well as NaNs, so the total amount of representable
numbers is lower than Two’s Complement, where every bit combination maps to a unique
integer value.
:::


:::{exercise}
:label: fp-03
**True or False**: The distance between floating point numbers increases as the absolute value of the numbers increase.
:::

:::{solution} fp-03
:label: fp-03-sol
:class: dropdown

**True.** The uneven spacing is due to the exponent representation of floating point numbers. There are a fixed number of bits in the significand. In IEEE $32$-bit storage there are $23 $ bits for the significand, which means the LSB represents $2^{−23}$ times 2 to the exponent. For example, if the exponent is zero (after allowing for the offset) the difference between two neighboring floats will be $2^{−23}$. If the exponent is $8 $, the difference between two neighboring floats will be $2^{−15}$ because the mantissa is multiplied by $2 ^{8}$. Limited precision makes binary floating-point numbersdiscontinuous; there are gaps between them.

:::

:::{exercise}
:label: fp-04
**True or False**: Floating Point addition is associative.
:::

:::{solution} fp-04
:label: fp-04-sol
:class: dropdown
**False.** Because of rounding errors, you can find Big and Small numbers such that: `(Small + Big) + Big != Small + (Big + Big)`

FP approximates results because it only has 23 bits for the significand.
:::

:::{exercise}
:label: fp-05
Why does normalized scientific notation always start with a 1 in base-2?
:::

:::{solution} fp-05
:label: fp-05-sol
:class: dropdown
A non-zero digit is required prior to the radix in scientific notation, and since the only non-zero
digit in base-2 is 1, the normalized value will always start with a 1.
:::