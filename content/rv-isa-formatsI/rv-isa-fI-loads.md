---
title: "Loads"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/QqHS2cElToU
:width: 100%
:title: "[CS61C FA20] Lecture 11.4 - RISC-V Instruction Formats I: Loads"
:::

::::

## Visuals

| funct3 |   | funct3 |   |
| :-- | --: | :-- | --: |
| `000` | add | `000` | addi |
| `000` | sub |   |   |
| `111` | and | `111` | andi |
| `110` | or | `110` | ori |
| `100` | xor | `100` | xori |
| `001` | sll | `001` | slli |
| `101` | srl | `101` | srli |
| `101` | sra | `101` | srai |
| `010` | slt | `010` | slti |
| `011` | sltu | `011` | sltiu |

|   |   |   | funct3 |   | opcode |   |
| :-- | -- | -- | -- | -- | -- | --: |
| `imm[11:0]` |   | `rs1` | `000` | `rd` | `0010011` | `addi` |
| `0000000` | `imm[4:0]` | `rs1` | `001` | `rd` | `0110011` | `slli` |
| `0000000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0110011` | `srli` |
| `0100000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0110011` | `srai` |

:::{figure} images/load-operation-isa.png
:label: fig-load-operation-isa
:width: 100%
:alt: "TODO"

Load operation instruction set.
:::

:::{figure} images/load-example.png
:label: fig-load-example
:width: 100%
:alt: "TODO"

Load word example instruction set.
:::

|   |   | funct3 |   | opcode |   |
| :-- | -- | -- | -- | -- | --: |
| `imm[11:0]` | `rs1` | `000` | `rd` | `0000011` | `lb` |
| `imm[11:0]` | `rs1` | `100` | `rd` | `0000011` | `lbu` |
| `imm[11:0]` | `rs1` | `001` | `rd` | `0000011` | `lh` |
| `imm[11:0]` | `rs1` | `101` | `rd` | `0000011` | `lhu` |
| `imm[11:0]` | `rs1` | `010` | `rd` | `0000011` | `lw` |

|   |   |   | funct3 |   | opcode |   |
| :-- | -- | -- | -- | -- | -- | --: |
|   | `imm[11:0]` | `rs1` | `000` | `rd` | `0010011` | `addi` |
|   | `imm[11:0]` | `rs1` | `111` | `rd` | `0010011` | `andi` |
|   | `imm[11:0]` | `rs1` | `110` | `rd` | `0010011` | `ori` |
|   | `imm[11:0]` | `rs1` | `100` | `rd` | `0010011` | `xori` |
| `0000000` | `imm[4:0]` | `rs1` | `001` | `rd` | `0010011` | `slli` |
| `0000000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0010011` | `srli` |
| `0000000` | `imm[4:0]` | `rs1` | `101` | `rd` | `0010011` | `srai` |
|   | `imm[11:0]` | `rs1` | `010` | `rd` | `0010011` | `slti` |
|   | `imm[11:0]` | `rs1` | `011` | `rd` | `0010011` | `sltiu` |

|   |   | funct3 |   | opcode |   |
| :-- | -- | -- | -- | -- | --: |
| `imm[11:0]` | `rs1` | `000` | `rd` | `0000011` | `lb` |
| `imm[11:0]` | `rs1` | `100` | `rd` | `0000011` | `lbu` |
| `imm[11:0]` | `rs1` | `001` | `rd` | `0000011` | `lh` |
| `imm[11:0]` | `rs1` | `101` | `rd` | `0000011` | `lhu` |
| `imm[11:0]` | `rs1` | `010` | `rd` | `0000011` | `lw` |
| `imm[11:0]` | `rs1` | `000` | `rd` | `1100111` | `jalr` |