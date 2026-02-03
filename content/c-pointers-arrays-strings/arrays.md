---
title: "Arrays"
---

(sec-array)=
## Learning Outcomes

* Declare and initialize C arrays.
* Understand that C arrays should be treated as contiguous blocks of memory, not as pointers. Array names are synonymous with the location of the first element in the array.
* Translate array indexing into pointer arithmetic followed by a dereference operation.
* Decay arrays to pointers when used as formal parameters for function definitions or arguments to functions.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/hJNoW4hlZDg
:width: 100%
:enumerated: false
:title: "Lecture 04.3 - C Intro: Pointers, Arrays, Strings: Arrays"
:::
::::


::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/J6mhHw7UTPM
:width: 100%
:enumerated: false
:title: "Meet the jewelry making community
Meet the jewelry making community
[CS61C FA20] Lecture 05.1 - C Memory Management: Dynamic Memory Allocation s"
:::
From 9:36 onwards: Arrays are not pointers example
::::

We continue our exploration of memory by studying C arrays. On the surface, C arrays seem fairly similar to what you might recognize from Java. In this section, we learn that arrays in C are **neither variables nor pointers**. When used in C statements, array names often behave like pointer variable names, for reasons we will describe shortly.

:::{hint} An adage from K&R
An array name is not a variable.
:::

:::{hint} An adage from us
A C array is really just a big block of consecutive things in memory with certain properties.
:::


To **declare** an array of two elements without initializing its values, we can use the below statement. This statement declares a block of memory large enough to hold two contiguous `int`s. It does not initialize values, so we can assume elements contain garbage:

```c
int arr_unitialized[2];
```

To **initialize and declare** an array of two elements 795 and 635, in that order:

```c
int arr2[] = {795, 635};
```

or equivalently

```c
int arr2[2] = {795, 635};
```

**Square-bracket indexing** is one way to access elements of the array. Like many languages, C specifies zero-indexed arrays:

```c
arr2[0]; // 795
```

(sec-array-indexing)=
## Array indexing uses pointer arithmetic

Is there another way to access array elements? Yes, otherwise we would not have been so cryptic earlier.

Square-bracket indexing for C arrays is what we call "syntactic sugar"–meaning, it exists for human readability, but the C compiler will translate it to two operations: [pointer arithmetic](#sec-pointer-arithmetic) followed by **dereference**:

The expression `arr[i]` is **equivalent** to the expression `*(arr+i)`. The latter treats the array name `arr` as a pointer, increments it, then dereferences.

### Example

Suppose that when compiled, @code-array-indexing below produces the memory layout in @fig-array-indexing. `q` is a pointer to a 32-bit unsigned integer, while `arr` is an array, i.e., a 24-byte contiguous block of 32-bit unsigned integers.

(code-array-indexing)=
```{code} c
:linenos:
#include <stdio.h>

int main () {
  uint32_t arr[] = {50, 60, 70}; // 32-bit unsigned array
  uint32_t *q = arr;

  printf("    *q: %d is %d\n", *q, q[0]);
  printf("*(q+1): %d is %d\n", *(q+1), q[1]);
  printf("*(q-1): %d is %d\n", *(q-1), q[-1]);
}
```

:::{figure} images/array-indexing.png
:label: fig-array-indexing
:width: 80%
:alt: "TODO"

Memory layout for @code-array-indexing.
:::

Because square-indexing is syntactic sugar for pointer arithmetic and dereference:

* Line 4: The pointer `q` points to an unsigned 32-bit integer at address `0x100`, which is `50`. Print `    *q: 50 is 50`.
* Line 5: Incrementing `q` points to the **next** 32-bit unsigned integer. If `q` points to the unsigned 32-bit integer at address `0x100`, then incrementing `q` points to the *next 32-bit unsigned integer* at address `0x104`, which is `60`. Print `*(q+1): 60 is 60`.
* Line 6: Because square-bracket indexing is syntactic sugar, *negative indexing does not produce any error*. Instead, decrementing `q` points to the **previous** 32-bit unsigned integer at address `0x9c`, which is an unknown value. This line would likely print garbage, e.g., `*(q-1): 32490 is 32490`.

## Arrays are not pointers

From K&R:

> There is one difference between an array name [(such as `a`)] and a pointer [(such as `pa`)] that must be kept in mind. A pointer is a variable, so `pa=a` and `pa++` are legal. But an array name is not a variable; constructions like `a=pa` and `a++` are illegal.

Also from K&R:

> The name of an array is a synonym for the location of the
initial element.

Pointers and arrays therefore differ in how they behave with the address operator, `&`. Consider @code-array-addressing:[^fstring]

[^fstring]: `%d`: signed decimal, `%x`: hex. [Wikipedia](https://en.wikipedia.org/wiki/Printf)

(code-array-addressing)=
```{code}c
:linenos:

int *p, *q, x;
int a[4];
p = &x;
q = a + 1;

*p = 1;
printf("*p:%d, p:%x, &p:%x\n", *p, p, &p);

*q = 2;
printf("*q:%d, q:%x, &q:%x\n", *q, q, &q);

*a = 3;
printf("*a:%d, a:%x, &a:%x\n", *a, a, &a);

```

With the memory layout in @fig-array-addressing, the output is:

```
*p:1, p:108, &p:100
*q:2, q:110, &q:104
*a:3, a:10c, &a:10c
```

:::{figure} images/array-addressing.png
:label: fig-array-addressing
:width: 80%
:alt: "TODO"

Memory layout for @code-array-addressing.
:::

The address of the array `a` is the address of the array itself, i.e., the address of the large contiguous memory block of `int`s!

:::{note} Show Explanation
:class: dropdown

* We discuss multiple declaration in a [previous section](#foot-multiple-declarations).

[^multiple-declarations]: You may notice that Line 8 declares two pointers by mashing the `*` next to `ptr1` and `ptr2`, respectively. We didn't discuss it, but a single-declaration `coord_t* ptr1;` is also valid. Most modern C programmers try to avoid declaring multiple variables on a single line where possible. But you'll see it often in legacy C applications. Read more on [Reddit](https://www.reddit.com/r/cpp/comments/vm8bwm/how_do_you_declare_pointer_variables/).

* Line 3: The `int` pointer, `p`, is initialized to the address of the `int` variable `x` .
  * Line 6: Take the value `p` points to; set it to 1.
  * `*p` dereferences `p` and gets the value at address `0x108`, which is `1`.
  * `p` is a pointer variable; `p`'s value is an address, which is `0x108`.
  * `&p` is the address of the variable `p`, which is `0x100`.
* Line 4: The `int` pointer `q` is initialized to the result of `a + 1`, which is **pointer arithmetic**! In the expression, the array name `a` is the address of the first element in `a`; incrementing by one yields the address of the _second_ element of `a`, at `0x110`.
  * Line 9: Take the value `q` points to; set it to 2.
  * `*q` dereferences `q` and gets the value at address `0x110`, which is `2`.
  * `q` is a pointer variable; `q`'s value is an address, which is `0x110`.
  * `&q` is the address of the variable `q`, which is `0x104`.
* Line 2: The array `a` is a memory block of 4 `int`s. The array starts at address `0x10c`, which is also the address of its first element.
  * Line 12: The array name `a` is the address of the first element in `a`; the statement `*a = 3;` gets this value and sets it to 3.
  * `*a` is **pointer arithmetic followed by a dereference**. The array name `a` is the address of the first element in `a`; dereferencing gets the element itself, which is `3`.
  * `a` is the address of the first element in `a` by definition, which is `0x10c`.
  * `&a` **gets the address of the array `a`**, which is `0x10c`.[^address-of-sizeof]

  [^address-of-sizeof]: We thought long and hard about how to explain `&a` and `sizeof(a)` (it involved sitting in a dark room with loud music). Both operations likely boil down to reasonable C design. After all, there must be _some_ way to refer to the address and the size of an array. Instead of erroring, these two expressions are likely the only exception to treating array names as synonymous with the address of the first element. If you, the reader, have a better explanation, we'd love to use it. Submit a pull request!
:::

(sec-array-decay)=
## Array names "decay" with functions

When used with functions, arrays **decay** to pointers in two ways. We use @code-decay below as an example.

(code-decay)=
```{code}c
:linenos:
int bar(int arr[], size_t nelems){
   … arr[…] … 
}
int main(void) {
    int a[5], b[10];
    … 
    bar(a, 5);
    …
}
```

**1. When used as formal parameters for function definitions.** On Line 2 of @code-decay, the definition `int arr[]` is syntactic sugar for the definition `int *arr`. We recommend using the latter where possible to avoid confusion.

**2. When passed in as arguments to function calls**. On Line 7 of @code-decay, the argument `a` is an array but decays to a pointer when the function is called. This decay effectively passes in the address of `a` as the first argument of `bar`.

:::{warning} Always pass in array lengths

Called functions will never know the bounds of arrays passed in as arguments. In fact, they won't even know that their pointer parameters are decayed arrays.
A pointer itself is not enough to deduce the length of the array, so if you need to keep track of the length of an array, you must use another variable or parameter (see Line 1 of @code-decay).
:::

(sec-array-sizeof)=
## `sizeof` with arrays

We've discussed `sizeof` many times. For arrays, the compile-time operator will evaluate to the size of the array, in bytes.[^address-of-sizeof] This observation informs the behavior of @code-array-sizeof:

(code-array-sizeof)=
```{code} c
:linenos:
void mystery(short arr[], int len) {
    printf("%d ", len);
    printf("%d\n", sizeof(arr));
}

int main() {
    short nums[] = {1, 2, 3, 99, 100};
    printf("%d ", sizeof(nums));
    mystery(nums, sizeof(nums)/sizeof(short));
    return 0;
}
```

:::{tip} "Quick" check
Assume a 64-bit architecture where `short`s are 16 bits. When @code-array-sizeof is run, what gets printed? 
:::

:::{note} Show Answer
:class: dropdown

Print output: `0 5 8`

* In Line 10, `sizeof(nums)` is in array’s declared scope. Evaluate to the total array size of five `short`s, i.e., 10.
* In Line 4, the value `len` is the result of evaluating `sizeof(nums)/sizeof(short)` in `main`, i.e., 10/2 = 5.
* In Line 8, `arr` is a function parameter. The formal declaration `short arr[]` is syntactic sugar for `short *arr`, so `arr` is a *pointer*. The size of a pointer is 64 bits, so `sizeof(arr)` is 8.

:::

In practice, C programmers will commonly use `sizeof(nums)/sizeof(short)` to count the **number of elements** in the array `nums`. Note that `nums` must be declared in the same scope, otherwise it decays to a pointer.

## Arrays are primitive! Reminders

Hopefully this section has convinced you that arrays are relatively primitive constructs:

* Array declarations set aside contiguous blocks in memory.
* Array names are synonymous with the location of the first element in the array.
* Arrays decay to pointers when used as function parameters or function arguments.

We close with a few final reminders of how this primitive nature begets responsible C practices.

:::{warning} Reminder 1
Keep array sizes in constants where possible.

Instead of code that manages multiple copies of integer constants,

```c
int i, arr[10];
for(i = 0; i < 10; i++) { ... }
```

choose to declare a "single source of truth":

```c
const int ARRAY_SIZE = 10;
int i, a[ARRAY_SIZE];
for(i = 0; i < ARRAY_SIZE; i++) { ... }
```
:::

:::{warning} Reminder 2
Array bounds are not checked during element access.

Element accessing is just pointer arithmetic with a dereference, so it is very easy to accidentally access off the end of an array. Can you find the subtle bug in this code?

```c
const int N = 100;
int foo[N];
int i;
...
for(i = 0; i <= N; ++i) {
   foo[i] = 0;
}
```

Improper access off the end of an array is referred to as **buffer overflow**,[^buffer-overflow]. This very common bug can corrupt other parts of the program, including internal C data. Buffer overflow exploits are security vulnerabilities that can crash programs

[^buffer-overflow]: Take Computer Security to learn more! [Wikipedia](https://en.wikipedia.org/wiki/Buffer_overflow)
:::

:::{warning} Reminder 3
Choose formal parameter definitions wisely.

`char *str` and `char str[]` are equivalent _when used as formal parameters in a function definition._ You will see both in practice. K&R suggests using the former where possible because it says more explicitly that the variable is a pointer.
:::

:::{warning} Reminder 4

Always pass in array lengths. See @sec-array-decay.
:::