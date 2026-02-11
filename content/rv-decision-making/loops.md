---
title: "Loops"
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

TODO: unconditional branch "definition" -- include this later when we discuss instruction formats

You might wonder if you can just make an unconditional branch using a conditional one, like beq x0, x0, label. While that would always jump, there is a catch: the range of a branch is shorter. Because RISC-V uses 32-bit instructions, we have to fit the instruction type, the registers being compared, and the label (an immediate value) into those 32 bits. A dedicated jump instruction doesn't need to specify registers to compare, so its immediate value can be larger, allowing it to reach farther in the program.
