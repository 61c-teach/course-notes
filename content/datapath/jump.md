---
title: "Supporting JAL, JALR"
---

(sec-datapath-jump)=
## Learning Outcomes

* Coming soon! We provide the animations for now.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/l5ML8v9R8w8
:width: 100%
:title: "[CS61C FA20] Lecture 19.4 - Single-Cycle CPU Datapath II: Adding JALR to Datapath"
:::

::::

## Tracing the `jalr` Datapath


::::{figure}
:label: anim-datapath-jalr
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-jalr.pptx
:width: 100%
:title: "Tracing the `jalr` Datapath"
:::
The `jalr` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::

To support `jalr`, you should connect PC+4 to your multiplexer in the write-back stage so that PC+4 can be written back to `rd`.

## Tracing the `jal` Datapath

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/op--CudioaA
:width: 100%
:title: "[CS61C FA20] Lecture 19.5 - Single-Cycle CPU Datapath II: Adding JAL"
:::

::::


::::{figure}
:label: anim-datapath-jal
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-jal.pptx
:width: 100%
:title: "Tracing the `jal` Datapath"
:::
The `jal` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::

For `jal`, “don’t care” about branch.