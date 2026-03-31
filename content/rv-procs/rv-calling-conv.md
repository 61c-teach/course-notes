---
title: "Calling Convention"
---

<!-- do not reference this one generally; reference sec-rv-calling-convention-->
(sec-rv-calling-convention-top)=
## Learning Outcomes

* Explain why register calling convention helps implement procedure calls in RISC-V.
* Identify whether the caller or callee is responsible for each of the six fundamental steps to procedure calls.
* Use the RISC-V green card to determine whether registers are caller-saved, callee-saved, or neither.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/TLskZ9Ic-T8
:width: 100%
:title: "[CS61C FA20] Lecture 10.2 - RISC-V Procedures: Register Conventions"
:::

::::

We have previously discussed [register names](#sec-register-names) and [register conventions](#sec-register-conventions):

> Register names define **convention**—that is, specifying how assembly instructions should use specific registers for specific common functions. These restrictions help build "agreement" upon how to translate separate components of a program so that the assembly instructions slot together.

Consider the [register convention table](#tab-calling-convention) on the RISC-V green card. So far we have only discussed a few register conventions–namely, the stack pointer `sp` and the return address `ra`.

The remainder of the register conventions we will discuss in this course[^gp-tp] pertain to how to use registers between **procedure calls**.

[^gp-tp]: Out of scope: `gp` (global pointer, used to store a reference to the heap) and `tp` (thread pointer, used to store separate stacks for threads). Consider these registers "off-limits"–using them violates register conventions!


## Motivation

:::{warning} Avoid clobbering

Because all instructions use the same RISC-V register conventions, register values can get **clobbered** with nested procedure calls–meaning that values can get overwritten.
:::

In the C code below, `main` calls `sum_square`, which makes two calls to `mult`.

```{code} c
:linenos:

int main() {
  int z = sum_quare(3, 4);
  ...
}

int mult(int x, int y) {
  return x * y;
}

int sum_square(int x, int y) {
  return mult(x, x) + mult(y, y);
}
```

As we discussed in [a previous section](#sec-rv-procedure-calls), `jal ra Label` and `jr ra` are a common instruction pair that saves a return address into register `ra`. Register naming conventions mean that in both instructions, `ra` refers to the same register number `x1`. However, necessarily `sum_square` will want to jump back to some `ra`, but this will be overwritten by both calls to `mult`. We therefore need to save `sum_square`'s return address somewhere before the call to `mult`—let's use the stack!


:::{tip} Quick Check

Suppose that we did not use the stack to store register values. From the RISC-V green card [register conventions](#tab-calling-convention), we know:

* Register `ra` is register `x1` and has the return address that a callee should use to return to the caller.
* Register `a0` is register `x10` and is the zero-th argument for a callee.
* Register `a0` is **also** the register that holds a return value when a callee returns to the caller.

If we _did not_ store anything to the stack, what might go wrong when we try to call `factorial(2)` using the factorial declaration below?

```c
// assume non-negative numbers
int factorial(int n) {
  if (n == 1) return 1;
  int a = n*factorial(n-1);
  return a;
}
```

:::

:::{note} Show Explanation
:class: dropdown

Using the [fundamental steps of procedure calls](#sec-rv-procedure-call-steps) discussed in an earlier section, we share what happens from the **caller** `factorial(2)`'s perspective.

1. `factorial(2)` Prepare for **callee** `factorial(1)` by putting the argument `1` to register `a0`.
1. Transfer control to callee `factorial(1)` by executing a `jal ra factorial` instruction.
1. (omitted; `factorial(1)`'s task)
1. (omitted; `factorial(1)`'s task)
1. (omitted; `factorial(1)`'s task)
1. (omitted; `factorial(1)`'s task)

At this point, `factorial(2)` has regained control and expects that `a0` has the return value from `factorial(1)`. 

Next, `factorial(2)` wants to multiply this return value by its own argument, `2`. Unfortunately, at this point, register `a0` has been overwritten!
:::

(sec-rv-calling-convention)=
## Register Calling Convention

Consider the [fundamental steps of function calls](#sec-rv-procedure-call-steps). As part of Step 2 (where a caller transfers control and execution to a callee), how might a caller "save" their curent registers?

:::{warning} Strawman solution

We _could_ push and pop a caller's 31 registers `x1` to `x31` to the stack betwen procedure calls. While simple, this approach is costly: we rarely use all 31 registers (given register conventions) so we could be copying extraneous data with expensive memory operations.
:::

Instead, RISC-V defines a **calling convention**:

> A set of generally accepted rules as to which registers will be unchanged after a procedure call, and which registers may be changed.

In other words, to minimize expensive loads and stores between procedure calls, RISC-V calling convention divides registers into two categories:

* Volatile, temporary registers that are **not** preserved across a procedure call.
* Saved registers that **are** preserved across the procedure call.

:::{hint} Calling convention does not imply that any registers are off-limits!

A procedure can both be a caller _and_ a callee! When a procedure is in control, it has access to all registers. What calling convention *implies* is a two-way contract:

1. **Caller expectation**: When the callee returns from executing, the caller should expect that volatile registers may have changed, but saved registers are unchanged.
1. **Callee expectation**: The callee can change values in saved registers, but it must restore original values before returning. The callee can change values in temporary registers without restoring values.
:::

There are multiple ways of specifying this convention. The [ASM Manual](https://github.com/riscv-non-isa/riscv-asm-manual/blob/main/src/asm-manual.adoc#general-registers) specifies the convention as whether registers are preserved across a procedure call ("yes" or "no"). The convention in @tab-calling-convention-copy specifies who must **save** the register values ("caller" or "callee").

* **Caller-saved volatile registers**. The caller is responsible for saving these register values for itself before calling a callee. After the callee returns, the caller can then restore these values if needed.
* **Callee-saved saved registers**. The callee is responsible for saving and restoring these register values. These two steps are often performed in the [prologue and epilogue](#sec-rv-procedure-call-steps), respectively.

:::{table} RV32I Register Calling Convention. This table is also available on our course [green card](#sec-green-card).
:label: tab-calling-convention-copy
:align: center

| Register(s) | Name | Description | Saver |
| :--- | :--- | :--- | :---: |
| `x0` | `zero` | Constant 0 | - |
| `x1` | `ra` | Return Address | Caller |
| `x2` | `sp` | Stack Pointer | Callee |
| `x3` | `gp` | Global Pointer[^gp-tp] | - |
| `x4` | `tp` | Thread Pointer[^gp-tp] | - |
| `x5-7` | `t0-2` | Temporary Registers | Caller |
| `x8` | `s0` / `fp` | Saved Register 0 / Frame Pointer | Callee |
| `x9` | `s1` | Saved Register | Callee |
| `x10-11` | `a0-1` | Procedure Arguments / Return Values | Caller |
| `x12-17` | `a2-7` | Procedure Arguments | Caller |
| `x18-x27` | `s2-11` | Saved Registers | Callee |
| `x28-31` | `t3-6` | Temporaries | Caller |
:::

:::{note} Saving and restoring registers

A caller can use saved registers to save/restore register values; meanwhile, a callee can use temporary registers to save/restore caller registers.

Both caller and callee can also use the stack to save/restore register values:

* **Save registers**. Allocate space on the stack frame first by decrementing `sp`, then store register values to stack memory.
* **Restore registers**. Load values from stack memory into registers, then deallocate space on the stack frame (by incrementing `sp`).

Generally, register saving and restoring is considered part of the stack frame. Many designers find it useful to decrement and increment the stack pointer exactly once in the prologue and epilogue, respectively—this corresponds to pushing and popping the stack frame.

:::

## Fundamental Steps, Revisted

In light of calling convention, we revisit the [Six Fundamental Steps to Procedure Calls](#sec-rv-procedure-call-steps) from a [previous section](#sec-rv-procedure-calls) in more detail:

(sec-rv-procedure-call-steps-revisited)=
:::{note} Six Fundamental Steps to Procedure Calls, Revisited

| Step | Who | Original Description | Revisited Description
| :---: | :--- | :--- | :--- |
| 1 | Caller | **Set up arguments**. Put arguments in registers. | **Set up for callee**. Save caller-saved registers if needed, either by copying to `s0-s11` or to stack. Put arguments in `a0`, …, `a7`, stack, etc. |
| 2 | Caller | **Transfer control to procedure**. Use `jal` (jump-and-link) instruction: `jal ra fnLabel` | - |
| 3 | Callee | **Prologue**. Acquire (local) storage resources: stack space (e.g., push a frame on the stack), save register values, etc. | **Prologue.** Push a new stack frame by decrementing `sp`. Save registers like `s0-s11` if callee needs to use them. Save `ra` if callee will call subroutine. Allocate enough space for local non-register variables like stack arrays. |
| 4 | Callee | **Perform the desired task.** | - |
| 5 | Callee | **Epilogue**. Put the return value in a place where the caller can access it, restore register values, and release local storage on stack (e.g., pop frame off the stack). | Put return value in `a0` (or `a1` if necessary). Restore `ra` if callee called a subroutine. Pop current stack frame by incrementing `sp`. |
| 6 | Callee | **Epilogue: Return control to point of origin**. Use the `jr` instruction: `j ra` | **Epilogue: Return control to caller.** Use the `jr` instruction: `j ra` |

:::