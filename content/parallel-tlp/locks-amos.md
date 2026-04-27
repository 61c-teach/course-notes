---
title: "Locks, Atomic Instructions"
subtitle: This content is not tested
---

(sec-locks)=
## Learning Outcomes

* Motivate why locks are needed to implement synchronization of accesses to shared memory/state.
* Use the Dining Philosophers Problem to motivate when deadlock occurs.
* Describe the behavior of atomic instructions in assembly, e.g., atomic memory operations.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Eumrdr9Oqys
:width: 100%
:title: "[CS61C FA20] Lecture 34.4 - Thread-Level Parallelism II: Synchronization"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/tJ9dqPYGb4E
:width: 100%
:title: "[CS61C FA20] Lecture 35.1 - Thread-Level Parallelism III: Hardware Synchronization"
:::
::::

<!-- TODO: find timestamps and break up this section.
atomic operations
RISC-V critical section
openMP critical section
openMP locks
openMP for loop
deadlock
openMP timing
-->

The core challenge to synchronization is contesting over **shared resources**, e.g., a specific location in memory, an I/O device, or (in general) some state. Critical sections specify sections of codes that must be exclusively accessed by at most one single thread at any given time. In practice, this exclusive access to a section of assembly instructions thereby enables exclusive access to shared state. But what might these "exclusive access" assembly instructions look like?

In this section, we first introduce the concept of **locks**[^spinlocks], which is a conceptual mechanism to implement exclusive access to shared state. Then, we describe some **atomic** assembly instructions in RISC-V.

[^spinlocks]: Specifically, we will describe a [spinlock](https://en.wikipedia.org/wiki/Spinlock). See an operating systems course for other synchronization primitives, like semaphores.

## Analogy: Buying Milk

You and your roommate want to agree on how to buy milk. Both of you will use the same procedure. Assume a shared fridge.

**Approach 1**: The below approach will not work. For example, what if you get home while your roommate is out buying milk? Once you buy milk, you will have two milk cartons in the fridge!

```{code} c
:label: code-milk-1
if milk not in fridge:
  buy milk at store
  put milk in fridge
```

**Approach 2**: A reasonable next step is to leave a sticky note on the fridge when we step out to buy milk. Even with this shared note message system, we can still run into two milk cartons in the fridge. Click the tabs below to see how.

::::{tab-set}

:::{tab-item} Code

```{code} c
:label: code-milk-2

if note not on fridge:
  if milk not in fridge:
    put note on fridge
    buy milk at store
    put milk in fridge
    take note off fridge
```

:::

:::{tab-item} Access Pattern

| Step | You | Roommate |
| :--- | :--- | :--- |
| 1 | `if note not on fridge:` | |
| 2 | &nbsp;&nbsp;`if milk not in fridge:` | |
| 3 | | `if note not on fridge:`|
| 4 | | &nbsp;&nbsp;`if milk not in fridge:` |
| 5 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`put note on fridge` | |
| 6 | | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`put note on fridge` |
| 7 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`buy milk at store` | |
| 8 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`put milk in fridge` | |
| 9 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`take note off fridge` | |
| 10 | | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`buy milk at store` |
| 11 | | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`put milk in fridge` |
| 12 | | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`take note off fridge` |

:::
::::

We could continue down this path—adding more messages and more notes—but these solutions do not address the key problem: that your roommate can insert themselves in-between you checking the fridge and you buying milk.

## Locks

One solution is to use a **lock** to grant a thread (here, you or your roommate) exclusive access to a shared resource. Each thread (well, you or your roommate) can try to "acquire" the lock, but only one thread can have the lock at a given time.

Formally, there are two operations with a lock:[^spinlock]

* **Acquire**: Try to acquire the lock. If successful, keep going. Otherwise, wait a bit and try again later.
* **Release**: Unlock the lock and continue (only works if we originally had the lock).

You have seen the notion of a lock before in public bathroom stalls. One person enters the stall (the shared resource) and locks the door ("acquires" the lock). Others wait until that person unlocks the door ("releases" the lock) to indicate the stall is available.

**Attempt 3**: With locks, we can successfully implement a milk-buying procedure where there is at most one milk carton in the fridge at any given time. Click the tabs below to see how.


::::{tab-set}

:::{tab-item} Code

```{code} c
:label: code-milk-3

acquire fridgelock
  if milk not in fridge:
    buy milk at store
    put milk in fridge
release fridgelock
```

:::

:::{tab-item} Access Pattern

| Step | You | Roommate |
| :--- | :--- | :--- |
| 1 | `acquire fridgelock` |
| 2 | | `acquire fridgelock // wait` |
| 3 | &nbsp;&nbsp;`if milk not in fridge:` | |
| 4 | &nbsp;&nbsp;&nbsp;&nbsp;`buy milk at store` | |
| 5 | &nbsp;&nbsp;&nbsp;&nbsp;`put milk in fridge` | |
| 6 | `release fridgelock` | |
| 7 | | &nbsp;&nbsp;`if milk not in fridge:` |
| 8 | | &nbsp;&nbsp;&nbsp;&nbsp;`buy milk at store` |
| 9 | | &nbsp;&nbsp;&nbsp;&nbsp;`put milk in fridge` |
| 10 | | `release fridgelock` |

:::
::::

### Deadlock

Introducing locks introduces a new problem: **deadlock**. **Deadlock** is a system state in which no progress is possible because everything is locked waiting for something else.

:::{figure} images/traffic-jam.jpg
:label: fig-traffic-jam
:width: 60%
:alt: "Photograph or stylized aerial diagram of vehicles gridlocked at an intersection, each lane waiting on another in a cycle so no car can proceed—mirroring circular wait in locking. Caption ties the visual metaphor to threads holding locks while waiting on peers."

A classic deadlock is a traffic jam, where no car can move because every car is blocked by another. Image source: [Reddit](https://www.reddit.com/r/pics/comments/6qulze/traffic_deadlock/)
:::

A classic CS example, the **dining philosophers problem**, illustrates how deadlock can occur.[^djikstra] Suppose there is a special spaghetti must be eaten with two forks (one left fork, one right fork). Each philosopher can only think OR eat. 
Consider a proposal in which each philosopher is instructed to behave as follows:

[^djikstra]: The Dining Philosophers Problem was first posed by Edsger Djikstra in 1965. [Wikipedia](https://en.wikipedia.org/wiki/Dining_philosophers_problem)

:::::{grid} 2

::::{grid-item}

* think unless the left fork is available; when it is, pick it up;
* think unless the right fork is available; when it is, pick it up;
* when both forks are held, eat for a fixed amount of time;
* put the left fork down;
* put the right fork down;
* repeat from the beginning.
::::

:::::

::::{grid-item}

:::{figure} images/dining-philosophers.jpg
:label: fig-dining-philosophers
:width: 60%
:alt: An illustration of the dining philosophers problem.

In the problem, each philosopher has a bowl of spaghetti and can reach the two forks on either side of them.. [Wikipedia](https://commons.wikimedia.org/wiki/File:Dining_philosophers_diagram.jpg)
:::
::::

This proposed algorithm can lead to deadlock. Suppose that all philosophers grab their left fork "at the same time" (that is, immediately after one-another). All are stuck waiting for the right fork and will be stuck thinking forever.

To avoid deadlock in multithreaded programs, we must ensure that multiple threads cannot interleave multiple shared memory accesses in a way that "locks out" a way forward, because one thread has acquired one lock and is waiting to acquire a second lock, but the second lock has already been acquired by a second thread that is waiting to acquire the first lock. 

:::{warning} Locks are tricky

Locks are a **means** of implementing synchronization of shared resources across threads. Instead of working with locks directly, we suggest specifying critical sections in a higher-level language. While critical sections do not entirely prevent deadlock, they are a higher-level abstraction that clusters together exclusive access to shared state.

For those absolutely curious, OpenMP has a lock directive. See the [OpenMP documentation](https://www.openmp.org/spec-html/5.0/openmpse31.html). Or take an Operating Systems course!

:::

### Naive implementation: Lock

With our current set of instructions, any lock implementation can still cause a data race when threads are interleaved.

Consider a "lock" in shared memory @ `0x55550000`. Let a value `0` at this address mean the lock is unlocked (open), and `1` mean the lock is locked (closed). Suppose that we use register `t0` to check the lock state, and we use `t1` to temporarily store the immediate to write to the lock in memory.

Suppose we write the `acquire` and `release` procedures using RISC-V assembly instructions. Click the tabs below to see how both threads may think they have acquired the singular lock:

::::{tab-set}

:::{tab-item} Code
```{code} bash
:label: code-lock-naive

# acquire
      li   t1 1
try:  lw   t0 0(s0)
      bnez t0 try
lock: sw   t1 0(s0)

...
# release
      sw   x0 0(s0)

```
:::

:::{tab-item} Access Pattern
| Step | Thread 1 | Thread 2 |
| :--- | :--- | :--- |
| 1 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`li t1, 1` | |
| 2 | | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`li t1, 1` |
| 3 | &nbsp;&nbsp;`try: lw t0, 0(s0)` | |
| 4 | | &nbsp;&nbsp;`try: lw t0, 0(s0)` |
| 5 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`bnez t0, try` | |
| 6 | | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`bnez t0, try` |
| 7 | `lock: sw t1, 0(s0)` | |
| 8 | | `lock: sw t1, 0(s0)` |

Unfortunately, this `acquire` implementation effectively recreates the "sticky note" [Approach 2](#code-milk-2) from our milk analogy!
:::


::::


:::{warning} Interleaving memory access

The issue stems from the "gap" between the two memory accesses needed to **acquire** the lock:

* "Test": memory read to check the status of the lock with `lw`
* "Set": memory write to update the status of the lock with `sw`

Any reasonable lock implementation must prevent **any interleaved access** between these memory accesses. The two memory accesses must appear to have happened **atomically**.
:::

## Atomic Instructions

To implement locks and other synchronization primitives, we need lower-level support at the assembly level. This hardware support must prevent an interloper (e.g., another thread) from changing values between the necessary memory accesses in a lock.[^nb] RISC-V and other ISAs support **atomic instructions** for memory read and memory write.

[^nb]: Note that such assembly-level support regardless if a system is uniprocessor or multicore, because OS interrupts will trigger thread context switches.

**Atomic instructions** are instructions where all other instructions must seem to happen strictly before or after the atomic instruction's operation.

Atomic instructions on the surface are composites of existing instructions, e.g., a read and write to a single memory location. However, to implement this read-write _atomically_, the hardware must be designed to not allow any other access to that memory location between that read and write.

These are two common approaches to implementing locks,[^spinlocks] both of which are supported with RISC-V extensions:

* Single atomic instruction: single instruction swaps register with memory, e.g., `amoswap` or compare-and-swap. [RISC-V Zaamo extension](https://github.com/riscv/riscv-zaamo-zalrsc)
* Pair of instructions are effectively atomic, e.g., load-reserved, store-conditional. [RISC-V Zalrsc extension](https://github.com/riscv/riscv-zaamo-zalrsc)

The implementation of these extension instructions is out of scope.

### (Zaamo) Lock Implementation with Atomic Swap

The Zaamo extension implements **atomic memory operations** (**AMOs**),  which atomically perform an operation on an operand in memory and set the destination register to the original memory value. 

RISC-V AMOs are R-Type instructions with the format `amoinst rd rs2 (rs1)` that do the following:

* take the value pointed to by `rs1` and load it into `rd`
* apply the operation to that value with the contents in `rs2`
* store the result back to where `rs1` is pointed to

RISC-V supports these atomic insturctions with: swap, add, and/or/xor, min/max, min/max unsigned.

An AMO lock implementation works as follows. On `acquire`, if the lock state was previously also 1, then another thread has the lock, so we "spin" and try again until lock state was previously 0.

```{code} bash
:label: code-lock-amo

# acquire
        li             t0 1
try:    amoswap.w.aq   t0 t0 (s0)
        bnez           t0 try
locked: # already locked now

# release
unlock: amoswap.w.rl  x0 x0 (s0)
```

The code above looks very similar to our [naive implementation](#code-lock-amo), but now we use AMOs in place of `lw` and `sw`.

A single atomic memory swap operation is hard to implement because it requires both memory read and write in a single instruction.
We know from building the datapath that this is not only difficult but also inefficient, potentially leading to a slower clocked system.

### (Zalrsc) Lock Implementation with Load-Reserved/Store-Conditional

An alternative approach to atomic instruction uses a pair of instructions (one read, one write) that are effectively atomic. To do so, we assume a different definition of success. If the _pair_ executes successfully, then nothing else has changed the value between the instruction pairs.

We discuss one common atomic insturction pair:

* `lr rd (rs1)`: Load reserved. Take the value pointed to by `rs1` and load it into `rd`. Add a reservation somewhere.
* `sc rd rs2 (rs1)`: Store conditional.
  * If the reservation is still valid, store the contents in `rs2` into the location pointed to by `rs1`. Then set the status in `rd` to `0` (success).
  * If the reservation is invalid (i.e., value pointed to by `rs1` has changed), do not store anything and set the status in rd to nonzero (failure)

A load-reserved/store-conditional lock implementation works as follows:

```{code} bash
# acquire
        li   t2  1
try:    lr   t1 s1
        bne  t1 x0 try
        sc   t0 s1 t2
        bnez t0 try
locked: # do nothing
...

# release
unlock: sw x0,0(s1)
```
