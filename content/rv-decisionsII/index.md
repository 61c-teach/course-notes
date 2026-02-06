---
title: "Logical Instructions"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/WQQlcC3btmM
:width: 100%
:title: "[CS61C FA20] Lecture 09.1 - RISC-V Decisions II: Logical Instructions"
:::

::::

## Visuals

| # | Name | Description |
|-------|-------|-------|
| `x0` | `zero` | Constant 0 |
| `x1` | `ra` | Return Address |
| `x2` | `sp` | Stack Pointer |
| `x3` | `gp` | Global Pointer |
| `x4` | `tp` | Thread Pointer |
| `x5` | `t0` | Temporary Register |
| `x6` | `t1` | Temporary Register |
| `x7` | `t2` | Temporary Register |

:::{figure} images/stackframe-1.png
:label: fig-rv-stackframe-1
:width: 50%
:alt: "TODO"

Stack frame example (1).
:::

:::{figure} images/stackframe-2.png
:label: fig-rv-stackframe-2
:width: 50%
:alt: "TODO"

Stack frame example (2).
:::

```{code} c
:linenos: 
li t0 0x73
sb t0 4(sp)
li t0 0x74
sb t0 5(sp)
li t0 0x72
sb t0 6(sp)
li t0 0x69
sb t0 7(sp)
li t0 0x6E
sb t0 8(sp)
li t0 0x67
sb t0 9(sp)
sb x0 10(sp)
```

:::{figure} images/stackframe-3.png
:label: fig-rv-stackframe-3
:width: 100%
:alt: "TODO"

Stack frame example (3).
:::

:::{figure} images/stackframe-4.png
:label: fig-rv-stackframe-4
:width: 50%
:alt: "TODO"

Stack frame example (4).
:::

:::{figure} images/stackframe-5.png
:label: fig-rv-stackframe-5
:width: 50%
:alt: "TODO"

Stack frame example (5).
:::

```{code} c
:linenos:
li t0 0x69727473
sw t0 4(sp)
li t1 0x0000676E
sw t1 8(sp)
```

:::{figure} images/stackframe-6.png
:label: fig-rv-stackframe-6
:width: 50%
:alt: "TODO"

Stack frame example (6).
:::

:::{figure} images/stackframe-7.png
:label: fig-rv-stackframe-7
:width: 50%
:alt: "TODO"

Stack frame example (7).
:::

```{code} c
:linenos:
lb t0 7(sp)
sb t0 52(sp)
```

:::{figure} images/stackframe-8.png
:label: fig-rv-stackframe-8
:width: 100%
:alt: "TODO"

Stack frame example (8).
:::

```{code} c
lw t0 0(sp)
lbu t1 52(sp)
add t2 t0 t1
sw t2 28(sp)
```

:::{figure} images/stackframe-9.png
:label: fig-rv-stackframe-9
:width: 50%
:alt: "TODO"

Stack frame example (9).
:::

```{code} c
li t0 20
lw t1 0(sp)
slli t1 t1 2
addi t1 t1 12
add t1 t1 sp
sw t0 0(t1)
```

```{code} c
li t0 5
sw t0 0(sp)
li t0 0x69727473
sw t0 4(sp)
li t1 0x0000676E
sw t1 8(sp)
lb t0 7(sp)
sb t0 52(sp)
lw t0 0(sp)
lbu t1 52(sp)
add t2 t0 t1
sw t2 28(sp)
li t0 20
lw t1 0(sp)
slli t1 t1 2
addi t1 t1 12
add t1 t1 sp
sw t0 0(t1)
```

|  | Example | RISC-V: Register |
|-------|-------|-------|
| AND | `0b1001 & 0b0111 = 0b001` | `and rd rs1 rs2` |
| OR | `0b1001 \| 0b0111 = 0b1111` | `or rd rs1 rs2` |
| XOR | `0b1001 ^ 0b0111 = 0b1110` | `xor rd rs1 rs2` |
| NOT | `~0b1001 = 0b0110` | `not rd rs1` |
| Shift left | `0b0001 << 3 = 0b1000 = 8` | `sll rd rs1 rs2` |
| Shift right | `0b1001 >> 2 = 0b0010 = 2` | `srl rd rs1 rs2` OR `sra rd rs1 rs2` |