---
title: "DGEMM: MIMD with OpenMP"
---

(sec-dgemm-mimd)=
## Learning Outcomes

* Compare threaded matrix multiplication with sequential programs.
* Compare performance using different `gcc` optimization flags: `-O0`, `-O2`, `-O3`.

This section is the final and largest step in our incremental performance journey of adapting DGEMM to the underlying hardware of our course hive machines. we use OpenMP to write threaded code that can utilize multiple cores.

Before continuing, we recommend reviewing:

* [DGEMM benchmark](#sec-dgemm-benchmark)
* [Performance optimizations](#sec-dgemm-sisd) on a sequential program
* [DGEMM on a SIMD architecture](#sec-dgemm-simd)

:::{embed} #fig-dgemm
:::

(sec-dgemm-benchmark-mimd)=
:::{hint} DGEMM Benchmark with MIMD

Updated benchmark:

* GCC: no optimization (flag `-O0`) unless otherwise stated
* Matrix dimensions: 512 by 512 (the precise matrices may vary by program)
* Timing library: `<openmp.h>` (not `<time.h>`)
* Machine: Course hive machines (6-core, 12 hardware threads)
* Intel SIMD extension: AVX (256-bit-wide registers packing **four** double-precision floating point values)

See lecture for example benchmark code. The benchmark will be hosted on the course notes in a future semester.
:::

**Timing** With non-threaded programs, we used the C standard library `<time.h>` to measure program time. However, on Linux, `clock()` measures CPU time across all threads, which will lead to an overall **over**-estimate. In the programs below, we will use `omp_get_wtime()` to get the **wall time** from the main thread; this time will be consistent within the main thread but not across threads. Read more on the [OpenMP docs.](https://www.openmp.org/spec-html/5.0/openmpsu160.html).

::::{tab-set}
:::{tab-item} OpenMP Timing
```{code} c
:label: code-openmp-timing
#include <omp.h>
int main() {
  ...

  clock_t start = omp_get_wtime();
  matrix_d_t* C = dgemm(A, B); // threaded
  clock_t end = omp_get_wtime();

  // execution time in seconds
  double delta_time = (double) (end - start)/CLOCKS_PER_SEC;
  ...
}
```
:::
:::{tab-item} <time.h> Timing
```{embed} #code-time-h
```
:::
::::

## DGEMM 11: OpenMP DGEMM

In the [below code](#code-dgemm-openmp), line 5 is the single insertion that makes this code run on multiple processors. Line 5, `#pragma omp parallel for`, is an OpenMP pragma  that tells the compiler to use multiple threads in the outermost loop. The resulting compiled program spreads the work of the outermost loop across the 12 threads on the course hive machines. For a 512 x 512 matrix multiplication, each thread then processes about 42 iterations of the loop.

::::{tab-set}
:::{tab-item} DGEMM, MIMD
```{code} c
:linenos:
:label: code-dgemm-openmp
:linenos:

matrix_d_t *dgemm_openmp(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols != B->nrows) return NULL;
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);

  #pragma omp parallel for
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
:::{tab-item} DGEMM (original)
```{embed} #code-dgemm
```
:::
::::

Even with no `gcc` compiler optimizations, our threaded OpenMP DGEMM is now _blazingly_ fast compared to all optimizations we tried earlier _and even compared to NumPy_:

```bash
C                  0.768672 seconds
python NumPy:      0.000964 seconds
registers:         0.277462 seconds
simd,naive:        0.416584 seconds
openmp:            0.0000001401 seconds
```

## DGEMM 12: OpenMP Tiled SIMD DGEMM

This is our final program optimization. Recall what we said [earlier](#sec-flynns-taxonomy):

:::{embed} #sec-spmd
:::

The [below code](#code-dgemm-openmp-simd-tile) combines our core optimizations:

* Use Intel Intrinsics to leverage SIMD for floating point operations.
* Use cache blocking to tile computation of multiple elements of C simultaneously.
* Use OpenMP to spread the outermost loop across all threads.

::::{tab-set}
:::{tab-item} DGEMM, OpenMP Tiled SIMD
```{code} c
:linenos:
:label: code-dgemm-openmp-simd-tile
:linenos:

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
matrix_d_t *dgemm_openmp_simd_block(matrix_d_t *A, matrix_d_t *B) {
  if (A->ncols!=B->nrows) return NULL;
  matrix_d_t *C = init_mat_d(A->nrows, B->ncols);
  #pragma omp parallel for
  for (int sj = 0; sj < B->ncols; sj += BLOCKSIZE) {
      for (int si = 0; si < A->nrows; si += BLOCKSIZE) {
            for (int sk = 0; sk < A->ncols; sk+= BLOCKSIZE) {
                matmul_simd_tile(si, sj, sk, A, B, C);
            }
    }
  }
  return C;
}

```
:::
:::{tab-item} DGEMM Tiled SIMD
```{embed} #code-dgemm-simd-tile
```
:::
:::{tab-item} AVX intrinsics
```{embed} #code-dgemm-avx
```
::::

Combining Intel SIMD Intrinsics and OpenMP gives us our fastest matrix multiplication yet:

```bash
C                  0.768672 seconds
python NumPy:      0.000964 seconds
registers:         0.277462 seconds
simd,naive:        0.416584 seconds
openmp:            0.0000001401 seconds
openmp,simd,tiled: 0.0000000686 seconds
```

## DGEMM 13: GCC Optimizations

Again, let's compile using different `gcc` optimization flags in @tab-dgemm-gcc-mimd. The threaded versions win, every time.

:::{list-table} Threaded DGEMM runtime (in seconds) with different optimization flags.
:header-rows: 1
:label: tab-dgemm-gcc-mimd

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
* - [DGEMM, naive SIMD](#code-dgemm-simd-naive)
  - 0.416584
  - 0.048405
  - 0.049970
  - 0.049045
* - [DGEMM tile SIMD](#code-dgemm-simd-tile)
  - 0.356344
  - 0.033386
  - 0.035177
  - 0.037030
* - [DGEMM, threaded](#code-dgemm-openmp)
  - 0.0000001401
  - 0.0000000347
  - 0.0000000456
  - 0.0000000467
* - [DGEMM, threaded, tile SIMD](#code-dgemm-openmp-simd-tile)
  - 0.0000000686
  - 0.0000000124
  - 0.0000000131
  - 0.0000000131
:::