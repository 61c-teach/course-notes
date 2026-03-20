---
title: "Supporting Jumps"
---

(sec-datapath-jump)=
## Learning Outcomes

* Implement a datapath that supports unconditional jumps (`jal` and `jalr`).
* Compare the control signals set for `jal` and `jalr`.
* Explain why unconditional jumps do not use the branch comparator.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/op--CudioaA
:width: 100%
:title: "[CS61C FA20] Lecture 19.5 - Single-Cycle CPU Datapath II: Adding JAL"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/l5ML8v9R8w8
:width: 100%
:title: "[CS61C FA20] Lecture 19.4 - Single-Cycle CPU Datapath II: Adding JALR to Datapath"
:::

::::

:::{note} Review jump instructions

RISC-V has two unconditional jump instructions. 
For a general overview of unconditional jumps, review [this section](#sec-jumps).

* `jal` (Jump and link): The sole J-Type instruction; review [J-Type details](#sec-j-type).
* `jalr` (Jump and link register): An I-Type instruction; review [`jalr` instruction format details](#sec-jalr-itype).

:::

## Datapath updates for `jal`

To support `jal`:

* RegFile: We read no registers but write one register `rd`. The value to write is `pc + 4`, i.e., the "link" to the next instruction.
* PC: We **read** from and **write** to PC. The value to write is `pc + imm`.

We can reuse many components of our R-, I-, S-, and B-Type datapath. We will need to **update** two blocks, shown in @fig-jal-new-blocks.

::::{figure} images/jal-new-blocks.png
:label: fig-jal-new-blocks
:width: 100%

Update the Immediate Generator block and the `WBSel` mux.
::::

**Immediate Generator**: Upgrade the [Immediate Generator](#sec-datapath-immgen) to support immediates in J-Type instructions.

**Mux**: The `WBSel` mux must now select between **three values** for `wdata` (the data to write to `R[rd]`):

* Arithmetic and Logical R-Type or I-Type instructions: The output of the ALU (`alu`), which is now wired both into `addr` and into the new mux.
* Load instructions: The output of DMEM (`mem`).
* Jump instructions: `pc + 4`.

## Tracing the `jal` Datapath

::::{figure}
:label: anim-datapath-jal
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-jal.pptx
:width: 100%
:title: "Tracing the `jal` Datapath"
:::
The `jal` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::

1. **Instruction Fetch**: At the beginning of the clock cycle, read PC and fetch the current instruction from IMEM. Feed `pc` and `pc + 4` to blocks.

    Before the next rising clock edge, set the output of the ALU to the input of PC.

1. **Instruction Decode**: Build the immediate `imm` for J-Type instructions. Also configure control logic (see below).

1. **Execute**: Compute `pc + imm` using the ALU. Because control signals are `ASel=1` and `BSel=1`, the two muxes before the ALU will select `pc` and `imm`, respectively. Because `ALUSel=Add`, these two values will be added together using the ALU to produce `pc + imm`.

1. **Memory**: (We don't access DMEM, so skip this.)

1. **Write Back**: Write `pc + 4` output to the destination register by connecting the output of the `WBSel` mux to RegFile's `wdata` input.

    Around the next rising clock edge, `wdata`, `RegWEn`, and `rd` should be held stable through setup and hold time of RegFile.


:::{note} Control Signals for `jal`

* Configure `ImmSel` to `J`-type immediates.
* Set `RegWEn` to `1`, i.e., write back to RegFile.
* Set `BrUn` to _don't care_ (*)[^dont-care]. The `jal` instruction does not use the branch comparator.
* Set `ASel` to `1`.
* Set `BSel` to `1`.
* Set `ALUSel` to `Add`.
* Set `MemRW` to `Read`. This means **no** write to DMEM.
* Set `WBSel` to `2` (to select `pc + 4` in @anim-datapath-jal).
* Set `PCSel` to `taken`.

[^dont-care]: Review [Control Signals for Stores](#sec-control-store) for an explanation of "don't care."

:::

## Datapath updates for `jalr`

To support `jalr`:

* RegFile: We **read** one register `rs1` and write one register `rd`. The value to write is `pc + 4`, i.e., the "link" to the next instruction.
* PC: We **read** from and **write** to `PC`. The value to write is `R[rs1] + imm`.

We do **not need any updates** to our datapath to support `jalr`! Because `jalr` is I-Type, the immediate generator block already supports it. Instead, for `jalr`, we need to set our control signals accordingly.

## Tracing the `jalr` Datapath

::::{figure}
:label: anim-datapath-jalr
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-jalr.pptx
:width: 100%
:title: "Tracing the `jalr` Datapath"
:::
The `jalr` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::


1. **Instruction Fetch**: At the beginning of the clock cycle, read PC and fetch the current instruction from `IMEM`. Feed `pc + 4` to blocks.

    Before the next rising clock edge, set the output of the ALU to the input of PC.

1. **Instruction Decode**: Fetch `R[rs1]` from RegFile and build the immediate `imm` for I-Type instructions. Also configure control logic (see below).

1. **Execute**: Compute `R[rs1] + imm` using the ALU. Because control signals are `ASel=0` and `BSel=1`, the two muxes before the ALU will select `R[rs1]` and `imm`, respectively. Because `ALUSel=Add`, the ALU will add these two values together.

1. **Memory**: (We don't access DMEM, so skip this.)

1. **Write Back**: Write `pc + 4` output to the destination register and connect the output of the `WBSel` mux to RegFile's `wdata` input.

    Around the next rising clock edge, `wdata`, `RegWEn`, and `rd` should be held stable through setup and hold time of RegFile.


:::{note} Control Signals for `jalr`

* Configure `ImmSel` to `I`-type immediates.
* Set `RegWEn` to `1`, i.e., write back to RegFile.
* Set `BrUn` to _don't care_ (*)[^dont-care]. The `jalr` instruction does not use the branch comparator.
* Set `ASel` to `0`.
* Set `BSel` to `1`.
* Set `ALUSel` to `Add`.
* Set `MemRW` to `Read`. This means **no** write to DMEM.
* Set `WBSel` to `2` (to select `pc + 4` in @anim-datapath-jalr).
* Set `PCSel` to `taken`.

:::