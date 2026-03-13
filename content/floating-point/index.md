---
title: "Motivation: Fixed Point"
---

## Learning Outcomes

* Understand the limits of a "fixed point" representation of numbers with fractional components.
* Compute range and step size for integer and fixed-point representations.
* Identify limitations of fixed-point representations.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/-nB32FCrlTA
:width: 100%
:title: "[CS61C FA20] Lecture 06.1 - Floating Point: Basics & Fixed Point"
:::

::::

Learning architecture means learning binary abstraction! Let’s revisit number representation. Now, our goal is to use 32 bits to represent numbers with fractional components—like 4.25, 5.17, and so on. We will learn the **IEEE 754 Single-Precision Floating Point** standard.

To start, I want to share a quote from James Gosling (the creator of Java) from back in 1998.[^gosling-cite]

> “95% of the folks out there are completely clueless about floating-point.”

[^gosling-cite]: From a keynote talk delivered by James Gosling on February 28, 1998. The original link is lost, but Professor Will Kahan's ["How Java’s Floating-Point Hurts Everyone Everywhere"](https://people.eecs.berkeley.edu/~wkahan/JAVAhurt.pdf) gives reasonable context for Gosling's talk, proposal, and alternatives.

You will be in the 5% after this chapter :-)

## Metrics: Range and Step Size

Recall that N-bit strings can represent up to $2^\texttt{N}$ distinct  values. We have covered several N-bit systems for representing integers so far, as shown in @tab-int-systems.

:::{table} A subset of the N-bit integer representations we have discussed in this class.
:label: tab-int-systems
:align: center

| System | \# bits | Minimum | Maximum | Step Size |
| :--- | :-: | :---: | :---: | :---: |
| Unsigned integers | 32 | 0 | $2^{32} - 1$, i.e., <br/> $4,294,967,295$ | 1 |
| Signed integers with two's complement | 32 | $2^{31}$, i.e., <br/> $-2,147,483,648$ | $2^{31} - 1$, i.e., <br/> $2,147,483,647$ | 1 |

:::

The **range** of a number representation system can be quantified by computing the minimum representable and maximum representable numbers. Just like with integer representations we will explicitly compute the range and compare it with some target application. In @tab-int-systems, we see that unsigned integers give a maximum that is about twice that of two's complement—because the latter allocates about half of its system to representing negative numbers.

The **step size** of a number representation system is defined as the spacing between two consecutive numbers. For integer representations that we consider in this class, step size is always 1 between consecutive integers. On the other hand, with fractional number representations we will not be able to represent the infinite range of (real) numbers between two consecutive numbers, hence step size becomes an important metric of **precision**.[^precision-footnote]

[^precision-footnote]: We will define precision properly soon; for now, consider precision a metric of our representations's ability to represent small changes in numbers.

## Fixed Point

Let's motivate floating point by first exploring a strawman[^strawman] approach: **fixed point**. A "fixed point" system fixes the number of digits used for representing integer and fractional parts.

[^strawman]: Wikipedia: [Straw Man](https://en.wikipedia.org/wiki/Straw_man)

Think back to when you first learned the **decimal point**. To the left of the point, you have your 1s ($10^0$), 10s ($10^1$), 100s ($10^2$), and so on. To the right of the point, the numbers represent tenths ($10^{-1}$), hundredths ($10^{-2}$), thousandths ($10^{-3}$), and so on. The **binary point** functions similarly for a _string of bits_. To the left of the binary point are powers of two: 1 ($2^{0}$), 2 ($2^{1}$), 4 ($2^{2}$), and so on. To the right of the binary point are negative powers of two: 1/2 ($2^{-1}$), 1/4 ($2^{-2}$), 1/8 ($2^{-3}$), and so on.

A 6-bit fixed-point binary representation fixes the binary point to be a specific location in a 6-bit bit pattern. Consider the 6-bit fixed-point representation shown in @fig-fixed-point. This fixes the binary point to be 4 bits in from the right, and assumes that we only represent non-negative numbers.

:::{figure} images/fixed-point.png
:label: fig-fixed-point
:width: 80%
:alt: "TODO"

Under this 6-bit fixed-point representation,  number 2.625 
:::

Under this system, the number 2.625 has bit pattern `101010`:

$$
\begin{align}
\texttt{1} × 2^1 + \texttt{0} × 2^0 &+ \texttt{1} \times 2^{-1} +  \texttt{0} \times 2^{-2} + \texttt{1} \times 2^{-3} + \texttt{0} \times 2^{-4} \\
    &= 2 + 	0.5 + 0.125 \\
    &= 2.625_{\text{ten}}
\end{align}
$$

### Fixed Point: Range and Step Size

:::{tip} Quick Check
Using this fixed-point representation, what is the range of representable numbers?
:::

:::{note} Show Answer
:class: dropdown

Range:

* Smallest number `000000`: zero.
* Largest number: `111111`, or 3.9375 = $4 - \texttt{1} \times 2^{-4}$

:::

:::{tip} Quick Check
Using this fixed-point representation, what is the **step size** between any two consecutive numbers?
:::

:::{note} Show answer
:class: dropdown

The smallest fractional step we can take is incrementing the least significant bit, which is $2^{-4} = 1/16$.

:::

### Arithmetic

@fig-fixed-point-add shows that fixed-point addition is simple. By lining up the binary points, fixed-point formats can reuse integer adders.

:::{figure} images/fixed-point-add.png
:label: fig-fixed-point-add
:width: 40%
:alt: "TODO"

$1.5 + 0.5 = 2$ using the 6-bit fixed point representation from @fig-fixed-point.
:::

However, @fig-fixed-point-mul shows that fixed-point multiplication is more complicated. Just like in decimal multiplication, we must shift the binary point based on the number of fractional digits in the factors.

:::{figure} images/fixed-point-mul.png
:label: fig-fixed-point-mul
:width: 40%
:alt: "TODO"

$1.5 \times 0.5 = 0.75$ using the 6-bit fixed point representation from @fig-fixed-point.
:::

### Use Cases

Fixed point representations are very useful in specific domains that prefer very fast computation of values with specific characteristics. Some graphics applications prefer fixed-point for fast calculations when rendering pictures.

## Scientific Numbers

Developers considered what was needed to define a number system that could represent the numbers used in common scientific applications:

* Very large numbers, e.g., the number of seconds in a millenium is $31,556,926,010 = 3.155692610 \times 10^{10}$
* Very small numbers, e.g., Bohr radius is approximately $0.000000000052917710 = 5.2917710 \times 10^{-11}$ meters
* Numbers with both integer and fractional points, e.g., $2.625$

A fixed-point representation that could represent all three of these example values would need to be at least 92 bits[^fp-huge], which is much larger than the 32-bit integer systems discussed in @tab-int-systems.

[^fp-huge]: $31,556,926,010 = 3.155692610 \times 10^{10}$ needs 34 bits for the integer part, and $0.000000000052917710 = 5.2917710 \times 10^{-11}$ needs 58 bits for the fractional part.

The problem with fixed point is that once we determine the placement of our binary point, we are stuck. In our six-bit representation from @fig-fixed-point, we have no way of representing numbers much larger than $3.975$ or numbers between, say, $0$ and $1/16$, much less the many numbers in across scientific applications.

What if we had a way to "float" the binary point around and instead choose its location depending on the target number? Developers of the IEEE 754 floating point standard found a solution in a very common scientific practice for denoting decimal numbers: **scientific notation**. Let's read on!
