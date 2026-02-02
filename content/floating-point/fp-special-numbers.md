---
title: "Special Numbers"
---

(sec-special-floats)=
## Learning Outcomes

* Understand how the IEEE 754 standard represents zero, infinity, and NaNs
* Convert denormalized numbers into their decimal counterpart
* Understand when floating point numbers trigger overflow
* Understand when floating point numbers trigger underflow


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

Normalized numbers are only a _fraction_ (heh) of floating point representations. For single-precision (32-bit), IEEE defines the following numbers based on the exponent field (here, the "biased exponent"):

| Biased Exponent | Significand field | Object |
| :--- | :--- | :--- |
| 0 | all zeros | $\pm 0$ |
| 0 | nonzero | Denormalized numbers |
| 1 – 254 | anything | Normalized floating point |
| 255 | all zeros | $\pm \infty$ |
| 255 | nonzero | `NaN`s |

In this section, we will motivate why these "special numbers" exist by considering the pitfalls of overflow **and** underflow. Then, we'll define each of the special numbers.

