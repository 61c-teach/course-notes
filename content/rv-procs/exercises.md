---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. After calling a function and having that function return, the `t` registers may have been changed
during the execution of the function, while a registers cannot.

:::{note} Solution
:class: dropdown

**False.** `a0` and `a1` registers are often used to store the return value from a function, so the function can set their values to its return values before returning.

:::

2. In order to use the saved registers (`s0`-`s11`) in a function, we must store their values before using them and restore their values before returning.

:::{note} Solution
:class: dropdown

**True.** The saved registers are callee-saved, so we must save and restore them at the beginning
and end of functions. This is frequently done in organized blocks of code called the "function
prologue" and "function epilogue."

:::

3. The stack should only be manipulated at the beginning and end of functions, where the callee-saved registers are temporarily saved.

:::{note} Solution
:class: dropdown

**False.** While it is a good idea to create a separate 'prologue' and 'epilogue' to save callee registers onto the stack, the stack is mutable anywhere in the function. A good example is if you want
to preserve the current value of a temporary register, you can decrement the sp to save the
register onto the stack right before a function call.

:::

<!-- ## Short Exercises

1. **True/False**: 

:::{note} Solution
:class: dropdown
**True.** Explanation
::: -->
