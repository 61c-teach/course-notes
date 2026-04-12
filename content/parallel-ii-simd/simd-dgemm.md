---
title: "Matrix Multiplication: dgemm"
subtitle: TODO
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

## SIMD Cache Blocking

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
