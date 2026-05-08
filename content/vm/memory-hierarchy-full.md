---
title: "Putting It All Together"
---

(sec-pipt)=
## Learning Outcomes

* Compare and contrast the terminology of caches and virtual memory.
* Trace the steps of memory hierarchy access when we assume physically indexed, physically tagged caches.
* Use AMAT to motivate why designing systems for extremely low page fault rate is so performance-critical.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/TO_oTALe3KM
:width: 100%
:title: "[CS61C FA20] Lecture 30.4 - Virtual Memory II: VM Performance"
:::

::::

We are finally, _finally_ ready to consider access to the full memory hierarchy. How does this memory hierarchy improve performance?

:::{figure} images/memory-hierarchy-full.png
:label: fig-memory-hierarchy-full

The full memory hierarchy. Now, we consider access to memory caches, main memory (primary storage), and disk (secondary storage).
:::

## Virtual Memory and Caches

Virtual memory and caches are tricky to work with together because they do not use the same terminology, nor are they implemented similarly. Virtual memory was a historic concept created out of the limitations of tiny memory; the concept came before caches, which were built to make performance fast. Nevertheless, they are both layers in the memory hierarchy.

To compare virtual memory to caches, let us consider a horizontal view of the memory hierarchy shown in @fig-memory-hierarchy-horizontal.

:::{figure} images/memory-hierarchy-horizontal.png
:label: fig-memory-hierarchy-horizontal

Layers of the hierarchy on the left are closer to the CPU and access is faster; as we move right, modules get further from the CPU and access is much slower.
:::

**Terminology: Memory units**. Blocks, pages, words, bytes are all units in the memory hierarchy.  In @fig-memory-hierarchy-horizontal above:

* **Caches** copy _blocks_ (or lines) from main memory. On [modern systems](#block-cache-size), blocks are 64B or 128B.
* **Memory** is organized into _pages_. These pages are copied from disk. On [modern](#code-hive-memory) [systems](#code-m4-memory), pages are 4-16 KiB.

**Copies of data**. Remember what we learned when we first explored other layers of the memory hierarchy in a [previous section](#sec-memory-hierarchy-copy):

```{embed} #sec-memory-hierarchy-copy
```

* **Caches** are a quick-access copy of data in main memory.
* **Main memory** is a "quick"-access copy of data on disk.
* In @fig-memory-hierarchy-copy, 

:::{figure} images/memory-hierarchy-copy.png
:label: fig-memory-hierarchy-copy

The 🙂 data in the L1 cache is also available in a block of the L2 cache, on a physical page of main memory, and on a disk page.
:::

Recall from an [earlier section](#sec-page-table), page tables **do not have data**; they help translate addresses and facilitate [demand paging](#sec-demand-paging). 

:::{figure} images/memory-hierarchy-pt.png
:label: fig-memory-hierarchy-pt

With demand paging, pages on disk are loaded into memory only when needed by the process. The location of each page is tracked by status bits the page table—here, the valid bit in each page table entry, combined with the physical page number (if the valid bit is set).
:::

The full comparison of these two parts of the memory hierarchy is in @tab-vm-vs-caches.

:::{table} Terminology of virtual memory vs. caches.
:label: tab-vm-vs-caches

| Feature | Caches | Virtual Memory |
| :--- | :--- | :--- |
| **In memory hierarchy** | Caches ↔ Memory | Memory ↔ Disk |
| **Memory unit** | Line or Block (~64 bytes) | Page (~4096 bytes) |
| **Miss** | Cache Miss | Page Fault |
| **Associativity** | Direct-mapped, N-way set associative, fully associative | "Fully associative" (location determined by OS) |
| **Replacement policy** | Least-recently-used (LRU) or random | LRU (most common), FIFO, or random |
| **Write policy** | Write-through or write-back | Write-back |

:::

@tab-vm-vs-caches above does not include terminology for the TLB, which is our cache for address translations. To differentiate misses in the TLB from those in memory caches, we use the terminology: TLB hit, TLB miss.

## Physically Indexed, Physically Tagged Caches

We would love to put everything together: memory caches, TLB, page tables, disks—you name it! But what order do we put things in? Consider the following questions as you look at @fig-pipt-cloud:

* Can a cache hold the requested data if the corresponding page is not in main memory?
* When should we translate virtual addresses?
* On a memory reference, what should we access first?

:::{figure} images/pipt-cloud.png
:label: fig-pipt-cloud
:width: 100%
Putting it all together: what is the order in which we access things? This scenario assumes one layer of caches.
:::

Other more complicated designs exist, but in this class we assume **physically indexed, physically tagged (PIPT) caches**. In @fig-pipt, the fully associative TLB uses the virtual page number to construct its tag, [^tlb-tio]. By contrast, the memory cache uses the physical address to construct its tag and index, and the cache is indexed via this physical index. Note that page offset and block offsets are different sizes, because blocks are smaller than pages.

[^tlb-tio]: In low-associativity TLBs, the virtual page number is split into the TLB tag and the TLB index; then, the TLB is indexed by this "virtual index."

:::{figure} images/pipt.png
:label: fig-pipt
:width: 100%
Physically indexed, physically tagged caches.
:::

A PIPT cache design determines the order of access as shown in @fig-pipt-full:

1. **Address translation**: First translate virtual address to physical address.
2. **Data access**: Use the physical address to access the data in the memory hierarchy.

:::{figure} images/pipt-full.png
:label: fig-pipt-full
:width: 100%
With PIPT caches, address translation happens first. This memory scenario assumes one layer of caches.
:::

:::{note} Explanation of @fig-pipt-full:

A process requests a data at a given virtual address (VA).

**Address translation**: Translate the virtual address to the physical address.

1. Access the **translation lookaside buffer** (done by the memory manager) to see if the corresponding virtual page number was recently translated.
    * On a TLB hit: (See next step.)
    * On a TLB miss:
      * Do a **page table walk** to access the page table in memory.
      * If there is a **page fault** because the correpsonding page table entry is invalid, load the page from disk.
      * At some point, write the correct address translation from this page table entry to the TLB.
1. Construct the physical address using the physical page number from the corresponding TLB entry.

**Data access**: Access data at the physical address in the memory hierarchy and return to the process.

1. Access the **cache** to see if the data with this physical address is a block in the cache. For set-associative and direct-mapped caches, split the physical address into a physical tag, physical index, and block offset.[^pipt]
    * On a cache hit: (See next step.)
    * On a cache miss: Go to memory. See the footnote for multi-level caches.[^multi-level]
1. Access **memory** to copy the block into the cache.
1. Return the requested data to the process.

[^pipt]: Often, the physical index and tag comprise the physical page number.

[^multi-level]: If there are multiple levels of caches, treat them all as part of the "Cache" block in @fig-pipt-full and assume they are all physically indexed, physically tagged. If there is a miss in a higher-level cache, go to a lower level of cache. If the lowest-level cache misses, then go to memory and get a block for the lowest-level cache, then copy the block to the second-lowest-level cache, etc.

:::

## Revisiting AMAT: Impact of Paging

:::{note} Review AMAT

Review our section on [Average Memory Access Time](#sec-amat).

:::

At a high-level, see @tab-amat-cache-vm.

:::{table} Memory hierarchy metrics (review [terminology](#tab-cache-terminology)): Hit rate, hit time, miss rate, and miss penalty. We ignore the TLB for simplicity in computing AMAT, but advanced readers can try incorporating it.
:label: tab-amat-cache-vm

| Feature | Cache | Virtual Memory |
| :-- | :-- | :-- |
| Unit | Block (32-64 B) | Page (4-16 KiB) |
| Miss rate | 1% to 20% | 0.001% |
| Hit time | ≈ 1 cycle | ≈ 100 cycles |
| Miss penalty | ≈ 100 cycles | ≈ 5M cycles |

:::

Let's compute AMAT for a specific example. Suppose we have the following parameters (with no TLB):

* L1 cache: Hit time 1 cycle, hit rate 95%
* L2 cache: Hit time 10 cycles, hit rate 60% (of L1 misses)
* DRAM: Hit time 200 cycles, with some hit rate
* Disk: 20,000,000 clock cycles.

Note that for a 2 GHz clock, 200 cycles is 100 ns, and 20,000,000 cycles is 10 ms.

Suppose we only have DRAM and never access disk. Average memory access time in this case is $AMAT_{no}$ below:

```{math}
\begin{aligned}
AMAT_{no} &= 1 + 0.05 \times (\text{L1 miss penalty}) \\
&= 1 + 0.05 \times (10 + 0.r0 \times (\text{L2 miss penalty})) \\
&= 1 + 0.05 \times 10 + 0.05 \times 0.40 \times 200 \\
&= 5.5 \text{ clock cycles}
\end{aligned}
```

With paging, i.e., disk access, define a rate $R$ that is our "hit rate" to memory. Equivalently, $1-R$ is our probability of a page fault. AMAT becomes:

```{math}
\begin{aligned}
AMAT &= 1 + 0.05 \times 10 + 0.05 \times 0.40 \times (200 + (1 - R) \times 20,000,000) \\
&= AMAT_{no} + (0.05 \times 0.40 \times (1 - R) \times 20,000,000)
\end{aligned}
```

The second factor is a performance cost proportional to the performance of our demand paging system. We mentioned above in @tab-amat-cache-vm that a miss rate for VM is 0.001%. This is our page fault rate, $1 - R$. $1 - R$ = 0.001% = 0.00001 seems like a tiny rate, but we can see quickly how AMAT explodes with higher rates:

* $R = 99.9999\%$:
  $$ AMAT = 5.5+(0.02 \times (.000001) \times 20,000,000)
  = 5.9 \text{ cycles}$$
* $R = 99.9\%$:
  $$ AMAT = 5.5+(0.02 \times (.001) \times 20,000,000)
  = 405.5 \text{ cycles}$$
* $R = 99\%$:
  $$ AMAT = 5.5+(0.02 \times (99) \times 20,000,000)
  = 4005.5 \text{ cycles}$$

The last of these is about 680 times slower than the first of these. That's really, really, REALLY slow...!

Given this analysis, we hope we have convinced you how **costly** page faults are, and why switching to software with the OS to determine page placement and replacement in memory is well worth it.

That wraps up virtual memory and our exploration of the memory hierarchy! Congratulations!!!
