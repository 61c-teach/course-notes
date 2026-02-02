---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. **True/False**: The correct way of declaring a character array is `char[] array`.

:::{note} Solution
:class: dropdown

**False.** The correct way is `char array[]`.

<!--See: [Lecture 4 Slide 20](https://docs.google.com/presentation/d/1qSZZ1_rcPgtix08uJtxgkueccjWzwiCRrr4fhsGueJw/edit?slide=id.g32c0b5df322_0_692#slide=id.g32c0b5df322_0_692)-->
:::

2. **True/False**: C is a pass-by-value language.

:::{note} Solution
:class: dropdown

**True.** If you want to pass a reference to anything, you should use a pointer.

<!--See: [Lecture 4 Slide 5](https://docs.google.com/presentation/d/1qSZZ1_rcPgtix08uJtxgkueccjWzwiCRrr4fhsGueJw/edit?slide=id.g32af6a99fd0_0_10#slide=id.g32af6a99fd0_0_10)-->
:::

3. What is a pointer? What does it have in common with an array variable?

:::{note} Solution
:class: dropdown

As we like to say, "everything is just bits." A pointer is just a sequence of bits, interpreted as a memory address. An array acts like a pointer to the first element in the allocated memory for that array. However, an array name is not a variable, that is, `&arr = arr` whereas `&ptr != ptr` unless some magic happens (what does that mean?).

<!--See: [Lecture 4 Slide 5](https://docs.google.com/presentation/d/1qSZZ1_rcPgtix08uJtxgkueccjWzwiCRrr4fhsGueJw/edit?slide=id.g32af6a99fd0_0_10#slide=id.g32af6a99fd0_0_10)-->
:::

4. If you try to dereference a variable that is not a pointer, what will happen? What about when you free one?

:::{note} Solution
:class: dropdown

It will treat that variable's underlying bits as if they were a pointer and attempt to access the data there. C will allow you to do almost anything you want, though if you attempt to access an "illegal" memory address, it will segfault for reasons we will learn later in the course. It's why C is not considered "memory safe": you can shoot yourself in the foot if you're not careful. If you free a variable that either has been freed before or was not malloced/calloced/realloced, bad things happen. The behavior is undefined and terminates execution, resulting in an "invalid free" error.

<!--See: [Lecture 4 Slide 18](https://docs.google.com/presentation/d/1qSZZ1_rcPgtix08uJtxgkueccjWzwiCRrr4fhsGueJw/edit?slide=id.g32a3dfb97c2_1_32#slide=id.g32a3dfb97c2_1_32)-->
:::

## Short Exercises

1. Fill in the memory contents for each system after initializing `arr`. Assume `arr` begins at memory address `0x1000`.

```
uint32_t arr[2] = {0xD3ADB33F, 0x61C0FFEE};
```

**(a)** Little-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` |       |       |       |       |
| `0x1004` |       |       |       |       |
|        | ...                   |

**(b)** Big-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` |       |       |       |       |
| `0x1004` |       |       |       |       |
|        | ...                   |

:::{note} Solution
:class: dropdown

**(a)** Little-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` | `0x3F` | `0xB3` | `0xAD` | `0xD3` |
| `0x1004` | `0xEE` | `0xFF` | `0xC0` | `0x61` |
|        | ...                   |

**(b)** Big-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` | `0xD3` | `0xAD` | `0xB3` | `0x3F` |
| `0x1004` | `0x61` | `0xC0` | `0xFF` | `0xEE` |
|        | ...                   |

:::