---
title: "Example"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/ZG8CSM0CaM4
:width: 100%
:title: "[CS61C FA20] Lecture 13.6 - Compilation, Assembly, Linking, Loading: Example"
:::

::::

## Visuals

```{code} c
:linenos:
#include <stdio.h>
int main() {
    printf("Hello, %s\n", "world");
    return 0;
}
```

```{code} c
:linenos:
.text
    .align 2
    .global main
main:
    addi sp sp -4
    sw   ra 0(sp)
    la   a0 str1
    la   a1 str2
    call printf
    lw   ra 0(sp)
    addi sp sp 4
    li   a0 0
    ret
.section .rodata
    .balign 4
str1:
    .string "Hello, %s!\n"
str2:
    .string "world"
```

```{code} c
:linenos:
00000000 <main>:
0:  ff010113 addi sp sp -16
4:  00112623 sw   ra 12(sp)
8:  00000537 lui  a0 0x0
c:  00050513 addi a0 a0 0
10: 000005b7 lui  a1 0x0
14: 00058593 addi a1 a1 0
18: 000080e7 jalr ra 0
1c: 00c12083 lw   ra 12(sp)
20: 01010113 addi sp sp 16
24: 00000513 addi a0 a0 0
28: 00008067 jalr ra
```