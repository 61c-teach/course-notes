---
title: "Implementing Branches"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/XTgyEsFRvWg
:width: 100%
:title: "[CS61C FA20] Lecture 19.3 - Single-Cycle CPU Datapath II: Implementing Branches"
:::

::::

## Tracing the Branch Datapath

<iframe src='https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-branch.pptx' width='100%' height='600px' frameborder='0'>

## Branch Comparator Block

:::{figure} images/element-branch-comparator.png
:label: @fig-element-branch-comparator
:width: 30%

Branch Comparator Block
:::

This subcircuit takes two inputs and outputs the result of comparing the two inputs. This output later is used to implementing branches.

### Course Project Details

:::{table} Signals for Branch Comparator. Course project signal names, if different, are in parentheses.
:label: tab-branch-comparator-signals
:align: center

| Name | Directino | Bit Width | Description |
| :-- | :-- | :-- | :-- |
| `A` (`BrData1`) | Input | 32 | First value to compare |
| `B` (`BrData2`) | Input | 32 | Second value to compare |
| `BrUn` | Input | 1 | `1` when an **unsigned** comparison is wanted, and `0` when a **signed** comparison is wanted |
| `BrEq` | Output | 1 | Set to `1` if the two values are equal |
| `BrLt` | Output | 1 | Set to `1` if the value in rs1 is less than the value in rs2 |

:::