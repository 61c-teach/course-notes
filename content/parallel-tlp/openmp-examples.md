---
title: "OpenMP Examples"
---

## Example 1: Arrays

:::{card}
OpenMP C program: `for.c`
^^^

```{code} c
:linenos:
#include <stdio.h>
#include <omp.h>
int main() {
  omp_set_num_threads(4);
  int a[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  const int N = sizeof(a)/sizeof(int);

  #pragma omp parallel for
  for (int i = 0; i < N; i++) {
    printf("thread %d, i = %2d\n", omp_get_thread_num(), i);
    a[i] = a[i] + 10 * omp_get_thread_num();
  }

  for (int i = 0; i < N; i++) {
    printf("%02d ", a[i]);
  }
  printf("\n");
  return 0;
}
```

:::

Output:

```{code} bash
$ gcc -fopenmp -o for for.c
$ ./for
thread 0, i =  0
thread 1, i =  3
thread 2, i =  6
thread 3, i =  8
thread 0, i =  1
thread 1, i =  4
thread 2, i =  7
thread 3, i =  9
thread 0, i =  2
thread 1, i =  5
00 01 02 13 14 15 26 27 38 39 
```

## Example 2: Computing $\pi$

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/bqdaOK9mHeU
:width: 100%
:title: "[CS61C FA20] Lecture 34.3 - Thread-Level Parallelism II: Computing Pi"
:::

::::

We can compute $\pi$ with numerical integration[^compute-pi]:

$$\pi = \int_0^1 \frac{4.0}{1+x^2} dx$$

[^compute-pi]: Review calculus (e.g., [wikipedia](https://en.wikipedia.org/wiki/Pi)), or trust me. Briefly: a unit circle satisfies the Cartesian coordinate equation $x^2 + y^2 = 1$. The arc length of the top-half of the circle is $\pi = \int_{-1}^1 \frac{dx}{\sqrt{1 - x^2}}$. Use calculus rules to get $\pi = \int_0^1 \frac{4}{1+x^2} dx$.

We can use Riemann's sum to approximate the integral as a sum of $N$ rectangles:

$$\pi \approx \sum_{i=0}^N F(x_i) \Delta x,$$

where the $i$-th rectangle has width $\Delta x$ and height $F(x_i) = \frac{4}{1+x^2}$ at the middle of interval $i$.

::::{figure}
:label: fig-openmp-pi
:alt: "Embedded slides with diagrams for estimating pi via numerical integration and corresponding OpenMP parallel loop structure discussed in this section."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQj4u8ExC2O8m288BGtkBQzM8SE0bj8TQDCTo9a06ZGIZ-fFBP2y4CDS9Ih_3U0hw/pubembed?start=false&loop=false
:width: 100%
:title: "Slides associated with the code in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1XyhToa61fNXXBWOOerjT5AgiJs_-iLQI/edit?usp=sharing&ouid=113745915748997113650&rtpof=true&sd=true)"
:::

Slides version of the code below, with some additional diagrams.
::::


:::::{tab-set}
::::{tab-item} Sequential Pi
```{code} c
#include <stdio.h>

int main(void) {
  const long num_steps = 10;
  double sum = 0.0;
  for (int i = 0; i < num_steps; i++) {
    double x = (i + 0.5) * step;
    sum += 4.0 * step/(1.0 + x*x);
  }
  printf("pi = %6.12f\n", sum);

  return 0;
}
```

Output:

```{code} bash
pi = 3.142425985001
```

Resembles $\pi$, but not very accurate. Let’s increase `num_steps` and parallelize.
::::
:::{tab-item} Parallelize 1
```{code} c
#include <stdio.h>
#include <omp.h>

int main(void) {
  const long num_steps = 10;
  double sum = 0.0;
  #pragma parallel for
  for (int i = 0; i < num_steps; i++) {
    double x = (i + 0.5) * step;
    sum += 4.0 * step/(1.0 + x*x);
  }
  printf("pi = %6.12f\n", sum);

  return 0;
}
```

Problem: Each thread needs access to the shared variable `sum`. Code runs sequentially!
:::

:::{tab-item} Parallelize 2
Compute a `sum` array, chunked into components of the Riemann's Sum. Then, add up the elements of the `sum` array.

```{code} c
#include <stdio.h>
#include <omp.h>

int main(void) {
  const int NUM_THREADS = 4;
  omp_set_num_threads(NUM_THREADS);

  double sum[NUM_THREADS];
  for (int tid = 0; tid < NUM_THREADS; tid++) {
    sum[tid] = 0;
  }

  const long num_steps = 10;
  double step = 1.0/((double) num_steps);
  #pragma omp parallel
  {
    int tid = omp_get_thread_num();
    for (int i = tid; i < num_steps; i+= NUM_THREADS) {
      double x = (i + 0.5) * step;
      sum[tid] += 4.0 * step/(1.0 + x*x);
      printf("i = %3d, tid = %3d\n", i, tid);
    }
  }

  double pi = 0;
  for (int tid = 0; tid < NUM_THREADS; tid++) {
    pi += sum[tid];
  }
  printf("pi = %6.12f\n", pi);

  return 0;
}
```

Output:

```{code} bash
$ ./pi
i =  1,  id =  1
i =  0,  id =  0
i =  2,  id =  2
i =  3,  id =  3
i =  5,  id =  1
i =  4,  id =  0
i =  6,  id =  2
i =  7,  id =  3
i =  9,  id =  1
i =  8,  id =  0
pi = 3.142425985001
```
:::

:::{tab-item} Parallelize 3: Scale Up

Scale up: `num_steps =` = 10{sup}`6`

```{code} c
#include <stdio.h>
#include <omp.h>

int main(void) {
  const int NUM_THREADS = 4;
  omp_set_num_threads(NUM_THREADS);

  double sum[NUM_THREADS];
  for (int tid = 0; tid < NUM_THREADS; tid++) {
    sum[tid] = 0;
  }

  const long num_steps = 1000000;
  double step = 1.0/((double) num_steps);
  #pragma omp parallel
  {
    int tid = omp_get_thread_num();
    for (int i = tid; i < num_steps; i+= NUM_THREADS) {
      double x = (i + 0.5) * step;
      sum[tid] += 4.0 * step/(1.0 + x*x);
      // printf("i = %3d, tid = %3d\n", i, tid);
    }
  }

  double pi = 0;
  for (int tid = 0; tid < NUM_THREADS; tid++) {
    pi += sum[tid];
  }
  printf("pi = %6.12f\n", pi);

  return 0;
}
```

Output:

```{code} bash
$ ./pi
pi = 3.141592653590
```

Verify how many digits are correct!
:::
:::::
<!-- tab-set -->

This example is adapted from the OpenMP "Hands On Tutorial" from SC08.[^openmp-sc08] View the original [slides PDF](https://www.openmp.org/wp-content/uploads/omp-hands-on-SC08.pdf).
[^openmp-sc08]: Tim Mattson and Larry Meadows, SC08 OpenMP "Hands On Tutorial." 2008. [Access on OpenMP website](https://www.openmp.org/uncategorized/sc08-openmp-hands-on-tutorial-available/)

(sec-openmp-for-ex)=
## Example 3: More on the `for` Directive

This section expands on the OpenMP directive `for` described in an [earlier section](#sec-openmp-for). Consider the below program, which uses a loop to assign elements of a giant heap-allocated array:

```{code} c
#define LENGTH (1 << 27)
int main(void) {
  char *arr = malloc(sizeof(char) * LENGTH);
  for (int i = 0; i < LENGTH; i++) {
      arr[i] = ...;
  }
}
```

Toggle between the cards below to compare different parallelizations of this program. Asssume that `OMP_NUM_THREADS` on this

:::::{tab-set}
::::{tab-item} Code 1
:sync: tab-openmp-for-1
```{code} c
#define LENGTH (1 << 27)
int main(void) {
  char *arr = malloc(sizeof(char) * LENGTH);
  #pragma omp parallel
  {
    for(int i = 0; i < LENGTH; i++) {
      arr[i] = ...;
    }
  }
}
```
::::

::::{tab-item} Code 2
:sync: tab-openmp-for-2
```{code} c
#define LENGTH (1 << 27)
int main(void) {
  char *arr = malloc(sizeof(char) * LENGTH);
  #pragma omp parallel
  {
    int tid = omp_get_thread_num();
    int num_threads = omp_get_num_threads();
    for(int i = tid; i < LENGTH; i+= num_threads) {
      arr[i] = j;
    }
  }
}
```
::::

::::{tab-item} Code 3
:sync: tab-openmp-for-3
```{code} c
#define LENGTH (1 << 27)
int main(void) {
  char *arr = malloc(sizeof(char) * LENGTH);
  #pragma omp parallel
  {
    int tid = omp_get_thread_num();
    int num_threads = omp_get_num_threads();
    int thread_start = tid * LENGTH / num_threads;
    int thread_end = (tid+1)*LENGTH / num_threads;
    for(int i = thread_start; i < thread_end; i++) {
      arr[i] = j;
    }
  }
}
```
::::

::::{tab-item} Code 4
:sync: tab-openmp-for-4
```{code} c
#define LENGTH (1 << 27)
int main(void) {
  char *arr = malloc(sizeof(char) * LENGTH);
  #pragma omp parallel
  {
    #pragma omp for
    for(int i = 0; i < LENGTH; i++) {
      arr[i] = j;
    }
  }
}
```
::::

::::{tab-item} Code 5
:sync: tab-openmp-for-5
```{code} c
#define LENGTH (1 << 27)
int main(void) {
  char *arr = malloc(sizeof(char) * LENGTH);
  #pragma omp parallel for
  for(int i = 0; i < LENGTH; i++) {
    arr[i] = j;
  }
}
```
::::
:::::
<!-- tab-set-->

<!-- GOT TO HERE

make two different tab sets, which are synced-->

:::::{tab-set}
::::{tab-item} Explanation 1
:sync: tab-openmp-for-1
Duplicates work. The for-loop is repeated 12 times, so each array element is assigned 12 times.
::::

::::{tab-item} Explanation 2
:sync: tab-openmp-for-2
"Interweaves" array access between threads. If there are 12 OpenMP threads, then thread 0 accesses elements 0, 12, 24, etc.; thread 1 accesses elements 1, 13, 25, etc. Potentially wasteful memory access pattern.
::::

::::{tab-item} Explanation 3
:sync: tab-openmp-for-3
"Chunks" array sections by thread. If there are 12 OpenMP threads, then thread 0 accesses elements 0 through `LENGTH/12 - 1`; thread 1 elements elements `LENGTH/12` through element `2*LENGTH/12`, etc. Same as Code 4 and Code 5.
::::

::::{tab-item} Explanation 4
:sync: tab-openmp-for-4

Same as Code 3 and Code 5. Here, the `#pragma omp for` directive specifies loop work-sharing, which is then planned via OpenMP.
::::


::::{tab-item} Explanation 5
:sync: tab-openmp-for-5

Same as Code 3 and Code 4. Like Code 4, the loop work-sharing is planned via OpenMP, though the code is more readable because of the combined directive `#pragma omp parallel for`.
::::

:::::
<!-- tab-set-->