---
title: "Matrix Multiplication: dgemm"
subtitle: More coming soon! Thanks for your patience.
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/_z_0l6FmnbU
:width: 100%
:title: "[CS61C FA20] Lecture 32.2 - Flynn Taxonomy, SIMD Instructions: Matrix Multiplication"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/V-uBL49SFK0
:width: 100%
:title: "[CS61C FA20] Lecture 32.6 - Flynn Taxonomy, SIMD Instructions: Matrix Multiply Example"
:::

::::

## DGEMM: Double GEneral Matrix Multiplication

**FLOPs** (Floating Point Operations per Second). Count the number of floating point operations (e.g., floating point adds, floating point multiplications, etc.) and scale by measured program execution time.

:::{table} Python MFLOPs vs. Python GFLOPs vs. C GFLOPs
:label: tab-flops

| N | Python (MFLOPs) | Python (GFLOPs) | C (GFLOPs) |
| :--- | :--- | :--- | :--- |
| 32 | 5.4 | 0.0054 | 1.30 |
| 160 | 5.5 | 0.0055 | 1.30 |
| 480 | 5.4 | 0.0054 | 1.32 |
| 960 | 5.3 | 0.0053 | 0.91 |

:::

:::{figure} images/simd-dgemm.png
:label: fig-simd-dgemm
:width: 100%
:alt: "TODO"

SIMD Scalar `dgemm` Matrix Multiplication.
:::

::::{figure}
:label: simd-dgemm-animate
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQmMcdwMl4VdgEpOtv6WFcddT58fZmS6APz_ZPHzDX4LasA6KPpDdgOZGdtShY4J4cdS3htIpi4wSZz/pubembed?start=false&loop=false
:width: 100%
:title: "SIMD `dgemm`"
:::
SIMD `dgemm` matrix multiplication with four-double vector. Use the menu bar to trace through the animation or access the [original Google Slides](https://docs.google.com/presentation/d/1luqaX7cXBd158mvN9ZJDBcNa5O2MK4aWIZcrm1wsXeo/edit?usp=sharing).
::::

:::{figure} images/simd-col-major.png
:label: fig-simd-col-major
:width: 100%
:alt: "TODO"

SIMD Scalar `dgemm` Matrix Multiplication - result stored in column major order.
:::
