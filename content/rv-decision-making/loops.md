---
title: "Loops"
---

## Learning Outcomes

* Implement a for loop in assembly.


::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/OWxcAqFNkpo
:width: 100%
:title: "[CS61C FA20] Lecture 08.3 - RISC-V lw, sw, Decisions I: Decision Making"

8:50 onwards
::::


:::{hint} Learn one loop, learn them all


There are several types of loops in C: `while`, `for`, `do-while`.

As you may recall from an earlier class like CS 61A, each loop structure can be written into one of the other loops (try this with for loops and while loops). Once we learn how to write conditional branches with one loop, we can apply the same branching method to all loops.

:::

We'll cover the `for` loop implementation in detail below, then leave the other loops for you to reference later.

## C code

The below C loop adds up 20 integers in an array `arr` and stores the result in `sum`.

(code-c-for-loop)=
:::{code} c
:linenos:

int arr[20];
... // fill arr with data
int sum = 0;
for (int i=0; i<20; i++) {
    sum += arr[i];
}
// ...
:::

Implementing loops in assembly is similar to writing loops with `goto` [syntax](#sec-goto-warning). Click to show how we can rewrite the loop above with `goto` and [labels](#sec-labels).

::::{note} Click to show `goto` loop
:class: dropdown

(code-goto-for-loop)=
:::{code} c
:linenos:
      int arr[20];
      …
      int sum = 0;
      int i = 0;
Loop: if(i >= 20) goto End
      sum += arr[i];
      i++;
      goto Loop
End:  // …
:::

(sec-goto-warning)=
:::{warning} `goto` is not good C practice
Do not write `goto` in real C code! For reasons we discuss in the [Appendix](#sec-appendix-goto) of this page.
:::

::::


## RISC-V translation

Here is the full assembly translation of the [original C code](#code-c-for-loop).

(code-for-loop-rv)=
```{code} bash
    add   x9  x8  x0
    add  x10  x0  x0
    add  x11  x0  x0
    addi x13  x0  20
Loop:
    bge  x11 x13 End
    lw   x12  0(x9)
    add  x10 x10 x12
    addi  x9  x9   4
    addi x11 x11   1
    j Loop
End:
    ...
```

### Register Assignments

:::{tip} Quick Check

As you trace the code, try to understand how the register numbers used map to the local variables in the [original C code](#code-c-for-loop).

Reading the [assembly above](#code-for-loop-rv), match the registers on the left to one of the C expressions on the right.

| Registers | C expression |
| :--: | :-- |
| **1.**   `x8` | **A.** `sum` |
| **2.**  `x11` | **B.** `i` |
| **3.**   `x9` | **C.** `20` |
| **4.**  `x12` | **D.** `arr[0]` |
| **5.**  `x10` | **E.** `&arr[0]` |
| **6.**  `x13` | **F.** `arr[i]` |
| | **G.** `&arr[i]` |

**Hint**: Register `x8` holds the address of `arr`.

:::

:::{note} Show Answer
:class: dropdown

Reference the [assembly above](#code-for-loop-rv) as you go through the answers.

1. Register `x8` holds `&arr[0]`, the address of the first element of the `arr` (equivalently, the address of `arr`).
1. Register `x11` holds `i` , the loop variable. Hints are from the `add x11 x0 x0` instruction right before the `Loop`, and the `addi x11 x11 1` instruction before we jump back to the start of the `Loop`.
1. Register `x9` holds `&arr[i]`, the address of the current element of the `arr`. Hints are from the first instruction `add x9 x8 x0` and the **integer pointer arithmetic** instruction `add x9 x9 4` before we jump back to the start of the `Loop`.
1. Register `x12` holds `arr[i]`, the current element of `arr` (the value, not the address). Hints are from its initialization with `add x10 x0 x0` and its use within the loop, `add x10 x10 x12`.
1. Register `x10` holds `sum`, the current value of `sum`. The hint is the singular `add x10 x10 x12` instruction in the `Loop`.
1. Register `x13` has the immediate value `20` and it is set in `addi x13 x0 20`. This value is used in the `bge` branch instruction, which must compare **registers**.
:::


### Line-by-Line

The assembly again, now commented. Hover to reference the [original C code](#code-c-for-loop).

```{code} bash
:linenos:
    add   x9  x8  x0 # &arr[0]
    add  x10  x0  x0 # sum = 0
    add  x11  x0  x0 # i=0
    addi x13  x0  20
Loop:
    bge  x11 x13 End # if i >= 20, then branch
    lw   x12  0(x9)
    add  x10 x10 x12 # sum += arr[i]
    addi  x9  x9   4 # &arr[i+1]
    addi x11 x11   1 # i++
    j Loop
End:
    ...
```

**Line 1**. `add x9 x8 x0`. Put the first (zero-th) element in register `x9`.

**Line 2**. `add x10 x0 x0`. Initialize the `sum` to zero in register `x10`.

**Line 3**: `add x11 x0 x0`. Initialize the loop variable `i` to zero in register `x11`.

**Line 4**: `addi x13 x0 20` (`li x13 20`). Put the value `20` in register `x13` to use for the branch instruction.

**Line 5-6**: `bge x11 x13 End`. If the current loop variable is greater than or equal to zero, branch to the End instruction in Line 13.

* `bge` exits loop if `R[x11] >= R[x13]` is true.
* Otherwise if false, then `i < 20`, so continue in the loop.
* Note that the labels `Loop` and `End` are not instructions; rather, they are bound to instruction addresses (i.e., `Loop` is the address of the `bge` instruction).

**Line 7**: `lw   x12  0(x9)`. Get the value of `arr[i]` and put it in register `x12`.

**Line 8**: `add  x10 x10 x12`. Add `arr[i]` to the current sum in register `x10`; write the result back to register `x10`.

**Line 9**: `addi  x9  x9   4`. Get the address of the next element, `&arr[i+1]`. Update the byte address in register `x9` by adding 4 (`sizeof(int)` is 4).

**Line 10**: `addi x11 x11 1`. Increment `i` by one. This is needed for the branch instruction comparison.

**Line 11**: `j Loop` Jump to the branch instruction.

**Line 12**: If we reached this instruction, we have exited the loop.

## Control Structure Reductions

We describe "go-to" (heh) ways of reducing common loops to structures that are more directly translatable into assembly.

### `if` conditional

Consider the below C code. The code reduction uses the idea leveraged in [Example 1](#sec-branch-ex1) and [Example 2](#sec-branch-ex2) to flip the conditional with a `goto` statement.

```c
if(cond) {
    line1;
    line2;
}
line3;
```

:::{note} Show Reduction
:class: dropdown

```c
if(!cond) goto AfterIf;
line1;
line2;

AfterIf:
    line3;
```
:::


### `while` loop

```c
while(cond) {
    line1;
    line2;
} 
line3;
```

:::{note} Show Reduction
:class: dropdown

```c
Loop:
    if(!cond) goto AfterLoop;
    line1;
    line2;
    goto Loop;

AfterLoop:
    line3;
```
:::

### `while` loop with `break`

In the below code, `break` reduces to a `goto` statement:

```c
while(true) {
    line;
    break;
}
line;
```

:::{note} Show Translation
:class: dropdown

```c
while(true) {
    line;
    goto AfterWhile;
}
AfterWhile:
    line;
```

:::

### `for` loop

```c
for(startline;cond;incline) {
    line1;
    line2;
} 
line3;
```

We recommend first translating `for` loops into the equivalent `while` loop:

```c
startline;
while(cond) {
    line1;
    line2;
    incline;
} 
line3;
```

Finally, reduce with `goto`.

:::{note} Show Reduction
:class: dropdown

```c
startline;

Loop:
    if(!cond) goto AfterLoop
    line1;
    line2;
    incline;
    goto Loop

AfterLoop:
    line3;
```
:::

### `do-while` loop

The C code:

```c
do {
    line1;
    line2;
} while(cond)
line3;
```

:::{note} Show Reduction
:class: dropdown

```c
Loop:
    line1;
    line2;
    if(cond) goto Loop;
 
line3;
```
:::


(sec-appendix-goto)=
## Appendix: `goto`

In C, the `goto Label;` statement sets the next line to execute to be the line [labeled](#sec-labels) with `Label`. This labeled line can be anywhere else in the program.


(sec-goto-warning-2)=
:::{warning} `goto` is not good C practice
Do not write `goto` in real C code!

The use of [goto](https://en.wikipedia.org/wiki/Goto) was historically popular in earlier programming languages, likely because it reflected how assembly languages execute instructions. Nowadays, modern C and higher-level languages advocate for structured control flow statements via `if-else`, `for` and `while` loops, etc.
:::

Nevertheless, we share a few `goto` examples in C, for those of you who want more practice writing code more amicable to direct assembly translation. We encourage you to take these examples with a grain of salt.

### `malloc` example

Consider the below code. We would like to rewrite this code in case any `malloc` call fails and returns `NULL`.

```c
int* a = malloc(sizeof(int)*1000);
int* b = malloc(sizeof(int)*1000000);
int* c = malloc(sizeof(int)*1000000000);
FILE* d = fopen(filename);
```

The below code is one attempt, though it fails to free previous `malloc` blocks.

```c
int* a = malloc(sizeof(int)*1000);
if(a == NULL) allocation_failed();
int* b = malloc(sizeof(int)*1000000);
if(b == NULL) allocation_failed();
int* c = malloc(sizeof(int)*1000000000);
if(c == NULL) allocation_failed();
FILE* d = fopen(filename);
if(d == NULL) allocation_failed();
```

The final code uses `goto` to free previously allocated blocks upon any single failure.

```c
int* a = malloc(sizeof(int)*1000);
if(a == NULL) goto ErrorA;
int* b = malloc(sizeof(int)*1000000);
if(b == NULL) goto ErrorB;
int* c = malloc(sizeof(int)*1000000000);
if(c == NULL) goto ErrorC;
FILE* d = fopen(filename);
if(d == NULL) {
           free(c);
ErrorC:    free(b);
ErrorB:    free(a);
ErrorA:    allocation_failed();
}
```