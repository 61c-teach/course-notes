---
title: "Normalized Numbers"
---

## Learning Outcomes

* Understand how the normalized number representation in the IEEE 754 single-precision floating point standard is inspired by scientific notation.
* Identify how the IEEE 754 single-precision floating point format uses three fields:
  * The sign bit represents sign
  * The exponent field represents the exponent value. 
  * The significand field represents the fractional part of the mantissa value.
* For normalized numbers:
  * The exponent field represents the exponent value as a bias-encoded number
  * The mantissa always has an implicit, leading one.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/GzOMIRj1yO0
:width: 100%
:title: "[CS61C FA20] Lecture 06.2 - Floating Point: Floating Point"
:::

Omitted (for the purposes of the next section): Overflow and Underflow, 6:54 - 8:40

::::

## Intuition: Scientific Notation

Instead of identifying the fixed binary point location across every number in our representation, the **floating point** paradigm determines a binary point location for _each_ number.

Consider the decimal number $0.1640625$ which has binary representation[^exercise]

[^exercise]: We leave this conversion as an exercise to the reader.

$$
\dots\texttt{000000.001010100000}\dots.
$$

There are many zeros in this binary representation. For example, there is no integer component, so everything to the left of the binary point is zero. In fact, there are really only one "interesting" range with some "energy", e.g., varying ones and zeros: `10101`. This bit pattern is located two values right of the binary point.

With these two pieces of information—what the **significant bits** are, and what **exponent** the significant bits are associated with—we can suddently represent both very large and very small numbers. This is the intuition behind **scientific notation**.

### Scientific Notation (Base-10)

You may have seen scientific notation in a physics or chemistry course, but we review it here and introduce core terminology that carry over into the binary case. The scientific notation for the number $0.1640625$ is $1.640625 \times 10^{-1}$ (@fig-scientific-notation-base10):

:::{figure} images/scientific-notation-base10.png
:label: fig-scientific-notation-base10
:width: 40%
:alt: "TODO"

Scientific notation assumes a **normalized** form, where the mantissa has exactly one non-zero digit to the left of the decimal point.
:::

* **Radix**: The base. In decimal, base 10.
* **Mantissa**: The "energy" of the number, i.e., the [significant figures](https://en.wikipedia.org/wiki/Significant_figures) (1.640625 in  @fig-scientific-notation-base10)
* **Exponent**: The power the radix is raised to ($-1$ in @fig-scientific-notation-base10).

Scientific notation assumes a **normalized form** of numbers, where the mantissa has exactly one digit to the left of the decimal point.

Every number represented in scientific notation has exactly **one normalized form** for a given number of significant figures. For example, the number $1/1000000$ has normalized form (for two significant figures) $1.0 \times 10^{-9}$ and non-normalized forms $0.1 \times 10^{-8}, 10 \times 10^{-10}$, and so on.

### Binary Normalized Form

The number $0.1640625$ in a binary normalized form is $1.0101_{\text{two}} \times 2^{-3}$ (@fig-scientific-notation-base2):

:::{figure} images/scientific-notation-base2.png
:label: fig-scientific-notation-base2
:width: 40%
:alt: "TODO"

In binary, we also assume a **normalized** form, where the mantissa has exactly one non-zero digit to the left of the binary point.
:::

* **Radix**: The base in binary is base 2.
* **Mantissa**: $1.0101$ in @fig-scientific-notation-base2.
* **Exponent**: $-3$ in @fig-scientific-notation-base2.

We close this discussion with two important points:

* A 32-bit **floating point representation** of binary normalized form should allocate two separate fields within the 32 bits—one to represent the mantissa, and one to represent the exponent.
* With binary normalized form, mantissa **always have a leading one**.

:::{warning} Binary normalized form means mantissa is always of the form `1.xyz...`!
:class: dropdown

Why? Consider the definition of normalized form:

> The mantissa has exactly one non-zero digit to the left of the decimal point.

In binary, there is only one non-zero digit: `1`. This means that a representation like $0.1101_{two} \times 2^{2}$ is not normalized and must be scaled _down_ by a power of 2 to its normalized form, $1.101_{two} \times 2^{1}$.

:::

## IEEE 754 Single-Precision Floating Point

This discussion leads us to the definition of the **IEEE 754 Single-Precision Floating Point**, which is used for the C  `float` data type. This format leverages binary normalized form to represent a wide range of numbers for scientific use using **32 bits**.[^double]

[^double]: The IEEE 754 Double-Precision Floating Point is used for the C `double` data type, which is 64 bits.

This standard was pioneered by UC Berkeley Professor William ("Velvel") Kahan. Prior to Kahan's system, the ecosystem for representing floating points was chaotic, and calculations on one machine would give different answers on another. By leading the effort to centralize floating point arithmetic into the IEEE 754 standard, Professor Kahan [earned the Turing Award in 1988](https://people.eecs.berkeley.edu/~wkahan/ieee754status/754story.html).

The three fields in the IEEE 754 standard are designed to maximize the **accuracy** of representing many numbers using the same limited **precision** of 32 bits (for single-precision, and 64 bits for double-precision). This leads us to two important definitions to help us quantify the efficacy of this number representation:

* **Precision** is a count of the number of bits used to represent a value.
* **Accuracy** is the difference between the actual value of a number and its computer representation.

Without further ado, @fig-float defines the three fields in the IEEE 754 single-precision floating point for 32 bits. 

:::{figure} images/float.png
:label: fig-float
:width: 100%
:alt: "TODO"

Bit fields in IEEE 754 single-precision floating point. The least significant bit (rightmost) is indexed 0; the most significant bit (leftmost) is indexed 31.
:::

(sec-normalized)=
## Normalized Numbers

The three fields in @fig-float can be used to represent normalized numbers of the form in Equation @eq-float-normalized.

(eq-float-normalized)=
:::{math}
:enumerated: true
(-1)^\text{s} \times (1 + \text{significand}) \times 2^{(\text{exponent}-127)}
:::

This design will seem esoteric at first glance. Why is there a $1+$? Where did the mantissa go—what's a significand? Why is the exponent offset by $-127$? As stated before, these three fields are defined to maximize the accuracy of representable numbers in 32 bits. In other words, _none of the bit patterns in these three fields use two's complement_! Instead, the standard uses @tab-float defines precisely how to interpret each field's bit pattern for representing normalized numbers.

:::{table} Sign, exponent, and significand fields for normalized numbers.
:label: tab-float
:align: center

| Field Name | Represents | Normalized Numbers|
| :--- | :-- | :--- |
| s | Sign | 1 is negative; 0 is positive |
| exponent | Bias-Encoded Exponent | Subtract 127 from exponent field to get the exponent value. |
| significand | Fractional Component of the Mantissa | Interpret the significand as a 23-bit fraction (`0.xx...xx`) and add 1 to get the mantissa value. |

:::

:::{note} Why use bias-encoded exponents?
:class: dropdown

Designers wanted floating point numbers to be supported even when specialized floating point hardware didn't exist. For example, it should still be possible to sort floating point numbers using just integer compares, as long as we know which bit fields should be considered.

To support sorting numbers of the same sign with just integer hardware, a bigger exponent field should represent bigger numbers. With two's complement, negative numbers would look bigger (because they lead with `1`, the sign-bit). With bias encoding, on the other hand, all floating point numbers are ordered by the value of the exponent: the `000...000` exponent field represents the smallest exponent value (numbers are $\times 2^{-127}$), and the `111....111` exponent field represents the largest exponent value (numbers are $\times 2^{128}$).

:::

:::{note} Why not directly represent mantissa? Why assume an implicit 1?
:class: dropdown

Remember that in binary normalized form, the mantissa _always_ leads with a 1. IEEE 754 represents normalized numbers by assuming that there is _always_ an implicit 1, then having the significand explicitly representing the bits bits after the binary point. In other words, it is always true that for normalized numbers, 0 < significand < 1.

This assumption for normalized numbers helps IEEE 754 single-precision pack more representable (normalized) numbers into the same 23 bits, because now we represent 24-bit (normalized) mantissas!
:::

## Zero, Infinity, and More

[Normalized numbers](#sec-normalized) are not the only values that can be represented by the IEEE 754 standard. We discuss zero, infinity, and other numbers in [a later section](#sec-special-floats).

## Use a Floating Point Converter

Check out [this web app](https://www.h-schmidt.net/FloatConverter/IEEE754.html) for a simple converter between decimal numbers and their IEEE 754 single-precision floating point format.

While we would love for you to use the converter to understand the comic in @fig-smbc-float, it should be noted that the robot is assuming IEEE 754 **double**-precision format.

:::{figure} images/smbc-float.png
:label: fig-smbc-float
:alt: "TODO"
:align: center
:width: 50%

Welcome to the Secret Robot Internet ([SMBC Comics](https://www.smbc-comics.com/comic/2013-06-05)).
:::

Because floating point is based on powers of two, it cannot represent most decimal fractions exactly. Here, 0.3 is inaccurately represented as `0.29999999999`, and $0.1 + 0.2$ with `double`s is `0.30000000000000004`.  Read more about `double`s, addition, and accuracy in the [optional section](#sec-float-discussion).