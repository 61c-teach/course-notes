---
title: "Supporting Immediates"
---

(sec-datapath-i-type)=
## Learning Outcomes

* Implement a datapath that supports R-Type and I-Type arithmetic/logical instructions by reusing the ALU and adding an immediate generator block.
* Explain why a MUX is needed at the `B` input of the ALU.
* Design an immediate generator block that outputs a 32-bit immediate value from a 32-bit instruction.
* Extend the immediate generator block to support multiple immediate formats based on instruction format: I-, S-, B-, J-, and U-Type.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vtZ6UAboFRk
:width: 100%
:title: "[CS61C FA20] Lecture 18.5 - Single-Cycle CPU Datapath I: Datapath with Immediates"
:::

::::

## Building a R-Type + `addi` processor

Let's extend our R-Type datapath to support I-Type arithmetic and logical instructions, starting with `addi`. To support `addi`:

* `RegFile`: We **read** _one_ register `rs1` and write one register `rd`. The value to write is the **sum** between the read register value and an immediate, `R[rs1] + imm`.
* `PC`: We **read** from and **write** to `PC`. The value to write is `PC + 4`.

The `addi` instruction updates the same two states as R-Type instructions. But we now need to build an immediate `imm`!

To do so, we **reuse** what already exists in our R-Type datapath, then consider what additional blocks we need to add. In @fig-addi-cloud, we notice:

* We can leave the `PC = PC + 4` portion of the datapath unchanged.
* We can reuse much of the read/writing of the RegFile portion of the datapath. We still want to read `R[rs1]` and write `R[rd]`.
* We want add two 32-bit values, so we should probably reuse the `ALU` to "add."
  * We can keep the wire to ALU's input signal `A` unchanged.
  * We want to change the input signal `B` to be set to an immediate `imm` so that the ALU computes `alu = R[rs1] + imm`.

::::{figure} images/addi-cloud.png
:label: fig-addi-cloud
:width: 100%

`addi`: Reuse `PC = PC + 4` loop and ideally the "add" operation in the ALU.
::::

We therefore need **additional logic** that, for I-Type instructions, feeds in an immediate `imm` to ALU input `B` (instead of `R[rs2]`, used for R-Type). @fig-addi-new-blocks introduces the two new blocks and wires them to our existing datapath:

1. A new **mux** selects the immediate for the ALU input `B` based on a new control signal `BSel`. Read about muxes/multiplexors in a [previous section](#sec-mux).
    * Set `BSel` to `1` to pass in the immediate `imm`.
    * Set `Bsel` to `0` to pass in the register value `R[rs2]`.
1. A new block, the **immediate generator**, generates a 32-bit value `imm` from the instruction bits `inst`.

::::{figure} images/addi-new-blocks.png
:label: fig-addi-new-blocks
:width: 100%

`addi`: Add the `BSel` mux and the `ImmGen` block.
::::

(sec-datapath-addi)=
## Tracing the `addi` Datapath

Let's walk through the `addi` datapath with this new knowledge.

::::{figure}
:label: anim-datapath-addi
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-addi.pptx
:width: 100%
:title: "Tracing the `addi` Datapath"
:::
The `addi` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file. 
::::

1. **Instruction Fetch**: Increment PC to next instruction (see [R-Type datapath](#sec-datapath-add)).

1. **Instruction Decode**:
    * Read `R[rs1]` from RegFile (see [R-Type](#sec-datapath-add)).
    * Set up the destination register `rd` for writing.
    * Build the immediate `imm`. For [I-Type instructions](#tab-i-type), wire the upper 12 bits of the instruction `inst[31:20]` to the input to the Immediate Generator block.
    * Configure control logic.
        * Configure `ImmSel` to `I`-type immediates (for now, we only have one type of immediate).
        * Set `RegWEn` to `1`.
        * Set `BSel` to `1`.
        * Set `ALUSel` to `Add`.

    After some delay, the immediate generator block updates its output signal `imm` to the appropriate sign-extended 32-bit immediate value, register value `R[rs1]` is read, and control signals are set.

1. **Execute**: Because the control line `BSel=1` selects the generated immediate `imm` for ALU input `B`, our ALU computes `R[rs1] + imm`.

1. **Memory**: (We don't access memory, so skip this.)

1. **Write Back**: Write ALU output to the destination register by connecting `alu` to RegFile's `wdata` input (see [R-Type](#sec-datapath-add)).

    Around the next rising clock edge, `wdata`, `RegWEn`, and `rd` should be held stable through setup and hold time of RegFile.


:::{note} RegFile still outputs two signals!

In our datapath, read operations are like combinational logic, meaning RegFile, IMEM, and DMEM perform reads based on the input signals. There is no way to "turn off" read operations.

Data `inst[24:20]` still feeds into `RegFile`, which still outputs `R[rs2]`.
However, control `Bsel=1` means `R[rs2]` data line is ignored.

In general, our diagrams will omit unselected data lines from lighting.

:::

(sec-datapath-immgen)=
## Immediate Generator Block

We encourage revisiting this section after reading a few more example datapath traces.

:::{note} The Immediate Generator is combinational logic

In the full RISC-V implementation, our Immediate Generator (@fig-element-immgen) generates 32-bit values for all instruction formats that have immediates. The precise 32-bit output `imm` depends on the instruction `inst`, which specifies:

* The immediate "type," based on the instruction format type: I-, S-, B-, J-, and U-Type.
* The immediate bits in the instruction, which depends on the instruction type.

We recommend reviewing the "bit swirling" of immediates from a [previous section](#sec-imm-swirl).

:::

:::{figure} images/element-immgen.png
:label: fig-element-immgen

Immediate Generator Block
:::

:::{table} Signals for Immediate Generator. Course project signal names, if different, are in parentheses.
:label: tab-immgen-signals
:align: center

| Name | Direction | Bit Width | Description |
| :-- | :-- | :-- | :-- |
| Input | `inst` (`Instruction`) | 32 | The instruction being executed |
| Input | `ImmSel` | 3  | Value determining how to reconstruct the immediate |
| Output | `imm` (`Immediate`) | 32 | Value of the immediate in the instruction |

:::

Recall that the bits of the immediate are stored in different bits of the instruction, depending on the type of the instruction. The `ImmSel` signal, which is implemented in the control logic, will determine which type of immediate this subcircuit should generate.

The immediate storage formats are listed below in @tab-immgen-types.

:::{table} Immediate Storage Formats from the [RISC-V Green Card](#sec-green-card).
:label: tab-immgen-types
<table style="border: 1px solid black; border-collapse: collapse; font-family: monospace; width: 100%;">
  <thead>
    <tr style="background-color: #f2f2f2;">
      <th style="border: 1px solid black; padding: 5px; text-align: left;">Type</th>
      <th style="border: 1px solid black; padding: 5px; text-align: left;">ImmSel (default)</th>
      <th style="border: 1px solid black; padding: 5px; text-align: center;">Bits 31-20</th>
      <th style="border: 1px solid black; padding: 5px; text-align: center;">Bits 19-12</th>
      <th style="border: 1px solid black; padding: 5px; text-align: center;">Bit 11</th>
      <th style="border: 1px solid black; padding: 5px; text-align: center;">Bits 10-5</th>
      <th style="border: 1px solid black; padding: 5px; text-align: center;">Bits 4-1</th>
      <th style="border: 1px solid black; padding: 5px; text-align: center;">Bit 0</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border: 1px solid black; padding: 5px;">I</td>
      <td style="border: 1px solid black; padding: 5px;"><code>0b000</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="3"><code>inst[31:20]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="3"><code>inst[30:20]</code></td>
    </tr>
    <tr>
      <td style="border: 1px solid black; padding: 5px;">S</td>
      <td style="border: 1px solid black; padding: 5px;"><code>0b001</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="3"><code>inst[31]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>inst[30:25]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="2"><code>inst[11:7]</code></td>
    </tr>
    <tr>
      <td style="border: 1px solid black; padding: 5px;">B</td>
      <td style="border: 1px solid black; padding: 5px;"><code>0b010</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="2"><code>inst[31]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>inst[7]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>inst[30:25]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>inst[11:8]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>0</code></td>
    </tr>
    <tr>
      <td style="border: 1px solid black; padding: 5px;">U</td>
      <td style="border: 1px solid black; padding: 5px;"><code>0b011</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="2"><code>inst[31:12]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="4"><code>0</code></td>
    </tr>
    <tr>
      <td style="border: 1px solid black; padding: 5px;">J</td>
      <td style="border: 1px solid black; padding: 5px;"><code>0b100</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>inst[31]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>inst[19:12]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>inst[20]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;" colspan="2"><code>inst[30:21]</code></td>
      <td style="border: 1px solid black; padding: 5px; text-align: center;"><code>0</code></td>
    </tr>
  </tbody>
</table>

:::

Observations/reminders:

* You should treat I*-type immediates as I-type immediates, since the ALU should only use the lowest 5 bits of the B input when computing shifts.
* Recall that all immediates are 32 bits and **sign-extended**. Sign extension is shown in @tab-immgen-types as `inst[31]` repeated in the upper bits.

Like with the full datapath, we "iteratively" build the immediate generator to support I-Type, then S-Type, then B-Type. We leave the implementation of J-Type and U-Type immediates to you and the course project.

### I-Type

First, suppose our datapath only supported immediates from I-Type instructions. In this case, the immediate generator would perform two operations as shown in @fig-immgen-i-type.
:::{figure} images/immgen-i-type.png
:label: fig-immgen-i-type

Immediate Generator Block: I-Type
:::

:::{note} Show Explanation
:class: dropdown

1. `imm[31:12]`: **Sign-extend**. Copy the **sign bit** `inst[31]` to the upper 20 bits of the immediate, `imm[31:12]`.
1. `imm[11:0]`: **Wire**. Directly connect the two upper 12 bits of the instruction `inst[31:20]` to the lower 12 bits of the output `imm[11:0]`.

:::


### I-Type, S-Type

Next, suppose our datapath supported immediates from both I-Type and S-Type instructions. The immediate generator must set the lower bits `imm[4:0]` based on the immediate type. In @fig-immgen-i-s-type, we implement this selection with a MUX.

:::{figure} images/immgen-i-s-type.png
:label: fig-immgen-i-s-type

Immediate Generator Block: I-Type, S-Type
:::

:::{note} Show Explanation
:class: dropdown

1. `imm[31:12]`: **Sign-extend**. In both instruction formats, `inst[31]` is the sign bit of the immediate. Copy the **sign bit** `inst[31]` to the upper 20 bits of the immediate, `imm[31:12]`.
1. `imm[11:5]`: **Wire**. Directly connect the instruction bits `imm[31:25]` to the output `imm[11:5]`.
1. `imm[4:0]`: **Select**. Select the five bits to fill `imm[4:0]`: `inst[24:20]` if I-Type, and `inst[11:7]` if S-Type.
:::

### I-Type, S-Type, B-Type

Finally, suppose our datapath supports I-Type, S-Type, and B-Type instructions. The immediate generator design is shown in @fig-immgen-i-s-b-type, now with even more MUXes.

:::{figure} images/immgen-i-s-b-type.png
:label: fig-immgen-i-s-b-type

Immediate Generator Block: I-Type, S-Type
:::

:::{note} Show Explanation
:class: dropdown

1. `imm[31:12]`: **Sign-extend**. In all three instruction formats, `inst[31]` is the sign bit of the immediate. Copy the sign bit `inst[31]` to the upper 20 bits of the immediate, `imm[31:12]`.
1. `imm[11]`: **Select** `inst[31]` if I-Type or S-Type, and `inst[7]` if B-Type.
1. `imm[10:5]`: **Wire**. Directly connect the instruction bits `imm[30:25]` to the output `imm[10:5]`.
1. `imm[4:1]`: **Select**. `inst[24:20]` if I-Type, and `inst[11:8]` if S- or B-Type.
1. `imm[0]`: **Select**. `inst[20]` if I-Type, `inst[7]` if S-Type, and `0` ([implicit](#sec-implicit-zero-b-type)) if B-Type.

:::

### Course Project Details

:::{table} Default `ImmSel` encodings for the course project. You are welcome to pick your own.
:label: tab-immgen-operations

| `ImmGen` Value <br/>(for Project) | Immediate Type |
| :-- | :-- |
| `0b000` | I |
| `0b001` | S |
| `0b010` | B |
| `0b011` | U |
| `0b100` | J |

:::
