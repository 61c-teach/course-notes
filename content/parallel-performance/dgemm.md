---
title: "dgemm: Matrix Multiplication"
---

(sec-dgemm)=
## Learning Outcomes

* Explain the DGEMM benchmark: row-major order matrix multiplication.
* Explain why C DGEMM runs faster than Python DGEMM.
* Understand that in practice, library implementations like NumPy DGEMM are plenty fast because they use the optimizations described in this chapter.

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

How might we begin evaluating performance? Remember from our discussion of the [iron law of processor performance](#sec-iron-law) that in order to evaluate performance, we must determine a **program benchmark.** Over the next few lectures, we will evaluate different optimizations of a core benchmark to many engineering, data, and image processing tasks today: **matrix multiplication.**

:::{figure} images/matmul-ml.png
:label: fig-matmul-ml
:width: 80%

A machine learning application is shown. There are many matrix-matrix and matrix-vector multiplications, e.g., in each layer of a multi-layer neural network. Matrix multiplication is also core to tasks in other domains, e.g., image filtering and noise reduction.
:::

## Matrix Multiplication

Matrix multiplication is defined as $C = AB$ for matrices $A$, $B$, and $C$. If $\mathbb{R}$ is the set of all real numbers, the dimensions of these three matrices are: $A \in \mathbb{R}^{n \times d}, B \in \mathbb{R}^{d \times m}, C \in \mathbb{R}^{n \times m}$.

To compute each element of the resulting matrix $C$, we take the dot-product of a row of $A$ and a column of $B$. @fig-matmul-00 shows how we can compute the zero-th row, zero-th column element of $C$, $C_{00}$, by multiplying element-wise the (zero-indexed) zero-th row of $A$ and zero-th column of $B$, then summing everything together.

:::{figure} images/matmul-00.png
:label: fig-matmul-00
:width: 60%

Compute $C_{00}$ by taking the dot product of row $0$ of $A$ and column $0$ of $B$.
:::

Similarly, to compute $C_{01}$, we can multiply element-wise the zero-th row of $A$ and first column of $B$, then sum everything together, as in @fig-matmul-ij.

:::{figure} images/matmul-ij.png
:label: fig-matmul-ij
:width: 60%

Compute $C_{ij}$ by taking the dot product of row $i$ of $A$ and column $j$ of $B$.
:::

A straightforward description of this algorithm in C:

```c
void dgemm(int N, double **A, double **B, double **C) {
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
        // for row i, col j of C
        double sum = 0;
        for (int k = 0; k < size; k++) {
        sum += A[i][k] * B[k][j];
        }
        C[i][j] = sum;
    }
  }
}
```

The code above assumes that matrices are stored as two-dimensional arrays, but this will complicate our analysis of memory—particularly as it relates to spatial locality for caches and the memory hierarchy.

Next, we describe the true benchmark we will use in this course:

## The DGEMM benchmark

The above matrix multiplication task is common called DGEMM, which stands for **D**ouble-precision **GE**neral **M**atrix **M**ultiply.

The following code represents matrices $A$, $B$, and $C$ as variables `A`, `B`, and `C`, respectively. Further assumptions:

* Heap allocated;
* **Square** with dimensions $n \times n$; and
* Have elements stored in a `double` array, in **row-major order**.

(card-dgemm)=
:::{card}
DGEMM: Double-precision General Matrix Multiplication
^^^

```{code} c
:linenos:
:label: code-dgemm
matrix_d_t *dgemm(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols != B->nrows) return NULL;
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);
    
  for (int i = 0; i < A->nrows; i++) {
    for (int j = 0; j < B->ncols; j++) {
      double sum = 0; 
      for (int k = 0; k < A->ncols; k++) {
        sum += A->data[i*A->ncols+k]*B->data[k*B->ncols+j];
      }
      C->data[i*C->ncols+j] = sum;
    } 
  }   
  return C;
} 

```

:::


### Matrix Dimensions

The P&H textbook assumes that all matrices are square, where `N` specifies both row and column dimensions. For those less familiar with matrix multiplication, reducing to this one value may make it hard to picture matrix multiplication, even if it makes our code simpler.

For the purposes of our course demo, we will assume DGEMM works on a struct that stores the row and column dimensions along with our matrix data. as shown [below](#card-dgemm-helper). All matrices are **pointers** to **heap-allocated** structs; these are allocated and freed with `init_mat_d` and `free_mat_d`.

(card-dgemm-helper)=
:::{card}
DGEMM Helpers
^^^
```{code} c
:linenos:
typedef struct {
    int nrows; 
    int ncols;
  double* data;
} matrix_d_t;
            
matrix_d_t *init_mat_d(int nrows, int ncols);
matrix_d_t *load_mat_d(FILE* f);
void print_mat_d(matrix_d_t *mat);
void free_mat_d(matrix_d_t *mat);
```
:::

:::{table} Matrix multiplication dimensions with the `matrix_d_t` struct.

| Matrix | C declaration | Rows | Columns |
| :-- | :-- | :-- | :-- |
| $A$ | `matrix_d_t *A;` | `A->nrows` or $n$ | `A->ncols` or $d$ |
| $B$ | `matrix_d_t *B;` | `B->nrows` or $d$ | `B->ncols` or $m$|
| $A$ | `matrix_d_t *C;` | `C->nrows` or $n$ | `C->ncols` or $m$|
:::

Going forward, we will use this syntax, but all of our timing benchmarks and subsequent optimizations will assume that all matrices are square, i.e., $n = d = m$. We will further assume $n$ **powers of two** (or at minimum a multiple of 4). We will test:

* $512 \times 512$
* $1024 \times 1024$
* $2048 \times 2048$
* etc.

In practice, matrix dimensions are passed as parameters to avoid `struct`s and keep indirection to a minimum. We will probably revisit and rewrite this benchmark in future semesters to measure performance more clearly.

### Row-major order

Assume that matrices $A$, $B$, and $C$ are stored as `A`, `B`, and `C`. In the code, these matrices are stoerd as arrays of `double` arrays. By convention, these arrays store matrix elements in **row-major order**.[^col-major]

[^col-major]: The **row-major order** convention is used in C and Python (e.g., NumPy), though **column-major order** conventions exist in other languages (e.g., FORTRAN). One reasoning is that in C, `A[i][j]` almost inevitably implies row-major order because it can be rewritten as `(A[i])[j]`, where `A[i]` is a row. Read more on [Wikipedia](https://en.wikipedia.org/wiki/Row-_and_column-major_order).

In @fig-matmul-row-major, each element of `A[i]` is the $i$-th row of matrix $A$; furthermore, the zero-th element of the $i+1$-th row immediately follows the last element of the $i$-th row, as shown in @fig-matmul-row-major.

:::{figure} images/matmul-row-major.png
:label: fig-matmul-row-major

Assume that all matrices are stored in **row-major order**.
:::

We revisit the inner loop of the [DGEMM benchmark code](#code-dgemm). Flip between the two tabs to see how to compute $C_{ij}$, the element of $C$ in row `i` and column `j` if we assume all matrices are stored in row-major order.

::::{tab-set}
:::{tab-item} Row-major

```{code} c
double sum = 0; 
for (int k = 0; k < A->ncols; k++) {
  sum += A->data[i*A->ncols+k]*B->data[k*B->ncols+j];
}
C->data[i*C->ncols+j] = sum;
```
:::

:::{tab-item} 2-D
```{code} c
double sum = 0;
for (int k = 0; k < size; k++) {
sum += A[i][k] * B[k][j];
}
C[i][j] = sum;
```
:::
::::

:::{note} Show Explanation
:class: dropdown

* Row `i`, column `k` of $A$: First find the address of the `i`-th row at `mat_A->data + i*mat_ncols`. Then, increment by `k` elements to get the address of the `k`-th element in this row.
* Row `k`, Column `j` of $B$: First find the address of the `k`-th row at `mat_B->data + k*mat_B->ncols`. Then, increment by `i` elements to get the address of the `j`-th element in this row.
* Row `i`, Column `j` of $C$: First find the address of the `i`-th row at `mat_C->data + i*mat_C->ncols`. Then, increment by `j` elements to get the address of the `j`-th element in this row.
:::

## DGEMM Benchmark Performance

### Demo Information

(sec-dgemm-benchmark)=
:::{hint} DGEMM Benchmark

For each of the optimizations described in this chapter, we evaluate performance on the same DGEMM benchmark on the same machine to measure the speedup due to specific performance improvements.

* GCC: no optimization (flag `-O0`) unless otherwise stated
* Matrix dimensions: 512 by 512 (the precise matrices may vary by program)
* Timing library: `<time.h>` (except for OpenMP)
* Machine: Course hive machines

See lecture for example benchmark code. The benchmark will be hosted on the course notes in a future semester.
:::

**GCC Options**: For now, unless otherwise stated, all C benchmarks are compiled with **no optimization flags** turned on in `gcc` by passing in the option `O0`. 
We discuss `gcc` optimization flags in a [later section](#sec-dgemm-sequential).

```bash
gcc -g3 -std=c11 -Wall -O0 matmul.c run_matmul.c -o run_matmul
```

**Timing**: For non-threaded programs (no [OpenMP](#sec-openmp)), we use the clock from the C standard library `<time.h>`. The `CLOCKS_PER_SEC` name[^time-h] is used to convert the value returned by the clock() function into seconds.

[^time-h]: See the [UNIX specification](https://pubs.opengroup.org/onlinepubs/7908799/xsh/time.h.html) of `<time.h>` for more information on `CLOCKS_PER_SEC` and `clock()`.

```c
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

**Machine**: The demos in **this section** ∂run on the **shared** course hive machines.  Intel(R) Core(TM) [i7-8700T](https://www.intel.com/content/www/us/en/products/sku/129948/intel-core-i78700t-processor-12m-cache-up-to-4-00-ghz/specifications.html) Processor. 6 cores (2 threads per core) and cache size 12MiB.

For better or for worse, hive machines are shared. Our timing is measured from program start to program end, and we may be sharing the machine with other users. So the improvement from these times is certainly an upper bound :-)

:::{warning} Reported time

We report the runtime of a single run of each program. For our intents and purposes we are just interested in the **order of magnitude** between optimizations.

In practice, one should report (1) the average runtime over, say, 3-5 runs, and (2) the minimum runtime, or some metric of runtime spread. These metrics would better characterize the variance based on server load and matrix complexity.

:::

For more accurate numbers, we recommend reading Leiserson et al. 2020.[^leiserson]

[^leiserson]: Charles E. Leiserson et al. "There’s plenty of room at the Top: What will drive computer performance after Moore’s law?" _Science_ Volume 368, Issue 6495 (2020). [DOI:10.1126/science.aam9744](https://doi.org/10.1126/science.aam9744) Code is on [GitHub](https://github.com/neboat/Moore/tree/v1.0.1) as described on [Zenodo](https://zenodo.org/records/3715525).

### DGEMM 1: C vs. Python

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

### DGEMM 2: `int` vs. `double`, FLOPs

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

### DGEMM 3: C vs. Python NumPy

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

But how did NumPy accelerate matrix multiplication performance? We discuss a few optimizations in this chapter. Let's get started...!

<!-- TODO put benchmark here, not in Drive -->