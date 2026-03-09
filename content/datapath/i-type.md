---
title: "Immediates on the Datapath"
---

## Learning Outcomes

* Coming soon! We provide the animations for now.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vtZ6UAboFRk
:width: 100%
:title: "[CS61C FA20] Lecture 18.5 - Single-Cycle CPU Datapath I: Datapath with Immediates"
:::

::::

## Tracing the `addi` Datapath

<iframe src='https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-addi.pptx' width='100%' height='600px' frameborder='0'>


Data `inst[24:20]` still feeds into `Reg[]`, which still outputs `R[rs2]`.
However, control `Bsel=1` means `R[rs2]` data line is ignored.

## Immediate Generator Block: I-Type

:::{figure} images/immgen-i-type.png
:label: @fig-immgen-i-type

Immediate Generator Block: I-Type
:::
