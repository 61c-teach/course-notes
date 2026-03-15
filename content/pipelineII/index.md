---
title: "Pipelining RISC-V"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/or7jzHOc0ks
:width: 100%
:title: "[CS61C FA20] Lecture 22.1 - Pipelining II: Pipelining RISC-V"
:::

::::

## Visuals

:::{figure} images/sequential-inst-datapath.png
:label: fig-seq-inst-datapath
:width: 100%
:alt: "TODO"

Sequential RISC-V datapath for 3 instructions.
:::

:::{figure} images/pipelined-inst-datapath.png
:label: fig-pip-inst-datapath
:width: 100%
:alt: "TODO"

Pipelined RISC-V datapath for 3 instructions.
:::

:::{figure} images/single-cycle-datapath.png
:label: fig-single-cycle-datapath
:width: 100%
:alt: "TODO"

High-level diagram of single-cycle datapath.
:::

<!-- :::{table} Sequential Instructions.
:label: tab-seq-inst
:align: center

|  | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `add s0 t0 t1` | IF | ID | EX | M | WB |   |   |   |   |   |
| `sub t2 s0 t0` |   |   |   |   |   | IF | ID | EX | M | WB |
::: -->

<!-- Numbers represent time steps; rows represent sequence of instructions -->
```{list-table} Sequential Instructions.
:header-rows: 1
:label: tab-seq-inst
* -  
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
  - 10
* - `add s0 t0 t1`
  - IF
  - ID
  - EX
  - M
  - WB
  -  
  -  
  -  
  -  
  -  
* - `sub t2 s0 t0`
  -  
  -  
  -  
  -  
  -  
  - IF
  - ID
  - EX
  - M
  - WB
```

:::{figure} images/pipelined-datapath.png
:label: fig-pipelined-datapath
:width: 100%
:alt: "TODO"

High-level diagram of pipelined datapath.
:::

<!-- Numbers represent time steps; rows represent sequence of instructions -->
```{list-table} Pipelined Instructions.
:header-rows: 1
:label: tab-pip-inst
* -  
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
* - `add s0 t0 t1`
  - IF
  - ID
  - EX
  - M
  - WB
  -  
* - `sub t2 s0 t0`
  -  
  - IF
  - ID
  - EX
  - M
  - WB
```