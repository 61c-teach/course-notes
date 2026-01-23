---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. What is a bit? How many bits are in a byte? Nibble?

:::{note} Solution
:class: dropdown

A bit is the smallest unit of digital information and it can be either 0 of 1. There are 4 bits in a nibble and 8 bits in a byte.

<!--See: [Lecture 2 Slide 13](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_154#slide=id.g2af3b38b3e2_1_154)-->
:::

2. What is overflow?

:::{note} Solution
:class: dropdown

When the result of an arithmetic operation is outside the range of what is representable by given number of bits.

<!--See: [Lecture 2 Slide 26](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_186#slide=id.g2af3b38b3e2_1_186)-->
:::

3. What is the range of numbers representable by $n$-bit unsigned, sign-magnitude, one's complement, two's complement, and biased notation?

:::{note} Solution
:class: dropdown

* **Unsigned**: $[0, 2^n-1]$
* **Sign-Magnitude**: $[-(2^{n-1} - 1), 2^{n-1} - 1]$
* **One's complement**: $[-(2^{n-1} - 1), 2^{n-1} - 1]$
* **Two's complement**: $[-2^{n-1}, 2^{n-1} - 1]$
* **Bias**: $[0+$bias$, 2^n-1+$bias$]$

<!--See:  [Lecture 2](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g32e4dda2ba9_0_123#slide=id.g32e4dda2ba9_0_123)-->
:::

4. How many ways to represent zero do these representations have, $n$-bit unsigned, sign-magnitude, one's complement, two's complement, and biased notation?

:::{note} Solution
:class: dropdown
* **Unsigned**: 1
* **Sign-Magnitude**: 2
* **One's complement**: 2
* **Two's complement**: 1
* **Bias**: 1 or 0 (depending on bias)

<!--See: [Lecture 2](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g32e4dda2ba9_0_123#slide=id.g32e4dda2ba9_0_123)-->
:::

## Short Exercises

1. **True/False**: Depending on the context, the same sequence of bits may represent different things.

:::{note} Solution
:class: dropdown
**True.** The same bits can be interpreted in many different ways with the exact same bits! The bits
can represent anything from an unsigned number to a signed number or even, as we will cover
later, a program. It is all dependent on its agreed upon interpretation.
:::

2. **True/False**: If you interpret a $N$-bit Two's complement number as an unsigned number, negative numbers would be smaller than 
positive numbers.

:::{note} Solution
:class: dropdown
**False.** In Two’s Complement, the MSB is always 1 for a negative number. This means EVERY
negative number in Two’s Complement, when converted to unsigned, will be larger than the
positive numbers.
:::

3. **True/False**: We can represent fractions and decimals in our given number representation formats (unsigned, biased, and Two’s Complement).

:::{note} Solution
:class: dropdown
**False.** Our current representation formats has a major limitation; we can only represent and do
arithmetic with integers. To successfully represent fractional values as well as numbers with
extremely high magnitude beyond our current boundaries, we need another representation
format.
:::

4. How many numbers can be represented by an unsigned, base-4, $n$-digit number.

    **A.** 1

    **B.** $2^n - 1$

    **C.** $4^n$

    **D.** $4^{n-1}$

    **E.** $4^n - 1$

:::{note} Solution
:class: dropdown
**C.**
:::

5. How many bits are needed to represent decimal number 116 in binary?

:::{note} Solution
:class: dropdown
**7 bits**. $(116)_{10} =$ `0b111 0100` or $log{_2}{116} \approx 6.85$ which we round to 7 bits.
:::