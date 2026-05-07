---
title: "Supporting U-Type"
---

(sec-datapath-u-type)=
## Learning Outcomes

* Implement a datapath that supports U-Type instructions (`lui` and `auipc`).
* Explain why the ALU (in our course datapath) needs to support wiring the input `B` directly to its output.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/8q8l0tXs_Lc
:width: 100%
:title: "[CS61C FA20] Lecture 19.6 - Single-Cycle CPU Datapath II: Adding U-Types"
:::

::::

At this point, we have a datapath that can support R-, I-, S-, B-, and J-Type instructions. There is just one instruction format left: the **U-Type** (**upper immediate**) instruction. Review [U-Type instructions](#sec-u-type) before continuing.

## Updates needed for U-Type

To support U-Type:

* RegFile: We read no registers but write one register `rd`.
* PC: We **read** from and **write** to PC. The value to write is `pc + 4`.

There are **two** updates we need to make:

* The [**immediate generator**](#sec-datapath-immgen) must now support immediates in U-Type instructions.
* The [ALU](#sec-datapath-alu) must support passing the immediate through (i.e., select only ALU input `B` and ignore input `A`). This operation is needed for the `lui` instruction.

## Tracing the `lui` Datapath

<!-- ::::{figure}
:label: anim-datapath-lui
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-lui.pptx
:width: 100%
:title: "Slides tracing through the `lui` Datapath."
:::
The `lui` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
:::: -->

::::{figure}
:label: anim-datapath-lui
:alt: "Embedded slides tracing load-upper-immediate on the single-cycle datapath, wiring the U-type immediate into the ALU bypass path and register write-back."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQaJ2vmNAHWYtsHOqepOlL_mOnOM3HPvfvhTAO_CLlNLoEo17GiOuslYVycWHUb_w/pubembed?start=false&loop=false
:width: 100%
:title: "Slides tracing through the `lui` Datapath."
:::
The `lui` datapath. Use the menu bar to trace through the animation or access the [original Google slides](https://docs.google.com/presentation/d/11CKXsYN9z-0RRWkwVz-Ae6ZvZIcirluV/edit?usp=sharing).
::::

1. **Instruction Fetch**: At the beginning of the clock cycle, read PC and fetch the current instruction from IMEM.

    Before the next rising clock edge, set `pc + 4` to the input of PC.

1. **Instruction Decode**: Build the immediate `imm` for U-Type instructions. Also configure control logic (see below).

1. **Execute**: Get the value `imm` and set as the ALU output.

1. **Memory**: (We don't access DMEM, so skip this.)

1. **Write Back**: Write the ALU output to the destination register and connect output of the `WBSel` mux to RegFile's `wdata` input.

    Around the next rising clock edge, `wdata`, `RegWEn`, and `rd` should be held stable through setup and hold time of RegFile.

:::{note} Control Signals for `lui`

* Configure `ImmSel` to `U`-type immediates.
* Set `RegWEn` to `1`, i.e., write back to RegFile
* Set `BrUn` to _don't care_ (*)[^dont-care].
* Set `ASel` to _don't care_ (*)[^dont-care].
* Set `BSel` to `1`.
* Set `ALUSel` to connect the input `B` directly to the output (project name: `bsel`).
* Set `MemRW` to `Read`. This means **no** write to `DMEM`.
* Set `WBSel` to `1` (to select `alu` output in @anim-datapath-lui).
* Set `PCSel` to `not taken`.

[^dont-care]: Review [Control Signals for Stores](#sec-control-store) for an explanation of "don't care."

:::

## Tracing the `auipc` Datapath

<!-- ::::{figure}
:label: anim-datapath-auipc
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-auipc.pptx
:width: 100%
:title: "Slides tracing through the `auipc` Datapath."
:::
The `auipc` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
:::: -->

::::{figure}
:label: anim-datapath-auipc
:alt: "Embedded slides tracing add-upper-immediate-to-PC on the single-cycle datapath, combining PC with the upper immediate for PC-relative addressing setup."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQTNKmHKQSo2p_zRGfFjMYdnQ5QoIcEeFI57fdjlvmkOQJKbXAZ42_Y6x5iT8TNGw/pubembed?start=false&loop=false
:width: 100%
:title: "Slides tracing through the `auipc` Datapath."
:::
The `auipc` datapath. Use the menu bar to trace through the animation or access the [original Google slides](https://docs.google.com/presentation/d/117GS6W-vKD25dAOlAd9ycbFZpMBSAgp1/edit?usp=sharing).
::::

1. **Instruction Fetch**: At the beginning of the clock cycle, read PC and fetch the current instruction from IMEM. Feed `pc` to `EX` phase.

    Before the next rising clock edge, set `pc + 4` to the input of PC.

1. **Instruction Decode**: Build the immediate `imm` for U-Type instructions. Also configure control logic (see below).

1. **Execute**: Compute `pc + imm` using the ALU. Because control signals are `ASel=1` and `BSel=1`, the two muxes before the ALU will select `pc` and `imm`, respectively. Because `ALUSel=Add`, the ALU will add these two values together.

1. **Memory**: (We don't access DMEM, so skip this.)

1. **Write Back**: Write the ALU output to the destination register and connect output of the `WBSel` mux to RegFile's `wdata` input.

    Around the next rising clock edge, `wdata`, `RegWEn`, and `rd` should be held stable through setup and hold time of RegFile.

:::{note} Control Signals for `auipc`

* Configure `ImmSel` to `U`-type immediates.
* Set `RegWEn` to `1`, i.e., write back to RegFile
* Set `BrUn` to _don't care_ (*)[^dont-care].
* Set `ASel` to `1`
* Set `BSel` to `1`.
* Set `ALUSel` to `Add`.
* Set `MemRW` to `Read`. This means **no** write to `DMEM`.
* Set `WBSel` to `1` (to select `alu` output in @anim-datapath-auipc).
* Set `PCSel` to `not taken`.

:::
