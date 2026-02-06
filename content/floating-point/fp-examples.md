---
title: "Normalized Numbers: Practice"
---

## Learning Outcomes

* Practice converting between IEEE 754 single-precision floating point formats to decimal numbers.


::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/7MRtSYK1IOI
:width: 100%
:title: "[CS61C FA20] Lecture 06.4 - Floating Point: Examples, Discussion"
:::

::::

In this course, we will expect that you should be able to translate between a number's IEEE 754 Floating Point format and their decimal representation. We give some examples below.

In practice, you can and should use floating point converters. [This web app](https://www.h-schmidt.net/FloatConverter/IEEE754.html) gives a fantastic converter that you can and should use to explore numbers beyond those discussed below!

## Example 1: Floating Point to Decimal

:::{tip} Example 1

What is the decimal number represented by this IEEE 754 single-precision binary floating point format?

| s | exponent | significand |
| :--: | :--: | :--: |
| `1` | `1000 0001` | `111 0000 0000 0000 0000 0000` |

* **A.** $-7 \times 2^{129}$
* **B.** -3.5
* **C.** -3.75
* **D.** 7
* **E.** -7.5
* **F.** Something else

:::

:::{note} Show Answer
:class: dropdown

**E.** -7.5.

We separate these 32 bits into the bit fields of sign (1 bit), exponent (8 bits), and significand (23 bits) first and translate each part separately.

* s: 1, so sign is negative
* exponent: `1000 0001` is $128 + 1 = 129$, so exponent value is $129 - 127 = 2$
* significand: `1110....0` is `111`, so mantissa value is `1.111` (in base 2)

Plug into our formula, noting that components are decimal unless otherwise noted with subscript:

$$
\begin{align}
(-1)^\text{s} \times (1 + \text{significand})_{\text{two}} \times 2^{(\text{exponent}-127)} \\
= (-1)^1 \times (1 + .111)_{\text{two}} \times 2^{(129-127)} \\
= -1 \times (1.111)_{\text{two}} \times 2^2 \\
= -111.1_{\text{two}} \\
= -7.5
\end{align}
$$

* Second to last line: $(1.111)_{\text{two}} \times 2^2$ involves moving the binary point to the left by two spots, e.g., $111.1_{\text{two}}$.
* Last line: Integer component `111` is $7$; fractional component `.1` is $\texttt{1} \times 2^{-1} = 1/2 = 0.5$.

For those interested, this means that writing the C statement `float x = -7.5;` results in `x` having the bit pattern `0xC0F00000`.

:::

## Example 2: Step size with limited precision

Because we have a fixed # of bits (precision), we cannot represent all numbers in a range. With floating point numbers, the exponent field informs our step size.

:::{tip} Example 2
Suppose `y` has the floating point format below. What is the **step size** around `y`?

| s | exponent | significand |
| :--: | :--: | :--: |
| `0` | `1000 0001` | `111 0000 0000 0000 0000 0000` |

_Hint_: Consider the difference between the bit patterns of `y` and the next representable number after (or before) `y`.

:::

:::{note} Show Answer
:class: dropdown

We consider the next representable number **after** `y`. This involves incrementing the significand by `1` in the least significant bit, which corresponds to the smallest possible increment ("step size"):

| s | exponent | significand |
| :--: | :--: | :--: |
| `0` | `1000 0001` | `111 0000 0000 0000 0000 0001` |

This new number is `y + z`, for some small step size `z`:

$$
= y + \left( (.0...01)_{\text{two}} \times 2^{(\text{exponent}-127)} \right)\\
$$

Instead of translating `y` and this new number `y + z`, then taking their difference, we instead note that we are trying to find `z` itself. Let's figure out exactly what power of 2 `z` represents, given the provided exponent.

The least significant bit `.0....01`, for any mantissa of a binary normalized form:

* Implicit leading 1 is not represent by any of 23 bits but corresponds to $2^0$
* bit 22 (most significant bit) of significand is $2^{-1}$
* bit 0 (least significant bit) of significand is $2^{-23}$

In other words, for an exponent value of $127 - 127 = 0$ (with no shifts), `z` would be $2^{-23}$. However, with our exponent field, we shift over this bit to the appropriate power.

The exponent value for `10000001` is $129 - 127 = 2$. This shifts over $2^{-23}$  right by two. Our step size `z` is therefore

$$\left(2^{-23} \times 2^2\right) = 2^{-21}.$$

:::

Bigger exponents mean bigger step sizes, and vice versa. This is actually the desired behavior: when we have super large numbers, fractional differences become infinitesimal. However, with tiny numbers, smaller step sizes are more valuable and our precision (as represented by the bits of the significand) must go towards representing differences.

## Example 3: Floating Point to Decimal

:::{tip} Example 3

What is the decimal number represented by this IEEE 754 single-precision binary floating point format?

| s | exponent | significand |
| :--: | :--: | :--: |
| `0` | `0110 1000` | `101 0101 0100 0011 0100 0010` |

:::

::::{note} Show Answer
:class: dropdown

$$1.666115 \times 2^{-23} \approx 1.986 \times 10^{-7}$$

<!-- TODO: change image to translated example -->

Explanation (for now) is by image (@fig-float-ex3):

:::{figure} images/float-ex3.png
:label: fig-float-ex3
:width: 100%
:alt: "TODO"

Example 3, explained
:::

::::

## Example 4: Decimal to Floating Point


:::{tip} Example 4
What is $-2.340625 \times 10^1$ in IEEE 754 single-precision binary floating point format?
:::

::::{note} Show Answer
:class: dropdown

| s | exponent | significand |
| :--: | :--: | :--: |
| `1` | `1000 0011` | `011 1011 0100 0000 0000 0000` |

<!-- TODO: change image to translated example -->

Explanation (for now) is by image (@fig-float-ex4):

:::{figure} images/float-ex4.png
:label: fig-float-ex4
:width: 100%
:alt: "TODO"

Example 4, explained
:::

::::

## Example 5: Decimal to Floating Point

This exercise shows the limitations of accurate representation using the fixed-_precision_ IEEE 754 standard. After all, fixed precision means we only have 32 bits, and binary representations sometimes fall short.

:::{tip} Example 5
What is $\frac{1}{3}$ in IEEE 754 single-precision binary floating point format?
:::

::::{note} Show Answer
:class: dropdown

| s | exponent | significand |
| :--: | :--: | :--: |
| `0` | `0111 1101` | `010 1010 1010 1010 1010 1010` |

<!-- TODO: change image to translated example -->

Explanation (for now) is by image (@fig-float-ex5):

:::{figure} images/float-ex5.png
:label: fig-float-ex5
:width: 100%
:alt: "TODO"

Example 5, explained
:::

::::