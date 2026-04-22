---
title: "DGEMM: Performance Benchmark"
---

(sec-dgemm-sisd)=
## Learning Outcomes

* Explain why C DGEMM runs faster than Python DGEMM.
* Understand that in practice, library implementations like NumPy DGEMM are plenty fast because they use the optimizations described in this unit.
* Compare sequential optimizations on matrix multiplication: loop unrolling, the `register` keyword, and transposing matrices.
* Compare performance using different `gcc` optimization flags: `-O0`, `-O2`, `-O3`.

Review the DGEMM (Double GEneral Matrix Multiplication) algorithm in an [earlier section](#sec-dgemm).

:::{embed} #card-dgemm
:::

## Demo Information

(sec-dgemm-benchmark)=
:::{hint} DGEMM Benchmark

For each of the optimizations described in this chapter, we evaluate performance on the same DGEMM benchmark on the same machine to measure the speedup due to specific performance improvements.

* GCC: no optimization (flag `-O0`) unless otherwise stated
* Matrix dimensions: 512 by 512 (the precise matrices may vary by program)
* Timing library: `<time.h>` (except for OpenMP)
* Machine: Course hive machines

See lecture for example benchmark code. The benchmark will be hosted on the course notes in a future semester.

<!-- TODO put benchmark here, not in Drive -->

:::

**GCC Options**: For now, unless otherwise stated, all C benchmarks are compiled with **no optimization flags** turned on in `gcc` by passing in the option `O0`. 
We discuss `gcc` optimization flags in a [later section](#sec-dgemm-sequential).

```bash
gcc -g3 -std=c11 -Wall -O0 matmul.c run_matmul.c -o run_matmul
```

(sec-time-h-timing)=
**Timing**: For non-threaded programs (no [OpenMP](#sec-openmp)[^openmp-timing]), we use the clock from the C standard library `<time.h>`. The `CLOCKS_PER_SEC` name[^time-h] is used to convert the value returned by the clock() function into seconds.

[^time-h]: See the [UNIX specification](https://pubs.opengroup.org/onlinepubs/7908799/xsh/time.h.html) of `<time.h>` for more information on `CLOCKS_PER_SEC` and `clock()`.

```{code} c
:label: code-time-h
#include <time.h>
int main() {
  ...

  clock_t start = clock();
  matrix_d_t* C = dgemm(A, B);
  clock_t end = clock();

  // execution time in seconds
  double delta_time = (double) (end - start)/CLOCKS_PER_SEC;
  ...
}
```

[^openmp-timing]: For timing multi-threaded programs, see a [later section](#sec-dgemm-mimd).

**Machine**: The demos in **this section** run on the **shared** course hive machines.  Intel(R) Core(TM) [i7-8700T](https://www.intel.com/content/www/us/en/products/sku/129948/intel-core-i78700t-processor-12m-cache-up-to-4-00-ghz/specifications.html) Processor. 6 cores (2 threads per core) and cache size 12MiB.

For better or for worse, hive machines are shared. Our timing is measured from program start to program end, and we may be sharing the machine with other users. So the improvement from these times is certainly an upper bound :-)

:::{warning} Reported time

We report the runtime of a single run of each program. For our intents and purposes we are just interested in the **order of magnitude** between optimizations.

In practice, one should report (1) the average runtime over, say, 3-5 runs, and (2) the minimum runtime, or some metric of runtime spread. These metrics would better characterize the variance based on server load and matrix complexity.

:::

For more accurate numbers, we recommend reading Leiserson et al. 2020.[^leiserson]

[^leiserson]: Charles E. Leiserson et al. "There’s plenty of room at the Top: What will drive computer performance after Moore’s law?" _Science_ Volume 368, Issue 6495 (2020). [DOI:10.1126/science.aam9744](https://doi.org/10.1126/science.aam9744) Code is on [GitHub](https://github.com/neboat/Moore/tree/v1.0.1) as described on [Zenodo](https://zenodo.org/records/3715525).

## DGEMM 1: `int` vs. `double`, FLOPs

The **double-precision** component of DGEMM is challenging because it requires many floating point operations. Integer multiplication and addition are faster than their floating-point analogs:

```bash
dgemm:  0.770195 seconds
igemm:  0.734030 seconds
```

:::{note} Click to show "IGEMM" (Integer GEneral Matrix Multiplication)
:class: dropdown

```{code} c
:linenos:
:label: igemm-simple
typedef struct {
  int nrows; 
  int ncols; 
  int* data;
} matrix_t;
        
matrix_t *init_mat(int nrows, int ncols);
matrix_t *load_mat(FILE* f);
void print_mat(matrix_t *mat);
void free_mat(matrix_t *mat);

matrix_t *igemm(matrix_t *mat_A, matrix_t *mat_B) {
  if (mat_A->ncols != mat_B->nrows) return NULL;
    matrix_t *mat_C = init_mat(mat_A->nrows, mat_B->ncols);
    
  for (int i = 0; i < mat_A->nrows; i++) {
    for (int j = 0; j < mat_B->ncols; j++) {
      int sum = 0; 
      for (int k = 0; k < mat_A->ncols; k++) {
        sum += mat_A->data[i*mat_A->ncols+k]*mat_B->data[k*mat_B->ncols+j];
      }
      mat_C->data[i*mat_C->ncols+j] = sum;
    } 
  } 
  return mat_C;
} 
```

:::

To measure **instruction count**, we may find it useful to use a secondary metric that explicitly measures the execution time of the bottleneck operations.

**FLOPS** (Floating Point Operations per Second) counts the number of floating point operations (e.g., floating point adds, floating point multiplications, etc.) and scales by measured program execution time.

@tab-flops shows the FLOPS (and megaflops, and gigaflops) of a standard Python or C implementation of DGEMM.

:::{table} Python vs. C in FLOPS.
:label: tab-flops

| N | Python (MFLOPS) | Python (GFLOPS) | C (GFLOPS) |
| :--- | :--- | :--- | :--- |
| 32 | 5.4 | 0.0054 | 1.30 |
| 160 | 5.5 | 0.0055 | 1.30 |
| 480 | 5.4 | 0.0054 | 1.32 |
| 960 | 5.3 | 0.0053 | 0.91 |

:::

## DGEMM 2: C vs. Python

The analogous Python code to the the [C DGEMM benchmark](#code-dgemm):

(card-dgemm-py)=
:::{card}
DGEMM: Python
^^^

```{code} python
:linenos:
:label: code-dgemm-py
def matmul(A, B, N): 
    C = [0 for _ in A]
    for i in range(N):
        for j in range(N):
            for k in range(N):
                C[i*N + j] += A[i+k*N] * B[k+j*N]
```
:::

Running and timing C vs. Python on a 512 $\times$ 512 matrix multiplication:

```bash
C:      0.770195 seconds
Python: 32.67397 seconds
```

Implementing DGEMM in C yields more than a 40x improvement than implementing DGEMM in Python! This performance comes from reducing the number of operations the program performs. From P&H 2.21:

> The reasons for the speedup are fundamentally using a compiler instead of an interpreter and because the type declarations of C allow the compiler to produce much more efficient code.

## DGEMM 3: C vs. Python NumPy

Should we move back to C for all our mathematical and scientific computations? In practice, no. Modern scientific computing libraries leverage many of the performance optimizations we will discuss in the next few sections. 

NumPy is a Python library designed specifically to add support for large, multi-dimensional arrays and matrices. Matrix multiplication in NumPy assumes that matrices `A` and `B` are `numpy.ndarray`s:

(card-dgemm-numpy)=
:::{card}
DGEMM: Python NumPy
^^^

```{code} python
:linenos:
:label: code-dgemm-numpy

import numpy as np

...
A = np.array(A).reshape((N, N))
B = np.array(B).reshape((N, N))
C = A * B
```
:::

Now with NumPy:

```bash
C:      0.770195 seconds
NumPy:  0.000964 seconds
```

That's right—using NumPy gives a nearly 800x improvement over our C benchmark! Instead of reinventing the wheel, for practical reasons in your future work, **we suggest just using scientific libraries like those offered by Python's NumPy**.

NumPy accelerates matrix multiplication by leveraging parallelism and cache blocking, discussed later in this unit.

## DGEMM 4: The `register` keyword

We update our [C dgemm benchmark from before](#card-dgemm) to use registers for the innermost loop variable `k`, the pointer to elements in matrices `A` and `B`, and the `sum` value that will eventually be written to the corresponding element of matrix `C`.

::::{tab-set}
:::{tab-item} DGEMM with Registers
```{code} c
:linenos:
:label: code-dgemm-reg

matrix_d_t *dgemm(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols != B->nrows) return NULL;
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);

  for (int i = 0; i < A->nrows; i++) {
    for (int j = 0; j < B->ncols; j++) {
      register double sum = 0;
      register double *ptr_A = (A->data) + (i*A->ncols);
      register double *ptr_B = (B->data) + j;
      register int k = 0;
      for(; k < C->ncols; ){
          sum += (*ptr_A) + (*ptr_B);
          ptr_A++;
          ptr_B += B->ncols;
          k++;
      }
      C->data[i*C->ncols+j] = sum;
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
::::

:::{note} Show Explanation

Line 11 uses unconventional loop syntax and is closest to the following:

```
for(k = 0; k < C->ncols; ) {...}
```

Note that the initial value of `sum` is already declared in Line 7; this can possibly reduce instruction count if we have a zero register (e.g., `x0`). Ultimately, the code is more readable if we specify Line 11 more normally and delegate additional optimizations to the compiler.

:::

On a 512 $\times$ 512 matrix multiplication:

```bash
C          0.768672 seconds
registers: 0.277462 seconds
```

We get a 4x improvement by moving frequently accessed values to registers!

## DGEMM 5: Cache blocking with matrix transpose

In this section, we first transpose the $B$ matrix to store it in column-major order (as the variable `B_T`). We additionally include the `register` optimization from before.

::::{tab-set}
:::{tab-item} Transpose + Registers
```{code} c
:label: code-dgemm-reg-transpose
:linenos:

matrix_d_t *dgemm(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols!=B->nrows) return NULL;
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);
  matrix_d_t *B_T = transpose_mat_d(B);
  for (int i = 0; i < A->nrows; i++) {
    for (int j = 0; j < B->ncols; j++) {
      register double sum = 0;
      register double *ptr_A = A->data+(i*A->ncols);
      register double *ptr_B_T = B_T->data+(j*B_T->ncols);
      register int k = 0;
      for (; k < A->ncols;) {
        sum+=(*ptr_A) * (*ptr_B_T);
        ptr_A++;
        ptr_B_T++;
        k++;
      }
      C->data[i*C->ncols+j] = sum;
    }
  }
  free_mat_d(B_T);
  return C;
}
```
:::
:::{tab-item} Registers

```{embed} #code-dgemm-reg
```
:::
::::

:::{note} Show Explanation
:class: dropdown

* Line 4 transposes `B` to produce `B_T`. `B_T` stores the elements of matrix $B$ in column-major order.
* Line 9 accesses the `j`th column of $B$ (by pointing to the `j`th row of `B_T`)
* Line 14 increments the pointer to the next element in the `j`th column of $B$ (by incrementing the `ptr_B_T` pointer).

BTW: We use a straightforward transpose implementation. Nothing fancy.

```{code} c
matrix_d_t *transpose_mat_d(matrix_d_t *mat) {
    // new data array is "transpose", ncols x nrows
    // data_ij = orig_data_ji
    matrix_d_t *transpose = init_mat_d(mat->ncols, mat->nrows);
    for (int i = 0; i < transpose->nrows; i++) {
        for (int j = 0; j < transpose->ncols; j++) {
            transpose->data[i*transpose->ncols+j] = mat->data[j*mat->ncols+i];
        }
    } 
    return transpose;
}
```
:::

On a 512 $\times$ 512 matrix multiplication:

```bash
C          0.768672 seconds
registers: 0.277462 seconds
transpose: 0.204523 seconds
```

This performance speedup may be less than you expected. Understandably, the matrix transpose in Line 4 will add slow memory accesses, even though it speeds up accesses in the core triple for-loop of matrix multiplication. The transpose optimization should be faster for large matrices but slower for small matrices.[^numpy-transpose]

[^numpy-transpose]: In practice (if you look at the NumPy code), the transpose and a matrix are both used for matrix multiplication; it is natural to assume that the transpose is computed ahead of time and updated when needed. See the reference open-source code for NumPy at the end of the section if you are curious.

## DGEMM 6: GCC optimizations

We run [original DGEMM](#code-dgemm), [`register` DGEMM](#code-dgemm-reg), [transpose DGEMM](#code-dgemm-reg-transpose) with different `gcc` optimization flags and report the results in @tab-dgemm-gcc.

:::{list-table} DGEMM/matrix multiplication runtime (in seconds) with different optimization flags.
:header-rows: 1
:label: tab-dgemm-gcc

* - Program
  - `-O0`
  - `-O1`
  - `-O2`
  - `-O3`
* - [DGEMM](#code-dgemm) (original)
  - 0.768672
  - 0.193948
  - 0.197389
  - 0.193935
* - [DGEMM with registers](#code-dgemm-reg)
  - 0.277462
  - 0.191474
  - 0.191921
  - 0.126439
* - [DGEMM transpose](#code-dgemm-reg-transpose) (and registers)
  - 0.204523
  - 0.132441
  - 0.132383
  - 0.126460
:::

Why doesn't loop unrolling produce (`-O3`) produce wildly faster code? In our current code, it is entirely possible that unrolling is limited because our outer loop is **too large** (the size of N). To enhance code for loop unrolling, we could introduce a fourth nested loop (that iterates for `UNROLL` iterations), then let `gcc` optimize that.[^dgemm-unroll]

[^dgemm-unroll]: We may implement DGEMM unrolling in a future version of this course. For now, we leave this implementation to those of you who are truly inspired. :-)