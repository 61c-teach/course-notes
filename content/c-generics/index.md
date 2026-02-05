---
title: "Introduction"
---

(sec-generics)=
## Learning Outcomes

* Identify generic functions used in heap memory management.
* Understand why generics support general-purpose code in C.

In this chapter, we practice our C memory skills with two more concepts involving pointers.

As mentioned in a [previous chapter](#sec-pointers), normally pointers can only point to one type. Declaring `int *p;` tells us that `p` should point to an `int` value, and it also determines `p`'s operation with operators like pointer arithmetic (what byte stride to adjust by) and dereferencing (how many bytes to read).

In this section, we discuss the `void *` pointer, a **generic pointers** that can point to anything. Generics support general-purpose code by reducing **code duplication**. Generics are used throughout C to sort an array of any type, search an array of any type, free memory containing data of any type, and more.

By defining one function for each of these use cases, we can call that function across variable types. This helps us make improvements in a single place, instead of multiple very similar places. In doing so, we must further understand memory so that we avoid bugs when writing our own generics.

We have two goals for generics:

1. Generics should generally regardless of argument type.
1. Generics should work by accessing blocks of memory, regardless of the data type stored in those blocks.

The first of these is self-evident; the second will become clear [later](#sec-generic-swap).

## Generic functions in standard C libraries

While we said that we would use generics sparingly to avoid program bugs, you have already encountered your first generics! Check out the `stdlib.h` heap memory management functions:

* `void *malloc(size_t n)`
* `void free(void *ptr)`
* `void *realloc(void *ptr, size_t size)`

These functions are **generic functions** (or **generics**[^java] for short) because they return or use do not assume anything about the type of the memory being allocated or freed. As described in a [previous section](#sec-heap), we cast the return values of `malloc` and `realloc` calls to the appropriate pointer types and use them in local, typed pointer variables.

[^java]: Java also supports generics to (among other things) support the creation of data structures that can hold any reference type, e.g.,  `DataStructure<T>`

(sec-swap-motivation)=
## Motivation: `swap_int`, `swap_short`, `swap_string`

### `swap_int`

Suppose we write a function `swap_int` for swapping integers:

(code-swap-int)=
```{code} c
:linenos:
void swap_int(int *ptr1, int *ptr2) {
  int temp = *ptr1;
  *ptr1 = *ptr2;
  *ptr2 = temp;
}
```

Because C is pass-by-value, in order to swap integers declared in a different function scope, we pass in arguments as pointers. For example, we could call `swap_int` as follows:

(code-swap-int-main)=
```{code} c
int x = 2;
int y = 5;
swap_int(&x, &y);
```

The slidedeck below traces through a toy example that assumes that initially, `x` stores `2` at address `0x100` and `y` stores `5` at `0x104`. After the `swap_int` call, `x` and `y` are still at the same addresses but have swapped values to `5` and `2`, respectively.

:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vSPi9zeMb9_6MHbefYmj3qLUG360ZXXl6jFvy4nCSf5dhSJN7BmIVoT5x2LWBnNAUktlzvhtYoNuZ2G/pubembed?start=false&loop=false
:width: 100%
:title: "Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1pjgFhJh-Rx3CapS7gbUSkjjqCC3OrL9k7MMT14lau8o/edit?usp=sharing)"
:::

Click below to show the explanation of the animation.

:::{note} Explanation
:class: dropdown

The function `swap_int` leverages pointer dereferencing and its own `temp` local variable to update the correct values in memory.

* Function call: The _addresses_ of the local variables `x` and `y` are passed to the `swap_int` function call as `ptr1` and `ptr2`, respectively. `ptr1` stores address `0x100`, and `ptr2` stores address `0x104`.
* [Line 2](#code-swap-int): The local variable `temp` makes a copy of the value at `ptr1`, which is `2` (currently stored at address `0x100`).
* [Line 3](#code-swap-int): Set the value at `ptr1` to a copy of the value at `ptr2`. The right-hand side, `*ptr2`, dereferences `ptr2` and evaluates to `5` (because those are the `int` bytes at the address `0x104`). The left-hand side, `*ptr1`, denotes the target location—the integer bytes at address `0x100`.
* [Line 4](#code-swap-int): Set the value at `ptr2` to a copy of `temp`. The right-hand side evaluates to an `int`—the value `2`. The left-hand side, `*ptr2`, denotes the target location to store these bytes—at address `0x104`.
:::

### `swap_short`

Next we write a function `swap_short` for swapping shorts (the integer type, not the fashion statement):

(code-swap-short)=
```{code} c
:linenos:
void swap_short(short *ptr1, short *ptr2) {
  short temp = *ptr1;
  *ptr1 = *ptr2;
  *ptr2 = temp;
}
```

Aside from the type declarations of `ptr1`, `ptr2`, and `temp`, the logic remains similar.

### `swap_string`

The logic is still similar with `swap_string`, which "swaps strings". 

(code-swap-string)=
```{code} c
:linenos:
void swap_string(char **ptr1, char **ptr2) {
  char *temp = *ptr1;
  *ptr1 = *ptr2;
  *ptr2 = temp;
}
```

Instead of making copies of `char` bytes, this function swaps the addresses of two `char *` variables (i.e., pointers to C strings). We could call `swap_str` with the below code.

(code-swap-string-main)=
```{code} c
char *s1 = "CS";
char *s2 = "61C";
swap_string(&s1, &s2);
```

@fig-swap-string-before illustrates a toy example of memory at the start of the call to `swap_string`; @fig-swap-string-after illustrates the memory right before the call returns.

:::{figure} images/swap-string-before.png
:label: fig-swap-string-before
:width: 60%
:alt: "TODO"

`swap_string` is called.
:::

:::{figure} images/swap-string-after.png
:label: fig-swap-string-after
:width: 60%
:alt: "TODO"

Right before `swap_string` call returns.
:::

Click below to show the explanation of @fig-swap-string-before and @fig-swap-string-after.

:::{note} Explanation
asdf:class: dropdown

@fig-swap-string-before:

* [Function call](#code-swap-string-main): The _addresses_ of the variables `s1` and `s2` are passed to the `swap_string` function call as `ptr1` and `ptr2`, respectively. The variables are of type `char *`, therefore pointers to these variables are of type `char **`. `ptr1` stores address `0x7F...F0`; `ptr2` stores address `0x7F...F4`.
* `s1` is a pointer to a string located at `0x0FACE0`. `s1` stores the value `0x0FACE0` at address `0x7F...F0`.
* `s2` is a pointer to a string located at `0x0ABBA0`. `s2` stores the value `0x0ABBA0` at address `0x7F...F4`.

@fig-swap-string-after:

* [Line 2](#code-swap-string): The local variable `temp` makes a copy of the value at `ptr1`, which is `0x0FACE0`.
* [Line 3](#code-swap-string): Set the value at `ptr1` to a copy of the value at `ptr2`. The right-hand side, `*ptr2`, dereferences `ptr2` and evaluates to `0x0ABBA0` (because those are the bytes at the address `0x7F...F4`). The left-hand side, `*ptr1`, denotes the target location–the bytes at address `0x07F...F0`.
* [Line 4](#code-swap-int): Set the value at `ptr2` to a copy of `temp`. The right-hand side evaluates to the value `0x0FACE0`. The left-hand side, `*ptr2`, denotes the target location to store these bytes–at address `0x07F...F4`.

:::

### Can we write a generic swap?

These three functions demonstrate that at a high level, swapping two values of the same data type follow the same logic. We would like to write a function that can perform a **generic swap**. Let's read on!
