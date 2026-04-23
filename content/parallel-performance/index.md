---
title: "Amdahl's Law"
---

(sec-amdahls-law)=
## Learning Outcomes

* Use Amdahl's Law to quantify the speedup to program execution time, given a specific optimization.
* Use Amdahl's Law to explain the limitations of infinite parallelization and the inherent bottleneck of non-parallel components.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/QS9b7UDSXr4
:width: 100%
:title: "[CS61C FA20] Lecture 36.1 - Amdahl's Law"
:::

::::

## Why parallelism?

To make a better computer and to run our applications faster, we have spent a good portion of time trying to understand the principles behind building a better computer. We have seen pipelining as a way to increase performance by working on multiple instructions at the same time in the pipeline.

Pipelining was the primary way people tried to increase processor performance from the 90s up to the early 2000s, where we kept building deeper and deeper pipelines and simultaneously used that to crank up the clock frequencies. However, as every processor generation came out, the power requirements kept shooting up—unsustainable, really (@fig-power-density-pred). Eventually, Moore's Law also tapered off.

:::{figure} images/power-density-prediction.png
:label: fig-power-density-pred
:width: 80%
:alt: "Projected power-density-over-time trend chart from multicore-era analysis spanning 1970 through 2010. The plot includes labeled comparisons to other thermal references, including a hot plate, a nuclear reactor rocket nozzle, and the surface of the sun."

Power-Density prediction plot. Source: S. Borkar, Intel, circa 2000.
:::

:::{embed} #fig-great-idea-2
:::

To stay under reasonable power limits, people explored using **parallelism in software and in hardware.** Nowadays, almost all high-programs exploit parallelism in some way.

:::{warning} Amdahl's "Heartbreaking" Law

Before proceeding further, we note that **parallel processing programs** have been _much harder to develop_ than sequential programs. **Sequential programs** are simpler and easier to develop, so we _must_ get better performance or better energy efficiency from pursuing a parallel alternative.

In this section we introduce Amdahl's "heartbreaking" law that once again evaluates program execution time—this time, the _improvement_ in execution time given an optimization (i.e., program "improvement" or "enhancement").
:::

## Amdahl's Law

A common pitfall when programmers first start pursuing performance (P&H 1.11):

> Pitfall: Expecting the improvement of one aspect of a computer to increase overall performance by an amount proportional to the size of the improvement.

It reminds us that the opportunity for improvement is affected by how much _fraction of time_ the improved event consumes. 

**Amdahl's Law** is the following straightforward Equation @eq-amdahl-01:

```{math}
:label: eq-amdahl-01
:enumerated: true

\text{Exec. time with improvement} = \frac{\text{Exec. time affected by improvement}}{\text{Amount of improvement}} + \text{Exec. time not affected}
```

We rewrite Amdahl's Law as Equation @eq-amdahl-02 to capture the **speedup** of a given program improvement, enhancement, or optimization:

```{math}
:label: eq-amdahl-02
:enumerated: true

\text{Speedup with enhancement} &= \frac{\text{Exec. time before enhancement}}{\text{Exec. time after enhancement}} \\
```

Finally, we rewrite in terms of the proportion of the program that is optimized/affected by the improvement $\text{frac}_{\text{optimized}}$ and the speedup factor to this component of the program $\text{factor}_{\text{improvement}}$ to produce Equation @eq-amdahl-03:

```{math}
:label: eq-amdahl-03
:enumerated: true

\text{Speedup with enhancement} &= \dfrac{1}{\left(1 - \text{frac}_{\text{optimized}}\right) + \dfrac{\text{frac}_{\text{optimized}}}{\text{factor}_{\text{improvement}}}}
```

Amdahl's Law tells us that overall improvement to program execution time is not linear.

## Amdahl's Law: Examples

The execution time of a third of a program can be accelerated by a factor of 2, due to some enhancement (e.g., multithreading and multicore).

:::{figure} images/amdahl-ex01.png
:label: fig-amdahl-ex01
:width: 90%
:alt: "Two rectangles compare program execution time with and without enhancement using Amdahl's Law. In the top rectangle, one-third of the original program is highlighted as the fraction that can be optimized with parallel programming. In the bottom rectangle, that portion is shown with a two-times speedup, resulting in a shorter total execution time."

The execution time of a third of a program can be accelerated by a factor of 2 due to some enhancement.
:::

The overall program speedup due to this enhancement can be computed using Amdahl's Law (Equation @eq-amdahl-03). Here, $\text{frac}_{\text{optimized}} = 1/3$ and $\text{factor}_{\text{improvement}} = 2$.

```{math}
\text{speedup} &= \dfrac{1}{2/3 + \frac{1/3}{2}} \\
&= 1.2
```

Because parallelism is another type of program optimization, performance gains _due to_ parallelism are limited by the ratio of software processing that must be executed sequentially. We illustrate this limitation below.

(sec-amdahl-quick-check)=
::::{tip} Quick Check

Suppose we had 128 processors that can improve the parallelizable component of any program by a factor of 128.
If we are looking to write a program that gets a **10x speedup** from this parallel architecture, what fraction S of the program can be sequential?

:::{figure} images/amdahl-ex02.png
:label: fig-amdahl-ex02
:width: 90%
:alt: "Amdahl's Law equation showing speedup with enhancement as the inverse of the sum of the serial fraction and the parallel fraction divided by the improvement factor. The equation expresses total program speedup given a parallelizable fraction and a specified parallel speedup."

Assuming a program can be optimized with parallelism, the sequential fraction of program is $s = (1 - \text{fract}_{\text{optimized}})$.
:::

* **A.** 50%
* **B.** 15%
* **C.** 10%
* **D.** 9%
* **E.** Something else
::::

:::{note} Show Answer
:class: dropdown

**D.** 9%.

One approach is to plug in choices until we exceed the desired 10x speedup with enhancement. We discuss this further [below](#sec-amdahl-quick-check-sol-02)

:::

## Parallelism: Theoretical limitations

Applications can almost **never** be completely parallelized; some code will always remain that must be executed sequentially.

As an analogy, consider @fig-parallel-analogy, where we collaborate with an infinitely large set of classmates to write a project report. In parallel, each classmate can do research and update a shared document, thanks to cloud technologies. However, even as the set of classmates approaches infinity, some fraction of the project will inevitably need to run sequentially before and after the large bulk of parallelization, e.g., to coordinate the parallel work itself, or to check for consistencies and print the report. These sequential parts may also increase and eventually outweigh any performance gains in parallelization.

:::{figure} images/parallel-analogy.png
:label: fig-parallel-analogy
:alt: "Process-flow analogy for Amdahl’s limits: a single sequential prelude box leads to three parallel swimlanes where different workers fetch or update files simultaneously, each lane labeled with a distinct employee name; curved arrows show concurrent progress. The three lanes reconverge into a final sequential box representing reporting or integration work that cannot overlap, underscoring that parallel segments still leave serial bookends."

Reasonable assumption: Even with parallelization, some fraction of a program will need to run sequentially, e.g., to coordinate the parallel work itself.
:::

In the simplest case, assume the parallelization speedup due to $P$ processors is $\text{factor}_{\text{improvement}} = P$. If we let $s$ be the sequential fraction of our program, then the eventual speedup is limited by $s$:

```{math}
\text{Speedup}(P) &= \frac{\text{Original program time}}{\text{Parallelized program time}} \\
&= \frac{1}{s + \dfrac{1 - s}{P}} \\
&\rightarrow \dfrac{1}{s} \text{ as } P \rightarrow \infty 
```

In a perfect world, as the speedup factor $P$ goes to infinity—if you have a million or a trillion processors—the speedup can still be no bigger than  than 1/s, determined by the sequential portion.[^energy]
This theoretical limit is illustrated in @fig-amdahl-plot.

[^energy]: Energy would also be a HUGE limitation here...!
:::{figure} images/amdahl-plot.png
:label: fig-amdahl-plot
:width: 90%
:alt: "Amdahl’s Law plot of achievable speedup versus processor count for different serial fractions. The plot shows the trend line for programs with 50% parallel portion, 75% parallel portion, 90% parallel portion, and 95% parallel portion."

Plot of Amdahl’s Law: Speedup vs. Number of Processors.
:::

(sec-amdahl-quick-check-sol-02)=
::::{note} Show Answer to [Quick Check](#sec-amdahl-quick-check), continued
:class: dropdown

If we take a vertical line at 128 processors, we see that a 90% parallelizable program (e.g., 10% sequential) achieves less than a 10x speedup, whereas a 95% parallelizable program (e.g., 5% sequential) achieves more than a 16x speedup.

:::{figure} images/amdahl-plot-annotated.png
:label: fig-amdahl-plot-annotated
:width: 75%
:alt: "Annotated Amdahl speedup vs. number of processors plot highlighting that all trend lines begin to reach a steady state asymptotic limit in speedup from non-parallelizable program portions once they reach 128 processors."

Consider the speedup described in the [Quick Check](#sec-amdahl-quick-check).
:::

Option **D** (9% sequential, or 91% parallel) is something in-between.

::::

At the end of the day, parallelism in hardware does not solve everything. We will need to choose, design, and write software tasks that actually leverage the parallelism available in our architecture. Onto the next section!

<!-- Other exercises

Consider an enhancement which runs 20 times faster but which is only usable
25% of the time
Speedup w/ E = 1/(.75 + .25/20) = 1.31
What if its usable only 15% of the time?
Speedup w/ E = 1/(.85 + .15/20) = 1.17

Amdahl’s Law tells us that to achieve linear speedup with 100 processors, none of the original computation can be scalar!
To get a speedup of 90 from 100 processors, the percentage of the original program that could be scalar would have to be 0.1% or less
Speedup w/ E = 1/(.001 + .999/100) = 90.99 -->
