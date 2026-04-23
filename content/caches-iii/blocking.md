---
title: "Cache Blocking"
---

(sec-cache-blocking)=
## Learning Outcomes

* Write programs that leverage understanding of the underlying cache design.
* Define cache blocking.

We have seen in a [previous section](#sec-cache-optimizations) how as computer architects, we can reduce cache misses by increasing the capacity of our cache. However, as programmers, we often may not have control over the hardware of our computer. It is not trivial to swap out the cache. Instead, we must assume that we have some fixed hardware architecture, then see how we can rewrite our programmer to maximize use of the hardware.

**Cache blocking** is a programmer technique that rearranges data accesses to make better use of the data brought into the cache and reduce cache misses.

In this section, we consider one specific program benchmark: [matrix multiplication](#sec-dgemm). After trying an initial naive implementatno, we hhow knowing the underlying design of our cache can actually improve how we write programs.

## Matrix Multiplication (DGEMM)

In this section, we use a matrix multiplication benchmark.
In this example, we will consider multiplying matrix $A$ (4 rows $\times$ 8 columns) by matrix $B$ (8 rows $\times$ 4 columns) to produce the matrix $C$ (4 rows $\times$ 4 columns).[^int-notation] 

[^int-notation]: Using proper mathematical notation, where $\mathbb{Z}$ is the set of all integers: $A \in \mathbb{Z}^{n \times d}, B \in \mathbb{Z}^{d \times m}, C \in \mathbb{Z}^{n \times m}$. In our example, $n = m = 4, d = 8$.

```{note} Matrix Multiplication details
Review [this section](#sec-dgemm) that describes the row-major order matrix multiplication benchmark in this section.
```

Assume that matrices $A$, $B$, and $C$ are stored in **row-major order** as `int A[]`, `int B[]`, and `int C[]`.

C code, for your reference:

<!-- :::{figure} images/matmul-row-major.png
:label: fig-matmul-row-major
:alt: "Matrix memory-layout illustration showing row-major storage order for A, B, and C matrices in memory. The top rectangle shows the wide Nx8 matrix with elements labeled 1 through 16. The bottom rectangle shows the Nx8 elements of the matrix laid out in contiguous space in memory where the matrix is stored."

Assume that all matrices are stored in **row-major order**.
:::
 -->
:::{embed} #code-igemm-simple
:::

## Architecture details

Suppose we run our C program on a 32-bit architecture that has a single-layer cache:

* 128B capacity
* fully associative
* 16B block size (so 8 blocks)
* LRU replacement policy
* Write-back write policy with dirty bit

For our matrix multiplication example, we will assume that on this architecture, `sizeof(int)` is `4`, so each block holds four `int`s.

## Approach 1: Naive DGEMM Memory Access Pattern

Assume the cache starts out cold.

Suppose we first compute $C_{00}$, which is the dot-product of the (zero-indexed) zero-th row of $A$ and the (zero-indexed) zero-th column of $B$.

<!-- ::::{figure}
:label: anim-matmul-00
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/caches-iii/pptx/matmul-00.pptx
:width: 100%
:title: "C[0][0] Memory Access Pattern"
:::
Computing $C_00$ as vector multiplication of the zero-th row of $A$ and the zero-th column of $B$. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
:::: -->

::::{figure}
:label: anim-matmul-00
:alt: "Embedded slides animating memory accesses while computing matrix element C zero zero from the zero-th row of A and zero-th column of B."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vTAFRr4VJ6o2brFhpjCS_edmdWM0j2cKViq6OjTX1XqDhRJWYa68FU07IyZw2oG6g/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through a C[0][0] Memory Access Pattern."
:::
Computing $C_{00}$ as vector multiplication of the zero-th row of $A$ and the zero-th column of $B$. Use the menu bar to trace through the animation or access the [original Google Slides](https://docs.google.com/presentation/d/1GJiXwZ8gGuZxLxSU5raiTPY_E0I4AQVU/edit?usp=sharing).
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

<!-- ::::{figure}
:label: anim-matmul-ij
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/caches-iii/pptx/matmul-00.pptx
:width: 100%
:title: "C[i][j] Memory Access Pattern"
:::
Computing $C_{ij}$ as vector multiplication of the i-th row of $A$ and the j-th column of $B$. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
:::: -->

::::{figure}
:label: anim-matmul-ij
:alt: "Embedded slides animating memory accesses while computing a general inner product C i j from row i of A and column j of B."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vRWBkNhA5huAtKWqxfxruNlEUAqXRxVDGHzjT88Ov3ZJnfrupfQsbNZHSyXOyS3SQ/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through a C[i][j] Memory Access Pattern."
:::
Computing $C_{ij}$ as vector multiplication of the i-th row of $A$ and the j-th column of $B$. Use the menu bar to trace through the animation or access the [original Google slides](https://docs.google.com/presentation/d/1AekxfV7tcsUA0CcpvY4J9jg1YvnWKMfZ/edit?usp=sharing).
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

In our matmul example, we know that `B` is stored in row-major-layout. To access a **column** of $B$ as is needed in matrix multiplication, we must load in all 8 rows of `B`.

From P&H 4.4 for square matrices (N-by-N):

> If the cache can hold one N-by-N matrix and one row of N, then at least the `i`th row of `A` and the entire matrix `B` may stay in the cache. Less than that and misses may occur for both `B` and `C`. In the worst case, there would be 2 N{sup}`3`+ N{sup}`2` memory words accesed for N{sup}`3` operations.

## Approach 2: Cache Blocking with Transpose

One observation is that it would be much better to load in just the 8 elements in the _column_ of `B`, and not elements in other columns needed for later matrix multiplications.

A cache blocking technique could **transpose** B before matrix multiplication. The transpose of $B$ is written as $B^T$ and is defined where $B^T_{jk} = B_{kj}$ for all indices $j$ and $k$, as shown in @fig-matmul-transpose.

:::{figure} images/matmul-transpose.png
:label: fig-matmul-transpose
:alt: "Matrix transpose diagram illustrating B transpose used to improve contiguous-memory access in multiplication. The left rectangle shows the original tall matrix B with column 1 highlighted, and elements 0 and 4 highlighted further. The right rectangle shows B transpose with the same elements highlighted, but now in their new transpose locations. An arrow between the two rectangles shows the ability to transform between B and B transpose."
:width: 60%

$B^T$ is the matrix transpose of $B$ 

:::

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

Transposing is quite slow; it also requires a N{sup}`2` overhead to complete and triggers the same types of cache misses as we observed in our original computation. We have simply moved our poor cache performance from matrix multiplication to another part of the program.

(sec-cache-blocking-tiling)=
## Approach 3: Cache Blocking with Submatrix Computation (Tiling)

Our second cache blocking approach observes that matrix multiplication can be computed piecewise. A **submatrix** (i.e.,  **tile**) of $C$ can be computed as the sum of multiplying different submatrices of $A$ and $B$.

@anim-matmul-block-2 illustrates cache blocking with a **blocking factor** or `BLOCKSIZE` of 2. We compute the 2x2 tile of $C$ with elements $C_{ij}$, where $i \in {0, 1}$ and $j \in {0, 1}$. This tile can be computed as four submatrix multiplications.

::::{figure}
:label: anim-matmul-block-2
:alt: "Embedded slides illustrating cache blocking with a two-by-two tile of C computed from smaller submatrix multiplications of A and B."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQU5B3-twc1_pBY024sp72KsxJ6O8tieO_QwOYPj4VgLt7--ONJ0BbG-Lj1CDwdoQ/pubembed?start=false&loop=false
:width: 100%
:title: "Slides illustrating cache blocking with a C[i][j] Memory Access Pattern."
:::
Cache blocking. Use the menu bar to trace through the animation or access the [original Google slides](https://docs.google.com/presentation/d/1HY9AE2z3eb1eWPx0VQvVusZ83caTvZ5s/edit?usp=drive_link&ouid=113745915748997113650&rtpof=true&sd=true).
::::

:::{note} Show Explanation
:class: dropdown

1. Multiply the first two elements in Rows 0 and 1 of A by the first two elements in Rows 0 and 1 of B. Store the four results in the target C tile.

    Cache contents[^not-lru]:
    * Row $0$ of A, first half
    * Row $1$ of A, first half
    * Row $0$ of B
    * Row $1$ of B
    * Row $0$ of C
    * Row $1$ of C

[^not-lru]: Not in LRU order for now. Marking this as TODO for future semesters.

1. Multiply the next two elements of A by the first two elements in Rows 2 and 3 of B. Add to the results in the target C tile.

    Cache contents[^not-lru]:
    * Row $0$ of A, first half
    * Row $1$ of A, first half
    * Row $0$ of B
    * Row $1$ of B
    * Row $0$ of C
    * Row $1$ of C
    * Row $2$ of B
    * Row $3$ of B

1. Multiply the next two elements of A by the first two elements in Rows 4 and 5 of B. Add to the results in the target C tile.

    Cache contents[^not-lru]:
    * Row $3$ of A, first half
    * Row $4$ of A, first half
    * Row $0$ of C
    * Row $1$ of C
    * Row $4$ of B
    * Row $5$ of B

1. Multiply the last two elements of A by the first two elements in Rows 6 and 7 of B. Add to the results in the target C tile.

    Cache contents[^not-lru]:
    * Row $3$ of A, first half
    * Row $4$ of A, first half
    * Row $0$ of C
    * Row $1$ of C
    * Row $6$ of B
    * Row $7$ of B

:::

## Performance Analysis

See the following two sections:

* [Approach 1](#sec-dgemm-sisd): Naive DGEMM
* [Approach 2](#sec-dgemm-sisd): DGEMM Transpose
* [Approach 3](#sec-dgemm-simd): DGEMM Tiled (with SIMD)

A tiled approach to matrix multiplication is much more efficient when we can leverage parallelism in hardware.

## Summary: Cache Blocking

Note that cache blocking may still replace rows of $B$ that will be needed later; it does not avoid all capacity misses. However, it reduces the **total number of memory accesses**, thereby reducing the total number of compulsory misses.

From P&H 4.4 for square matrices (N-by-N):

> Looking only at capacity misses, the total number of memory words accessed is 2 N{sup}`3`/`BLOCKSIZE` + N{sup}`2`. This total is an improvement by about a factor of `BLOCKSIZE`.

Blocking exploits a combination of spatial and temporal locality:

* $A$ benefits from spatial locality
* $B$ benefits from temporal locality
* $C$ benefits from spatial locality (more results of $C$ are computed for the same memory accesses to $A$ and $B$).
