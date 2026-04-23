---
title: "Cache Misses"
---

(sec-cache-misses)=
## Learning Outcomes

* Define the three types of cache misses: compulsory miss, capacity miss, and conflict miss.
* Explain how conflict miss helps evaluate our cache associativity.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/DiH8xtQeCJA
:width: 100%
:title: "[CS61C FA20] Lecture 26.2 - Caches III: Writes, Block Sizes, Misses"
:::

::::

The classical approach to improving cache behavior is to reduce **miss rates**.

To gain better insights into the causes of misses, we first categorize misses into three categories:

* **Compulsory Miss**: Caused by the first access to a line that has never been in the cache. The very first access to a block _cannot_ be in the cache, so the block must be brought in. Also called cold-start misses or first-reference misses.
* **Capacity Miss**: Caused when the cache cannot contain all the lines needed during the execution of a program. Occur when lines were in the cache, replaced, and later retrieved.
* **Conflict Miss**: Multiple lines compete for the same location in the cache, even when the cache has not reached full capacity. These misses are also called _collision_ misses.

## Categorizing Misses

To categorize misses, we can first run an address trace against a set of caches, then perform the following steps[^thanks-kubi]:

1. First, consider an infinite-size, fully-associative cache. For every miss that occurs now, consider it a **compulsory miss**.

1. Next, consider a finite-sized cache (of the size you want to examine) with full-associativity. Every miss that is not in #1 is a **capacity miss**.

1. Finally, consider a finite-size cache with finite-associativity. All of the remaining misses that are not #1 or #2 are **conflict misses**.

    Conflict misses occur only with **set-associative** or **direct-mapped** caches. Conflict misses are those that occur going from fully associative to, say, 8-way associative, 4-way associative, and so on.

[^thanks-kubi]: Thanks Professor Kubiatowicz for this algorithm.

:::{warning} Non-compulsory misses

In this class, we will only distinguish between compulsory and non-compulsory misses. **Non-compulsory misses** are defined as misses that are not compulsory, i.e., **capacity miss** or **conflict miss**.

You are still required to know the definition of capacity/conflict misses, but you will not be required to classify any specific non-compulsory miss into one of these two subcategories. We will see the nuances of why at the end of this section.

:::

:::{hint} Quick Check 1

Which of the three miss types can occur with fully associative caches?
:::

:::{note} Show Answer
:class: dropdown

* Compulsory misses
* Capacity misses
:::

:::{hint} Quick Check 2

Which of the three miss types can occur with direct-mapped caches?
:::

:::{note} Show Answer
:class: dropdown

* Compulsory misses
* Capacity misses
* Conflict misses

:::

A slightly more precise definition of **conflict misses** is therefore:

> Misses that would not occur if the cache was fully-associative and had LRU replacement, (with all other noncompulsory misses being capacity).

[^wrl]: Norman P. Jouppi. "WRL Technical Note TN-53: Reducing Compulsory and Capacity Misses." August 1990. [Source](https://bitsavers.org/pdf/dec/tech_reports/WRL-TN-53.pdf)

We will see in the next section that this definition does not precisely hold water for specific memory accesses, but it is sufficient to categorize conflict miss _rates_ in general.

## Conflict misses, in detail

This section is useful if you are still confused about the difference between the two non-compulsory misses: capacity misses and conflict misses. However, the precise details of the example are out of scope.

### Example

Let's compare the hit patterns of a few cache types.
The below diagram shows the hit/miss pattern of various caches when run on a [Matrix Multiply](#sec-cache-blocking) Example.

1. FA 1M (Fully Associative, 1 million blocks. This is our "infinite" cache with as many hits as possible)
1. FA 4 blocks (Fully Associative)
1. 2SA 4 blocks (Set Associative)
1. DM 4 blocks (Direct Mapped)

@fig-cache-pedantic-misses illustrates each memory access as columns going from left to right. Each column is a hit or a miss in each of the four caches.

:::{figure} images/cache-pedantic-misses.png
:label: fig-cache-pedantic-misses
:alt: "Cache-access sequence graphic marking misses in red and hits in white to contrast miss categories for fully associative cache with 1M blocks, fully associative cache with 4 blocks, 2-way-set-associative cache with 4 blocks, and direct mapped cache with 4 blocks."

Cache misses are in red, and cache hits are transparent (in white).
:::

As we go through each of the three cache misses by definition, we realize there is a "fourth" category of misses that we have not covered. See the animation below.

::::{figure}
:label: anim-cache-pedantic-misses
:alt: "Embedded slides walking through conflict misses and equivalent fully associative versus lower-associativity cache behavior for the pedantic example in this section."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vR259Lvwi0mq_JUcQbeLD7oLLF-ZvFn1PBihG3YMV09mwtIhw0U08XBnmQXHDced7-vGWrc9RTXOc8B/pubembed?start=false&loop=false
:width: 100%
:title: "Slides walking through conflict misses for cache in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1nL8eIuc16BVBKdSvs-z3B5huPgI5AHZy3s6wT7nfu4A/edit?usp=sharing)"
:::
::::

Our current definition of conflict misses assumes that all misses in equivalent FA cache also cause misses in lower associativities. As we see in our example, sometimes we get "conflict hits" because a block that would have been replaced ends up staying in the cache longer. This behavior depends on the chosen replacement policy and the precise ordering of memory accesses.

### In practice: Conflict miss rates

In practice, computer architects **do not** look at every single instruction to analyze the type of miss. This is expensive and seems unnecessary. Rather, memory access performance is analyzed as aggregate **miss rates** against program benchmarks.

Define the **conflict miss rate** as the total measured miss rate, minus the miss rate due to compulsory misses, minus the fully associative LRU non-compulsory miss rate.

This is the definition that most benchmarkers use for several reasons:

* It is easy to calculate.
* The definition hinges not on the misses of any given memory access, but rather the aggregate misses incurred on our program benchmark across different cache designs.
* This definition truly characterizes what we care about: **how associativity impacts cache performance** via cache misses: not a miss because of cold caches, neither a miss because we maxed out associativity.

For some examples, see our section on [cache optimizations](#sec-cache-optimizations).

### Possible redefinition

This section is out of scope. If we truly wanted to be precise about misses, we _could_ discuss a second definition of conflict misses by memory access:

Define a conflict miss as a miss that would not have happened if the cache was fully associative under at least one "consistent" replacement policy. Define a "consistent" replacement policy as one that keeps all the data in the lower-associativity cache, i.e., any replacement policy such that the data in the fully associative cache is a superset of the data in our target cache. This definition guarantees that we don't have "conflict hits", but also tends to classify misses more as capacity misses than as conflict misses. 

In practice, this second definition is not used. Again, in performance we care more about **average** runtime and **overall** categories of misses. So the first definition is the one you should take away should you strive to evaluate memory access performance.
