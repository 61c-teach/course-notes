---
title: "Recursive Procedure Calls"
---


## Learning Outcomes

* Identify the prologue and epilogue of a procedure.
* Practice procedure calls, using recursive procedures as an example.
* Identify use cases for unconditional jump instructions and pseudoinstructions–in particular, know how to jump to procedures and return from procedures.

We recommend pulling up the [register convention section](#tab-calling-convention) of the [RISC-V Green Card](#sec-green-card). We also recommend referencing the [Fundamental Steps](#sec-rv-procedure-call-steps) ([revisited version](#sec-rv-procedure-call-steps-revisited)) of procedure calls.
%
## Recursive Example: `factorial`

Consider the below assembly implementation of `factorial`. We have omitted some lines for simplicity; see the full code at the end of this section.

(code-factorial-recursive)=
```{code} bash
:linenos:
main:
  li a0 3
  jal ra factorial
  …
factorial:
  addi sp sp -8
  sw ra 0(sp)
  sw s0 4(sp)
  mv s0 a0
  li t0 1
  bne s0 t0 recurse
  li a0 1
  j epilogue
recurse:
  addi a0 s0 -1
  jal ra factorial
  mul a0 s0 a0
epilogue:
  lw ra 0(sp)
  lw s0 4(sp)
  addi sp sp 8
  jr ra
```

:::{hint} Quick Check
Which lines correspond to the prologue and epilogue of the `factorial` procedure?
:::

:::{note} Show Answer
:class: dropdown

Start with the **epilogue**, which is labeled (the label `epilogue` on line 18  is tied to the `lw` instruction on line 19). Instructions on lines 19, 20, and 21 load values back into saved register `s0` and return address `ra`. and increment the stack pointer `sp`. Finally, line 22 `jr ra` returns to the caller function.

If the epilogue is "tear down," the **prologue** is "set up." We can see that instructions on lines 6, 7, and 8 decrement the stack pointer `sp` and store *callee-saved** registers `s0` and `ra` on the stack, which are used in the procedure itself.
:::

### Discussion Questions

[Hover here](#code-factorial-recursive) for the RISC-V assembly.

:::{note} Expand for equivalent C code
```{code} c
:linenos:
// assume positive numbers
int factorial(int n) {
  if (n == 1) return 1;
  int a = n * factorial(n-1);
  return a;
}
```
:::

:::{hint} Prologue

1. How large is the stack frame?
1. Which registers get saved to the stack?
:::

:::{note} Show Answer
:class: dropdown

1. 8B
1. Our own `ra`, because we (may) do a recursive function call. Our caller’s `s0`
:::

:::{hint} Recursive call
[Line 16](#code-factorial-recursive): As caller, what do we save before making the recursive call? Why?
:::

:::{note} Show answer
:class: dropdown

Recursive factorial (for positive numbers) computes $\text{factorial}(n) = n! = n \cdot (n - 1)!$, for $n > 1$. $\text{factorial}(1) = 1! = 1.$

The [calling convention](#sec-rv-calling-convention) means saved registers like `s0` are preserved across the recursive call, so copy argument `a0` ($n$) to saved register `s0` so we can still use this value after the recursive call $(n-1)!$ completes.

:::

:::{hint} Temporary registers
[Lines 10-11](#code-factorial-recursive): Why do we use the temporary register `t0`?
:::

:::{note} Show answer
:class: dropdown

The branch instruction `bne` compare two registers. This instruction checks for our base case, which (as per Line 10) is `1`. We therefore load the immediate `1` into register `t0`.[^a0-s0] [^base-case-zero]

[^a0-s0]: Given the `mv s0 a0` instruction, we could have equivalently replaced the branch instruction `bne s0 t0 recurse` with `bne a0 t0 recurse`. The code likely uses the former to distinguish register naming conventions for register `a0`, which is both the first function argument and the return value. The register `s0` is designated as the value of $n$ in $\text{factorial}(n)$, and the register `a0` will soon become the return value (as per line 12).
[^base-case-zero]: Factorially is [mathematically defined](https://en.wikipedia.org/wiki/Factorial) over all non-negative numbers, including $0!= 1$. The lecture code pedagogically chooses to ignore the zero case to show you `bne` with two non-zero register values.
:::


:::{hint} Epilogue
[Lines 18-22](#code-factorial-recursive) Do we restore registers first or pop stack frame?
:::

:::{note} Show Answer
:class: dropdown

First restore registers, whose values are stored on the stack. Then, pop the stack frame, right before returning to the caller.
:::

:::{hint} [Line 13](#code-factorial-recursive)
Why `j epilogue`? Why not `j ra`?
:::

:::{note} Show Answer
:class: dropdown

When returning, **the callee** is always responsible for preserving calling convention: restoring saved registers and deallocating the stack frame (e.g., restoring `sp`). While Lines 12 and 13 imply the callee has reached the base case, the base case must also complete the epilogue before returning to the caller.

:::

### Run Demo

The below code is for reference.

:::{note} Expand for `recursive.s`
:class: dropdown

```bash
#### Recursive factorial
.globl factorial

.text
main:
    li a0 4
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

# factorial takes one argument:
# a0 contains the number which we want to compute the factorial of
# The return value should be stored in a0

factorial:
    # Prologue
    addi sp sp -8
    sw ra 0(sp)
    sw s0 4(sp)
    
    # Body
    mv s0 a0
    li t0 1
    
    bne s0 t0 recurse
    
    # Base Case
    li a0 1
    j epilogue
    
recurse:
    addi a0 s0 -1
    jal ra factorial
    mul a0 s0 a0

epilogue:
    lw ra 0(sp)
    lw s0 4(sp)
    addi sp sp 8
    jr ra
```

:::

:::{note} Expand for suggested Venus simulator settings
:class: dropdown

* In `main`:
  * `jal ra, factorial` (e.g., `factorial(4)` function call)
  * update `li a0 3` to simulate `factorial(3)`
* Set breakpoints in `factorial`:
  * the start of the procedure, i.e., `factorial` label
  * Base case
  * recursive call

Check register values `a0` and `s0`; suggest switching to `Decimal` view of register values
:::

## Another Recursive Example

Check it out!

```{code} c
:linenos:
int foo(int i) {
  if (i == 0) return 0;
  int a = i + foo(i-1);
  return a;
}
int j = foo(3);
int k = foo(100);
int m = j+k;
```

```{code} bash
:linenos:
  j main
foo:          # int foo(int i)
  addi sp sp -8 # Prologue
  sw ra 0(sp)   # Prologue
  sw s0 4(sp)   # Prologue
  mv s0 a0      # Move i
  bne s0 x0 Next# if i != 0, skip this
  li a0 0       # int a = 0;
  j Epilogue    # Go to Epilogue
              # (to restore stack)
Next: 
  addi a0 s0 -1 # int j = i - 1;
  jal ra foo    # j = foo(j);
  add a0 s0 a0  # int a = i + j;
Epilogue: 
  lw ra 0(sp)   # Epilogue
  lw s0 4(sp)   # Epilogue
  addi sp sp 8  # Epilogue
  jr ra         # return a;
main:
  li a0 3       # int j = foo(3);
  jal ra foo    # call foo
  mv s0 a0      # mv rd rs1 sets rd = rs1
  li a0 100     # int k = foo(100);
  jal ra foo    # call foo
  mv s1 a0      # Saves return value in s1
  add a0 s0 s1  # int m = j+k;
```