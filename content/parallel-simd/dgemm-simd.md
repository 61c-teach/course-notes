---
title: "dgemm: SIMD"
subtitle: Coming soon! Thanks for your patience.
---

<!-- ## Learning Outcomes

* TODO
* TODO -->

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

<!-- 


:::{figure} images/simd-col-major.png
:label: fig-simd-col-major
:width: 100%
:alt: "TODO"

SIMD Scalar `dgemm` Matrix Multiplication - result stored in column major order.
:::

:::{table} SIMD Pseudo Functions and their Descriptions
:label: tab-simd-funcs

| SIMD Pseudo Functions | Description |
| :--- | :--- |
| `vector vec_load(double *A);` | Loads four doubles at memory address A into a vector. | 
| `void vec_store(double *dst, vector src);` | Stores `src` to `dst`. |
| `vector vec_setnum(double num);` | Creates a vector where every element is equal to `num`. |
| `vector vec_add(vector A, vector B);` | Returns the result of adding A and B element-wise. |

::: -->