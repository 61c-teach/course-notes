---
title: "Supporting Immediates"
---

## Learning Outcomes

* Coming soon! We provide the animations for now.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vtZ6UAboFRk
:width: 100%
:title: "[CS61C FA20] Lecture 18.5 - Single-Cycle CPU Datapath I: Datapath with Immediates"
:::

::::

## Tracing the `addi` Datapath

<iframe src='https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-addi.pptx' width='100%' height='600px' frameborder='0'>


Data `inst[24:20]` still feeds into `RegFile`, which still outputs `R[rs2]`.
However, control `Bsel=1` means `R[rs2]` data line is ignored.

## Immediate Generator Block

:::{figure} images/element-immgen.png
:label: @fig-element-immgen

Immediate Generator Block
:::

### I-Type

:::{figure} images/immgen-i-type.png
:label: @fig-immgen-i-type

Immediate Generator Block: I-Type
:::

### Multiple instruction formats (e.g., I-Type, S-Type)

Coming soon. We recommend revisiting this section after you have traced through stores in our datapath.

### Course Project Details

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

The immediate storage formats are listed below:

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
