---
title: "Precheck Summary"
---

## To Review$\dots$

Register-to-register operations (R-type): `inst rd rs1 rs2`:
|||
| -------- | ------- |
| `add` | Adds `R[rs1]` and `R[rs2]` and stores the result in rd |
| `xor` | Exclusive ORs `R[rs1]` and `R[rs2]` and stores the result in rd |
| `mul` | Multiplies `R[rs1]` by `R[rs2]` and stores the result in rd |
| `sll` | Logical left shifts `R[rs1]` by `R[rs2]` and stores the result in rd |
| `srl` | Logical right shifts `R[rs1]` by `R[rs2]` and stores the result in rd |
| `sra` | Arithmetic right shifts `R[rs1]` by `R[rs2]` and stores the result in rd |
| `slt(u)` | If `R[rs1]` < `R[rs2]`, puts 1 in `rd`, else puts 0 (`u compares unsigned) |

Memory operations:
|||
| -------- | ------- |
| `sw rs2 rs1(imm)` | Stores `R[rs2]` to the address `R[rs1] + imm` in memory |
| `lw rd rs1(imm)` | Loads address `R[rs1] + imm` *from* memory into `rs2` |

Branch operations (B-type): `inst rs1 rs2 label`:
|||
| -------- | ------- |
| `bne` | If `rs1 != rs2`, jump to `label` |

Branch operations (B-type): `inst rs1 rs2 label`:
|||
| -------- | ------- |
| `beq` | If `rs1 == rs2`, jump to `label` |

Jump operations (J-type): `inst rd label`
|||
| -------- | ------- |
| `jal` | Stores the next instruction’s address into `rd` and jumps to `label` |
