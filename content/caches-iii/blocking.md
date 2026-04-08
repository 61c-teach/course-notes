---
title: "Cache Blocking"
---

(sec-cache-matmul)=
## Learning Outcomes

* Write programs that leverage understanding of the underlying cache design.
* Define cache blocking.

In this section, we consider how knowing the underlying design of our cache can actually improve how we write programs.

## Matrix Multiplication

Recall that matrix multiplication is defined as $AB = C$ for matrices $A$, $B$, and $C$ with appropriate dimensions. In this example, we will consider multiplying matrix $A$ (4 rows $\times$ 8 columns) by matrix $B$ (8 rows $\times$ 4 columns) to produce the matrix $C$ (4 rows $\times$ 4 columns).[^real-numbers]

[^real-numbers]: Using proper mathematical notation: $A \in \mathbb{R}^{n \times m}, B \in \mathbb{R}^{m \times p}, C \in \mathbb{R}^{n \times p}$. In our example, $n = p = 4, m = 8$.

To compute each element of the resulting matrix $C$, we take the dot-product of a row of $A$ and a column of $B$. @fig-matmul-00 shows how we can compute the zero-th row, zero-th column element of $C$, $C_{00}$, by multiplying element-wise the (zero-indexed) zero-th row of $A$ and zero-th column of $B$, then summing everything together.

:::{figure} images/matmul-00.png
:label: fig-matmul-00
:width: 60%

Compute $C_00$ by taking the dot product of row $0$ of $A$ and column $0$ of $B$.
:::

Similarly, to compute $C_{01}$, we can multiply element-wise the zero-th row of $A$ and first column of $B$, then sum everything together, as in @fig-matmul-ij.

:::{figure} images/matmul-ij.png
:label: fig-matmul-ij
:width: 60%

Compute $C_ij$ by taking the dot product of row $i$ of $A$ and column $j$ of $B$.
:::

## C code: `matmul`

If `A`, `B`, and `C` are the matrix representation of $A$, $B$, and $C$, respectively, and memory is appropriately allocated, we can write straight-forward C to implement matrix multiplication code:

```c
// for row i, col j of C
int sum = 0; // sizeof(int) = 4
for (int k = 0; k < size; k++) {
  sum += A[i][k] * B[k][j];
}
C[i][j] = sum;
```

::::{warning} Row-major order

Assume that matrices $A$, $B$, and $C$ are stored as `A`, `B`, and `C`. In the code, these variables are arrays of `int` arrays. The matrices therefore by definition are stored in **row-major order**. For example, each element of `A[i]` is the $i$-th row of matrix $A$; furthermore, the zero-th element of the $i+1$-th row immediately follows the last element of the $i$-th row, as shown in @fig-matmul-row-major.

:::{figure} images/matmul-row-major.png
:label: fig-matmul-row-major

Assume that all matrices are stored in **row-major order**.
:::
::::

## Architecture details

Suppose we run our C program on a 32-bit architecture that has a single-layer cache:

* 128B capacity
* fully associative
* 16B block size (so 8 blocks)
* LRU replacement policy
* Write-back write policy with dirty bit

For our matrix multiplication example, we will assume that on this architecture, `sizeof(int)` is `4`, so each block holds four `int`s.

## `matmul` Memory Access Pattern

How does matrix multiplication fare? Assume the cache starts out cold.

Suppose we first compute $C_{00}$, which is the dot-product of the (zero-indexed) zero-th row of $A$ and the (zero-indexed) zero-th column of $B$.

::::{figure}
:label: anim-matmul-00
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/caches-iii/pptx/matmul-00.pptx
:width: 100%
:title: "C[0][0] Memory Access Pattern"
:::
Computing $C_00$ as vector multiplication of the zero-th row of $A$ and the zero-th column of $B$. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::

:::{note} Show cache hits/misses
:class: dropdown

Assume `sum` is stored in a register. Assume accessing any element of `A`, `B`, or `C` will result in a memory access.

1. `A[0][0] * B[0][0]`. Compulsory cache miss on `A[0][0]`, compulsory cache miss on `B[0][0]`.

    Cache contents, in order of most recently used:
    * Row $0$ of B
    * Row $0$ of A, first half (elements $0$ to $3$)

1. `A[0][1] * B[1][0]`. Cache hit on `A[0][1]`, compulsory cache miss on `B[1][0]`.

    Cache contents:
    * Row $1$ of B
    * Row $0$ of A, first half
    * Row $0$ of B

1. `A[0][2] * B[2][0]`. Cache hit on `A[0][2]`, compulsory cache miss on `B[2][0]`.

    Cache contents:
    * Row $2$ of B
    * Row $0$ of A, first half
    * Row $1$ of B
    * Row $0$ of B

1. `A[0][3] * B[3][0]`. Cache hit on `A[0][3]`, compulsory cache miss on `B[3][0]`.

    Cache contents:
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B
    * Row $0$ of B

1. `A[0][4] * B[4][0]`. Compulsory cache miss on `A[0][4]`, compulsory cache miss on `B[4][0]`.

    Cache contents:
    * Row $4$ of B
    * Row $0$ of A, second half
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B
    * Row $0$ of B

1. `A[0][5] * B[5][0]`. Cache hit on `A[0][5]`, compulsory cache miss on `B[5][0]`.

    Cache contents:
    * Row $5$ of B
    * Row $0$ of A, second half
    * Row $4$ of B
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B
    * Row $0$ of B

  Cache is now at capacity (full).

1. `A[0][6] * B[6][0]`. Cache hit on `A[0][6]`, compulsory cache miss on `B[6][0]`. Cache is full, so replace least recently used block (row $0$ of B).

    Cache contents:
    * Row $6$ of B
    * Row $0$ of A, second half
    * Row $5$ of B
    * Row $4$ of B
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B
    * Row $0$ of B

1. `A[0][7] * B[7][0]`. Cache hit on `A[0][6]`, compulsory cache miss on `B[7][0]`. Cache is full, so replace least recently used block (row $1$ of B).

    Cache contents:
    * Row $7$ of B
    * Row $0$ of A, second half
    * Row $6$ of B
    * Row $5$ of B
    * Row $4$ of B
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B

1. `C[0][0] = sum`. Cache miss on `C[0][0]`. Cache is full, so replace least recently used block (row $2$ of B).

    Cache contents:
    * Row $0$ of C
    * Row $7$ of B
    * Row $0$ of A, second half
    * Row $6$ of B
    * Row $5$ of B
    * Row $4$ of B
    * Row $0$ of A, first half
    * Row $3$ of B
:::

Cache contents after computing $C_{00}$, in order of most recently used:

* Row $0$ of C
* Row $7$ of B
* Row $0$ of A, second half
* Row $6$ of B
* Row $5$ of B
* Row $4$ of B
* Row $0$ of A, first half
* Row $3$ of B

Next, suppose we computed $C_{01}$, which is the dot-product of the (zero-indexed) zero-th row of $A$ and the (zero-indexed) first column of $B$.

::::{figure}
:label: anim-matmul-ij
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/caches-iii/pptx/matmul-00.pptx
:width: 100%
:title: "C[i][j] Memory Access Pattern"
:::
Computing $C_{ij}$ as vector multiplication of the i-th row of $A$ and the j-th column of $B$. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::

:::{note} Show cache hits/misses
:class: dropdown

Assume `sum` is stored in a register. Assume accessing any element of `A`, `B`, or `C` will result in a memory access.

1. `A[0][0] * B[1][0]`. Cache hit on `A[0][0]`, **non-compulsory** cache miss on `B[1][0]`. Cache is full, so replace least recently used block (row $3$ of B).

    Cache contents:
    * Row $0$ of B
    * Row $0$ of A, first half
    * Row $0$ of C
    * Row $7$ of B
    * Row $0$ of A, second half
    * Row $6$ of B
    * Row $5$ of B
    * Row $4$ of B

1. `A[0][1] * B[1][1]`. Cache hit on `A[0][1]`, **non-compulsory** cache miss on `B[1][1]`. Cache is full, so replace least recently used block (row $4$ of B).

    Cache contents:
    * Row $1$ of B
    * Row $0$ of A, first half
    * Row $0$ of B
    * Row $0$ of C
    * Row $7$ of B
    * Row $0$ of A, second half
    * Row $6$ of B
    * Row $5$ of B

1. `A[0][2] * B[1][2]`. Cache hit on `A[0][2]`, **non-compulsory** cache miss on `B[1][2]`. Cache is full, so replace least recently used block (row $5$ of B).

    Cache contents:
    * Row $2$ of B
    * Row $0$ of A, first half
    * Row $1$ of B
    * Row $0$ of B
    * Row $0$ of C
    * Row $7$ of B
    * Row $0$ of A, second half
    * Row $6$ of B

1. `A[0][3] * B[1][3]`. Cache hit on `A[0][3]`, **non-compulsory** cache miss on `B[1][3]`. Cache is full, so replace least recently used block (row $6$ of B).

    Cache contents:
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B
    * Row $0$ of B
    * Row $0$ of C
    * Row $7$ of B
    * Row $0$ of A, second half

1. `A[0][4] * B[1][4]`. Cache hit on `A[0][4]`, **non-compulsory** cache miss on `B[1][4]`. Cache is full, so replace least recently used block (row $7$ of B).

    Cache contents:
    * Row $4$ of B
    * Row $0$ of A, second half
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B
    * Row $0$ of B
    * Row $0$ of C

1. `A[0][5] * B[1][5]`. Cache hit on `A[0][5]`, **non-compulsory** cache miss on `B[1][5]`. Cache is full, so replace least recently used block (row $0$ of C).

    Cache contents:
    * Row $5$ of B
    * Row $0$ of A, second half
    * Row $4$ of B
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B
    * Row $0$ of B

1. `A[0][6] * B[1][6]`. Cache hit on `A[0][6]`, **non-compulsory** cache miss on `B[1][6]`. Cache is full, so replace least recently used block (row $0$ of B).

    Cache contents:
    * Row $6$ of B
    * Row $0$ of A, second half
    * Row $5$ of B
    * Row $4$ of B
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B
    * Row $1$ of B

1. `A[0][7] * B[1][7]`. Cache hit on `A[0][7]`, **non-compulsory** cache miss on `B[1][7]`. Cache is full, so replace least recently used block (row $1$ of B).

    Cache contents:
    * Row $7$ of B
    * Row $0$ of A, second half
    * Row $6$ of B
    * Row $5$ of B
    * Row $4$ of B
    * Row $3$ of B
    * Row $0$ of A, first half
    * Row $2$ of B

1. `C[0][0] = sum`. **Non-compulsory** cache miss on `C[0][0]`. Cache is full, so replace least recently used block (row $2$ of B).

    Cache contents:
    * Row $0$ of C
    * Row $7$ of B
    * Row $0$ of A, second half
    * Row $6$ of B
    * Row $5$ of B
    * Row $4$ of B
    * Row $3$ of B
    * Row $0$ of A, first half
:::

Cache contents after computing $C_{01}$, in order of most recently used:

* Row $0$ of C
* Row $7$ of B
* Row $0$ of A, second half
* Row $6$ of B
* Row $5$ of B
* Row $4$ of B
* Row $3$ of B
* Row $0$ of A, first half

:::{warning} Row-major order, revisited

In matrix multiplication, computing subsequent elements of $C$ results in non-compulsory cache misses on elements of $B$ and the destination row of $C$!

B's row-major layout in memory causes excessive memory accesses. We are constantly replacing rows of $B$!
:::

We have seen in a [previous section](#sec-cache-optimizations) how as computer architects, we can reduce these misses by increasing the capacity of our cache. However, as programmers, we often may not have control over the hardware of our computer. It is not trivial to swap out the cache. Instead, we must assume that we have some fixed hardware architecture, then see how we can rewrite our programmer to maximize use of the hardware.

## Cache Blocking

**Cache blocking** is a programmer technique that rearranges data accesses to make better use of the data brought into the cache.

In our matmul example, we know that `B` is stored in row-major-layout. To access a **column** of $B$ as is needed in matrix multiplication, we must load in all 8 rows of `B`. It would be much better to load in just the 8 elements in the _column_ of `B`, and not elements in other columns needed for later matrix multiplications.

A cache blocking technique could **transpose** B before matrix multiplication. The transpose of $B$ is written as $B^T$ and is defined where $B^T_jk = B_kj$ for all indices $j$ and $k$, as shown in @fig-matmul-transpose.

:::{figure} images/matmul-transpose.png
:label: fig-matmul-transpose

$B^T$ is the matrix transpose of $B$ 

If we maintain a copy of `B_T` (mathematically $B^T$), we can therefore redefine our matrix multiplication as follows:

```c
// cache-blocking code
// for row i, col j of C
int sum = 0; // sizeof(int) = 4
for (int k = 0; k < size; k++) {
  sum += A[i][k] * B_T[j][k];
}
C[i][j] = sum;
```

Notes:

* `B_T` is still a matrix stored in row-major order. However, now our original matrix $B$ is effectively stored in column-major order.
* With the above optimization, we prevent repeatedly replacing and fetching the same data from main memory. Instead, we load in each column of `B`, two memory accesses at a time.