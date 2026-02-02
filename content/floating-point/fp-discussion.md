---
title: "Floating Point: More Discussion"
subtitle: "This content is not tested"
---

(sec-float-discussion)=
## Learning Outcomes

* Understand which floating point formats are used in practice

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/VkLcogCQAho
:width: 100%
:title: "[CS61C FA20] Lecture 06.5 - Floating Point: Floating Point Discussion"
:::

::::

In a previous version of the course, we covered floating point in much more detail. For now, we leave this content as general reference.

## Floating Point Addition

Let's consider arithmetic with floating point numbers.

Floating point addition is more complex than integer addition. We can't just add significands without considering the exponent value. In general:

* Denormalize to match exponents
* Add significands together
* Keep the matched exponent
* Normalize, possibly changing the exponent
* (Note: If signs differ, just perform a subtract instead.)

Because of how floating point numbers are stored, simple operations like addition are not always associative.

Define `x`, `y`, and `z` as $-1.5 \times 10^{38}$, `y`: $1.5 \times 10^{38}$, and $1.0$, respectively.

$$
\begin{align}
\texttt{x + (y + z)} &= -1.5 \times 10^{38} + (1.5 \times 10^{38} + 1.0) \\
&= -1.5 \times 10^{38} + (1.5 \times 10^{38}) \\
&= 0.0
\end{align}
$$

$$
\begin{align}
\texttt{(x + y) + z} &= (-1.5 \times 10^{38} + 1.5 \times 10^{38}) + 1.0 \\
&= 0.0 + 1.0\\
&= 1.0
\end{align}
$$


Remember, floating point effectively **approximates** real results. With bigger exponents, step size between floats gets bigger too. In this example, $1.5 \times 10^{38}$ is so much larger than $1.0$ that $1.5 \times 10^{38} + 1.0$ in floating point representation rounds to $1.5 \times 10^{38}$.

## Floating Point Rounding Modes

When we perform math on real numbers, we have to worry about rounding to fit the result in the significand field. The floating point hardware carries two extra bits of precision, and then rounds to get the proper value.

There are four primary rounding modes:

* **Round towards $+\infty$**. ALWAYS round “up”: 2.001 → 3, -2.001 → -2
* **Round towards $-\infty$**. ALWAYS round “down”: 1.999 →  1, -1.999 →  -2
* **Truncate**. Just drop the last bits (round towards 0)
* **Unbiased**. If midway, round to even.

The unbiased mode is the default, though the others can be specified. Unbiased works _almost_ like normal rounding. Generally, we round to the nearest representable number, e.g., 2.4 rounds to 2, 2.6 to 3, 2.5 to 2, 3.5 to 4, etc. If the value is on the borderline, we round to the nearest even number. In other words, if there is a "tie", half the time we round up; the other half time we round down. This "unbiased" nature ensures fairness on calculation by balancing out inaccuracies.

## Casting and converting

Rounding also occurs when converting betwen numeric types. In C:

* **`int` to `float`**: There are large integers that a `float` cannot handle exactly because it lacks enough bits in the significand. For instance, $2^24 + 1$ will "snap" to the closest even float.
* **`float` to `int`**: Floating points with fractional components simply don't have integer representations. C uses **truncation** to coerce and convert floating point to the nearest integer.  For example, `(int) 1.5` gets chopped off to `1`.

Double-casting therefore does not work as expected. Code A and Code B below may not always print `"true"`:

```c
/* Code A */
int i = …;
if (i == (int)((float) i)) {
   printf("true\n");
}

/* Code B */
float f = …;
if (f == (float)((int) f)) {
   printf("true\n");
}
```

## Other Floating Point Representations

### Precision vs. Accuracy

Recall from before:

* **Precision** is a count of the number of bits used to represent a value.
* **Accuracy** is the difference between the actual value of a number and its computer representation.

High precision permits high accuracy but doesn’t guarantee it.
It is possible to have high precision but low accuracy.

For example, consider `float pi = 3.14;`. `pi` will be represented using all 23 bits of the significand ("highly precise"), but it is only an approximation of $\pi$ ("not accurate").

Below, we discuss other floating point representations that can yield more accurate numbers in certain cases. However, because all of these representations are fixed precision (i.e., fixed bit-width) we cannot represent everything perfectly.