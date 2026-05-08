---
title: "The RISC-V 5-Stage Pipeline"
---

(sec-five-stage-pipeline)=
## Learning Outcomes

* Explain how pipeline registers pass data in-between stages of the 5-stage pipeline.
* Contrast the ways that the five-steps of a RISC-V instruction are implemented in a 5-stage pipelined processor and a single-cycle processor.
* Discuss approaches to pipelining control.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/n5czmvbyX1w
:width: 100%
:title: "[CS61C FA20] Lecture 22.3 - Pipelining II: Pipelining Datapath"
:::

::::

:::{warning} Review pipelined circuits

We strongly recommend first reading about **registers in pipelined circuits**, covered in [this section](#sec-pipelining-circuits) of the Synchronous Digital Systems unit.

:::

In this section, we transform the single-cycle processor into our RISC-V **five-stage pipelined processor**. 
A pipelined processor "separates" the [five steps to a RISC-V instruction](#sec-five-steps) into **stages**, where instructions execute in stages, and stages of different instructions execute in **parallel** during the same clock cycle.

(sec-pipeline-datapath)=
## Pipelined Datapath

Toggle between the visualizations below to visualize the five-stage pipelined datapath. At each rising clock edge, **pipeline registers** carry data and control signals to the next stage. We discuss control [below](#sec-pipeline-control).

:::::{tab-set}
::::{tab-item} 5-Stage Pipelined Datapath
:::{figure} images/five-stage-pipeline.png
:label: fig-five-stage-pipeline
:width: 100%
:alt: "Five-stage pipeline datapath with IF, ID, EX, MEM, and WB separated by pipeline registers."

Five-stage RISC-V datapath diagram. Pipeline registers are inserted between stages to hold signals until the next clock cycle.
:::
::::
::::{tab-item} Single-Cycle Datapath
:::{figure} images/five-stage-single-cycle.png
:label: fig-five-stage-single-cycle
:width: 100%
:alt: "Single-cycle datapath partitioned into the five logical instruction-execution steps for comparison."

Single-cycle RISC-V datapath, separated into the [five steps](#sec-five-steps).
:::
::::
:::::

:::{note} Pipeline registers

Each stage needs to process data from a different instruction. To do so, the five-stage pipeline inserts **pipeline registers** between each stage.

**Pipeline registers** are registers inserted between stages that retain the results of individual instructions computed in one stage to be used in the next stage. These registers allow for portions of a single processor to be shared by multiple instructions.

:::

Just like [the single-cycle datapath](#sec-single-cycle), in the five-stage pipeline, data and control signals still generally move left to right. There are also still two loops. We extend our original quote from P&H 4.7:

> Instructions and data move generally from left to right through the five stages as they complete execution. Returning to our laundry analogy, clothes get cleaner, drier, and more organized as they move through the line, and they never move backward.
>
> There are, however, two exceptions to this left-to-right flow of instructions:
>
> * The write-back stage, which places the results back into the register file in the middle of the datapath
> * The selection of the next value of the PC, choosing between the incremental PC and the branch address from the MEM stage
>
> Data flowing from right to left do not affect the current instruction; these reverse data movements influence only later instructions in the pipeline. Note that the first right-to-left flow of data can lead to data hazards and the second leads to control hazards.[^hazards]

[^hazards]: We discuss [hazards](#sec-pipeline-hazards) in a later section of this chapter.

We define pipeline registers by the two stages they are inserted between, e.g., `IF/ID` pipeline registers refer to the registers between the `IF` and `ID` stages. From P&H 4.7:

> Returning to our laundry analogy, we might have a basket between each pair of stages to hold the clothes for the next step.

## Five Stages of the RISC-V Pipelined Processor

We now revisit the [five steps to a RISC-V instruction](#sec-five-steps) in the context of our new five-stage pipelined datapath in @fig-five-stage-pipeline. Here are the five steps.

```{embed} #sec-five-steps
```

And here are the stages of the five-stage RISC-V pipelined processor, one step per stage.

(sec-five-stages)=
:::{note} Five _stages_ of a RISC-V instruction

1. **Instruction Fetch (`IF`)**: Fetch the current instruction from IMEM and compute `PC + 4`.

    An instruction concurrently executing in a later stage (`MEM`) sets the control signal `PCSel` to determine the next instruction to execute.
1. **Instruction Decode (`ID`)**: Decode the operation from the bits of the instruction, read registers from the RegFile, and generate a 32-bit immediate.

    The `IF/ID` pipeline registers provide the instruction bits.
1. **Execute (`EX`)**: Use the ALU to either perform register-register arithmetic (R-Type), register-immediate arithmetic (I-Type, S-Type), PC-immediate arithmetic (loads, B-Type, `jal`, `auipc`), or get the immediate (`lui`).

    The `ID/EX` pipeline registers provide the operands for the ALU, as well as the instruction bits that determine the ALU operation.

    Additionally, use the Branch Comparator to compare the source register values, and pass the results into the control unit.
1. **Memory Access (`MEM`)**: Load data from (or store data to) DMEM.

    The `EX/MEM` pipeline registers provide the memory address and the data to write.

    Additionally, the results of the Branch Comparator are known at this time. Use the control unit to determine the `PCSel` control signal. In a [later section](#sec-control-hazards), we discuss how this design may lead to **control hazards**, or potential out-of-order execution of instructions.
1. **Write Back (`WB`)**: Write back to the RegFile.

    The `MEM/WB` pipeline registers provide the data to write, as well as the instruction bits that determine what to write (for the `WBSel` mux).

    Recall that in our discussion of [instruction timing](#sec-instruction-timing) the `WB` phase of the single-cycle datapath simply included a MUX and register setup time, because it was assumed that the RegFile element performed rising-edge triggered writes. In a [later section](#sec-data-hazards), we discuss a modified RegFile element that can perform writes on the _falling edge_ of the clock.
:::

(sec-pipeline-registers)=
## Pipeline Registers in the 5-Stage Datapath

Below, we explain @fig-five-stage-pipeline-registers from the perspective of what is fed _into_ each set of pipeline registers. For example, when discussing `IF/ID` registers, we describe the instruction currently executing in the `IF` stage.

::::{figure}
:label: fig-five-stage-pipeline-registers
:alt: "Embedded slides animating what each set of pipeline registers captures between IF, ID, EX, MEM, and WB stages in the five-stage RISC-V datapath."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vSMgaBei-28IrooFMzb-ygC5ZURZV2WCwkfozWm8e6q74JxnLWYUySPoWurEwVVUgAL7rDPgbnxmULt/pubembed?start=false&loop=false
:width: 100%
:title: "Animation that steps through the pipeline registers in the five stage datapath, including what is fed into each, as discussed in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1U2q6p5iPYqNPFLD4cDYgE2T4o7FA0dfSVsiAt0qBCsA/edit?usp=sharing)"
:::
Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1U2q6p5iPYqNPFLD4cDYgE2T4o7FA0dfSVsiAt0qBCsA/edit?usp=sharing). A more complete picture is in @fig-five-stage-summary.
::::

:::{note} `IF/ID`: Show Explanation
:class: dropdown

An instruction that is currently in the `IF` stage passes the following into `IF/ID` pipeline registers:

* `PC`: The PC (i.e., address of this instruction) is saved in case it is needed in a later clock cycle, e.g., in the `EX` stage, where conditional branch/unconditional jump instructions use the ALU to compute PC-relative addresses.
* `inst`: The instruction data, which is read from IMEM during this stage, is saved for immediate use in the instruction's next stage, `ID`, e.g., to determine source registers. Recall that in the `IF` stage, the computer cannot know which type of instruction is potentially being fetched, so it must prepare for any instruction, passing potentially needed information down the pipeline (P&H 4.7).
:::

:::{note} `ID/EX`: Show Explanation
:class: dropdown

An instruction that is currently in the `ID` stage passes the following into `ID/EX` pipeline registers:

* `PC`: Unchanged but may still be needed by this instruction in a later stage (see `IF/ID` discussion). We pass this data directly between the `IF/ID` and `ID/EX` pipeline registers.
* `RegReadData1`: The `rdata1` output signal from RegFile read during this instruction's `ID` stage.
* `RegReadData2`: The `rdata2` output signal from RegFile, read during this instruction's `ID` stage.
* `imm`: The output of the immediate generator, produced in this instruction's `ID` stage.
* `inst`: Again, we pass the instruction along with its data onto the instruction's next stage, `EX`.

:::

:::{note} `EX/MEM`: Show Explanation
:class: dropdown

An instruction that is currently in the `EX` stage passes the following into `EX/MEM` pipeline registers:

* `PC`: Unchanged as part of this instruction's `EX` stage but may be needed in later cycles of this instruction, e.g., with `auipc`.
* `ALUOut`: The ALU result, computed during this stage.
* `RegRead2`: The data in register `rs2`; if this instruction is a store (S-Type), it will need this data in its `MEM` stage.
* `inst`: Again, we pass the instruction along with its data onto the instruction's next stage, `MEM`.
:::

:::{note} `MEM/WB`: Show Explanation
:class: dropdown

An instruction that is currently in the `MEM` stage passes the following into `MEM/WB` registers.

* `ALU`: Unchanged in this instruction's `MEM` stage, but needed as one of the options to write back to the RegFile in this instruction's next stage, `WB`.
* `PC+4`: To avoid sending both `PC` and `PC + 4` down the pipeline, we add an additional subcircuit to recalculate `PC + 4` as one of the write-back options in this instruction's next stage, `WB`.
* `Mem`: The result of reading DMEM, read in this stage.
* `inst`: We are repeating ourselves here. :-)
:::

(sec-pipeline-control)=
## Pipelined Control

Since pipelining the datapath leaves the meaning of the control lines unchanged, we can use the same control values but now group together the control signals by pipeline stage, as in @tab-controller-signals-pipeline and @fig-five-stage-control.

:::{table} Signals for control logic, grouped by pipeline stage.
:label: tab-controller-signals-pipeline

| Name | Stage |
| :-- | :-- |
| `ImmSel` | `ID` |
| `BrUn` | `EX` |
| `ASel` | `EX` |
| `BSel` | `EX` |
| `ALUSel` | `EX` |
| `MemRW` | `MEM` |
| `PCSel` | `MEM` |
| `WBSel` | `EX` |
| `RegWEn` | `WB` |

:::

We note there is nothing special to control in the `IF` stage, because the control signals to read instruction memory and to write the PC are always implicitly asserted.

:::{tip} Quick Check
:label: block-pcsel-mem

Suppose we execute a B-Type instruction on a five-stage pipelined datapath. In which stage of this instruction will we know whether the conditional branch is taken?

:::

:::{note} Answer

**The `MEM` stage.**

As shown in @fig-five-stage-control, `PCSel` is the control signal to determine _what_ to write to the PC, is determined in `MEM`. While the outcome of Branch Comparator output in the `EX` stage, the control computes the result of `PCSel` in the `MEM` stage.

:::

:::{figure} images/five-stage-with-control.png
:label: fig-five-stage-control
:width: 100%
:alt: "Five-stage pipeline diagram annotated with control signals carried and used at later stages."

Five-stage RISC-V processor diagram with control.
:::

### Implementing Pipelined Control

Implementing control means setting these control lines to the correct values in each stage for each instruction.

@fig-five-stage-control above shows a **one** approach. Each stage now has a separate control unit that determines the control signals based on the instruction currently executing in that stage. This is illustrated by the inputs to the different control signal groups: `inst (ID)`, `inst (EX)`, `inst (M)`, and `inst (WB)`.

::::{note} Click to show a second approach.
:class: dropdown

Another approach computes as many control signals as possible during instruction decode (`ID`) because all control signals but `PCSel` can be derived from the instruction. As shown in @fig-pipelined-control, this extends the pipeline registers to include control information to pipeline control "words" between stages. This approach reuses much of the control circuitry from our single-cycle processor, but it breaks from the grouping in @tab-controller-signals-pipeline.

:::{figure} images/pipelined-control.png
:label: fig-pipelined-control
:width: 80%
:alt: "Added pipeline register fields for control bits flowing alongside datapath values between stages."

Diagram of additional pipelined register for control.
:::

::::

## Summary

The full five-stage pipeline processor is shown in @fig-five-stage-summary; this is also on the course reference card.

:::{figure} images/five-stage-summary.png
:label: fig-five-stage-summary
:width: 100%
:alt: "Combined summary diagram of five-stage datapath and associated pipelined control paths."

Five-stage RISC-V processor diagram: datapath and control.
:::

The 5-stage pipeline we have studied is commonplace in many devices: cars, appliances, etc.
