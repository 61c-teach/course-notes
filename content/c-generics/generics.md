---
title: "Generics"
---

(sec-generic-swap)=
## Learning Outcomes

* Understand why generic pointers (`void *`) cannot be dereferenced
* Use `memcpy` and `memmove` to access memory in generic functions

In this section, we focus on implementing **generic** swap. Recall our goals for generic functions from the [introduction](#sec-generics):

1. Generics should work regardless of argument type.
1. Generics should work by accessing blocks of memory, regardless of the data type stored in those blocks.

We translate these high-level ideas into pseudocode for generic swap:

(code-swap-pseudo)=
```c
void swap(void *ptr1, void *ptr2) {
  // 1. store a copy of data1 in temporary storage

  // 2. copy data2 to location of data1

  // 3. copy data in temporary storage to location of data2
}
```

The above parameters approximately achieve the first of our goals for generic functions. By declaring `ptr1` and `ptr2` as generic pointers with `void *`, we effectively assume there is some data at the locations that `ptr1` and `ptr2` point to that need to be swapped. (We will see later that some adjustments to this function signature are necessary.)

What about the function body? Our [`swap_int` function](#code-swap-int) function from earlier uses the dereference operator (`*`) to read and write data to and from the memory pointed to by `ptr1` and `ptr2`. We will see in this section that dereferencing generic pointers _will not work_, and we must use explore other operations for accessing memory.

## You cannot dereference `void *`

It is natural to want to write a generic swap function following the pattern of `swap_int`, `swap_short`, and `swap_string` from [earlier](#sec-swap-motivation). However, the following code will _not_ work:

(code-swap-faulty)=
```{code} c
:linenos:
/* produces compiler errors */
void swap_faulty(void *ptr1, void *ptr2) {
  void temp = *ptr1;
  *ptr1 = *ptr2;
  *ptr2 = temp;
}
```

When we attempt to compile with `gcc`, the compiler is _not happy_:

```
$ gcc -c -o swap.o swap.c -Wall -std=c99 -g
swap.c: In function ‘swap_faulty’:
swap.c:10:8: error: variable or field ‘temp’ declared void
   10 |   void temp = *ptr1;
      |        ^~~~
swap.c:10:15: warning: dereferencing ‘void *’ pointer
   10 |   void temp = *ptr1;
      |               ^~~~~
swap.c:10:15: error: void value not ignored as it ought to be
   10 |   void temp = *ptr1;
      |               ^
swap.c:11:3: warning: dereferencing ‘void *’ pointer
   11 |   *ptr1 = *ptr2;
      |   ^~~~~
swap.c:11:11: warning: dereferencing ‘void *’ pointer
   11 |   *ptr1 = *ptr2;
      |           ^~~~~
swap.c:11:9: error: invalid use of void expression
   11 |   *ptr1 = *ptr2;
      |         ^
swap.c:12:3: warning: dereferencing ‘void *’ pointer
   12 |   *ptr2 = temp;
      |   ^~~~~
swap.c:12:9: error: invalid use of void expression
   12 |   *ptr2 = temp;
      |         ^
```

There are two main reasons this code won't work. First, we cannot declare untyped variables, so a declaration like `void temp;` errors. Second, dereferencing `void *` pointers _does not yield_ [_anything usable_](https://www.gnu.org/software/c-intro-and-ref/manual/html_node/Void-Pointers.html).

Consider what it means to dereference a pointer, say, declared and initialized as `int32_t *p = ...;` pointer means. This means we know that the `p` is an address of an `int32_t` value, and dereferencing with `*p` _accesses those 4 bytes of memory_. This allows the compiler to translate later statements like `(*p) + 4` into integer arithmetic, _because it knows that `*p` is an `int32_t`-typed value.

:::{hint} You can only dereference typed pointers!
To dereference a pointer, we must know the number of bytes to access in memory at **compile time**. Generic pointers (`void *`) **cannot** use the dereference operator!
:::

:::{warning} You _can_ dereference `void **`!

By contrast, `void **` is **not** a generic pointer, because it points to a known type. It is terribly confusing that the following code compiles and runs fine:

```c
void **doubleptr = …;
printf("%p\n", *doubleptr);
```

Note that the size of _any_ pointer is known at compile-time, because all pointers are word-sized. `sizeof(*doubleptr)` is `sizeof(void *)` which is the size of an address. In this case, dereferencing `doubleptr` in the `printf` call evaluates to a generic pointer, i.e., an address. _Generic pointers are typed_—they have type `void *`!

:::

## Generic memory access with `memcpy`, `memmove`

Generics cannot use the dereference operator (`*`) because the type of the data pointed to by generic pointers is unknown. Instead, generics use two functions from the C standard library: `memcpy` and `memmove`.

```c
void *memcpy(void *dest, const void *src, size_t n); 
void *memmove(void *dest, const void *src, size_t n); 
```

These `string.h` generic functions **copy** `n` bytes from memory area `src` to memory area `dest`. In other words, they allow read/write access to data in memory using a `void *` pointer!

:::{hint} Use `memcpy` for performance reasons, unless you know memory areas overlap.

From the Linux `man` pages for `memcpy`: "The memory areas must not overlap."

By contrast, `memmove`: "The memory areas may overlap: copying takes place as though the bytes in `src` are first copied into a temporary array that does not overlap `src` or `dest`, and the bytes are then copied from the temporary array to dest."

Because of the above, `memcpy` is generally faster[^memmove-slow]

[^memmove-slow]: [Some implementations](https://clc-wiki.net/wiki/memmove) of memmove actually employ temporary storage (like in C99), which risks running out of memory. Read more on [StackOverflow](https://stackoverflow.com/questions/4415910/memcpy-vs-memmove).

:::

## Generic Swap

Let's consider how the generic `memcpy` will replace dereferencing in one of the statements in our [`swap_int` function](#code-swap-int) function:

```c
// in swap_int:
// ptr1, ptr2 are both declared int *
*ptr1 = *ptr2; 
```

This statement is simply a `memcpy`—it copies the bytes of the `int` at `ptr2` into the corresponding bytes at `ptr1`!

```c
// equivalent to swap_int's *ptr1 = *ptr2;
memcpy(ptr1, ptr2, sizeof(int));
```

`memcpy` requires knowing how many bytes to copy from a source to a destination. Recall from [an earlier chapter](#sec-array-decay) that with pointer parameters, functions _will not know_ how much data is pointed to. We must therefore update our [pseudocode](#code-swap-pseudo) to add an additional size parameter:

(code-swap-pseudo-size)=
```c
void swap(void *ptr1, void *ptr2, size_t nbytes) {
  // 1. store a copy of data1 in temporary storage

  // 2. copy data2 to location of data1

  // 3. copy data in temporary storage to location of data2
}
```

### Implementation

Finally, we are ready to implement our **generic swap** function, `swap`!

:::{card}
Generic swap function
^^^
(code-swap-generic)=
```{code} c
:linenos:
void swap(void *ptr1, void *ptr2, size_t nbytes) {
  // 1. store a copy of data1 in temporary storage
  char temp[nbytes];
  memcpy(temp, ptr1, nbytes);

  // 2. copy data2 to location of data1
  memcpy(ptr1, ptr2, nbytes);

  // 3. copy data in temporary storage to location of data2
  memcpy(ptr2, temp, nbytes);
}
```
:::

The `swap` function above uses `memcpy` and therefore assumes that `ptr1` points to `nbytes` of memory and `ptr2` points to nbytes of memory, and that there is no overlap in these two memory areas.

:::{warning} What's up with that `char temp[nbytes]` declaration?

Our non-generic [`swap_int` function](#code-swap-int) declared `temp` to be a local variable large enough to hold `sizeof(int)` bytes. To do the same in a generic function, we must declare a similar temporary "generic" storage.

Because `sizeof(char)` is defined as one byte in C, we can achieve this generic storage by declaring a local `char` array, i.e., a **buffer**.
:::

Now, let's use this new generic `swap` to swap two `int`s:

(code-swap-generic-main)=
```{code} c
:linenos:
int data1 = 22;
int data2 = 61; 
swap(&data1, &data2, sizeof(data1));
```

The function call looks near-identical to [our non-generic call to `swap_int`](#code-swap-int-main)! Just like before, we pass in the locations of the two values we want to swap. The only modification is that we now additionally pass in the size of the value(s), which we assume to be identical.

The below slidedeck traces through `swap` in action using a toy example. Initially, `data1` stores `22` at address `0x100`, and `data2` stores `61` at address `0x104`. Assume `sizeof(int)` is 4.


:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vTd9HX8X0gtVYXfqM9Fv7-BkzzX7HHsRTjQLMV8zu9FqBTT0-NKepc9RWIJW9lKReYLZAPo16cX3G4V/pubembed?start=false&loop=false
:width: 100%
:title: "Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1pIqociLW0G65W5Bm4kPh9Kjq7UB64VdcOkhaA1zStxg/edit?usp=sharing)"
:::

## Application: `swap_ends`

Finally, let’s consider generics that operate on a generic array of values. We will need to do pointer arithmetic!

We would like to use the `swap` function to write a function `swap_ends`, that swaps the first and last elements in an array.

The [code below](#code-swap-ends-main) will update the array `arr` as shown in @fig-swap-ends:

(code-swap-ends-main)=
```{code} c
int main() {
  ...
  int32_t arr[] = {1, 2, 3, 4, 5};
  int32_t n = sizeof(arr)/sizeof(arr[0]);
  swap_ends(arr, n, sizeof(arr[0]); // to implement
  ...
}
```

:::{figure} images/swap-ends.png
:label: fig-swap-ends
:width: 60%
:alt: "TODO"

`swap_ends` swaps the elements `1` and `5` in the `arr` array.
:::

The function `swap_ends` has the following inputs and output:

```c
void swap_ends(void *arr, size_t nelems, size_t nbytes);
```

* `arr`: A generic pointer to a memory block (recall that all "array" arguments decay to pointers)
* `size_t nelems`: Number of elements in the array
* `size_t nbytes`: Size of each element, in bytes

The last two parameters specify (1) how large the block of memory ("array") at `arr` is and (2) how to access sequential elements within the block. Combined, `nelems` and `nbytes` should help us access the last element in the array.

:::{tip} Fill in the blank

Consider the partial implementation of `swap_ends` below. What goes in the blank?

```c
void swap_ends(void *arr, size_t nelems, size_t nbytes) {
    swap(arr, ______ , nbytes); 
}
```

* **A.** `arr + nelems - 1`
* **B.** `arr + (nelems - 1)*nbytes`
* **C.** `(char *) arr + (nelems - 1) * nbytes`
* **D.** `(char *) (arr + (nelems - 1) * nbytes)`
* **E.**  Something else

:::

**Answer**: Let's consider what `swap` does. It takes two pointers and swaps `nbytes` at those positions. To swap the ends of the array in @fig-swap-ends, we would like to pass in `0x100` and `0x104` to swap.

Option C does this explicitly:

* `(char *) arr`: Cast generic `arr` to a `char *` to perform **bytewise arithmetic**.
* Add `(nelems - 1) * nbytes` to the `(char *) arr` pointer.
  * Here, because the pointer is to a `char`, pointer arithmetic is **effectively bytewise**.
  * To point to the last element, we jump to the end of the array (in bytes), then go back by one element's length, in bytes.

The final implementation of `swap_ends`:

```c
void swap_ends(void *arr, size_t nelems, size_t nbytes) {
    swap(arr, (char *) arr + (nelems - 1) * nbytes, nbytes); 
}
```

:::{note} Other options: Non-standard C

Options B and D also work (without the `(char *)` cast) but are [not standard C](https://stackoverflow.com/questions/10058234/void-vs-char-pointer-arithmetic), which does not define pointer arithmetic on `void *` pointers. However, these options will compile and run fine on the course machines with `gcc`, which is a compiler to _GNU_ C.

:::


(sec-generic-strings)=
## More Generics in `string.h`

The `string.h` header in the C standard library contains string functions _and_ functions that handle memory, like `memcpy`, `memmove`, and `memset`.

At first glance, you may then find the header name a bit misleading. However, as we have seen, memory handling functions operate byte-by-byte. Furthermore, by definition strings are byte arrays that happen to be null-terminated! Because byte arrays can be accessed with `char *` pointers, many implementations of string functions simply assume `char *` operands.

For example, the glibc implementation of `strncpy` uses `memset` and `memcpy`. From the Linux `man` pages:

```
... at most n bytes of src are copied. Warning: If there is no null byte among
the first n bytes of src, the string placed in dest will not be 
null-terminated. If the length of src is less than n, strncpy() writes 
additional null bytes to dest to ensure that a total of n bytes are written.

...[returns] a pointer to the destination string dest.
```

 Here is a simplified version of the [full implementation](https://codebrowser.dev/glibc/glibc/string/strncpy.c.html) in glibc:

```{code} c
:linenos:
char *strncpy(char *dest, const char *src, size_t n) {
  size_t size = strnlen(src, n); // max(strlen(src), n)
  if (size != n) 
    memset(dest + size, '\0', n – size);
  return memcpy(dest, src, size);
}
```

:::{note} Explanation
:class: dropdown

Each line, explained:

1. Function declaration.
1. `size` is set to $\max ($`strlen(src)`, `n` $)$. From the Linux `man` pages: "The `strnlen()` function returns `strlen(s)`, if that is less than  `maxlen`, or `maxlen` if there is no null terminating (`'\0'`) among the first `maxlen` characters pointed to by `s`."
1. Recall that conditional statements without curly braces treat the next statement as the singular statement of the conditional body (here, Line 4).
1. Write in null terminators beyond the length of `src`. If `n` is at least `strlen(src) + 1` bytes, this line null-terminates the result.
1. Copy `size` bytes from `src` to `dest`.

:::
