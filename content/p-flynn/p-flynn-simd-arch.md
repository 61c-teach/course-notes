---
title: "SIMD Architectures"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/pSkO2Fi9Q0o
:width: 100%
:title: "[CS61C FA20] Lecture 32.4 - Flynn Taxonomy, SIMD Instructions: SIMD Architectures"
:::

::::

## Visuals

:::{figure} images/simd-arch.png
:label: fig-SIMD-arch
:width: 90%
:alt: "TODO"

SIMD: Single Instruction, Multiple Data Architecture.
:::

:::{figure} images/simd-ext.png
:label: fig-simd-ext
:width: 65%
:alt: "TODO"

First SIMD Extensions: MIT Lincoln Labs TX-2, 1957.
:::

:::{figure} images/simd-ops.png
:label: fig-simd-ops
:width: 100%
:alt: "TODO"

SIMD Operations: Fetch one instruction, perform multiple instructions.
:::

:::{figure} images/simd-vector-regs.png
:label: fig-simd-vec-regs
:width: 90%
:alt: "TODO"

SIMD Specialized *vector* registers.
:::

:::{table} SIMD Pseudo Functions and their Descriptions
:label: tab-simd-funcs

| SIMD Pseudo Functions | Description |
| :--- | :--- |
| `vector vec_load(double *A);` | Loads four doubles at memory address A into a vector. | 
| `void vec_store(double *dst, vector src);` | Stores `src` to `dst`. |
| `vector vec_setnum(double num);` | Creates a vector where every element is equal to `num`. |
| `vector vec_add(vector A, vector B);` | Returns the result of adding A and B element-wise. |

:::