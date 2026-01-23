---
title: "C Variables, C Syntax"
subtitle: "Typed Variables and a Laundry List"
---

## Learning Outcomes

You are not expected to learn the details of C off the bat. But you should know how to declare and initialize basic variable types. Treat the second half of this note as reference material until you need it for homework and projects.

* Use basic variable types in C.
  * Use `stdint.h` typedefs where possible, because widths of basic integer types are processor-dependent.
  * Always remember that uninitialized variables contain garbage.
  * Remember that all values in C can be cast to booleans, and the only `false` values are `0`, `NULL`, and `false`.
* Navigate the large laundry list of other details.
  * Pay special attention to `typedef` and `struct`, which are used to declare and organize more complex data types.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/euf_2BqbdIw?si=a2uoMhvfi4gXmZ2_
:width: 100%
:title: "[CS61C FA20] Lecture 03.1 - C Intro: Basics: Intro and Background"
:::

::::

## C Basic Variable Types

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

:::{warning} Keep in mind: `sizeof`

**The size of a variable is known at compile time**. We will see why when we discuss C memory management in a few lectures.

`sizeof` is a compile time operator. `sizeof(arg)` gives the size of a data type or variable, in **bytes**.

:::

While types of variables can't change, you can typecast values and store them in other variable types. This is discussed in the laundry list.

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
We encourage you to use `inttypes.h`, part of the C standard library. It specifies unsigned and signed types[^typedef-int] like `uint8_t` and `int32_t`, where width is specified in bits. So `int32_t x;` would declare `x` as a 32-bit wide signed integer that uses two's complement representation.

[^typedef-int]: More precisely, `inttypes.h` declares many `typedef` names of the form `intN_t` and `uintN_t` that designate two's complement and unsigned integer types, respectively, of specific bitwidth `N`.

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

## More C Syntax

:::{warning}
Treat the rest of this note as reference material until you need it for homework and projects. The `typedef` and `struct` keywords will be useful to grasp earlier than the rest of this section.
:::

### `typedef`

`typedef` allows you to create an additional name (alias) for another data type.

```c
typedef uint8_t BYTE;
BYTE b1, b2;
```

The above code defines `BYTE` as another name for `uint8_t`, allowing us to declare `b1` and `b2` both as `BYTE` type. Side note: We don't recommend declaring multiple variables within the same value as above; it leads to confusing types when we introduce pointers next time.

### Structs

`struct`s are structured groups of data. A `struct` is an abstract data type definition. Within the struct, each name is a **field** that refers to a **member** of the struct. It feels very much like Python where you have a class and dot fields, but you have a lot more control.

Structs and `typedef`s are often used in tandem. Longer example:

```{code} c
:linenos:
typedef struct {
    uint16_t length_in_seconds;
    uint16_t year_recorded;
} SONG;

SONG song1;
song1.length_in_seconds  =  213;
song1.year_recorded      = 1994;

SONG song2;
song2.length_in_seconds  =  248;
song2.year_recorded      = 1988;
```

:::{note} Code, explained
:class: dropdown

* Lines 1 - 4 `SONG` is an alias for `typedef struct {int length_in_seconds; int year_recorded; }`
* Line 6: Declare `song1` as a struct that has two `uint16_t` fields, `length_in_seconds` and `year_recorded.
* Line 7-8: Initialize the members within the `song1` variable.
* Lines 10-12: Do something similar for `song2`.
:::

Important:
* Structs are **not** objects.
* The dot (`.`) operator is therefore not a method call; it merely accesses data at a specific location. More later.

### C Preprocessor Macros, `#define`

`#define PI (3.14159)` is a CPP (C Preprocessor) Macro. Prior to compilation, preprocess by performing string replacement in the program based on all `#define macros`. The line above replaces all `PI` with `(3.14159)` and in effect makes `PI` a "constant."

You often see CPP macros defined to create small "functions". But remember that because `#define` is effectively string replacement, these aren't actual functions—instead, you are simply changing the text of the program.

Because `#define` is effectively string replacement, this can produce interesting errors. For example:

```c
#define min(X,Y) ((X)<(Y))
next = min(w, foo(z));
```

is translated to this code, before compiling:

```c
next = ((w)<(foo(z))?(w):(foo(z)));
```

If `foo(z)` has a side effect, that side effect will occur twice!

:::{note} More about CPP
:class: dropdown

C source files first pass through macro processor (C Pre-Processor, or CPP), before the compiler sees code. For example, the CPP replaces comments with a single space.

All CPP commands begin with `#`:
* `#include "file.h"`: Inserts `file.h` into output
* `#include <stdio.h>`: Looks for `stdio.h` in a standard location, but otherwise equivalent to previous item
* `#define PI (3.14159)`: Define constant
* `#if/#endif`: Conditionally include text. Useful if this C program will be compiled onto different machines and therefore require architecture-dependent libaries

To see the result of preprocessing, you can use the `-save-temps` option in `gcc`. Read more about [CPP on the GCC docs](http://gcc.gnu.org/onlinedocs/cpp/)

:::


### Constants and Enums

The keyword `const` declares a **constant**; the variable is assigned a typed value once in the declaration. You can have a constant version of any of the standard C variable types, but values can't change during entire execution of program.

```c
const float  golden_ratio = 1.618;
const int    days_in_week = 7;
const double the_law      = 2.99792458e8;
```

An **enum** is a nice feature for enumerated constants It declares a group of related integer constraints, like red=0, green=1, blue=2:

```c
enum cardsuit {CLUBS,DIAMONDS,HEARTS,SPADES};
enum color {RED, GREEN, BLUE};
```

My strong recommendation: don't peek under the hood to find out what those bits are. Instead, use the abstraction; your code should work even if you rearrange the ordered set.

### Control Flow

Very similar to Java. Not much to say here beyond two items:

**Curly braces**: Bodies of if-else conditionals and loops can be surrounded by curly braces or stand-alone. See the [previous section](#c-vs-java-sec).

**While loops**: In addition to the standard `while` loop, C also has the `do-while` loop:

```c
do statement while (expression);
```

**Switch**: Until you reach a break statement, you will continue to execute statements, even those in subsequent `case`s.

```c
switch (expression){
  case const1:    statements
  case const2:    statements
  default:        statements
}
break;

```

When writing C code, we don't recommend the `do-while` loop, nor the dreaded `goto`. But we'll find both ideas useful when we discuss control flow in assembly language. More (much) later.


### Functions

Two example functions:

```c
int number_of_people(int class1, int class2) {
  return class1 + class2;
}

float dollars_and_cents (float cost) {  return cost; }
```

* You have to declare the type of data you plan to return from a function.
* The `return` type can be any C variable type (or `void`), and is placed to the left of the function name. The `void` return type implies that no value will be returned; we return to this later in the course.
* Parameters also must be typed.

Variables and functions must be declared before use. In older C versions, this meant that all function declarations needed to be at top of files, or included in headers. Function implementations could be described later in the file. In more recent C, functions can be used so long as they are declared in the file.
