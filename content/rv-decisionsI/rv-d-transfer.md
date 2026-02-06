---
title: "Data Transfer Instructions"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Vo2WL9acC5M
:width: 100%
:title: "[CS61C FA20] Lecture 08.2 - RISC-V lw, sw, Decisions I: Data Transfer Instructions"
:::

::::

## Visuals

:::{figure} images/memory.png
:label: fig-rv-memory
:width: 100%
:alt: "TODO"

Diagram of processor and memory data transfer.
:::

:::{figure} images/load-store.png
:label: fig-rv-load-store
:width: 100%
:alt: "TODO"

Load and store between register and memory.
:::

:::{figure} images/loadword-mem.png
:label: fig-rv-loadword-mem
:width: 50%
:alt: "TODO"

Example memory contents during load word operation.
:::

:::{figure} images/loadword-ex.png
:label: fig-rv-loadword-ex
:width: 100%
:alt: "TODO"

Example load word instruction in memory.
:::

:::{figure} images/storeword-mem.png
:label: fig-rv-storeword-mem
:width: 50%
:alt: "TODO"

Example memory contents during store word operation.
:::

:::{figure} images/storeword-ex.png
:label: fig-rv-storeword-ex
:width: 100%
:alt: "TODO"

Example store word instruction in memory.
:::

:::{figure} images/loadbyte.png
:label: fig-rv-loadbyte
:width: 100%
:alt: "TODO"

Example load byte instruction in memory.
:::

:::{figure} images/storebyte.png
:label: fig-rv-storebyte
:width: 100%
:alt: "TODO"

Example store byte instruction in memory.
:::

|  | `lw` | `lh/lhu` | `lb/lbu` |
|-------|-------|-------|-------|
| loading size in byte | 4 | 2 | 1 |

:::{figure} images/examplex12.png
:label: fig-rv-example-x12
:width: 100%
:alt: "TODO"

Load instruction example with x12.
:::

:::{figure} images/examplex12-sol1.png
:label: fig-rv-example-x12-sol1
:width: 100%
:alt: "TODO"

Solution (1/3): load instruction example with x12.
:::

:::{figure} images/examplex12-sol2.png
:label: fig-rv-example-x12-sol2
:width: 100%
:alt: "TODO"

Solution (2/3) (store): load instruction example with x12.
:::

:::{figure} images/examplex12-sol3.png
:label: fig-rv-example-x12-sol3
:width: 100%
:alt: "TODO"

Solution (3/3) (load): load instruction example with x12.
:::