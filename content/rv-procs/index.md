---
title: "Procedure Calls"
---

(sec-rv-procedure-calls)=
## Learning Outcomes

* Remember the six fundamental steps to procedure calls.
* Differentiate between a caller and a callee.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/XZAHwb7Smj0
:width: 100%
:title: "[CS61C FA20] Lecture 09.3 - RISC-V Decisions II: RISC-V Function Calls"
:::

Until 9:10

::::

To round off our discussion of RISC-V, let's discuss RISC-V implements **procedure calls**[^procedures].

[^procedures]: Terminology: The RISC-V manual refers to **procedure** calls and returns, wheras C refers to **function** calls and returns. For more information, see [this Wikipedia page](https://en.wikipedia.org/wiki/Function_(computer_programming)) and [this C wikibooks page](https://en.wikibooks.org/wiki/C_Programming/Procedures_and_functions).


We first outline the fundamental steps of procedure calls in this section. We then we revisit a few topics in detail:

| Topic | Previous Chapters | This Chapter |
| :-- | :--: | :--: |
| Unconditional Jumps | [Usage in branches](#sec-branches) | [General jump instructions](#sec-jumps) |
| Stack Frames | [Stack arrays](#sec-example-sp) | [Pushing/popping stack frames](#sec-rv-stack) | 
| Register conventions | [Register names](#sec-register-names), <br/>[Register conventions](#sec-register-conventions) | [Calling convention](#sec-rv-calling-convention-top) |

Finally, we see some examples of recursive procedures in RISC-V.

## Function Calls in C

We begin by developing our intuition about how **state** changes during a function call in C.
Consider this slightly silly C code. What information must the compiler or programmer keep track of to perform the two `mult` calls in `main`?

```{code} c
:linenos:
int main() {
  int j = ...;
  int k = ...;

  int i = mult(j, k); // first call to mult
  int m = mult(i, i); // second call to mult
}

/* very silly mult function with parameters,
   local variables, and return value */
int mult(int mcand, int mlier) {
  int product = 0;
  while (mlier > 0 {
    product = product + mcand;
    mlier = mlier - 1;
  }
  return product;
}
```

Some notes:

* Parameters: `j` and `k` need to be copied as arguments to `mult`
* `mult` can access its own local variables (e.g., `product`)
* `mult` should be able to execute instructions
* `mult` instructions are located somewhere, and `main` instructions are somewhere else
* After `mult` returns to `main`, `main`'s local variables (e.g., `j` and `k`) should still be there, untouched

### House-Sitting Analogy

Recall that in our computer layout, there is **only one computer** with a fixed set of registers. Procedure calls therefore involve "sharing" compute and storage space. When we make a procedure call, we need to keep track of program **data** (e.g., which local variables belong to whom), procedure **control** (e.g., which procedure is executing and which is waiting), and **parameter passing**.

Procedure calls are kind of like house-sitting. Imagine that you have have parents[^out-of-state] that ask ("call") you to watch their house for a night.

[^out-of-state]: Or anyone, really. Imagine this analogy applies to any group of people who call on you to do something for them, and you have to use their property to complete the task. Assume reasonable compensation. :-)

1. **Set up.** Before you arrive, your parents prep some essentials that they know you'll need; they put these on the table.
1. **Transfer control.** Your parents hide the key. They call you over and leave; they also tell you where they hid the key (under the potted plant.)
1. **Prologue.** The first thing you do (after unlocking the door) is make space for your stuff. Your parents left some stuff on the table that's not for you; you put these things in the closet. You know you're going to use some more things that don't all fit on the table, so you make some more space in the hallway closet.
1. **Perform the desired task.** You watch the pet dog (or cat). Sleep over. Eat dinner. Do homework. Watch TV. Surf the internet.
1. **Epilogue.** To clean up, you put your parents' things from the closet back on the table. You restore the house to the original state (including the closet). You leave them a nice gift, also on the table.
1. **Epilogue: Return control to point of origin.** You put the key back in the agreed location (under the potted plant). After you leave, you call your parents telling them to come back.

In this analogy, your parents' home is the computer. Registers are the table. The closet/garbage/house storage is memory. The essentials your parents prep for you are the arguments. The nice gift you leave is the return value. Your parents are the **caller** procedure, and you are the **callee** procedure.

### Fundamental Steps

:::{hint} Procedure calls generally involve two parties:

* **CalleR**: the calling procedure
* **CalleE**: the procedure being called

:::

(sec-rv-procedure-call-steps)=
:::{note} Six Fundamental Steps to Procedure Calls

1. [Caller] **Set up arguments**. Put arguments in registers.
1. [Caller] **Transfer control to proceduren**. Use `jal` (jump-and-link) instruction: `jal ra fnLabel`
1. [Callee] **Prologue**. Acquire (local) storage resources: stack space (e.g., push a frame on the stack), save register values, etc.
1. [Callee] **Perform the desired task**.
1. [Callee] **Epilogue**. Put the return value in a place where the caller can access it, restore register values, and release local storage on stack (e.g., pop frame off the stack).
1. [Callee] **Epilogue: Return control to point of origin**. Use the `jr` instruction: `j ra`

:::

We revisit these six fundamental steps in a [later section](#sec-rv-procedure-call-steps-revisited).
