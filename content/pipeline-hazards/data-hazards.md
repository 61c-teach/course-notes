---
title: "Data Hazards"
subtitle: Coming soon. Watch video for now!
---

(sec-data-hazards)=
## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/iOKJ-oW1urY
:width: 100%
:title: "[CS61C FA20] Lecture 22.4 - Pipelining II: Data Hazards"
:::

::::

From [earlier](#sec-pipeline-hazards):

:::{embed} #block-def-hazard-data
:::

Data hazards occur because instructions read from and write to the same registers and memory. From P&H 4.6:

> Suppose you found a sock at the folding station for which no match existed. One possible strategy is to run down to your room and search through your clothes bureau to see if you can find the match. Obviously, while you ar edoing the search, loads that have completed drying are ready to fold and those that have finished are ready to dry.

In this section, we discuss how the five-stage pipelined processor can be modified to mitigate performance hits due to data hazards.

Consider the following [waterfall diagram](#sec-waterfall) in @tab-data-hazard-1. The `add` and `sub` instructions have a data hazard because the former writes to _and_ the latter reads from register `s0`. 

```{list-table} Example 1. Data hazard.
:header-rows: 1
:label: tab-data-hazard-1

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0 t0 t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `sub t2 s0 t0`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  -
* - `or  t3 t4 t5`
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
```

The `sub` instruction must read the updated value of `s0` after the `add` instruction completes. In cycle 5, the `add` instruction writes to register `s0`. However, in cycle 3, `sub` reads from register `s0`, which gets the stale value of `s0`, before `add` has updated it. Then `sub` performs the incorrect subtraction of this stale value before writing the incorrect result.

(sec-data-hazards-stall)=
## Stalling

To resolve the data hazard in @tab-data-hazard-1, we can **stall** the pipeline until resources are "ready," i.e., `add` has written the correct value to register `s0`. Pipeline stalls, or **bubbles**, are effectively "no-ops" where affected pipelines do nothing.

The below diagram illustrates a three-stall solution. In @tab-data-hazard-1-stall, `sub` will most certainly read the correctly updated value of register `s0` by the end of cycle 6.

```{list-table} Example 1: Resolving data hazards with stalls. A dash (–) indicates that the pipeline is flushed and affected instructions do "nothing."
:label: tab-data-hazard-1-stall
:header-rows: 1

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0, t0, t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `sub → nop`
  - 
  - IF
  - –
  - –
  - –
  - –
  - 
  - 
  - 
* - `nop`
  - 
  - 
  - –
  - –
  - –
  - –
  - –
  - 
  - 
* - ` nop`
  - 
  - 
  - 
  - –
  - –
  - –
  - –
  - –
  - 
* - `sub t2, s0, t0`
  - 
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
```

Because performance suffers with stalling, we will discuss ways to avoid stalling where possible (though it is always a good last resort).

### Implementing Stalls

The details in this subsection are out of scope.
For more information, read P&H 4.8.

Implementing stalls in hardware requires control and extra pipeline state to prevent unintended state changes in stalled stages, e.g. writes to the program counter, register, or memory.

One approach described in P&H 4.8 is a hazard detection unit. For data hazards, this detection unit can be implemented in the `ID` stage to determine if the source registers of this instruction depend on the destination register of register(s) still in the pipeline.[^stall-pipeline-regs] To stall an instruction, we could deassert all control signals (by setting them to 0) so that when the instruction passes through later stages, the stages effectively do nothing.[^stall-instruction]

We illustrate this in @tab-data-hazard-1-stall, where in cycle 2, the hazard detection unit detects that the instruction in the `ID` stage, `sub`, has a source registere that depends on the `add` instruction. The hazard detection unit then bubbles nops through the pipeline and preserves the `sub` instruction until it can be safely completed[^stall-stages].

[^stall-pipeline-regs]: How do we check destination registers? The hazard detection unit checks the pipeline registers. For example, if register `rd` specified in the `ID/EX` pipeline registers is one of the source registers for the instruction in the `ID` stage, then stall the instruction in the `ID` stage.

[^stall-instruction]: If the instruction in the `ID` stage is stalled, then the instruction in the `IF` stage must also be stalled, etc. We can accomplish this by (1) preventing the PC register from incrementing, and (2) preventing the `IF/ID` pipeline register from changing. From P&H 4.8: "It's as if you restart the washer with the same clothes, and let the dryer continue tumbling empty. Of course, like the dryer, the back half of the pipeline starting with the EX stage must be doing something; what it is doing is executing instructions that have no effect: nops."

[^stall-stages]: We note that in @tab-data-hazard-1-stall, the `sub` instruction is really fetched in cycle 2, but its `ID` stage is delayed until clock cycle 6.

## RegFile: Write-Then-Read

Consider the waterfall diagram in @tab-data-hazard-2. Does the dependency between `add` and `sw` incur a data hazard?

```{list-table} Example 2. Data hazard...?
:header-rows: 1
:label: tab-data-hazard-2

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add t0 t1 t2`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `lw  t0 8(t3)`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
* - `or  t3 t4 t5`
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
* - `sw  t0 4(t6)`
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
* - `sll t6 t0 t3`
  - 
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
```

What is happening in cycle 5? If we are assuming our [original RegFile design](#sec-element-regfile), then the `add` instruction in the `WB` stage only sets up the MUX, so that the write to `t0` occurs at the _next_ rising clock, edge, or cycle 6. This would mean that in the same cycle 5, the `sw` instruction in the `ID` stage would indeed read a stale value, causing a data hazard.[^not-structural]

[^not-structural]: We note this hazard is **not a structural hazard**. After all, the [RegFile design](#sec-element-regfile) _does not prevent_ `add` and `sw` from reading/writing to the same register in the same cycle, because there are sufficient input ports. However, what is concerning is that the _value_ `sw` reads must be the correct value that `add` writes.

The RISC-V five-stage pipeline therefore "ups" the **hardware requirement** on the register file. We leverage the high speed of the register file (100 ps for each of read/write) to assume that the hardware unit supports **write-then-read**:

* `WB` stage instruction updates value in first half of cycle, e.g., on _falling_ edge.
* `ID` stage reads new value.

::::{hint} New hardware assumption: RegFile is write-then-read

This assumption is further illustrated by the shading of the `ID` and `WB` stages in the high-level pipeline processor diagram discussed in an [earlier section](#sec-processor-hl):

:::{figure} #fig-pipelined-processor-hl

The left half of the `WB` stage is shaded, indicating that the RegFile is written in the first half of the clock cycle. Similarly, the right half of the `ID` stage is shaded, indicating that the RegFile is read in the second half of the clock cycle. Reprinted from an [earlier section](#sec-processor-hl).
:::

Note that it **might not always be possible** to support a register file with write-then-read capabilities, especially in high-frequency designs. Always check processor design assumptions beforehand, particularly when answering homework questions.
::::

If we assume our RegFile supports write-then-read, then in cycle 5, the read of the `sw` instruction in the `ID` stage delivers what is written by the `add` instruction in the `WB` stage, so there is **no data hazard**.

Let's visit our [earlier simple example](#tab-data-hazard-1). If we assume the RegFile supports write-then-read, then we can just stall _two_ cycles, as shown in @tab-data-hazard-1-stall-fast. In the first half of cycle 5, the `add` instruction writes to register `s0`; in the second half, the `sub` instruction reads `s0`.

```{list-table}  Example 1: Resolving data hazards with stalls **and** an assumption that the register file supports write-then-read in the same cycle. A dash (–) indicates that the pipeline is flushed and affected instructions do "nothing."
:header-rows: 1
:label: tab-data-hazard-1-stall-fast

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0, t0, t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `sub → nop`
  - 
  - IF
  - –
  - –
  - –
  - –
  - 
  - 
  - 
* - `nop`
  - 
  - 
  - –
  - –
  - –
  - –
  - –
  - 
  - 
* - `sub t2, s0, t0`
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
```

(sec-data-hazards-forward)=
## Forwarding

So far, we have discussed some solutions to some hazards by (1) specifying appropriate hardware requirements, and, if all else fails, (2) stalling the pipeline until there are no hazards.

However, we observe that with data hazards, we don't need to wait for the instruction to complete before trying to resolve the data hazard. In other words, the data in question is ready _much earlier_ than the `WB` stage of the earlier instruction.

Consider the example in @tab-data-hazard-3, which has two data hazards because the `sub` and `or` instructions depend on the result of the `add` instruction writing to register `s0`. 

:::{list-table} Example 3.
:label: tab-data-hazard-3
:header-rows: 1

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0 t0 t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `sub t2 s0 t0`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
* - `or  t6 s0 t3`
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
:::

The result of adding `t0` and `t1` is ready at the beginning of cycle 4, once the `add` instruction completes the `EX` stage in cycle 3. Similarly, 
In other words, as soon as the ALU creates the sum for the `add` instruction, we could add extra hardware to supply it as the input for the `sub` instruction _and_ the `or` instruction.

Wiring more connections in the datapath to use results when computed is a process known as **forwarding** or **bypassing**. Instead of waiting for the value to be written into the RegFile, we can instead grab the operand directly from the next pipeline stage.

We use @fig-forwarding-hl to describe at a high-level what data is forwarded.

:::{figure} images/forwarding-hl.png
:label: fig-forwarding-hl
:width: 80%

Forwarding adds extra connections between [pipeline registers](#sec-pipeline-registers) and other components in the datapath.
:::

Notes:

* At the beginning of cycle 4, the ALU result from the `add` instruction is forwarded from its `EX/MEM` pipeline register directly to the ALU (for the `sub` instruction's `EX` stage).
* At the beginning of cycle 5, the ALU result from the `add` instruction is forwarded from its `MEM/WB` pipeline register directly to the ALU (for the `or` instruction's `EX` stage).
* The value of register `s0` is still updated in cycle 5, from the stale value 5 to the new value 9. The `ID` stages of the `sub` and `or` instructions still read the stale value of register `s0` in cycles 2 and 3, respectively. What matters is that the correct operands are fed into ALU during the `EX` stage for both of these instructions.
* Note that with hardware forwarding, we do not need to update the waterfall diagram in @tab-data-hazard-3 because no stalls occur.

### Implementing Forwarding

Forwarding is implemented by adding bypass wires between pipeline registers and other components, inserting muxes, and including additional control logic.

@fig-forwarding-ex-mem shows an implementation of the `EX/MEM` forwarding to resolve the `add` and `sub` data hazard in @tab-data-hazard-3. The forwarding path (e.g., **bypass**) connects the output of the ALU from the `EX/MEM` pipeline register to the ALU input muxes. These two muxes are now wider to account for the additional bypass option. The control signals `ASel` and `BSel` now must also use the instruction bits to determine if the bypass should be used for either input to the ALU.

:::{figure} images/forwarding-ex-mem.png
:label: fig-forwarding-ex-mem
:width: 100%
:alt: "TODO"

:::

Note that in this course, we discuss **two** bypasses: from the `EX/MEM` pipeline registers (e.g., in @tab-data-hazard-3, to resolve the `add`/`sub` data hazard) and the `MEM/WB` pipeline registers (to resolve the `add`/`or` data hazard). @fig-forwarding-all-hl shows how the B input to the ALU must select the data from the `ID/EX` pipeline registers, the `EX/MEM` pipeline registers, and the `MEM/WB` pipeline registers.

:::{figure} images/forwarding-all-hl.png
:label: fig-forwarding-all-hl
:width: 80%
:alt: "TODO"

Forwarding bypasses for the ALU's B input signal. For simplicitly, we do not draw the the bypasses for the A input signal, though they are certainly needed.
:::

We have only shown one in @fig-forwarding-ex-mem; we omit the full MEM/WB bypass diagram, leaving this for you to work out.

(sec-data-hazards-load)=
## Load Data Hazards

Watch lecture/video for now! Thanks.

<!-- :::{figure} images/read-write-data-hazard.png
:label: fig-data-hazard
:width: 100%
:alt: "TODO"

Waterfall diagram for read-write data hazard.
:::

:::{figure} images/alu-hazard-result.png
:label: fig-alu-hazard
:width: 100%
:alt: "TODO"

Waterfall diagram for ALU problem: WB in `inst1` must happen before EX in `inst2`.
:::

:::{figure} images/stalling.png
:label: fig-stalling
:width: 100%
:alt: "TODO"

Solution 1: Stalling pipeline with `nop`.
:::



:::{figure} images/forwarding-pipeline-table.png
:label: fig-forwarding-table
:width: 100%
:alt: "TODO"

Waterfall diagram for forwarding with EX hazard.
::: -->