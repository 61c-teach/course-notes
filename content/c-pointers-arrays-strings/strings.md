---
title: "C Strings"
---

(sec-strings)=
## Learning Outcomes

* Differentiate between an array of characters and a C string.
* Know how to use standard C library functions in `string.h`.

No video.

## C Strings vs. `char` arrays

A **C string** (i.e., "string") is just an array of characters, followed by a **null terminator**. A **null terminator** is the byte of all 0's, i.e., the '\0' character. The ASCII value of the null terminator is `0`. 

The null terminator lets us determine the length of a C string from just a pointer to the beginning of the string.

When you make a character array, you should terminate the array with a null terminator. For example, the code

```c
char my_str[] = {'e', 'x', 'a', 'm', 'p', 'l', 'e', '\0'};
```

declares an 8-byte `char` array on the stack, then initializes the array with the 8 specified `char`s. Read about the stack in [another section](@sec-stack).

If you are using double quotes (`"`) to create a string, the null terminator is implicitly added, so you should not add it yourself. For example the code

```c
char *my_str = "example";
```

declares a pointer to the 8-byte string literal (which includes the null terminator). 

:::{tip} Quick check

In the code below, is `arr` a C string?

```c
char arr[] = {'h', 'e', 'l', 'l', 'o'};
```
:::

:::{note} Show Answer
:class: Dropdown

No. While `arr` is a `char` array, it does not end in a null terminator and by definition is not a C string.
:::

:::{warning} Allocate enough memory for null-terminators

When allocating memory for a string, there must be enough memory to store the characters within the string and the null terminator. Otherwise, you might run into undefined behavior. However, the array could be larger than the string it stores.

:::

## `<string.h>`

C strings have functions in the C standard library, imported via the header `<string.h>`. See [Wikibooks](https://en.wikibooks.org/wiki/C_Programming/String_manipulation#The_%3Cstring.h%3E_standard_header) for descriptions of commonly used `<string.h>` functions. Here are the two that you may encounter in this course:

* `strlen`: computes the length of a string by counting the number of characters before a null terminator
* `strcpy`: copies a string from one memory location to another, one character at a time until it reaches a null terminator (the null terminator is copied as well).

To read about any standard string function, we recomment the manual pages ("man pages"). You can type the following into a terminal:

```
man strlen
```

Consider the following code, which is a reasonable implementation of `strlen`[^strlen-practical]. The `strlen` function is the standard C library function that computes the length of a string, minus the null terminator.

[^strlen-practical]: See [glibc](https://github.com/lattera/glibc/blob/master/string/strlen.c) for a more practical, efficient implementation of `strlen`.

```{code} c
:linenos:

int strlen(char s[]) {
    size_t n = 0; 
    while (*(s++) != 0) { n++; } 
    return n;
}
```

:::{note} Explanation

* Line 1: Array syntax in parameters are syntactic sugar for pointers; here, it is equivalent to `char *s`, declaring `s` as a pointer to a `char`. Here, we further assume that `s` points to a C string, but there is no way of explicitly describing this contraint via type declaration.
* Line 2: Declare a local unsigned integer `n` that is large enough to hold any count of bytes in memory (this is the `size_t` typedef)
* Line 3: Lots going on in this while loop.
  * Body: Increment `n` by one.
  * Condition:
    * Increment the value of `s` by one. This evaluates to the Before doing that, get the current value at `s`.
:::

## String literals

Strings created with the following syntax are read only, or **immutable**. After this **string literal** is created, a C program cannot dereference `my_immutable_str` and read its data, but it cannot alter the value of the string during execution.

```c
char *my_immutable_str = "Hello";
```

By contrast, the below declaration creates a string that _is_ mutable:

```c
char my_str[] = "hello";
```

:::{note} Explanation

Why is the first string immutable while the second string is mutable? The answer is [memory layout](#sec-mem-layout). The first string is stored in the read-only data segment[^rodata] of memory, while the second string is stored on the stack.

:::

[^rodata]: String literals are located in a read-only data segment, which we don't discuss in this class. Read more in the footnotes when we discuss [memory layout](#sec-mem-layout).