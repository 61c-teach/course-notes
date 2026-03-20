---
title: "Control and Status Registers"
subtitle: This content is not tested
---

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/WgV4h7NTp5U
:width: 100%
:title: "[CS61C FA20] Lecture 20.1 - Single-Cycle CPU Control: Control and Status Registers"
:::

::::

So far we have designed the datapath and control logic to support instructions in the RV32I base ISA to run any compiled C program. We are still missing a few components required for every computer.

## Control and Status Registers (CSRs)

**Control and status registers** (CSRs) are separate from the register file (`x0`-`x31`). CSRs are not in the base ISA, but they are pretty much mandatory for every implementation. Because the ISA is modular, CSRs are necessary for counters and timers, and communication with peripherals. In other words, CSRs monitor status and performance, such as counting the number of cycles executed and communicating with peripherals (like printers) or other units on the same chip (like floating-point co-processors).

The RISC-V ISA allows space for addressing up to 4096 CSRs. Communication is often done by placing a control word into the register for a peripheral to pick up; when done, the peripheral places its status (ready, waiting, or done) back in the register.  Sometimes this communication is just a single bit, drawing parallels to the postal service mailbox where raising a flag indicates mail is ready to be picked up. This is why single-bit pieces of information in processors are called flags, which we "set" and "clear."

Read more about CSRs in the [RISC-V Privileged ISA Specification, Volume II  Chapter 2](https://docs.riscv.org/reference/isa/priv/priv-csrs.html).

### CSR Instruction Formats

CSR instructions are separate from the base ISA in their own standard extension module. The CSR instruction format are similar to [I-Type](#sec-i-type), except the upper 12-bit field is reserved for the CSR address `csr` (instead of immediate `imm`).

@tab-csr-types shows the two instruction format types for CSR instructions:

:::{table} CSR Instruction Format Types
:label: tab-csr-types
:align: center

<table style="border: 1px solid black; border-collapse: collapse; font-family: monospace; width: 100%;">
  <thead>
    <tr style="background-color: #f2f2f2;">
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
      <td colspan="2" style="border: 1px solid black; text-align: center;">csr</td>
      <td style="border: 1px solid black; text-align: center;">rs</td>
      <td style="border: 1px solid black; text-align: center;">funct3</td>
      <td style="border: 1px solid black; text-align: center;">rd</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
    <tr>
      <td colspan="2" style="border: 1px solid black; text-align: center;">csr</td>
      <td style="border: 1px solid black; text-align: center;">uimm</td>
      <td style="border: 1px solid black; text-align: center;">funct3</td>
      <td style="border: 1px solid black; text-align: center;">rd</td>
      <td style="border: 1px solid black; text-align: center;">opcode</td>
    </tr>
  </tbody>
</table>

:::

* **Register operand** `rs`: Use a source register.
* **Immediate operand**, `uimm`: Use a 5-bit immediate value that is always zero-extended to 32 bits. (No arithmetic is performed on status bits).

All CSR instructions have `opcode` field `1110011` (SYSTEM).

### CSR Instructions

:::{note} This section is from the RISC-V ISA

Read more about CSR Instructions in the Zicsr extension in the [RISC-V Unprivileged Specification, Volume I Chapter 6](https://docs.riscv.org/reference/isa/unpriv/zicsr.html).
:::

The instructions in @tab-csr-instructions-reg generally work by swapping values between CSRs and general-purpose registers. 

:::{table} CSR Instructions: Register Operand
:label: tab-csr-instructions-reg

| Instruction | `rd` is `x0` | `rs1` is `x0` | Reads CSR | Writes CSR |
| :--- | :--- | :--- | :--- | :--- |
| CSRRW | Yes | - | No | Yes |
| CSRRW | No | - | Yes | Yes |
| CSRRS/CSRRC | - | Yes | Yes | No |
| CSRRS/CSRRC | - | No | Yes | Yes |

:::


* The **CSRRW (Atomic Read/Write CSR)** instruction copies the value of a specific CSR to a destination register (`rd`) while concurrently copying[^atomic] the value from the source register (`rs1`) into that CSR. 
* The **CSRRS (Atomic Read and Set Bits in CSR)** instruction reads the value of a CSR and writes it into destination `rd`, while concurrently setting[^atomic] bits in the CSR corresponding to high bits initially in `rs1` (if the CSR bit is writable).
* The **CSRRC (Atomic Read and Clear Bits in CSR)** instruction works like CSRRS, except now `rs` high bits will cause the corresponding bits in the CSR to be concurrently cleared[^atomic] (if the CSR bit is writable).
* In all instructions, if `rd` is `x0`, then the instruction shall not read the CSR and shall not cause any of the side effects that might occur on a CSR read.

[^atomic]: These pairs of concurrent operations are called **atomic**; we discuss this idea later.

The immediate operand instructions in @tab-csr-instructions-imm work similarly to their register operand counterparts. These instructions update the CSR based on a 5-bit unsigned immediate `uimm` field that is zero-extended to 32 bits.

:::{table} CSR Instructions: Immediate Operand
:label: tab-csr-instructions-imm

| Instruction | `rd` is `x0` | `uimm` is `0` | Reads CSR | Writes CSR |
| :--- | :--- | :--- | :--- | :--- |
| CSRRWI | Yes | - | No | Yes |
| CSRRWI | No | - | Yes | Yes |
| CSRRSI/CSRRCI | - | Yes | Yes | No |
| CSRRSI/CSRRCI | - | No | Yes | Yes |

:::

There are pseudoinstructions that do not read the CSR, opting to set `rd=x0`:

* `csrw csr rs1` is `csrrw x0 csr rs1`. This pseudoinstruction just writes `rs1` to the specified CSR.
* `csrwi csr uimm` is `csrrwi x0 csr uimm`. This pseudoinstruction just writes `uimm` to the specified CSR.

### Implementation

Implementing CSR and CSR instructions is not "magic"; like the RegFile, CSRs are just a block of registers. However, clocks and write enable signals are still essential to avoid accidentally "scribbling" over any CSRs.

## System Instructions

There are a few more instructions in the base set that share the same SYSTEM opcode `1110011` that you will inevitably encounter:

* `ecall` (I-Type) makes requests to supporting execution environment (OS), such as system calls (aka **syscalls**)
* `ebreak` – (I-Type) used (e.g. by debuggers) to transfer control to a debugging environment.
* `fence` – sequences memory (and I/O) accesses as viewed by other threads or co-processors.

:::{note} Read the RV32I Base ISA

* [Section 2.1.8: Environment Call and Breakpoints](https://docs.riscv.org/reference/isa/unpriv/rv32.html#ecall-ebreak): `ecall`, `ebreak`
* [Section 2.1.7: Memory Ordering Instructions](https://docs.riscv.org/reference/isa/unpriv/rv32.html#fence): `fence`

:::