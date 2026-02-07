---
title: "Special Numbers"
---

(sec-special-floats)=
## Learning Outcomes

* Understand how the IEEE 754 standard represents zero, infinity, and NaNs
* Understand what overflow or overflow mean with floating point numbers
* Understand how denormalized numbers implement "gradual" underflow
* Convert denormalized numbers into their decimal counterpart


::::{note} 🎥 Lecture Video (overflow and underflow)
:class: dropdown

:::{iframe} https://www.youtube.com/embed/GzOMIRj1yO0
:width: 100%
:title: "[CS61C FA20] Lecture 06.2 - Floating Point: Floating Point"
:::

Overflow and Underflow, 6:54 - 8:40

::::

::::{note} 🎥 Lecture Video (everything else)
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Gs0ARZzY-gM
:width: 100%
:title: "[CS61C FA20] Lecture 06.3 - Floating Point: Special Numbers"
:::

::::

**Normalized numbers** are only a _fraction_ (heh) of floating point representations. For single-precision (32-bit), IEEE defines the following numbers based on the exponent field (here, the "biased exponent"):


:::{table} Exponent field values for IEEE 754 single-precision.
:label: tab-float-exp-fields
:align: center

| Biased Exponent | Significand field | Description |
| :--- | :--- | :--- |
| 0 (`0000000`) | all zeros | [zero](#sec-zero) |
| 0 (`0000000`) | nonzero | Denormalized numbers, aka [denorms](#sec-denorms) |
| 1 – 254 | anything | [Normalized floating point](#sec-normalized) (mantissa has implicit leading 1) |
| 255 (`1111111`) | all zeros | [infinity](#sec-infty) |
| 255 (`1111111`) | nonzero | [`NaN`s](#sec-nans) |

:::

In this section, we will motivate why these "special numbers" exist by considering the pitfalls of overflow **and** underflow. Then, we'll define each of the special numbers.

## Overflow and Underflow

Coming soon!

## Special Numbers

Unlike integer representations, floating point representations similar to the IEEE 754 standards can more “gracefully” handle overflow, underflow, and errors with special numbers. We discuss the four non-normalized categories shown in @tab-float-exp-fields.

(sec-zero)=
### Zero

Just like in the sign-magnitude zero, IEEE 754 floating point has two zeros (@tab-float-zero). Recall that the standard was built for scientific computing! Having two zeros is mathematically useful. Two examples: limits towards zero and computing $\pm \infty$, the latter of which we discuss [next](#sec-infty)).

:::{table} IEEE 754 single-precision: Zero
:label: tab-float-zero

| value | s | exponent | significand |
| :-- | :--: | :--: | :--: |
| +0 | `0` | `0000 0000` | `000 0000 0000 0000 0000 0000` |
| -0 | `1` | `0000 0000` | `000 0000 0000 0000 0000 0000` |

:::

If we consider its mathematical representation, zero is our first encounter with a floating point representation that is **not normalized**. After all, there $0.0$ in scientific notation has no leading 1!

Floating point hardware often implements zero by reserving the biased exponent value zero `00000000` to signal no normalization, i.e., not to implicitly add 1. If the significand is additionally all zeros, then the hardware knows it is zero. If the significand is _non_ zero, we represent _other non-normalized numbers_, which we discuss below as [denormalized numbers](#sec-denorms).

(sec-infty)=
### Infinity


The IEEE 754 standard defines positive infinity ($+\infty$) and negative infinity ($-\infty$), as shown in @tab-float-zero. To represent infinity, we reserve the biased exponent value `11111111` and set the significand to zero.

:::{table} IEEE 754 single-precision: Infinity
:label: tab-float-infty

| value | s | exponent | significand |
| :-- | :--: | :--: | :--: |
| $+\infty$ | `0` | `1111 1111` | `000 0000 0000 0000 0000 0000` |
| $-\infty$ | `1` | `1111 1111` | `000 0000 0000 0000 0000 0000` |

:::

Because infinity is such an important concept in mathematics, the standard differentiates infinity from other arithmetic errors (which we discuss [next](#sec-nans)). Importantly, dividing by $\pm 0$ yields $\pm \infty$. Computations like $x / 0 > y$ should be representable,[^math] even if not as actual "numbers."

[^math]: We defer to math majors.

(sec-nans)=
### Not a Number (NaN)

What if we try to compute invalid arithmetic, like $\sqrt{-4}$ or $0/0$? For scientific computing, it may be more valuable to "bubble" these errors up to the user–instead of explicitly crashing the program or computing incorrect values due to wrap-around (e.g., in integer overflow).

**NaNs** (**N**ot **a** **N**umber) are values of the following form (@tab-float-nan):

:::{table} IEEE 754 single-precision: NaNs
:label: tab-float-nan

| value | s | exponent | significand |
| :-- | :--: | :--: | :--: |
| NaN | either | `1111 1111` | non-zero |

:::

Because these values are triggered upon overflow (note the high exponent), they _contaminate_: $\text{op}(\text{NaN}, x) = \text{NaN}$.

Certain proprietary hardware for floating point go further and use the significand to encode or identify where errors occur. This practice of error codes is not defined in the standard.

(sec-denorms)=
### Denormalized Numbers

Coming soon!