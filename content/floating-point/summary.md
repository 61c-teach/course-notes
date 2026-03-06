---
title: "Summary"
---

## And in Conclusion$\dots$


The IEEE 754 standard defines a binary representation for floating point values using three fields.

:::{figure} #fig-float
Single-Precision (32-bit) Floating Point Representation (reprint of @fig-float from [this section](#sec-fp)). The leftmost bit is the most significant bit; the rightmost bit is the least significant bit.
:::

* The *sign* determines the sign of the number ($0 $ for positive, $1 $ for negative).
* The *exponent* is in biased notation. For single-precision floating point numbers, the bias is $−127$, which comes from $-(2^{(8−1)} −1)$. For double-precision floating point numbers, the bias is $−1023$. An exponent of `00000000` represents a *denormalized number* and an exponent of `11111111` represents either *NaN*, if there is a non-zero mantissa, or *infinity*, if there is a zero mantissa.
* The *significand* is used to store a **fraction** instead of an integer and refers to the bits to the right of the leading "`1`" when normalized. For example, if a mantissa is `1.010011`, its significand is `010011`.


* For [normalized floats](#sec-normalized):

$$\text{Value} = (−1)^{\text{Sign}} × 2^{\text{Exp}+\text{Bias}} × 1.\text{Significand}_2$$

* For [denormalized floats](#sec-denorms), including [zero](#sec-zero):

$$\text{Value} = (−1)^{\text{Sign}} × 2^{\text{Exp}+\text{Bias}+1} × 0.\text{Significand}_2$$

When translating between binary and decimal floating point values, we must remember that there is a bias for the exponent.

:::{figure} #tab-float-exp-fields
The IEEE 754 single-precision exponent field has values from $0$ to $255 (reprint of @tab-float-exp-fields from [this section](#sec-special-floats)).
:::

## Textbook Readings

P&H 3.5, 3.9

## Additional References

* [IEEE 754 Simulator](https://www.h-schmidt.net/FloatConverter/IEEE754.html)