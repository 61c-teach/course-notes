---
title: "DGEMM: Matrix Multiplication"
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
:alt: "Machine-learning style matrix multiplication diagram showing sequential layers of a neural network from inputs to outputs where, at each layer, there are input weights and either matrix matrix or matrix vector mulitplication."
:width: 80%

A machine learning application is shown. There are many matrix-matrix and matrix-vector multiplications, e.g., in each layer of a multi-layer neural network. Matrix multiplication is also core to tasks in other domains, e.g., image filtering and noise reduction.
:::

## Matrix Multiplication

Matrix multiplication is defined as $C = AB$ for matrices $A$, $B$, and $C$. If $\mathbb{R}$ is the set of all real numbers, the dimensions of these three matrices are: $A \in \mathbb{R}^{n \times d}, B \in \mathbb{R}^{d \times m}, C \in \mathbb{R}^{n \times m}$.

To compute each element of the resulting matrix $C$, we take the **dot product** of a row of $A$ and a column of $B$. The **dot product** of two vectors is the sum of the element-wise product of the two vectors. @fig-matmul-00 shows how we can compute the zero-th row, zero-th column element of $C$, $C_{00}$, by multiplying element-wise the (zero-indexed) zero-th row of $A$ and zero-th column of $B$, then summing everything together.

:::{figure} images/matmul-00.png
:label: fig-matmul-00
:alt: "Visualization with three matrix rectangles, composed of smaller square representing individual elements. The first rectangle shows a wide matrix A with row 0 highlighted. The middle matrix shows a tall matrix B with the column 0 highlighted. The resulting right matrix is a square matrix with the 0,0 element highlighted, depicting how the dot product of row 0 of A and column 0 of B results in element 0,0 of C."
:width: 60%

Compute $C_{00}$ by taking the dot product of row $0$ of $A$ and column $0$ of $B$.
:::

Similarly, to compute $C_{01}$, we can multiply element-wise the zero-th row of $A$ and first column of $B$, then sum everything together, as in @fig-matmul-ij.

:::{figure} images/matmul-ij.png
:label: fig-matmul-ij
:alt: "General visualization of computing Cij in a result matrix by dot product of row i of matrix A with column j of matrix B. The visual again shows three rectangles with highlighted row, column, and resulting element to depict the matrix multiplication."
:width: 60%

Compute $C_{ij}$ by taking the dot product of row $i$ of $A$ and column $j$ of $B$.
:::

```c
// basic matrix multiplication
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

The code above assumes that matrices are stored as two-dimensional arrays, but this will complicate our analysis of memory—particularly as it relates to spatial locality for caches and the memory hierarchy. We therefore describe the row-major order implementation below, which we will use as our benchmark task.

## The DGEMM Code Benchmark

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

@fig-dgemm shows the innermost loop of the [DGEMM code](#code-dgemm) to compute $C_{ij}$, where $i = j = 0$.

:::{figure} images/dgemm.png
:label: fig-dgemm
:alt: "Three matrix diagram showing DGEMM nested-loop structure and index mapping over i, j, and k dimensions. Multiplication of row 0 in matrix A with column 0 of matrix B results in element 0,0 in matrix C."
:width: 100%

DGEMM for $8 \times 8$ square matrices A and B. $C_{00}$ is computed as the dot product of row `i = 0` of A and column `j = 0` of B. 
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
:alt: "Matrix memory-layout illustration showing row-major storage order for A, B, and C matrices in memory. The top rectangle shows the wide Nx8 matrix with elements labeled 1 through 16. The bottom rectangle shows the Nx8 elements of the matrix laid out in contiguous space in memory where the matrix is stored."

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