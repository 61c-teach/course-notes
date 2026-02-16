---
title: "RV32I \"Green Card\""
short_title: "RV32I Green Card"
subtitle: 32-bit RISC-V Processor, Integer Instruction Set
---


This "green card" is longer than one page, due to the accessible web format. We compensate by supplementing these lookup tables with references to the official ISA and/or assembly manuals where appropriate. For a two-sided reference card with the same information, check out the PDF reference card on our course website.

**Reference**: The official RISC-V unprivileged ISA specification, [RV32I Base Integer Instruction Set, Version 2.1](https://docs.riscv.org/reference/isa/unpriv/rv32.html). In practice, the [ASM Manual](https://github.com/riscv-non-isa/riscv-asm-manual/blob/main/src/asm-manual.adoc) will have everything you need.

(sec-green-card)=
## RV32I Base Integer Instruction Set

(sec-green-card-arithmetic)=
### Arithmetic

:::{table} RV32I Instructions: Arithmetic
:label: tab-rv32i-arithmetic
:align: center

| Instruction | Name | Description | Type | Opcode | Funct3 | Funct7 |
| :--- | :--- | :--- | :---: | :------ | :--- | :--- |
| `add rd rs1 rs2` | ADD | `R[rd] = R[rs1] + R[rs2]` | R | `011 0011` | `000` | `000 0000` |
| `sub rd rs1 rs2` | SUBtract | `R[rd] = R[rs1] - R[rs2]` | R | `011 0011` | `000` | `010 0000` |
| `and rd rs1 rs2` | bitwise AND | `R[rd] = R[rs1] & R[rs2]` | R | `011 0011` | `111` | `000 0000` |
| `or rd rs1 rs2` | bitwise OR | `R[rd] = R[rs1] \| R[rs2]` | R | `011 0011` | `110` | `000 0000` |
| `xor rd rs1 rs2` | bitwise XOR | `R[rd] = R[rs1] ^ R[rs2]` | R | `011 0011` | `100` | `000 0000` |
| `sll rd rs1 rs2` | Shift Left Logical | `R[rd] = R[rs1] << R[rs2]` | R | `011 0011` | `001` | `000 0000` |
| `srl rd rs1 rs2` | Shift Right Logical | `R[rd] = R[rs1] >> R[rs2]` (Zero-extend) | R | `011 0011` | `101` | `000 0000` |
| `sra rd rs1 rs2` | Shift Right Arithmetic | `R[rd] = R[rs1] >> R[rs2]` (Sign-extend) | R | `011 0011` | `101` | `010 0000` |
| `slt rd rs1 rs2` | Set Less Than | `if (R[rs1] < R[rs2]) `<br/>`{   R[rd] = 1 } else {`<br/>`   R[rd] = 0 }` | R | `011 0011` | `010` | `000 0000` |
| `sltu rd rs1 rs2`| Set Less Than (Unsigned) | `if (R[rs1] < R[rs2]) `<br/>`{   R[rd] = 1 } else {`<br/>`   R[rd] = 0 }` | R | `011 0011` | `011` | `000 0000` |
| `addi rd rs1 imm`| ADD Immediate | `R[rd] = R[rs1] + imm` | I | `001 0011` | `000` | - |
| `andi rd rs1 imm`| bitwise AND Immediate | `R[rd] = R[rs1] & imm` | I | `001 0011` | `111` | - |
| `ori rd rs1 imm` | bitwise OR Immediate | `R[rd] = R[rs1] \| imm` | I | `001 0011` | `110` | - |
| `xori rd rs1 imm`| bitwise XOR Immediate | `R[rd] = R[rs1] ^ imm` | I | `001 0011` | `100` | - |
| `slli rd rs1 imm`| Shift Left Logical Immediate | `R[rd] = R[rs1] << imm` | I* | `001 0011` | `001` | `000 0000` |
| `srli rd rs1 imm`| Shift Right Logical Immediate | `R[rd] = R[rs1] >> imm` (Zero-extend) | I* | `001 0011` | `101` | `000 0000` |
| `srai rd rs1 imm`| Shift Right Arithmetic Immediate | `R[rd] = R[rs1] >> imm` (Sign-extend) | I* | `001 0011` | `101` | `010 0000` |
| `slti rd rs1 imm`| Set Less Than Immediate (signed) | `if (R[rs1] < imm) `<br/>`{   R[rd] = 1 } else {`<br/>`   R[rd] = 0 }` | I | `001 0011` | `010` | - |
| `sltiu rd rs1, imm`| Set Less Than Immediate (Unsigned)| `if (R[rs1] < imm) `<br/>`{   R[rd] = 1 } else {`<br/>`   R[rd] = 0 }`  | I | `001 0011` | `011` | - |

:::

### Memory

:::{table} RV32I Instructions: Memory
:label: tab-rv32i-memory
:align: center

| Instruction | Name | Description | Type | Opcode | Funct3 |
| :--- | :--- | :--- | :---: | :---: | :---: | 
| `lb rd imm(rs1)` | Load Byte | `R[rd] = M[R[rs1] + imm][7:0]` (Sign-extend) | I | `000 0011` | `000` |
| `lbu rd imm(rs1)` | Load Byte (Unsigned) | `R[rd] = M[R[rs1] + imm][7:0]` (Zero-extend) | I | `000 0011` | `100` |
| `lh rd imm(rs1)` | Load Half-word | `R[rd] = M[R[rs1] + imm][15:0]` (Sign-extend)| I | `000 0011` | `001` |
| `lhu rd imm(rs1)` | Load Half-word (Unsigned)| `R[rd] = M[R[rs1] + imm][15:0]` (Zero-extend)| I | `000 0011` | `101` |
| `lw rd imm(rs1)` | Load Word | `R[rd] = M[R[rs1] + imm][31:0]` | I | `000 0011` | `010` |
| `sb rs2 imm(rs1)` | Store Byte | `M[R[rs1] + imm][7:0] = `<br/>`R[rs2][7:0]` | S | `010 0011` | `000` |
| `sh rs2 imm(rs1)` | Store Half-word | `M[R[rs1] + imm][15:0] = `<br/>`R[rs2][15:0]` | S | `010 0011` | `001` |
| `sw rs2 imm(rs1)` | Store Word | `M[R[rs1] + imm][31:0] = `<br/>`R[rs2][31:0]` | S | `010 0011` | `010` |

:::

### Control

:::{table} RV32I Instructions: Control
:label: tab-rv32i-control
:align: center

| Instruction | Name | Description | Type | Opcode | Funct3 | Funct7 |
| :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| `beq rs1 rs2 label` | Branch if EQual | `if (R[rs1] == R[rs2]) PC = PC + offset` | B | `110 0011` | `000` | |
| `bne rs1 rs2 label` | Branch if Not Equal | `if (R[rs1] != R[rs2]) PC = PC + offset` | B | `110 0011` | `001` | |
| `blt rs1 rs2 label` | Branch if Less Than (signed) | `if (R[rs1] < R[rs2]) PC = PC + offset` | B | `110 0011` | `100` | |
| `bltu rs1 rs2 label`| Branch if Less Than (Unsigned)| `if (R[rs1] < R[rs2]) PC = PC + offset` | B | `110 0011` | `110` | |
| `bge rs1 rs2 label` | Branch if Greater or Equal (signed)| `if (R[rs1] >= R[rs2]) PC = PC + offset`| B | `110 0011` | `101` | |
| `bgeu rs1 rs2 label`| Branch if Greater or Equal (Unsigned)| `if (R[rs1] >= R[rs2]) PC = PC + offset`| B | `110 0011` | `111` | |
| `jal rd label` | Jump And Link | `R[rd] = PC + 4;`<br/>`PC = PC + offset` | J | `110 1111` | | |
| `jalr rd rs1 imm` | Jump And Link Register | `R[rd] = PC + 4;`<br/>`PC = R[rs1] + imm` | I | `110 0111` | `000` | |

:::

### Other

:::{table} RV32I Instructions: Other
:label: tab-rv32i-other
:align: center

| Instruction | Name | Description | Type | Opcode | Funct3 | 
| :--- | :--- | :--- | :---: | :---: | :---: | 
| `auipc rd immu` | Add Upper Imm to PC | `imm = immu << 12`<br/>`R[rd] = PC + imm` | U | `001 0111` | |
| `lui rd immu` | Load Upper Immediate | `imm = immu << 12`<br/>`R[rd] = imm` | U | `011 0111` | |
| `ebreak` | Environment BREAK | Asks the debugger to do something (`imm = 0`)| I | `111 0011` | `000` |
| `ecall` | Environment CALL | Asks the OS to do something (`imm = 1`) | I | `111 0011` | `000` |

:::


:::{table} RV32I Extension Instructions
:label: tab-rv32i-extension
:align: center

| Instruction | Name | Description |
| :--- | :--- | :--- |
| `mul rd rs1 rs2` | Multiply (part of `mul` ISA extension) | `R[rd] = (R[rs1]) * (R[rs2])` |

:::

## Pseudoinstructions

See the [ASM Manual](https://github.com/riscv-non-isa/riscv-asm-manual/blob/main/src/asm-manual.adoc#pseudoinstructions) and [this 2024 GitHub issue discussion](https://github.com/riscv/riscv-isa-manual/issues/1470).

:::{table} RV32I Common Pseudoinstructions
:label: tab-rv32i-pseudoinstructions
:align: center

| Pseudoinstruction | Name | Description | Translation |
| :--- | :--- | :--- | :--- |
| `beqz rs1 label` | Branch if EQuals Zero | `if (R[rs1] == 0)`<br/>`PC = PC + offset` | `beq rs1 x0 label` |
| `bnez rs1 label` | Branch if Not Equals Zero | `if (R[rs1] != 0)`<br/>`PC = PC + offset` | `bne rs1 x0 label` |
| `j label` | Jump | `PC = PC + offset` | `jal x0 label` |
| `jal label` | Jump And Link (Pseudo) | `R[ra] = PC + 4`<br/>`PC = PC + offset` | `jal ra label` |
| `jr rs1` | Jump Register | `PC = R[rs1]` | `jalr x0 rs1 0` |
| `la rd label` | Load absolute Address | `R[rd] = &label` | `auipc`, `addi` |
| `li rd imm` | Load Immediate | `R[rd] = imm` | `lui` (if needed), `addi` |
| `mv rd rs1` | MoVe | `R[rd] = R[rs1]` | `addi rd rs1 0` |
| `neg rd rs1` | NEGate | `R[rd] = -(R[rs1])` | `sub rd x0 rs1` |
| `nop` | No OPeration | do nothing | `addi x0 x0 0` |
| `not rd rs1` | bitwise NOT | `R[rd] = ~(R[rs1])` | `xori rd rs1 -1` |
| `ret` | RETurn (`jr ra`) | `PC = R[ra]` | `jalr x0 ra 0` |

:::

## Register Convention

See the table from the [ASM Manual](https://github.com/riscv-non-isa/riscv-asm-manual/blob/main/src/asm-manual.adoc#general-registers), which we find the most useful. Other references include the RISC-V ELF psABI
Specification ([RISC-V Calling Conventions](https://github.com/riscv-non-isa/riscv-elf-psabi-doc/blob/master/riscv-cc.adoc)), which supercedes Volume I, V2.1, 2014: [Chapter 18
Calling Convention](https://riscv.org/wp-content/uploads/2024/12/riscv-calling.pdf).

:::{table} RV32I Register Convention
:label: tab-calling-convention
:align: center

| Register(s) | Name | Description | Saver |
| :--- | :--- | :--- | :---: |
| `x0` | `zero` | Constant 0 | - |
| `x1` | `ra` | Return Address | Caller |
| `x2` | `sp` | Stack Pointer | |
| `x3` | `gp` | Global Pointer | |
| `x4` | `tp` | Thread Pointer | |
| `x5-7` | `t0-2` | Temporary Registers | Caller |
| `x8` | `s0` / `fp` | Saved Register 0 / Frame Pointer | |
| `x9` | `s1` | Saved Register | |
| `x10-11` | `a0-1` | Function Arguments / Return Values | Caller |
| `x12-17` | `a2-7` | Function Arguments | Caller |
| `x18-x27` | `s2-11` | Saved Registers | Callee |
| `x28-31` | `t3-6` | Temporaries | Caller |
:::

## Instruction Types

:::{table} RV32I Instruction Types
:label: tab-rv32i-types
:align: center

<table style="border: 1px solid black; border-collapse: collapse; font-family: monospace; width: 100%;">
  <thead>
    <tr style="background-color: #f2f2f2;">
      <th style="border: 1px solid black; padding: 5px; text-align: center;">Type</th>
      <th style="border: 1px solid black; padding: 5px;"><div style="display: flex; justify-content: space-between;"><span>31</span><span>25</span></div></th>
      <th style="border: 1px solid black; padding: 5px;"><div style="display: flex; justify-content: space-between;"><span>24</span><span>20</span></div></th>
      <th style="border: 1px solid black; padding: 5px;"><div style="display: flex; justify-content: space-between;"><span>19</span><span>15</span></div></th>
      <th style="border: 1px solid black; padding: 5px;"><div style="display: flex; justify-content: space-between;"><span>14</span><span>12</span></div></th>
      <th style="border: 1px solid black; padding: 5px;"><div style="display: flex; justify-content: space-between;"><span>11</span><span>7</span></div></th>
      <th style="border: 1px solid black; padding: 5px;"><div style="display: flex; justify-content: space-between;"><span>6</span><span>0</span></div></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border: 1px solid black; text-align: center;"><b>R</b></td>
      <td style="border: 1px solid black; text-align: center;">funct7</td>
      <td style="border: 1px solid black; text-align: center;">rs2</td>
      <td style="border: 1px solid black; text-align: center;">rs1</td>
      <td style="border: 1px solid black; text-align: center;">funct3</td>
      <td style="border: 1px solid black; text-align: center;">rd</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
    <tr>
      <td style="border: 1px solid black; text-align: center;"><b>I</b></td>
      <td colspan="2" style="border: 1px solid black; text-align: center;">imm[11:0]</td>
      <td style="border: 1px solid black; text-align: center;">rs1</td>
      <td style="border: 1px solid black; text-align: center;">funct3</td>
      <td style="border: 1px solid black; text-align: center;">rd</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
    <tr>
      <td style="border: 1px solid black; text-align: center;"><b>I*</b></td>
      <td style="border: 1px solid black; text-align: center;">funct7</td>
      <td style="border: 1px solid black; text-align: center;">imm[4:0]</td>
      <td style="border: 1px solid black; text-align: center;">rs1</td>
      <td style="border: 1px solid black; text-align: center;">funct3</td>
      <td style="border: 1px solid black; text-align: center;">rd</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
    <tr>
      <td style="border: 1px solid black; text-align: center;"><b>S</b></td>
      <td style="border: 1px solid black; text-align: center;">imm[11:5]</td>
      <td style="border: 1px solid black; text-align: center;">rs2</td>
      <td style="border: 1px solid black; text-align: center;">rs1</td>
      <td style="border: 1px solid black; text-align: center;">funct3</td>
      <td style="border: 1px solid black; text-align: center;">imm[4:0]</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
    <tr>
      <td style="border: 1px solid black; text-align: center;"><b>B</b></td>
      <td style="border: 1px solid black; text-align: center;">imm[12|10:5]</td>
      <td style="border: 1px solid black; text-align: center;">rs2</td>
      <td style="border: 1px solid black; text-align: center;">rs1</td>
      <td style="border: 1px solid black; text-align: center;">funct3</td>
      <td style="border: 1px solid black; text-align: center;">imm[4:1|11]</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
    <tr>
      <td style="border: 1px solid black; text-align: center;"><b>U</b></td>
      <td colspan="4" style="border: 1px solid black; text-align: center;">imm[31:12]</td>
      <td style="border: 1px solid black; text-align: center;">rd</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
    <tr>
      <td style="border: 1px solid black; text-align: center;"><b>J</b></td>
      <td colspan="4" style="border: 1px solid black; text-align: center;">imm[20|10:1|11|19:12]</td>
      <td style="border: 1px solid black; text-align: center;">rd</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
  </tbody>
</table>

:::