---
title: "Function Pointers, Generics"
title: "Introduction"
---

(sec-generics)=
## Learning Outcomes

* Identify generic functions used in heap memory management.
* Understand function pointer syntax.

In this chapter, we practice our C memory skills with two more concepts involving pointers.

### Function Pointers

In a [previous chapter](#sec-pointers) we also briefly mentioned **function pointers**.

```c
int (*fn) (void *, void *) = &foo;
(*fn)(x, y);
```

In the first line, `fn` is a function that accepts two `void *` pointers and returns an `int`. With this declaration, we set it to pointing to the function `foo`. The second line then calls the function with arguments `x` and `y`.

Function pointers allow us to define **higher-order functions**, such as map, filter, and generic sort.


Normally a pointer can only point to one type. In a [future chapter](#sec-generics) we discuss the `void *` pointer, a **generic pointer** that can point to anything. In this course we will use the generic pointer sparingly to help avoid program bugs...and security issues...and other things... That being said, we will encounter generic pointers when working with memory management functions in the C standard library (`stdlib`).

### Generic Pointers

As mentioned in a [previous chapter](#sec-pointers), normally pointers can only point to one type. Declaring `int *p;` tells us that `p` should point to an `int` value, and it also determines `p`'s operation with operators like pointer arithmetic (what byte stride to adjust by) and dereferencing (how many bytes to read).

In this section, we discuss the `void *` pointer, a **generic pointers** that can point to anything. While we said that we would use generics sparingly to avoid program bugs, you have already encountered your first generics! Check out the `stdlib.h` heap memory management functions:

* `void *malloc(size_t n)`
* `void free(void *ptr)`
* `void *realloc(void *ptr, size_t size)`

These functions are **generic functions** (or **generics**[^java] for short) because they return or use do not assume anything about the type of the memory being allocated or freed. As described in a [previous section](#sec-heap), we cast the return values of `malloc` and `realloc` calls to the appropriate pointer types and use them in local, typed pointer variables.

Sometimes we'll want to write our own generics. We'll see the benefits and pitfalls in this chapter.

[^java]: Java also supports generics to (among other things) support the creation of data structures that can hold any reference type, e.g.,  `DataStructure<T>`
