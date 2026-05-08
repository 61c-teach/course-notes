---
title: "Control Hazards"
---

(sec-control-hazards)=
## Learning Outcomes

* Given instruction sequences and a processor architecture, identify potential control hazards.
* Explain the approach that the RISC-V five-stage pipeline uses to resolve control hazards.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/CnDgqw-bsyQ
:width: 100%
:title: "[CS61C FA20] Lecture 23.2 - Pipelining III: Control Hazards"
:::

::::

From [earlier](#sec-pipeline-hazards):

:::{embed} #block-def-hazard-control
:::

Control hazards occur when the instruction fetched may not be the one needed. In other words, _whether_ an instruction executes depends on the outcome of a previous execution. From P&H 4.6:

> Suppose our laundry crew was given the happy task of cleaning the uniforms of a football team. Given how filthy the laundry is, we need to determine whether the detergent and water temperature setting we select are strong enough to get the unifroms clean...In our laundry pipeline, we have to wait until the second stage to examine the dry uniform to see if we need to change the washer setup or not.

Control hazard occur with **jump and branch instructions**. We must begin fetching the instruction following the jump/branch on the following clock cycle. However, the pipeline cannot possibly know what the next instruction should be—since it only _just read_ the jump/branch instruction from memory.

```{embed} #block-pcsel-mem
```

:::{note} Show Answer
:class: dropdown

This Quick Check was covered in an earlier section: [Pipelined Control](#sec-pipeline-control). Additionally, review `MEM` in the [five stages section](#sec-five-stages).

:::

We demonstrate a control hazard with B-Type instructions in @tab-waterfall-branch. We take the branch in the `MEM` stage, _after_ we know the result of the `ALU` and branch comparator from the `EX` stage. Otherwise, if we don't take the branch, we continue selecting the next instruction as `PC + 4`.


```{list-table} Control hazards can occur with branch instructions, because instructions are executed before the branch outcome is known.
:label: tab-waterfall-branch
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
* - `beq t0 t1 Label`
  - IF
  - ID
  - EX
  - M
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
  - M
  - WB
  -
  -
  -
* - `or  t6 a0 t0`
  -
  -
  - IF
  - ID
  - EX
  - M
  - WB
  -
  -
* - `xor t5 t1 s0`
  -
  -
  -
  - IF
  - ID
  - EX
  - M
  - WB
  -
* - `Label: sw  s0 8(t3)`
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

For the `beq` instruction, we must wait until time cycle 4 (`beq`'s `MEM` stage) to determine if the branch is taken. By that time, the next three instructions have already started executing, before the branch outcome was known.

If the branch is indeed taken, to avoid a control hazard we need to ensure that the three instructions `sub`, `or`, and `xor` do not execute to completion. We discuss a naive approach first, then a more clever one.

## Approach 1: Stall on branch

One possibility is that whenever we detect a branch (or jump) instruction, we stall the pipeline when we detect a branch until the correct PC is known. This implementation would involve extra wiring so that as soon as a branch is decoded in the `ID` stage, other instructions are stalled until the branch outcome is determined in the `MEM` stage.

In @tab-waterfall-branch-simple, **every branch instruction incurs a three-instruction stall**, regardless if the branch is taken or not.

```{list-table} Approach 1. On a branch instruction, always stall until the next instruction is determined. A dash (–) indicates that the pipeline is flushed and affected instructions do "nothing."
:label: tab-waterfall-branch-simple
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
* - `beq t0, t1, Label`
  - IF
  - ID
  - EX
  - M
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
* - `nop`
  - 
  - 
  - 
  - –
  - –
  - –
  - –
  - –
  - 
* - `Label: sw s0, 8(t3)`
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

This approach is simple but slow. It is rather costly if our program has many branches. After all, if we _don't_ take the branch, we should proceed with executing the `sub` instruction after all.

## Approach 2: Assume branch not taken

Another approach could be to _stall only when needed_. In other words, proceed with executing the instructions in sequence, and immediately **flush the pipeline** once it is determined that the branch should be taken. Compare the two cases below.

If a branch is taken, we stall **three cycles**. In @tab-waterfall-branch-taken, once it is determined that the branch is taken in cycle 4, flush the pipeline. This involves converting the instructions in the `IF`, `IF`, `EX` stages to no-ops. Then, in cycle 5, the correct instruction (the `sw` instruction branched to) is executed.

```{list-table} Approach 2. In cycle 4, we determine that the branch is taken. A dash (–) indicates that the pipeline is flushed and affected instructions do "nothing."
:label: tab-waterfall-branch-taken
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
* - `beq t0 t1 Label`
  - IF
  - ID
  - EX
  - M
  - WB
  - 
  - 
  - 
  - 
* - `sub → nop`
  - 
  - IF
  - ID
  - EX
  - –
  - –
  - 
  - 
  - 
* - `or  → nop`
  - 
  - 
  - IF
  - ID
  - –
  - –
  - –
  - 
  - 
* - `xor  → nop`
  - 
  - 
  - 
  - IF
  - –
  - –
  - –
  - –
  - 
* - `Label: sw  s0 8(t3)`
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

If the branch is not taken, we stall **zero cycles**. In @tab-waterfall-branch-not-taken, if it is determined that the branch is _not_ taken in cycle 4, do not do anything out of the ordinary. Because the instructions `sub`, `or`, and `xor` are already in the pipeline, we do not waste any cycles on stalling. 

```{list-table} Approach 2. If the branch is not taken, proceed as normal. This table therefore looks identical to @tab-waterfall-branch!
:label: tab-waterfall-branch-not-taken
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
* - `beq t0 t1 Label`
  - IF
  - ID
  - EX
  - M
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
  - M
  - WB
  -
  -
  -
* - `or  t6 a0 t0`
  -
  -
  - IF
  - ID
  - EX
  - M
  - WB
  -
  -
* - `xor t5 t1 s0`
  -
  -
  -
  - IF
  - ID
  - EX
  - M
  - WB
  -
* - `Label: sw  s0 8(t3)`
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

:::{hint} The 5-Stage Pipeline resolves control hazards by assuming that branches are not taken.

From P&H 4.6:

> One simple approach is to predict always that conditional branches will be untaken. When you're right, the pipeline proceeds at full speed. Only when conditional branches are taken does the pipeline stall.

:::

Like most all cases we have seen thus far, we can evaluate the performance of this design—that is, assuming that branches are not taken, then stalling if they are—design on a program benchmark. If we have a program that takes many branches, this design will perform poorly. If we have a program that does not take many branches (even though many branch instructions exist), this design will work great!

## Approach 3: Branch Prediction

The simple approach used by our five-stage pipeline, described in the previous subsection, is an example of **branch prediction**. 

Computers nowadays use a more sophisticated version of branch prediction. A rigid version could predict before the program executes that some conditional branches are taken and some are untaken. This approach may rely on stereotypical behavior or the average case, or even a "coin flip" on each cycle

More complex versions of branch prediction are dynamic and occur in hardware, which make guesses depending on the behavior of each and every conditional branch. These dynamic hardware predictors may change predictions for a conditional branch over the life of a program.

For more approaches to branch prediction and control hazards, see P&H 4.9.

<!--
## Visuals
 
:::{figure} images/control-hazard.png
:label: fig-control-hazard
:width: 100%
:alt: "Pipeline waterfall diagram table with five instructions in the first column, and then subsequent columns for 9 cycles. Each instruction steps through IF, ID, EX, M, and WB, staggered from the instruction before it, illustrating a control hazard where branch outcome uncertainty affects following instructions."

Waterfall diagram for control hazard with conditional branches.
:::

:::{figure} images/branch-pipeline-diagram.png
:label: fig-branch-pipeline
:width: 100%
:alt: "Branch pipeline diagram showing the full five-stage datapath with labeled stages. The branch comparator in the EX stage is highlighted, along with the PCSel control signal, showing when branch decision information becomes available in the pipeline."

Pipeline diagram showing branch results are ready during MEM.
:::

:::{figure} images/control-hazard-branch.png
:label: fig-control-hazard-branch
:width: 100%
:alt: "Control-hazard waterfall diagram table for the branch-taken case showing flushed or redirected subsequent instructions."

Waterfall diagram if conditional branch taken.
:::

:::{figure} images/control-hazard-no-branch.png
:label: fig-control-hazard-no-branch
:width: 100%
:alt: "Control-hazard waterfall diagram table for the branch-not-taken case showing normal fall-through instruction flow."

Waterfall diagram if conditional branch **not** taken.
:::
-->