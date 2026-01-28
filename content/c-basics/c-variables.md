---
title: "C Variables"
subtitle: "Typed Variables and a Laundry List"
---

## Learning Outcomes

You are not expected to learn the many, many details of C off the bat. But you should know how to declare and initialize variables.

* Declare and initialize basic variable types in C.
* Use `stdint.h` typedefs where possible, because widths of basic integer types are processor-dependent.
* Always remember that uninitialized variables contain garbage.
* Remember that all values in C can be cast to booleans, and the only `false` values are `0`, `NULL`, and `false`.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/euf_2BqbdIw?si=a2uoMhvfi4gXmZ2_
:width: 100%
:title: "[CS61C FA20] Lecture 03.1 - C Intro: Basics: Intro and Background"
:::

::::

## C Basic Types

Just like in Java, all C variables are typed.

:::{table} C Basic Types; see [Wikibooks](https://en.wikibooks.org/wiki/C_Programming/Language_Reference#Table_of_data_types).
:label: tbl-c-types
:align: center

| Type | Description | Example |
| :--- | :--- | :--- |
| `int` | Integer Numbers (including negatives) | `0`, `78`, `-217`, `0x7337` |
| `unsigned int` | Unsigned Integers (i.e., non-negatives) | `0`, `6`, `35102` |
| `float` | Floating point decimal | `0.0`, `3.14159`, `6.02e23` |
| `double` | Equal or higher precision floating point | `0.0`, `3.14159`, `6.02e23` |
| `char` | Single character | `'a'`, `'D'`, `'\\n'` |
| `short` | Shorter int | `-7` |
| `long` | Longer int | `0`, `78`, `-217`, `301720971` |
| `long long` | Even longer int | `3170519272109251` |
:::

### Why are variables typed?

A variable's type is fixed at compile-time and cannot change for the duration of the program. This actually helps the compiler determine how to translate the program to machine code designed for the computer’s architecture:

* How many bytes does this variable take up in memory?
* What operators can this variable support?

:::{card}
`uint16_t y = 38;`
^^^
* `y` stores a 16-bit unsigned integer. (See [below](#inttypes) regarding `uint16_t`)
* `y` is initialized to a 16-bit unsigned representation of 38, i.e., the 16 bits `0000 0000 0010 0110`.
:::

### `sizeof`

:::{warning} `sizeof` is a compile-time operator

**The size of a variable is known at compile time**. We will see why when we discuss C memory management in a few lectures.

`sizeof(arg)` is **not a function call**! Instead, the C compiler resolves every `sizeof(arg)` value to the size of a data type or variable `arg`, in **bytes** and continues compiling the resulting program.

:::

While types of variables can't change, you can typecast values and define new variable types. This is discussed in the [laundry list](sec-laundry-list=).

### Sizes of Integer Types


:::{tip} Quick Check

Which of the following is true about the `int` C data type?
Select all that apply.

* A. Two's complement integer
* B. Contains all integers in the range $[−32767, +32767]$
* C. `sizeof(int) = 2`
* D. `sizeof(int) = 16`
* E. `sizeof(int) = 4`
* F. `sizeof(int) = 64`
* G. None of the above

Note: $2^{15} = 32768$.

:::

:::{note} Show Answer
:class: dropdown

Only (A) is always true across processors. The C standard does not define the size of `int`; it only guarantees that it is at least 8 bits wide.
:::

The C standard does not define the absolute size of all integer types! The standard only defines that **`char` is 1 byte wide**. All other types have _relative_ size guarantees:

$$
\texttt{sizeof(long long)} \geq \texttt{sizeof(long)}  \geq \texttt{sizeof(int)} \geq \texttt{sizeof(short)}
$$

Remember, C was built for efficiency. Early on, they determined that the size of `int` was the size most efficient to read, write, and operate on two's complement numbers. So a 32-bit machine would often have 4-byte integers (4 bytes = 32 bits) if the datapath was built for 32-bit values, and a 64-bit machine would have 8-byte integers (8 bytes = 64 bits), but not always.

:::{table} Integer types in C, Java and Python
:label: tbl-int-types
:align: center

| Language | size of integer (in bits) |
|:--- | :--- |
| Python | $\geq$ 32 bits (plain ints), infinite (long ints) |
| Java | 32 bits |
| C | Depends on computer; 16 or 32 or 64 |
:::

To write a C program, then, one would _really_ need to know the intricacies of hardware. But this loses the benefit of portability; code that assumes an $N$-bit-wide datatype (say, because we want to represent $2^N$ non-integer things) might use `int`, then need to change types to work on another machine.

(inttypes)=
:::{hint} Use `inttypes.h` or `stdint.h`

We encourage you to use `inttypes.h` or `stdint.h`, part of the C standard library[^inttypes-vs-stdint]. It specifies unsigned and signed types[^typedef-int] like `uint8_t` and `int32_t`, where width is specified in bits. So `int32_t x;` would declare `x` as a 32-bit wide signed integer that uses two's complement representation.

:::

[^typedef-int]: More precisely, `inttypes.h` declares many `typedef` names of the form `intN_t` and `uintN_t` that designate two's complement and unsigned integer types, respectively, of specific bitwidth `N`.

[^inttypes-vs-stdint]: See [StackOverflow](The array name `a` is the address of the first element in `a`; ) for differences between `inttypes.h` and `stdint.h`. For the purposes of this class, either is fine.

## Variable declaration and initialization

**Cautionary note**: A lot of C has "undefined behavior." It is totally possible for a C program will run one way on one computer and some other way on another. It is even possible to run differently each time the program is executed on the same machine![^heisenbug]

[^heisenbug]: “Heisenbugs” are bugs that seem random/hard to reproduce, and seem to disappear or change when debugging. By comparison, "Borhbugs" are repeatable and reproducible.

Consider the following code. What is printed?

```{code} c
:linenos:
#include <stdio.h>
int main(int argc, char *argv[]) {
    int32_t x = 0;
    int32_t y;
    
    printf("before: x=%d, y=%d\n", x, y);
    x++;
    y += x;

    printf(" after: x=%d, y=%d\n", x, y);
    return 0;
}
```

I tried running this on the CS 61C machines and got the following output the first time, and different output after I inserted some comments:

```
before: x=0, y=22621
 after: x=1, y=22622
```

:::{warning} Unlike Java, C variable declarations do **not** initialize variables to default values.

Take a look at line 4. Line 4 just **declares** `y` as type `int`; it does not **initialize** `y` to any default value. 

Why doesn't Line 8 cause an error? Recall that any 32-bit value can be interpreted as a two's complement integer. At compilation time, the compiler recognizes that `y += x;` is a valid operation based on the types of `x` and `y`. At runtime, the program simply takes whatever 32 bits are at `y` and adding the value of `x`, then updating those 32 bits.
:::


After editing comments and rerunning, I got different output a second time. What's happening?

## The C `bool` type

The `bool` type is a built-in type as of C23. For earlier versions (e.g., C17), we need to `#include <stdbool.h>` for definitions of `true` and `false`.

Values in C are truthy—meaning, every value can be interpreted as true or false.

* False values:
  * `0`, i.e., all bits of this value are 0
  * `NULL`, which is also defined as `0`, but is commonly used for pointers. More later.
  * `false`, if `stdbool.h` is used
* True values: Everything else.[^truthy-python]
  
[^truthy-python]: Python also has truthy and falsy values. See [Stack Overflow](https://stackoverflow.com/questions/39983695/what-is-truthy-and-falsy-how-is-it-different-from-true-and-false).


:::{tip} Quick Check

What does the following code do?

```c
if (42) {
  printf("meaning of life\n");
}
```

:::

:::{note} Show Answer
:class: dropdown

It prints `meaning of life` (plus a newline) because regardless of the integer width used, the constant `42` will have a non-zero bit representation. All non-zero bit representations are `true`.
:::
