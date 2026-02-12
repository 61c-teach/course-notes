---
title: "Function Call Example"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/THhKfRlQTyU
:width: 100%
:title: "[CS61C FA20] Lecture 10.1 - RISC-V Procedures: Function Call Example"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/XZAHwb7Smj0
:width: 100%
:title: "[CS61C FA20] Lecture 09.3 - RISC-V Decisions II: RISC-V Function Calls"
:::

::::

## Visuals

:::{figure} images/jal-jr.png
:label: fig-rv-jal-jr
:width: 100%
:alt: "TODO"

RISC-V Assembly with JAL and JR.
:::

## Visuals

:::{figure} images/frames-stackpointer.png
:label: fig-rv-frames-sp
:width: 50%
:alt: "TODO"

Function Main's stack pointer example.
:::

:::{figure} images/frames-stackpointer-foo.png
:label: fig-rv-frames-sp-foo
:width: 50%
:alt: "TODO"

Function Foo's stack pointer example.
:::

:::{figure} images/frames-stackpointer-foo-2.png
:label: fig-rv-frames-sp-foo-2
:width: 50%
:alt: "TODO"

Function Foo's stack pointer after function call.
:::

:::{figure} images/frames-stackpointer-2.png
:label: fig-rv-frames-sp-2
:width: 50%
:alt: "TODO"

Function Main's stack pointer after Foo Function call.
:::

:::{figure} images/clobbered-reg.png
:label: fig-rv-clobbered
:width: 50%
:alt: "TODO"

Registers in clobbered register example.
:::

:::{figure} images/recursive-fac-1.png
:label: fig-rv-recursive-fac-1
:width: 50%
:alt: "TODO"

Code walkthrough for recursive factorial function call example (1).
:::

:::{figure} images/recursive-fac-2.png
:label: fig-rv-recursive-fac-2
:width: 50%
:alt: "TODO"

Code walkthrough for recursive factorial function call example (2).
:::

:::{figure} images/recursive-fac-3.png
:label: fig-rv-recursive-fac-3
:width: 50%
:alt: "TODO"

Code walkthrough for recursive factorial function call example (3).
:::

:::{figure} images/recursive-fac-4.png
:label: fig-rv-recursive-fac-4
:width: 50%
:alt: "TODO"

Code walkthrough for recursive factorial function call example (4).
:::

:::{figure} images/recursive-fac-5.png
:label: fig-rv-recursive-fac-5
:width: 50%
:alt: "TODO"

Code walkthrough for recursive factorial function call example (5).
:::

:::{figure} images/recursive-fac-6.png
:label: fig-rv-recursive-fac-6
:width: 50%
:alt: "TODO"

Code walkthrough for recursive factorial function call example (6).
:::


## TODO: put this somewhere

TODO: unconditional branch "definition" -- include this later when we discuss instruction formats

You might wonder if you can just make an unconditional branch using a conditional one, like beq x0, x0, label. While that would always jump, there is a catch: the range of a branch is shorter. Because RISC-V uses 32-bit instructions, we have to fit the instruction type, the registers being compared, and the label (an immediate value) into those 32 bits. A dedicated jump instruction doesn't need to specify registers to compare, so its immediate value can be larger, allowing it to reach farther in the program.
