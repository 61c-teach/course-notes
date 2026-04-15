---
title: "Loop Unrolling, GCC"
---

(sec-dgemm-sequential)=
## Learning Outcomes

* Explain why loop unrolling reduces program execution time by reducing branches due to loops.
* Explain the `register` and `inline` keywords in C.
* Use `gcc` flags to specify program optimizations. `gcc` is not explicitly tested in this course but should be useful.

It is very tempting to jump straight into parallelization. We first discuss a few simple optimizations to sequential programs[^sequential-parallel] that work plenty fast.

[^sequential-parallel]: We differentiate these optimizations, which can be done for programs that run on a single-core processor, from parallel optimizations that require special hardware. More later.

## Cost of Operations

As a general rule of thumb, the runtime cost of operations for sequential programs can broken down into several categories:

1. **I/O operations**: Extremely slow. File operations from disk takes a long time! `print`s and other I/O operations are also expensive. As a general programming rule when testing program execution time, avoid printing lots of data. Also avoid repeatedly reading the same files.
2. **Memory operations**: Take about 3-100 clock cycles. RAM is faster than disk, so this category is about 100x faster than file operations. The base speed for memory operations in an architecture can be improved through **caching**. We discuss programming techniques below.
3. **Branch and Jumps** are slower than our last category, arithmetic operations, due to control hazards and more. We discuss programming techniques below.
4. **Arithmetic operations** are the fastest operations and take 1 cycle ideally (though some operations, particularly on CISC architectures, take longer).

:::{warning} Above all, optimize memory access

In most programs, memory operations will likely take the majority of runtime. So reducing the "footprint" of memory operations will often have the largest impact on our runtime—even if it increases our instruction count.
:::

## The `register` keyword

We can save commonly used values in registers. The `register` keyword can be used to request that a C variable gets put in a register, instead of on the stack.

When used, `register` is typically for loop counters and other **frequently used variables.** Toggle between the two code snippets below. The `register` keyword must be used for variable declarations outside of the loop.

::::{tab-set}
:::{tab-item} Register keyword

```{code} c
register int limit = max/4;
register int i;
for (i = 0; i < limit; i++) {
    f(i);
}
```
:::

:::{tab-item} Original code
```{code} c
for (int i = 0; i < max/4; i++) {
    f(i);
}
```
:::
::::

We note that the `register` keyword is like a "suggestion," meaning that compilers can choose to ignore this keyword.[^cplusplus] Nevertheless, this optimization can be especially valuable on embedded systems or even x86 architectures, where register files are small.[^x86-architecture] Since different CPUs can have different register files, this optimization is dependent on the architecture.

[^cplusplus]: In fact, the `register` keyword is actually deprecated in C++. Read more on [Wikipedia](
https://en.wikipedia.org/wiki/Register_(keyword))

[^x86-architecture]: There are 16 register names in x86-64. In x86, most variables get stored on the stack (unlike RISC-V, which has 32 registers).

Register usage is often implicitly used by `gcc` when optimization flags are specified, so results from this optimization can be inconsistent. More later.

## Loop Unrolling

How might we try reducing the number of jumps and branches in a program? In our matrix multiplication example, we can try **loop unrolling**, which increases the number of steps done per iteration of a loop in order to reduce the total number of branches.

::::{tab-set}
:::{tab-item} Loop Unrolling

```{code} c
int i = 0;
for (; i < max/4*4; i+=4) {
    arr[i] = f(i);
    arr[i+1] = f(i+1);
    arr[i+2] = f(i+2);
    arr[i+3] = f(i+3);
}

for (; i < max; i++) {
    arr[i] = i * i;
}
```
:::

:::{tab-item} Loop Unrolling with Function Inlining
```{code} c
int i = 0;
for (; i < max/4*4; i+=4) {
    arr[i] = i * i;
    arr[i+1] = (i+1) * (i+1);
    arr[i+2] = (i+2) * (i+2);
    arr[i+3] = (i+3) * (i+3);
}

for (; i < max; i++) {
    arr[i] = i * i;
}
```
:::

:::{tab-item} Original code
```{code} c
int f(int i) {return i*i;}
for (int i = 0; i < max; i++) {
    arr[i] = f(i);
}

```
:::
::::

Loop unrolling is already done by some compilers (including `gcc` at optimization level `-O3`, so speedup may be minimal and hard to predict). Because there are more assembly instructions, the resulting executable can also be larger; if a loop is too large, we can exceed the range of branch immediates and take a longer penalty to runtime.

Ultimately, loop unrolling makes code much harder to read and modify. So just unroll code at the end (e.g., with compilation).

### Function Inlining

Another related optimization is **function inlining**, where we replace a function call with the body of that function. Function calls require some stack setup (e.g., for calling convention), so inling function calls can be extremely useful.

We can use the `inline` keyword to explicitly request function inlining from the compile (though like before, compilers can choose to ignore this keyword). This can be useful if a function is declared for the purposes of abstraction but is rarely used. Duplicating the instruction code at the assembly level will increase the number of assembly instructions but will not complicate the higher-level code.

## Cache blocking

Recall from our discussion of [caches](#sec-cache-terminology) the concept of **spatial and temporal locality**: Accessing adjacent or recent memory will be on average faster than accessing nonadjacent memory. In general, we would like to minimize cache misses and perform as much computation on spatially and temporally local data as possible–_before_ cache blocks need to be replaced by main memory.

To do so, we leverage the idea of **cache blocking**. Cache blocking is a program optimization that is critical for the programmer to do, because compilers `gcc` does not know the intentions of our program—just the instructions themselves.

:::{note} Review cache blocking

Review [cache blocking](#sec-cache-blocking).
:::

## `gcc` Optimization Flags

Thus far, we have been avoiding any compiler optimizations by specifying the `-O0` option to `gcc`:

```bash
gcc -g3 -std=c11 -Wall -O0 matmul.c run_matmul.c -o run_matmul
```

We can specify different optimization levels for `gcc`. From the [GNU gcc docs](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html):

* `-O0`: Reduce compilation time and make debugging produce the expected results. This is the default (though see recommended `-Og` below).
* `-O1`: Optimize. Optimizing compilation takes somewhat more time, and a lot more memory for a large function. With `-O1`, the compiler tries to reduce code size and execution time, without performing any optimizations that take a great deal of compilation time.
* `-O2`: Optimize even more. GCC performs nearly all supported optimizations that do not involve a space-speed tradeoff. This option turns on all optimization flags specified by `-O1` and increases both compilation time and the performance of the generated code.
* `-O3`: Optimize yet more. `-O3` turns on all optimizations specified by `-O2`. These optimizations may optimize at the expense of instruction count or space.

:::{warning} `gcc` is not enough!

GCC can only optimize based on the provided high-level program. It does not know how to change the "algorithm" and incorporate optimizations like cache blocking, multithreading, etc.

Your task as a programmer therefore still involves writing good code that (1) minimizes cache misses, and (2) parallelizing where possible.
:::

We encourage you to look through the linked [GNU gcc docs](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html). We've sampled a few interesting ones below.

:::{note} Some `-O1` optimizations
:class: dropdown

* `-fdelayed-branch`(enabled at `-O1`, not at `-Og`): If supported for the target machine, attempt to reorder instructions to exploit instruction slots available after delayed branch instructions.
* `-fcombine-stack-adjustments`: Tracks stack adjustments (pushes and pops) and stack memory references and then tries to find ways to combine them.
* `-freorder-blocks`: Reorder basic blocks in the compiled function in order to reduce number of taken branches and improve code locality.
* `-finline-functions-called-once`: Hopefully self-explanatory.
:::

:::{note} Some `-O2` optimizations
:class: dropdown

* `-falign-functions`: Align the start of functions to the next power-of-two greater than or equal to n, skipping up to m-1 bytes. This ensures that at least the first m bytes of the function can be fetched by the CPU without crossing an n-byte alignment boundary. 
* `-finline-functions`: Consider all functions for inlining, even if they are not declared inline. The compiler heuristically decides which functions are worth integrating in this way.
* `-foptimize-strlen`: Optimize various standard C string functions (e.g. `strlen`, `strchr` or `strcpy`) ... into faster alternatives.
* `-foptimize-crc`: Detect loops calculating CRC (performing polynomial long division) and replace them with a faster implementation.

:::

:::{note} Some `-O3` optimizations
:class: dropdown

* `-floop-interchange`: Perform loop interchange outside of graphite. This flag can improve cache performance on loop nest and allow further loop optimizations, like vectorization, to take place.
* `-floop-unroll-and-jam`: Apply unroll and jam transformations on feasible loops. In a loop nest this unrolls the outer loop by some factor and fuses the resulting multiple inner loops. Our version of unrolling ([read more](https://dl.acm.org/doi/10.1145/3721145.3725778)).
:::

There is a lovely debugging option called `-Og` that you should use where possible. From the docs:

* `-Og`: Optimize while keeping in mind debugging experience. `-Og` should be the optimization level of choice for the standard edit-compile-debug cycle, offering a reasonable blend of optimization, fast compilation and debugging experience especially for code with a high abstraction penalty. ... `-Og` enables all `-O1` optimization flags except for those known to greatly interfere with debugging.


## Premature Optimization

The optimizations discussed in this section are useful but do not always lead to good code.

The Turing award winner [Don Knuth](https://en.wikipedia.org/wiki/Donald_Knuth) has a great quote on the pitfalls (and benefits!) of efficient, good programming:[^knuth]

[^knuth]: Donald E. Knuth. 1974. Structured Programming with go to Statements. ACM Comput. Surv. 6, 4 (Dec. 1974), 261–301. https://doi.org/10.1145/356635.356640

> The conventional wisdom shared by many of today's software engineers calls for ignoring efficiency in the small; but I believe this is simply an overreaction to the abuses they see being practiced by penny-wise-and-pound-foolish programmers, who can't debug or maintain their "optimized" programs.
> ...
> 
> There is no doubt that the grail of efficiency leads to abuse. Programmers waste enormous amounts of time thinking about, or worrying about, the speed of noncritical parts of their programs, and these attempts at efficiency actually havea  strong negative impact when debugging and maintenance are considered. We _should_ forget about small efficiencies, say, about 97% of the time: premature optimization is the root of all evil.
> 
> Yet we should not pass up our opportunities in that critical 3%. A good programmer will not be lulled into complacency by such reasoning, he will be wise to look at the critical code; but only _after_ that code has been identified.

We therefore encourage the following best practices:

* When debugging programs, compile with `-Og` so you can debug your code. With more optimizations, the mapping between high-level and assembly code gts more muddled, and stepping through code gets more esoteric.
* Leave loop unrolling and register declarations to the compiler.
* For `gcc`, use `-O2`. `-O3` often does too much.
*  The `inline` keyword is still useful. Function inlining requires knowing how frequently the function in question will be called.
* Memory accesses are by far one of the most valuable to optimize, so design your algorithms with a good understanding of cache accesses, and leverage cache blocking where needed.