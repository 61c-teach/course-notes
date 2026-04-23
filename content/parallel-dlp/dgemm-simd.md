---
title: "DGEMM: SIMD with Intel Intrinsics"
---

(sec-dgemm-simd)=
## Learning Outcomes

* Compare SIMD-extended matrix multiplication with sequential programs.
* Compare performance using different `gcc` optimization flags: `-O0`, `-O2`, `-O3`.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/_z_0l6FmnbU
:width: 100%
:title: "[CS61C FA20] Lecture 32.2 - Flynn Taxonomy, SIMD Instructions: Matrix Multiplication"
:::

::::

Before continuing, we recommend reviewing:

* [DGEMM benchmark](#sec-dgemm-benchmark)
* [Performance optimizations](#sec-dgemm-sisd) on a sequential program

:::{embed} #fig-dgemm
:::

(sec-dgemm-benchmark-simd)=
:::{hint} DGEMM Benchmark with SIMD

Updated benchmark:

* GCC: no optimization (flag `-O0`) unless otherwise stated
* Matrix dimensions: 512 by 512 (the precise matrices may vary by program)
* Timing library: `<time.h>` (except for OpenMP)
* Machine: Course hive machines
* Intel SIMD extension: AVX (256-bit-wide registers packing **four** double-precision floating point values)

See lecture for example benchmark code. The benchmark will be hosted on the course notes in a future semester.
:::

## DGEMM 7: Naive SIMD DGEMM

With the ability to perform SIMD multiplication, it is tempting to use our new 256-bit-wide registers to load in blocks of row A and blocks of column B for the element-wise multiplication necessary for dot products, as shown in @fig-dgemm-simd-naive.

:::{figure} images/dgemm-simd-naive.png
:label: fig-dgemm-simd-naive
:width: 90%
:alt: "Diagram of naive SIMD DGEMM using three matrix panels labeled A, B, and C. Row 0 of A and several columns of B are outlined or shaded to show which operands load into wide SIMD registers for one dot-product step; element C[0,0] is emphasized as the accumulator slot. The figure illustrates packing several independent multiplies from the same dot product into one SIMD instruction stream before summing into C."

"Naive" SIMD DGEMM that leverages SIMD architecture registers to parallelize multiplications _within_ a single dot product. The outlined boxes indicate which values are loaded into the 256-bit-wide registers.[^block-assumption]

[^block-assumption]: In @fig-dgemm-simd-naive, we assume a cache that has 256-bit blocks. This carries over the cache assumption from our [cache blocking discussion](#sec-cache-blocking).
:::

This naive SIMD implementation does better than our naive DGEMM but worse than specifying narrow registers with the `register` keyword in C:

```bash
C               0.768672 seconds
registers:      0.277462 seconds
simd,naive:     0.416584 seconds
```

The non-compulsory cache miss persists in our naive SIMD implementation—we are still loading in multiple rows of B instead of columns of B.

## DGEMM 8: Transpose SIMD DGEMM

We next apply cache blocking by first transposing B, then leveraging our 256-bit-wide (four-double) registers for element-wise multiplication:

:::{figure} images/dgemm-simd-transpose.png
:label: fig-dgemm-simd-transpose
:width: 90%
:alt: "Same three-matrix layout as the naive SIMD case but B is shown transposed so consecutive memory accesses align with SIMD loads. Row 0 of A and contiguous strips along the transposed B layout are highlighted to indicate 256-bit-wide register fills; C[0,0] remains the highlighted output cell. The diagram stresses that transposing B turns column walks into row-major-friendly blocks for the SIMD kernel."

"Transposed" SIMD DGEMM that uses a transposed B to load in columns of B to streamline memory accesses. The outlined boxes indicate which values are loaded into the 256-bit-wide registers.
:::

```bash
C               0.768672 seconds
registers:      0.277462 seconds
simd,naive:     0.416584 seconds
simd,transpose: 0.275622 seconds
```

This version is certainly speedier, but it does not prove huge benefits beyond our `register` keyword approach.

## DGEMM 9: Tiled SIMD DGEMM

Recall that cache blocking is any re-design of our algorithm to adjust memory accesses. [Earlier](#sec-cache-blocking-tiling), we discussed a submatrix tiling approach to matrix multiplication—where we compute multiple elements of C with the current set of rows of A and set of columns of B.

In @fig-dgemm-simd-block, we assume that the product of a scalar with a vector can be computed as a vector operation, provided that the scalar is copied to each element in a vector of the same length.

:::{figure} images/dgemm-simd-block.png
:label: fig-dgemm-simd-block
:width: 90%
:alt: "Tiled SIMD matrix-multiply illustration split into left and right regions. Left: a row of C with four adjacent elements accumulated in parallel, starting at C[i,j]. Right: cloud-shaped grouping where four elements from row k of B are scaled by the scalar A[i,k] and summed across k iterations; arrows or indices suggest the inner k loop. Together the panels show how a tile reuses A and B data while updating a short vector of C entries per step."

Compute four elements of C (starting with $C_{ij}$) by iteratively adding the result of scaling four elements of the $k$-th row of B (starting with $B_{kj}$) with $A_{ik}$.
:::

We can extend this idea to a tiled SIMD approach shown in @fig-simd-dgemm-animate.

::::{figure}
:label: fig-simd-dgemm-animate
:alt: "Embedded slides animating tiled SIMD matrix multiply: which matrix elements load into wide SIMD registers and how partial sums advance across an eight-by-eight example."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQmMcdwMl4VdgEpOtv6WFcddT58fZmS6APz_ZPHzDX4LasA6KPpDdgOZGdtShY4J4cdS3htIpi4wSZz/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through tiled SIMD `dgemm` matrix multiplication, as discussed in this section."
:::
SIMD `dgemm` tiled matrix multiplication. The outlined boxes indicate which values are loaded into the 256-bit-wide registers. Use the menu bar to trace through the animation or access the [original Google Slides](https://docs.google.com/presentation/d/1luqaX7cXBd158mvN9ZJDBcNa5O2MK4aWIZcrm1wsXeo/edit?usp=sharing).
::::

:::{note} Show Explanation
:class: dropdown

@fig-simd-dgemm-animate shows an 8-by-8 matrix multiplication.

1. `i = 0`. Compute elements $C_{0j}$ for $j = 0, 1, 2, 3$; let this be $\vec{c}$. Let $\vec{b}$ be the corresponding part of the $k$-th row of $B$.

    1a through 1h: Loop through $k = 0, ..., 7$. Compute the result of $A_{ik} \cdot $\vec{b}$ and add to the four elements of $\vec{c}$.
1. `i = 0`, still. Next, compute elements $C_{0j}$ for $j = 4, 5, 6, 7$; let this be $\vec{c}$. Let $\vec{b}$ be the corresponding part of the $k$-th row of $B$. Again, loop through the index $k$ to add the resulting scalar-by-vector to the elements of $\vec{c}$.
1. `i = 1`. Compute elements $C_{1j}$ for $j = 0, 1, 2, 3$.
1. `i = 1`. Compute elements $C_{1j}$ for $j = 4, 5, 6, 7$.
:::

The "tiled" cache blocking SIMD approach performs slightly worse than the transposed SIMD approach.
```bash
C               0.768672 seconds
registers:      0.277462 seconds
simd,naive:     0.416584 seconds
simd,transpose: 0.275622 seconds
simd,tiled:     0.356344 seconds
```

## DGEMM 10: GCC Optimization

Finally, let's compile using different `gcc` optimization flags. In @tab-dgemm-gcc-simd, we can see that even with mild `gcc` optimizations like `-O1`, SIMD vastly outperforms any SISD approach.

:::{list-table} DGEMM SIMD runtime (in seconds) with different optimization flags.
:header-rows: 1
:label: tab-dgemm-gcc-simd

* - Program
  - `-O0`
  - `-O1`
  - `-O2`
  - `-O3`
* - [DGEMM](#code-dgemm) (original)
  - 0.768672
  - 0.197168
  - 0.197538
  - 0.193889
* - [DGEMM with registers](#code-dgemm-reg)
  - 0.277462
  - 0.191474
  - 0.191921
  - 0.126439
* - [DGEMM, naive SIMD](#code-dgemm-simd-naive)
  - 0.416584
  - 0.048405
  - 0.049970
  - 0.049045
* - [DGEMM transpose SIMD](#code-dgemm-simd-transpose)
  - 0.275622
  - 0.031824
  - 0.032188
  - 0.031978
* - [DGEMM tile SIMD](#code-dgemm-simd-tile)
  - 0.356344
  - 0.033386
  - 0.035177
  - 0.037030
:::

Generally speaking, most of the speedup comes not from doing multiple math operations at a time, but instead from doing a **large memory load/store** at a time.

## DGEMM SIMD Code

The three algorithms discussed in this section leverage Intel SIMD extensions. You will see in the code below that the SIMD instructions are written in C as [Intel Intrinsics](#sec-intrinsics). More next!


::::{tab-set}
:::{tab-item} DGEMM, SIMD naive
```{code} c
:linenos:
:label: code-dgemm-simd-naive
:linenos:

matrix_d_t *dgemm_simd(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols!=B->nrows) return NULL; 
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);
  for (int i = 0; i < A->nrows; i++) {
    for (int j = 0; j < B->ncols; j+=4) { // 4 doubles at a time
            avx256_t v_C = avx_load(C->data + i*C->ncols +j);
            for (int k = 0; k < A->ncols; k++) {
                avx256_t s_A = avx_set_num(A->data[(i*A->ncols)+k]);
                avx256_t v_B = avx_load(B->data+k*B->ncols+j);
                // C_ij += a_ik * B_jk (for j = 0...3)
                v_C = avx_mul_add(s_A, v_B, v_C);
            }
            avx_store(C->data+i*C->ncols+j, v_C);
    }
  }
  return C;
}
```
:::
:::{tab-item} DGEMM, SIMD Transpose
```{code} c
:linenos:
:label: code-dgemm-simd-transpose

matrix_d_t *dgemm_simd_transpose(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols!=B->nrows) return NULL;
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);
  matrix_d_t *B_T = transpose_mat_d(B);
  for (int i = 0; i < A->nrows; i++) {
    for (int j = 0; j < B->ncols; j++) {
      double *ptr_A = A->data+(i*A->ncols);
      double *ptr_B_T = B_T->data+(j*B_T->ncols);
      int k = 0;
  
            // 4 doubles at a time
            avx256_t v_C = avx_set_num(0);
            for (; k < A->ncols/4*4; k+= 4) {
                avx256_t v_A = avx_load(ptr_A+k);
                avx256_t v_B = avx_load(ptr_B_T+k);
                v_C = avx_mul_add(v_A, v_B, v_C);
            }
  
      double mem[4] __attribute__ ((aligned (64)));
            avx_store(mem, v_C);
            double sum = mem[0] + mem[1] + mem[2] + mem[3];

            // tail case
            for(; k < A->ncols; k++) {
                sum += ptr_A[k]*ptr_B_T[k];
            }
            C->data[i*C->ncols+j] = sum;
    }
  }
  free_mat_d(B_T);
  return C;
}
```
:::
:::{tab-item} DGEMM, SIMD Tiled
```{code} c
:linenos:
:label: code-dgemm-simd-tile

static inline void matmul_simd_tile(int si, int sj, int sk,
                 matrix_d_t *A, matrix_d_t *B, matrix_d_t *C) {
    for (int i = si; i < si + BLOCKSIZE; i++) {
        for (int j = sj; j < sj + BLOCKSIZE; j+=4) { // 4 doubles at a time
            avx256_t v_C = avx_load(C->data+i*C->ncols+j);

            for (int k = sk; k < sk + BLOCKSIZE; k++) {
                avx256_t s_A = avx_set_num(A->data[(i*A->ncols)+k]);
                avx256_t v_B = avx_load(B->data+k*B->ncols+j);
                v_C = avx_mul_add(s_A, v_B, v_C);
            }
            avx_store(C->data+i*C->ncols+j, v_C);
        }
    }
}
matrix_d_t *dgemm_simd_block(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols!=B->nrows) return NULL;
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);
  for (int si = 0; si < A->nrows; si += BLOCKSIZE) {
    for (int sj = 0; sj < B->ncols; sj += BLOCKSIZE) {
            for (int sk = 0; sk < A->ncols; sk+= BLOCKSIZE) {
                matmul_simd_tile(si, sj, sk, A, B, C);
            }
    }
  }
  return C;
}
```
:::

:::{tab-item} DGEMM (original)

```{embed} #code-dgemm
```
:::

:::{tab-item} AVX intrinsics
```{code} c
:linenos:
:label: code-dgemm-avx

typedef __m256d avx256_t;

// Loads 8 doubles at memory address A into a avx256_t
static inline avx256_t avx_load(double *A) {
  return _mm256_load_pd(A);
}

// Stores the avx256_t at SRC to DST. Each avx256_t element gets stored in a 
// different index of the array passed into DST.
static inline void avx_store(double *dst, avx256_t src) {
  _mm256_store_pd(dst, src);
}

// Creates a avx256_t where every element is equal to num
static inline avx256_t avx_set_num(double num) {
  return _mm256_set1_pd(num);
}

// A * B + C
static inline avx256_t avx_mul_add(avx256_t A, avx256_t B, avx256_t C) {
  return _mm256_fmadd_pd(A, B, C);
}
```
:::
::::
<!-- 


:::{figure} images/simd-col-major.png
:label: fig-simd-col-major
:width: 100%
:alt: "On the left: cloud symbol encompassing a 4-element column vector times a single element. On the right, two column vectors multiplied together, the first identical to the original column vector, and the second is a new 4-element column vector set with four copies of the original single element. A right-pointing arrow connects the two sides and is labeled vec_setnum."

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