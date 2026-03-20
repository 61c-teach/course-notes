---
title: "Supporting Branches"
---

(sec-datapath-b-type)=
## Learning Outcomes

* Implement a datapath that supports conditional branches (B-Type).
* Explain how the input/output signals of the branch comparator help determine (for all B-Type instructions) if a branch is "taken."
* Explain how the PCSel control signal determines the instruction to execute in the next clock cycle.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/XTgyEsFRvWg
:width: 100%
:title: "[CS61C FA20] Lecture 19.3 - Single-Cycle CPU Datapath II: Implementing Branches"
:::

::::

To support [branch instructions](#sec-b-type) like `beq` we must consider **state element updates**, **arithmetic operations**, and **data selectors**.

_State element updates_:

* RegFile: We **read** two registers `rs1` and `rs2` and compare the values `R[rs1]` and `R[rs2]`. We do not write to any registers.
* PC: We **read** from and **write** to PC. The value to write now **conditionally** depends on the result of the two-register comparison, which determines whether a branch is *taken*:
  * **taken**: `pc + 4`
  * **not taken**: `pc + imm`
* DMEM: No reading nor writing.

Like before, we **reuse** what already exists in our R-, I-, and S-Type datapath. Even with this, we will need to add three new blocks and some additional control logic.

(sec-intro-branch-comparator)=
### Branch Comparator

There are **three** arithmetic operations that branch instructions must (proactively) perform.

1. `pc + 4`. This hardware is already in our datapath.
1. `pc + imm`.
1. Compare `R[rs1]` and `R[rs2]`.

We only have one general-purpose [ALU](#fig-element-alu) available during the `EX` phase of our single-cycle datapath. We use this ALU to compute `pc + imm`. We discuss details [below](#sec-datapath-asel)

Since this ALU is now busy, we must introduce additional combinational logic to compute a comparison of `R[rs1]` and `R[rs2]` within the same clock cycle. We call this new combinational logic block the [**branch comparator**](#sec-datapath-branch-comparator).

We discuss the details of the branch comparator at the [end of this section](#sec-datapath-branch-comparator).

### MUX for PC input

To conditionally update the input to the `PC` element, we introduce a new **mux** that selects between `pc + imm` and `pc + 4` to feed into the `PC` element. We also therefore introduce a new **control signal** `PCSel` to feed into this mux.

These two new blocks are shown in @fig-branch-new-blocks. The branch comparator performs a logical operation to compare `R[rs1]` and `R[rs2]` and feeds two 1-bit-wide signals, `BrEq` and `BrLT`, into control logic. The new mux uses `PCSel` to update `PC` based on the branch result.

:::{figure} images/branch-new-blocks.png
:label: fig-branch-new-blocks

The branch comparator block and the `PCSel` mux, with `PCSel` control signal.
:::

(sec-datapath-asel)=
### MUX for ALU input

We need **one more mux** in our datapath to compute `PC + imm` with our existing ALU. The new mux in @fig-branch-new-blocks-asel selects the ALU input `A` based on a new control signal, `ASel`.

* Set `ASel` to `1` to pass in the program counter value `pc`.
* Set `ASel` to `0` to pass in the register value `R[rs1]`.

:::{figure} images/branch-new-blocks-asel.png
:label: fig-branch-new-blocks-asel

Branches require two muxes with two control signals: `PCSel` and `ASel`. The latter determines one of the inputs to our ALU.
:::

### Immediate Generator Block

We must also update the Immediate Generator block, `ImmGen`. Immediates in B-Type are [different from I-Type and S-Type](#sec-imm-swirl) and have an [implicit trailing zero](#sec-implicit-zero-b-type). Read more in the [Immediate Generator section](#sec-immgen-b-type).

## Tracing the Branch Datapath

Let's walk through the updated datapath for branch instructions (B-Type):

<iframe src='https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-branch.pptx' width='100%' height='600px' frameborder='0'>

1. **Instruction Fetch**: At the beginning of the clock cycle, read PC and fetch the current instruction from IMEM.

    Before the next rising clock edge, set up `PCSel`, and ensure that the input to PC is stable. If `PCSel=taken`, update PC to the output of the ALU. Else, update to next instruction `pc + 4`.

1. **Instruction Decode**: Fetch `R[rs1]` and `R[rs2]` from RegFile, build the immediate `imm` for B-Type instructions. Also configure control logic (see below).

1. **Execute**: Compute `pc + imm` using the ALU. Because control signals are `ASel=1` and `BSel=1`, the two muxes before the ALU will select `pc` and `imm`, respectively. Because `ALUSel=Add`, the ALU will add these two values together.

    The branch comparator compares `R[rs1]` and `R[rs2]` (doing an unsigned comparison if `BrUn=1`) and outputs two signals, `BrEq` and `BrLT`, to the control logic.

    After some delay, the output of the ALU is stable at the mux controlled by `PCSel`. Additionally, the control signal `PCSel` is stable after the control logic uses the `BrEq` and `BrLT` signals to determine whether to take the branch (see details [below](#sec-control-pcsel)).

1. **Memory**: (We don't access DMEM, so skip this.)

1. **Write Back**: (We don't write to RegFile, so skip this.)


:::{note} Control Signals for Branches

* Configure `ImmSel` to `UB`-type immediates.
* Set `RegWEn` to `1`, i.e., write back to RegFile.
* Set `BrUn` to `1` if the branch comparator should perform an unsigned comparison. If the branch comparator should perform a signed comparison, set to `0`.
* Set `ASel` to `1`.
* Set `BSel` to `1`.
* Set `ALUSel` to `Add`.
* Set `MemRW` to `Read`. This means **no** write to `DMEM`.
* Set `WBSel` to _don't care_ (*)[^dont-care]
* Set `PCSel` to `taken` if `BrEq` and `BrLT` signals indicate the branch should be taken. Set `not taken` otherwise. See [below](#sec-control-pcsel).

[^dont-care]: Review [Control Signals for Stores](#sec-control-store) for an explanation of "don't care."

:::

(sec-datapath-branch-comparator)=
## Branch Comparator Block

The Branch Comparator Block in @fig-element-branch-comparator takes two data inputs and a control input, then outputs the result of comparing the two inputs. 

:::{figure} images/element-branch-comparator.png
:label: fig-element-branch-comparator
:width: 30%

Branch Comparator Block
:::

:::{table} Signals for Branch Comparator. Course project signal names, if different, are in parentheses.
:label: tab-branch-comparator-signals
:align: center

| Name | Direction | Bit Width | Description |
| :-- | :-- | :-- | :-- |
| `A` (`BrData1`) | Input | 32 | First value to compare |
| `B` (`BrData2`) | Input | 32 | Second value to compare |
| `BrUn` | Input | 1 | `1` when an **unsigned** comparison is wanted, and `0` when a **signed** comparison is wanted. Control signal. |
| `BrEq` | Output | 1 | Set to `1` if `A == B`, i.e., the two values are equal. |
| `BrLT` (`BrLt`) | Output | 1 | Set to `1` if `A < B`. Perform an unsigned comparison if `BrUn=1`, and signed otherwise. |

:::

:::{note} How does this branch comparator compute branch "taken"?

Review [B-Type instructions](#tab-rv32i-control): `beq`, `bne`, `blt`, `bltu`, `bge`, `bgeu`. Remember that all other branch comparisons are pseudoinstructions.
:::

This branch block is used to implement branches on the datapath with logic shown in @fig-branch-branch-comparator:

:::{figure} images/branch-branch-comparator.png
:label: fig-branch-branch-comparator
:width: 60%
:::

The control logic sets two control signals:

1. Sets `BrUn` based on the current instruction, i.e., sets `BrUn=1` if the instruction is `bltu` or `bgeu`.
2. Sets `PCSel` based on branch flags `BrLT` and `BrEq`.

In other words, the control logic subcircuit feeds input into the branch comparator _and_ uses output of the branch comparator to compute additional control signals.[^control-logic].

(sec-control-pcsel)=
### Set `PCSel`

Note that the two output signals `BrLT` and `BrEq` are sufficient for determining the results of all branch comparisons:

* `beq`, `bne`: Check `BrEq` and set `PCSel` accordingly.
* `blt` (and `bltu`): If `BrLT=1` and `BrEq=1`, then `PCSel=taken`.
* `bge` (and `bgeu`): If `BrLT=0`, then `PCSel=taken`. This is because checking $A \geq B$ is equivalent to checking $A \nless B$.

[^control-logic]: See a [later section](#sec-datapath-control) for more details.
