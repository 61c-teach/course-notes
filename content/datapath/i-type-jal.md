---
title: "Adding JAL"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/op--CudioaA
:width: 100%
:title: "[CS61C FA20] Lecture 19.5 - Single-Cycle CPU Datapath II: Adding JAL"
:::

::::

## Tracing the `jal` Datapath

<iframe src='https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-jal.pptx' width='100%' height='600px' frameborder='0'>

To support `jalr`, you should connect PC+4 to your multiplexer in the write-back stage so that PC+4 can be written back to `rd`.
