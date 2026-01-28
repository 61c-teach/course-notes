---
title: "C Strings"
---

## Learning Outcomes

* Differentiate between an array of characters and a C string.
* Know how to use standard C library functions in `string.h`.

No video.

## C Strings vs. `char` arrays

A **C string** is just an array of characters, followed by a **null terminator**. A **null terminator** is the byte of all 0's, i.e., the '\0' character.

The null terminator lets us determine the length of a C string from just a pointer to the beginning of the string. Consider the following code, which is a reasonable implementation of `strlen`[^strlen-practical], the standard C library function that computes the length of a string, minus the null terminator.

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


## `<string.h>`

C strings have functions in the C standard library, imported via the header `<string.h>`. See [Wikibooks](https://en.wikibooks.org/wiki/C_Programming/String_manipulation#The_%3Cstring.h%3E_standard_header) for descriptions of commonly used `<string.h>` functions.