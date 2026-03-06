---
title: "C Syntax"
subtitle: "Typed Variables and a Laundry List"
---

(sec-laundry-list)=
## Learning Outcomes

Treat this note as reference material until you need it. 

* Navigate the large laundry list of C topics here, and use the K&R reference to fill in details.
* Pay special attention to `typedef` and `struct`, which are used to declare and organize more complex data types.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/euf_2BqbdIw?si=a2uoMhvfi4gXmZ2_
:width: 100%
:title: "[CS61C FA20] Lecture 03.1 - C Intro: Basics: Intro and Background"
:::

::::

:::{warning}
Treat the rest of this note as reference material until you need it. The `typedef` and `struct` keywords will be particularly useful to know early.
:::

### `typedef`

`typedef` allows you to create an additional name (alias) for another data type.

```c
typedef uint8_t BYTE;
BYTE b1, b2;
```

The above code defines `BYTE` as another name for `uint8_t`, allowing us to declare `b1` and `b2` both as `BYTE` type. Side note: We don't recommend declaring multiple variables within the same value as above; it leads to confusing types when we introduce pointers next time.

### Structs

`struct`s are structured groups of variables. A `struct` is an abstract data type definition. It feels very much like Python where you have a class and dot fields, but you have a lot more control.

Structs and `typedef`s are often used in tandem[^typedef-struct]. Longer example:

[^typedef-struct]: Read more on [StackOverflow](https://stackoverflow.com/questions/1675351/typedef-struct-vs-struct-definitions).

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

* Lines 1 - 4: `SONG` is an alias for `typedef struct {int length_in_seconds; int year_recorded; }`.
* Line 6: Declare `song1` as a struct that has two `uint16_t` variables, `length_in_seconds` and `year_recorded`.
* Line 7-8: Instantiate the data within the `song1` variable.
* Lines 10-12: Do something similar for `song2`.
:::

Important:
* Structs are **not** objects.
* The dot (`.`) operator is therefore not a method call; it merely accesses data at a specific location. More later.

### C Preprocessor Macros, `#define`

`#define PI (3.14159)` is a CPP (C Preprocessor) macro. Prior to compilation, preprocess by performing string replacement in the program based on all `#define macros`. The line above replaces all `PI` with `(3.14159)` and in effect makes `PI` a "constant."

You often see CPP macros defined to create small "functions". But remember that because `#define` is effectively string replacement, these aren't actual functions—instead, you are simply changing the text of the program.

Because `#define` is effectively string replacement, this can produce interesting errors. For example:

```c
#define min(X,Y) ((X)<(Y)?(X):(Y))
next = min(w, foo(z));
```

is translated to this code, before compiling:

```c
next = ((w)<(foo(z))?(w):(foo(z)));
```

If `foo(z)` has a side effect, that side effect will occur twice!

:::{note} More about CPP

C source files first pass through the macro preprocessor (C Preprocessor or CPP) before the compiler sees code. For example, the CPP replaces comments with a single space.

All CPP commands begin with `#`:
* `#include "file.h"`: Inserts `file.h` into output
* `#include <stdio.h>`: Looks for `stdio.h` in a standard location, but otherwise equivalent to previous item
* `#define PI (3.14159)`: Define constant
* `#if/#endif`: Conditionally include text. Useful if this C program will be compiled onto different machines and therefore require architecture-dependent libaries

To see the result of preprocessing, you can use the `-save-temps` option in `gcc`. Read the GCC docs for more on [CPP](http://gcc.gnu.org/onlinedocs/cpp/) and [macros](https://gcc.gnu.org/onlinedocs/cpp/Macros.html).

:::

### Constants and Enums

The keyword `const` declares a **constant**; the variable is assigned a typed value once in the declaration. You can have a constant version of any of the standard C variable types, but values can't change during entire execution of program.

```c
const float  golden_ratio = 1.618;
const int    days_in_week = 7;
const double the_law      = 2.99792458e8;
```

An **enum** is a nice feature for enumerated constants. It declares a group of related integer constraints, like red=0, green=1, blue=2:

```c
enum cardsuit {CLUBS, DIAMONDS, HEARTS, SPADES};
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

float dollars_and_cents(float cost) { return cost; }
```

* You have to declare the type of data you plan to return from a function.
* The `return` type can be any C variable type (or `void`), and is placed to the left of the function name. The `void` return type implies that no value will be returned; we return to this later in the course.
* Parameters also must be typed.

Variables and functions must be declared before use. In older C versions, this meant that all function declarations needed to be at top of files, or included in headers. Function implementations could be described later in the file. In more recent C, functions can be used so long as they are declared in the file.

## Header files

Header files allow you to share functions and macros across different source files. For more info, see the [GCC header docs](https://gcc.gnu.org/onlinedocs/cpp/Header-Files.html#Header-Files).
