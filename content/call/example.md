---
title: "CAL Example: Hello World"
subtitle: "Translation: Compiler, Assembler, Linker"
---

(sec-call-example)=
## Learning Outcomes

* Identify which step of Compile, Assemble, and Link translates a specific assembly instruction to machine code.
* See an end-to-end example of translation of a `hello.c` program into an `a.out` executable.
* Identify assembly directives.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/ZG8CSM0CaM4
:width: 100%
:title: "[CS61C FA20] Lecture 13.6 - Compilation, Assembly, Linking, Loading: Example"
:::

::::

Let's describe program translation (Compile, Assemble, and Link) with a `hello_world` example.

:::{hint} Quick Check

At what point in the process are all the machine code bits determined for the following assembly instructions?

1. `add  x6 x7 x8`
1. `jal  x1 fprintf`

After compilation, after assembly, after linking, or after loading?

:::

:::{note} Show Answer

1. `add  x6 x7 x8` After assembly. No addresses need to be resolved.
1. `jal  x1 fprintf` After linking. `fprintf` is an external function (C `stdio.h`)

:::

## Compiler: `hello.c` $\rightarrow$ `hello.s`

`hello.c`:

```{code} c
:linenos:
#include <stdio.h>
int main() {
    printf("Hello, %s\n", "world");
    return 0;
}
```

`hello.s`:
(code-hello-s)=
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

Note the many **pseudoinstructions**: `la`, `call`, `li`, `ret`, etc.

:::{note} Click to show directives
:class: dropdown

* Line 1, `.text`: Enter `text` section
  * Line 2, `.align`: Align code to 2*2 bytes
  * Line 3, `.global`: Declare global symbol main
* Line 14, `section`: Enter read-only `data` section
  * Line 15, `balign`: Align data section to 4 bytes
  * Line 17, `.string`: null-terminated string
  * Line 19, `.string`: null-terminated string

More [directives](#sec-directives):

| Directive | Description |
| :--- | :--- |
| `.text` | Put subsequent items in the user Text segment (machine code) |
| `.data` | Put subsequent items in user Data segment (source file data in binary) |
| `.globl sym` | Declares sym global and can be referenced from other files |
| `.string str` | Store the string str in memory and null-terminate it |
| `.word` | Store the n 32-bit quantities in successive memory words |

:::

:::{note} Click to show labels
:class: dropdown

* Line 4, `main`
* Line 16, `str1`
* Line 18, `str2`
:::

## Assembler: `hello.s` $\rightarrow$ `hello.o`

The assembler output is an object file in binary:

```bash
     ... ff010113 00112623 00000537
00050513 000005b7 00058593 000080e7
00c12083 01010113 00000513 00008067 ...
```

### Text segment

This is not very readable, so we describe some components in more detail. Below is the text segment translating the `main` portion of `hello.o`. Refer to [`hello.s`](#code-hello-s) as needed.

(code-hello-o)=
```{code} bash
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

:::{note} How to read each line
:class: dropdown

* Left of colon, e.g., `10`: the relative address of the instruction in the module
* 8-digit hexadecimal, e.g., (`000005b7`): the 32-bit-wide machine code, perhaps with placeholders
* assembly instruction, e.g., (`lui a1 0x0`): the assembly insturction, perhaps with placeholders
:::

Pseudoinstructions are replaced where possible.
* `la`[^la] is replaced with `lui` and `addi`
* `call` is replaced with `jalr`

[^la]: The CS61C refcard says that the `la` pseudoinstruction resolves to an `auipc` and `addi`, implying that `la` is always a PC-relative address. However, this pseudo->real instruction resolution depends on the RISC-V compiler. In gcc, you can use the -fpic or -fno-pic flag to specify relative vs. absolute addressing ([source1](https://michaeljclark.github.io/asm.html), [source2](https://github.com/gcc-mirror/gcc/blob/master/gcc/config/riscv/riscv.h)). I suspect that for this example, we used absolute addressing in order to fully demonstrate the address placeholders. I’m leaving further exploration of this to future CS61C instructors.

The machine code includes **address placeholders** of zero (e.g., `lui a1 0x0` is machine code `000005b7`), denoting unresolved references for the linker to resolve.

### Symbol Table

The below would be in binary, but we illustrate it as a table:

:::{table} Symbol Table for `hello.o`
:label: tab-hello-symbol-table

| Label | Address (in segment of module) | type |
| :-- | :-- | :-- |
| `main` | `0x00000000` | global text |
| `str1` | `0x00000000` | local data |
| `str2` | `0x0000000c` | local data |

:::

### Relocation Table

The below would be in binary, but we illustrate it as a table:

:::{table} Relocation Table for `hello.o`
:label: tab-hello-relocation-table

| Address | type | Dependency |
| :-- | :-- | :-- |
| `0x00000008` | `lui `| `%hi(str1)` |
| `0x0000000c` | `addi` | `%low(str1)` |
| `0x00000010` | `lui` | `%hi(str2)` |
| ... | ... | ... |

:::

## Linker: `hello.s` $\rightarrow$ `a.out`

A portion of the `a.out` executable is shown:

```{code} bash
000101b0 <main>:
  101b0: ff010113 addi sp sp -16
  101b4: 00112623 sw   ra 12(sp)
  101b8: 00021537 lui  a0 0x21
  101bc: a1050513 addi a0 a0 -1520 # 20a10 <str1>
  101c0: 000215b7 lui  a1 0x21
  101c4: a1c58593 addi a1 a1 -1508 # 20a1c <str2>
  101c8: 288000ef jal  ra 10450    # <printf>
  101cc: 00c12083 lw   ra 12(sp)
  101d0: 01010113 addi sp sp,16
  101d4: 00000513 addi a0 0,0
  101d8: 00008067 jalr ra
```

* Squash all .o files
* Update in symbol table
* For each entry in the relocation table:
  * Replace placeholders with the actual address
  * Update machine code. Note that the `lui` upper immediate is incremented by 1; refer to an [earlier section](#sec-li-lui) about U-Type instruction formats and the `li` pseudoinstruction.
