---
title: "A Bit About Machine Program"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/X6SbnHmeN6w
:width: 100%
:title: "[CS61C FA20] Lecture 09.2 - RISC-V Decisions II: A Bit About Machine Program"
:::

::::

## Visuals

:::{figure} images/c-mem-layout.png
:label: fig-mem-layout
:width: 50%
:alt: "TODO"

Stack frame memory layout visualization (stack, heap, data, text).
:::

:::{figure} images/programcounter.png
:label: fig-pc
:width: 50%
:alt: "TODO"

Program counter example in RISC-V.
:::

```{code} c
:linenos:
…
… # li x10 0x34FF
slli 	x12 x10 0x10
srli  x12 x12 0x08
and   x12 x12 x10
```

:::{figure} images/control-flow.png
:label: fig-rv-cf
:width: 50%
:alt: "TODO"

Control flow in C.
:::

| Instruction | Name/Description |
|-------|-------|
| `beq rs1 rs2 Label` | Branch if Equal |
| `bne rs1 rs2 Label` | Branch if Not Equal |
| `blt rs1 rs2 Label` | Branch if Less Than (signed) (rs1 < rs2) |
| `bge rs1 rs2 Label` | Branch if Greater or Equal (signed) (rs1 >= rs2) |
| `bltu rs1 rs2 Label` | Branch if Less Than (unsigned) |
| `bgeu rs1 rs2 Label` | Branch if Greater Than or Equal (unsigned) |
| `j Label` | Unconditional jump |

:::{figure} images/loop-example1-3.png
:label: fig-rv_loopassembly1
:width: 100%
:alt: "TODO"

Loop in assembly example with register visualization (1).
:::

:::{figure} images/loop-example4-6.png
:label: fig-rv-loopassembly2
:width: 100%
:alt: "TODO"

Loop in assembly example with register visualization (2).
:::