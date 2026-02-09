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

**Normalized numbers** are only a _fraction_ (heh) of floating point representations. For single-precision (32-bit), IEEE defines @tab-float-exp-fields based on the exponent field (here, the "biased exponent"):


:::{table} Exponent field values for IEEE 754 single-precision.
:label:  tab-float-exp-fields
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

Because 0 and 255 are reserved exponent fields, the range of **normalized** single-precision floating point is $[-3.4\times 10^{38}, -2^{-126}]$ and $[+2^{-126}, +3.4\times 10^{38}]$. Note $2^{-126} \approx 1.2 \times 10^{-38}$.

:::{note} Show Explanation
:class: dropdown

Largest magnitude number: (`1.1…1`) $\times 2^{(254 - 127)} \approx 3.4 × 10^{38}$. Note the largest biased exponent is $254$, because $255$ is reserved for [infinity](#sec-infty) and [NaNs](#sec-nans).

| s | exponent | significand |
| :--: | :--: | :--: |
| `s` | `1111 1110` | `111 1111 1111 1111 1111 1111` |

(sec-float-range)=
Smallest magnitude number: (`1.0`) $\times 2^{(1-127)} = 2^{-126} \approx 1.2 × 10^{-38}$. Note the smallest biased exponent is $1$, because $0$ (all zeros) is reserved for [zero](#sec-zero) and [denorms](#sec-denorms).

| s | exponent | significand |
| :--: | :--: | :--: |
| `s` | `0000 0001` | `000 0000 0000 0000 0000 0000` |

:::

Because the floating point standard represents fractional components, it must now consider both **overflow** and **_underflow_** (@fig-over-under-flow):

* Overflow: Magnitude of value is too large to represent.
* Underflow: Magnitude of value is too _small_ to represent.

:::{figure} images/over-under-flow.png
:label: fig-over-under-flow
:width: 100%
:alt: "TODO"

Floating point representations can encounter both overflow and underflow.
:::

:::{warning} Why don't _integers_ experience underflow?

In the IEEE 754 normalized floating point representation, underflow refers to the gap between the two disjoint ranges of representable numbers. With integer representations, we can represent all valid numbers (i.e., integers) within a given range [`INT_MIN`, `INT_MAX`] because integer representations have the same step size of "1". There is therefore no "gap" in representation within this representable range.

:::

Recall that with integers, integer overflow causes arithmetic results to "wrap around." This means adding large positive integers can result in negative integers. Unlike integer representations, floating point representations similar to the IEEE 754 standards can more “gracefully” handle overflow, underflow, and errors with special numbers, which we discuss next.

When floating point arithmetic causes overflow, we signal [infinity](#sec-infty) or directly represent arithmetic errors with [NaN](#sec-nans). With underflow, we _gradually_ move towards [zero](#sec-zero) with [denorms](#sec-denorms).

## Special Numbers

See the four non-normalized categories shown in @tab-float-exp-fields.

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

| s | exponent | significand |
| :--: | :--: | :--: |
| either | `1111 1111` | non-zero |

:::

Because these values are triggered upon overflow (note the high exponent), they _contaminate_: $\text{op}(\text{NaN}, x) = \text{NaN}$.

Certain proprietary hardware for floating point go further and use the significand to encode or identify where errors occur. This practice of error codes is not defined in the standard.

(sec-denorms)=
### Denormalized Numbers

#### Gap around zero

In the case of overflow, infinity seems reasonable—after all, it is one step size past the largest representable normalized float (approximately $3.4\times 10^{38}$). Similarly, with underflow, zero is indeed one step size past the _smallest_ representable normalized float ($2^{-126}$).

However, when we consider the mathematical range in question in @fig-underflow, we observe a large **gap** around zero.

:::{figure} images/underflow.png
:label: fig-underflow
:width: 100%
:alt: "TODO"

Because of underflow, there is a "gap" of representable numbers around zero.
:::

Magnitude-wise, this gap is _not huge_—$2^{-126}$ is tiny! However, consider the 23-bit precision of `float`s. For normalized numbers in this area, we can use our precision to take tiny step sizes of $2^{-149}$.


:::{note} Show Explanation
:class: dropdown

Smallest normalized number [from before](#sec-float-range): (`1.0`) $\times 2^{(1-127)} = 2^{-126}$

| s | exponent | significand |
| :--: | :--: | :--: |
| `0` | `0000 0001` | `000 0000 0000 0000 0000 0000` |

Second smallest normalized number: (`1.00...001`) $\times 2^{(1-127)} = (1 + 2^{-23}) \times 2^{-126} = 2^{-126} + 2^{-149}$

| s | exponent | significand |
| :--: | :--: | :--: |
| `0` | `0000 0001` | `000 0000 0000 0000 0000 0000` |

Smallest normalized step size is this difference: $2^{-149}$

:::

In this range, we want to maintain high precision to represent tiny steps between said tiny numbers. However, because of the **implicit 1 in the normalized mantissa**—and zero's lack thereof—there is a relatively huge difference in step size between 0 and the smallest normalized number compared to the smallest and the second-smallest normalized numbers.

#### Gradual underflow

Given the above, the IEEE 754 standard specifies a range of numbers that can be still be used when we encounter underflow, so that not all arithmetic is lost. **Denormalized numbers** in the standard help support **gradual underflow**.[^gradual]

[^gradual]: If a denormalized number results from arithmetic of two normalized numbers, we _still say that underflow occured_. Put another way, denorms help preserve arithmetic precision during underflow.

The IEEE 754 standard defines denormalized numbers of the form in Equation @eq-float-denorm. 

(eq-float-denorm)=
:::{math}
:enumerated: true
(-1)^\text{s} \times (\text{significand}) \times 2^{-126}
:::

The standard specifies how to interpret fields for representing denormalized numbers, also known as **denorms** (@tab-denorm):

:::{table} Sign, exponent, and significand fields for denorms
:label: tab-denorm
:align: center

| Field Name | Represents | Denormalized Numbers |
| :--- | :-- | :--- |
| s | Sign | 1 is negative; 0 is positive |
| exponent | `0000 0000` | The exponent for denormalized numbers is always implicitly $-126$. |
| significand | Fractional Component of the Mantissa | Interpret the significand as a 23-bit fraction (`0.xx...xx`). **Do not add implicit 1** to get the mantissa value. |

:::

:::{warning} Why is it called denormalized?

Recall our intuition from scientific notation: normalized numbers in binary must have a leading implicit 1 in the mantissa. By contrast, denormalized numbers got their moniker because they don't have this 1.

Put another way, denorms are definitely the exception. There are only $2^{23}$ of them, and they represent tiny numbers in the unrepresentable underflow range. Normalized numbers are by far the lion's share of representable values, and when we say "float" we often mean normalized numbers.

:::

We will leave it to you to realize that the above definition means that there are $2^{23}$ denormalized numbers, each $2^{-149}$ apart. $2^{126} \times 2^{-23} = 2^{-126}$ is the step size between the smallest two _normalized_ numbers. This uniform step size for denorms is intentional because it produces the **gradual underflow** we want, as shown in @fig-underflow-gradual:

:::{figure} images/underflow-gradual.png
:label: fig-underflow-gradual
:width: 100%
:alt: "TODO"

Gradual underflow by specifying **denormalized numbers** in the IEEE 754 standard.
:::
