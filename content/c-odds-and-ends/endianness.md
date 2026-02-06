---
title: "Words, Endianness"
---

(sec-endianness)=
## Learning Outcomes

* Gain an intuition of how hardware word size can impact memory layout of a compiled C program.
* Differentiate between 32-bit and 64-bit architectures.
* Read memory layouts of C programs compiled on little endian machines.
* Understand how padding and packing can impact the memory layout of members within a C struct.

::::{note} 🎥 Lecture Video: Endianness
:class: dropdown

:::{iframe} https://www.youtube.com/embed/wXGhuhLKkqg
:width: 100%
:title: "[CS61C FA20] Lecture 07.3 - RISC-V Intro: RISC-V add/sub Instructions"

This video is taken from later in Fall 2020 and references RISC-V assembly, which we'll talk about in a few units. For now, please start from 7:33 onwards.
:::
::::

(sec-words)=
## Words

What's in a word? In computer architecture, a hardware **word** is an important unit of data. The word size determines many aspects of a computer's structure and operation, from how the computer accessses memory to how the compiler translates a single C arithmetic operation into multiple assembly instructions. A 32-bit architecture has a word size of 32 bits, or 4 bytes. A 64-bit architecture has a word size of 64 bits, or 8 bytes.

On most modern architectures, the size of the word often determines (among other things[^word]) the **largest possible address** and therefore the size of a C pointer (see [address space](@sec-address-space). A 32-bit architecture has 4-byte pointers; a 64-bit architecture has 8-byte pointers. The word size also often determines the **smallest accessible or most efficiently accessible unit of memory**. On a 32-bit architecture, memory reads and writes are often in units of 4-bytes; on a 64-bit architecture, in units of 8-bytes.

[^word]: The hardware word size is a natural unit of access in a computer and corresponds to the hardware register size (to discuss in a later section). Correspondingly, this register size determines the smallest accessible unit of memory, the size of an address, etc.

We will cover hardware words in much more detail when we learn about instruction set architectures. For now, we use the notion of a word to remind us that compiled C programs produce memory layouts that are *architecture-dependent*. We discuss a few architecture-dependent characteristics of compiled programs below.

(sec-address-space)=
## The Address Space

The **address space** is the hypothetical range of addressable memory locations on a particular machine. For example, a 32-bit architecture, a pointer can address $2^32$ locations in memory[^in-practice]. Because memory is byte-addressable and contiguous, our address space size for a program is therefore $2^32$ bytes (or 4 GiB, "four gibi-bytes". We cover this notation later).

[^in-practice]: Logically,  not in practice. Some areas of memory are read/write protected, e.g., accessing memory at the address `0` (`NULL`) causes an error.

:::{tip} Quick check

On a 32-bit architecture, what is `sizeof(int *)`? `sizeof(char *)`?
:::

:::{note} Show answer
:class: dropdown

A pointer on a 32-bit architecture must be large enough to represent all possible addresses in the address space. The address space of a 32-bit architecture is the $2^32$ byte addresses ranging from `0x00000000` to `0xFFFFFFFF`. These correspond to bit patterns of 32 bits, so a pointer must be able to store 32 bits of information.

All pointers on a 32-bit architecture must therefore be 4 bytes wide[^why-not-larger], so `sizeof(int *)` is `sizeof(char *)` is `sizeof(int **)` is 4.

[^why-not-larger]: Why do we not make 32-bit architecture pointers larger than 4 bytes? The primary reason is storage efficiency; if pointer addresses will never be larger than 4 bytes, do not waste bytes by allocating extra. The secondary reason is convention; by definition, a 32-bit architecture defines [word size](@sec-words), which defines pointer size. 
:::

## Another View of Address Space

Before we discuss our example, we'd like to share a diagram of memory that, while confusing at first glance, will be extremely useful in interpreting the memory layout of any compiled C program.

Recall that memory on a 32-bit architecture is laid out as a very long array of $2^32$ bytes. A very long array would not fit on any page, whether horizontally or vertically. Instead, we use a visualization like @tab-mem-layout, which shows memory as rows of 4 bytes, from low to high addresses:

* In the rightmost four columns, "xx" values refer to data (hypothetical or otherwise) at each of four bytes of memory. These four bytes have contiguous memory addresses. 
* The leftmost column denotes the *lowest* address of the bytes in that row, i.e., the address of the rightmost byte.
* In a given row, the rightmost byte has the lowest address, and the leftmost byte has the highest address. This is explained by the +3, +2, +1, and +0 headers.

:::{table} Memory is a very long array of bytes, but this diagram "wraps" the long array into rows of 4 bytes.
:label: tab-mem-layout
:align: center

| address | +3 | +2 | +1 | +0 |
| :--- | :--- | :--- | :--- | :--- |
| `0x0` | xx | xx | xx | xx |
| `0x4` | xx | xx | xx | xx |
| `...` | ... | ... | ... | ... |
| `0xFFFFFFF8` | xx | xx | xx | xx |
| `0xFFFFFFFC` | xx | xx | xx | xx |

:::

:::{note} Example byte addresses
:class: dropdown

* The upper-right "xx" is at adddress `0x0000000`, or `0b0000 0000 ... 0000 0000`. This is the lowest possible address in the 32-bit address space.
* The upper-left "xx" is at address `0x00000003`, or `0b0000 0000 ... 0000 0011`.
* The bottom-right "xx" is at address `0xFFFFFFC`, or `0b1111 1111 ... 1111 1100`.
* The bottom-left "xx" is at address `0xFFFFFFFF`, or `0b1111 1111 ... 1111 1111`. This is the highest possible address in the 32-bit address space.

:::

A notable property of this visualization is that the addresses in the left column are multiples of 4. This layout effectively aligns our memory layout to **words**, because a 32-bit architecture has 4-byte words.

A confusing property of this visualization is that "lower" addresses are in earlier rows, whereas "higher" addresses are in later rows. This is not great for those of us that value meaningful naming conventions. However, when displaying large ranges of memory using debuggers like `gdb`, command-line output often displays data starting from lower addresses first, just like in this visualization.

## Compiled program example

Suppose that the following C program is compiled on a 32-bit architecture and produces the memory layout in @tab-word-program.

(word-program)=
```c
#include <stdio.h>
#include <stdint.h>

int main(int argc, char *argv[]) {
  int32_t value = 0x12345678;
  char str1[] = "hi!";
  char str2[] = "cs61c";
  int16_t short_val = 0xaabb;
  …

  return 0;
}
```

:::{table} Data layout of program on a 32-bit little endian machine.
:label: tab-word-program
:align: center

| address | +3 | +2 | +1 | +0 |
| :--- | :--- | :--- | :--- | :--- |
| `0x0` | xx | xx | xx | xx |
| `0x4` | xx | xx | xx | xx |
| `...` | ... | ... | ... | ... |
| `0x7F...FE164` | `0xaa` | `0xbb` | xx | xx |
| `0x7F...FE168` | `0x12` | `0x34` | `0x56` | `0x78` |
| `0x7F...FE16C` | `'i'` | `'h'` | xx | xx |
| `0x7F...FE170` | `'s'` | `'c'` | `'\0'` | `'!'` |
| `0x7F...FE174` | `'\0'` | `'c'` | `'1'` | `'6'` |
| `0x7F...FE178` | xx | xx | xx | xx |
| `...` | ... | ... | ... | ... |
| `0xFFFFFFFC` | xx | xx | xx | xx |

:::

:::{tip} Quick Check

Determine the addresses of `value` and `str1`.
:::

:::{note} Answer

Recall that the address of a stored value is the **lowest** address among the bytes of that value.

* `value` (the 32-bit signed integer 305419896 in decimal) has four bytes: `0x12`, `0x34`, `0x56`, and `0x78`. The lowest address of these four bytes is the address of the byte `0x78`, which is `0x7FFFE168`.

* `str` is the C-string `"hi!"` which has four bytes including the null-terminator: `'h'`, `'i'`, `'!'`, `'\0'`. The lowest address of these bytes is the address of `'h'`, which is `0x7FFFE16C` + 2, or `0x7FFFE16E`.

:::

There are two architecture-dependent aspects of this memory layout:

1. The bytes of `value` appear to be stored in "reverse" order. The least significant byte, `0x78`, has the lowest address!
1. The word-sized `value` has address `0x7FFFE168`, which is a multiple of four.

Together, these two observations tell us that the architecture is **little endian**, and that 32-bit integers (and perhaps other word-sized values) are **word-aligned**.

## Endianness

When data occupies multiple contiguous bytes in memory, the computer must determine which of the bytes is stored at the lowest address. This decision is often informed by the hardware architecture and in what order bytes are read from memory.

This property is called **endianness**. For a given word:

* **Little endian** machines store the _least_significant byte_ first, at the lowest address of the word.
* **Big endian** machines store the _most_ significant byte_ first, at the lowest address of the word.

The choice of endianness is one of convention[^endianness]. Nearly all modern computer architectures are little endian.

:::{tip} Quick check

How does the diagram in @tab-word-program help us read 32-bit integers?
:::

:::{note} Answer

The 32-bit architecture is **little endian**. We know this because the integer `0x12345678` has least significant byte, `0x78` which is stored first at the lowest address.

In @tab-word-program, data columns are enumerated in reverse order: +3, +2, +1, +0. This helps us read numbers in **human format**, e.g., `0x12` is on the left, and `0x78` is on the right.

:::


Read more about endianness on [Wikipedia](https://en.wikipedia.org/wiki/Endianness).

[^endianness]: Endianness can also refer to the order in which bytes are transmitted over networks and other data communication media; most modern internet networks prefer big endian. See a relatively interesting discussion on [Reddit](https://www.reddit.com/r/learnprogramming/comments/1emdohb/can_someone_explain_to_me_why_therere_big_endian/).

## Alignment

### Word Alignment

One critical operation that the hardware word defines is memory access. As we shall see, many architectures are optimized to *word-aligned* memory access. This means that it is very fast to access an entire word when that word is located at a memory address that is a multiple of the word size. For a 32-bit architecture, this means reading 4 bytes, where the first byte lies on a 4-byte boundary.

Of the four variables in @word-program, only `value` is the size of a word. The compiler has therefore aligned `value` to a word boundary. The other variables `str1`, `str2`, and `short_val` do not have values that are word-sized and therefore do not have such a constraint.

### Struct Alignment

Let us revisit the idea of a `struct`.  and consider how much space each declared `struct` occupies. 

:::{card} Data structure alignment
From [Wikipedia](https://en.wikipedia.org/wiki/Data_structure_alignment):
^^^
Data structure alignment is the way data is arranged and accessed in computer memory. It consists of three separate but related issues: data alignment, data structure padding, and packing.

_Data alignment_ is the aligning of elements according to their natural alignment. To ensure natural alignment, it may be necessary to insert some _padding_ between structure elements or after the last element of a structure. For example, on a 32-bit machine, a data structure containing a 16-bit value followed by a 32-bit value could have 16 bits of padding between the 16-bit value and the 32-bit value to align the 32-bit value on a 32-bit boundary. Alternatively, one can _pack_ the structure, omitting the padding, which may lead to slower access, but saves 16 bits of memory.
:::

Consider the `foo` struct:

```c
struct foo {
    int32_t a;
    char b;
    struct foo *c;
}
```

By themselves, a 32-bit integer, and character, and a struct pointer occupy 9 bytes. However, when declared together as a struct, C compilers may often choose to introduce **padding** into the struct itself to align the members of the struct. Padding a struct allows operations on its members to leverage the same speedups from word alignment had the members been declared separately.

:::{table} Structs can introduce byte padding. On the below 32-bit architecture, `sizeof(struct foo)` is 12.
:label: tab-struct
:align: center

| +3 | +2 | +1 | +0 |
| :--- | :--- | :--- | :--- |
| AA | AA | AA | AA |
| xx | xx | xx | BB |
| CC | CC | CC | CC |

:::

:::{note} Explanation
:class: dropdown

Suppose we declare `struct foo s;` and compile a program onto a 32-bit architecture. We might see @tab-struct as above.

- AA denotes the four bytes occupied by `s.a`. `sizeof(s.a)` is 4.
- BB denotes the single byte occupied by `s.b`. `sizeof(s.b)` is 1. The precise alignment of `s.b` is implementation-specific.
- CC denotes the four bytes occupied by the `s.c`. `sizeof(s.c)` is 3.

:::

Ultimately, the `struct` declaration is a guideline for how to arrange a bunch of bytes in a bucket. The precise size of a struct—and field order within a struct type–depends on the C compiler and whether it is optimizing for padding or packing. We recommend you always check sizes with a debugger like `gdb`.