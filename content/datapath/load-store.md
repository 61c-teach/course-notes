---
title: "Supporting Loads and Stores"
---

(sec-datapath-load-store)=
## Learning Outcomes

* Implement a datapath that supports loads (I-Type) and stores (S-Type).
* Explain why certain control signals can be marked as "don't care" (*).
* Implement partial loads and stores for the course project, and gain a basic understanding of the minimum requirements for the DMEM block.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/TnDpXz75SGA
:width: 100%
:title: "[CS61C FA20] Lecture 19.1 - Single-Cycle CPU Datapath II: Supporting Loads"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Sra2m_9mgCU
:width: 100%
:title: "[CS61C FA20] Lecture 19.2 - Single-Cycle CPU Datapath II: Datapath for Stores"
:::

::::

## Building a Processor with DMEM access

Recall that [load](#sec-load-word) instructions are [I-Type](#sec-rv-load) because they read a register, have an immediate, and write to a register a 32-bit value read from memory.

To support `lw`, we use a similar datapath to `addi` but instead compute an address with which to access DMEM.

* RegFile: We **read** _one_ register `rs1` and write one register `rd`. The value to write is a **word** read from memory.
* PC: We **read** from and **write** to PC. The value to write is `pc + 4`.
* DMEM: We **read** the memory word at address `R[rs1] + imm`.

Loads (and stores) participate in the `MEM` phase of [the five step process](#sec-five-steps). We therefore introduce additional logic connecting DMEM to the ALU and the RegFile, as shown in @fig-lw-new-blocks.

::::{figure} images/lw-new-blocks.png
:label: fig-lw-new-blocks
:width: 100%

DMEM: Connect and use a mux before `WB` (Write Back) phase.
::::

**DMEM**: To read the memory at an address, we use the ALU to compute the address as `alu = R[rs1] + imm`. This  readily reuses the circuitry for arithmetic and logical I-Type instructions.

**Mux**: We now include a mux after the ALU and DMEM that uses the control signal `WBSel` to select between two values for `wdata` (the data to write to `R[rd]`):

* Arithmetic and Logical R-Type or I-Type instructions: The output of the ALU (`alu`), which is now wired both into `addr` and into the new mux.
* Load instructions: The output of DMEM (`mem`).

::::{figure}
:label: anim-datapath-lw
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-load.pptx
:width: 100%
:title: "Tracing the `lw` Datapath"
:::
The `lw` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file. 
::::

1. **Instruction Fetch**: Increment PC to next instruction (see [R-Type datapath](#sec-datapath-add)). Read the instruction `inst` from IMEM.

1. **Instruction Decode**: Fetch `R[rs1]` from RegFile, build the immediate `imm` for [I-Type instructions](#tab-i-type) (see [I-Type datapath](#sec-datapath-i-type)). Also configure control logic:
    * Configure `ImmSel` to `I`-type immediates.
    * Set `RegWEn` to `1`.
    * Set `BSel` to `1`.
    * Set `ALUSel` to `Add`.
    * Set `MemRW` to `Read`.
    * Set `WBSel` to `0`.

    After some delay, the immediate generator block updates its output signal `imm` to the appropriate sign-extended 32-bit immediate value, register value `R[rs1]` is read, and control signals are set.

1. **Execute**: Because the control line `BSel=1` selects the generated immediate `imm` for ALU input `B`, our ALU computes `R[rs1] + imm`.

1. **Memory**: Read memory at address `alu = R[rs1] + imm`. After some delay, the output signal `mem` has the value `Mem[R[rs1] + imm]`.

1. **Write Back**: Write DMEM output to the destination register and connect the output of the `WBSel` mux to RegFile's `wdata` input.

    Around the next rising clock edge, `wdata`, `RegWEn`, and `rd` should be held stable through setup and hold time of RegFile.

(sec-datapath-store)=
## Tracing the Store Datapath

By contrast, [store](#sec-store-word) instructions, by contrast, are [S-Type](#sec-s-type) because they read two registers, have an immediate, and write to memory. Stores do not write data to registers.

We **do not** need to add additional blocks for stores, but we will need to:

* Upgrade the Immediate Generator to support immediates in S-Type instructions; we encourage you to read [that section](#sec-datapath-immgen) afterwards.
* Wire `R[rs2]` to `wdata` (DMEM input signal).

::::{figure}
:label: anim-datapath-sw
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-store.pptx
:width: 100%
:title: "Tracing the `sw` Datapath"
:::
The `sw` datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
::::

1. **Instruction Fetch**: Increment PC to next instruction (see [R-Type datapath](#sec-datapath-add)).

1. **Instruction Decode**: Fetch `R[rs1]` and `R[rs2]` from RegFile, and build the immediate `imm` for S-Type instructions. Also configure control logic (see below).

1. **Execute**: Because the control line `BSel=1` selects the generated immediate `imm` for ALU input `B`, our ALU computes `R[rs1] + imm`.

1. **Memory**: Write memory at address `alu = R[rs1] + imm` by holding `addr` and `wdata` (DMEM input). 

    Around the next rising clock edge, `wdata` (DMEM input), `MemRW`, and `addr` should be held stable through setup and hold time of RegFile.

1. **Write Back**: (We don't write to RegFile, so skip this.)

(sec-control-store)=
:::{note} Control Signals for Stores

* Configure `ImmSel` to `S`-type immediates.
* Set `RegWEn` to `0`. This means **no** write back to RegFile.
* Set `BSel` to `1`.
* Set `ALUSel` to `Add`.
* Set `MemRW` to `Write`. This means write to `DMEM` on next rising clock edge.
* Set `WBSel` to _whatever_.

We **don't care** about the signal `WBSel` because `RegWEn` is set to `0`. We write "don't care" as `*`, implying that `WBSel` can be `0` or `1` for store instructions.

:::

(sec-datapath-partial-load-store)=
## Partial Loads and Stores: Course project details

This section discusses how to implement partial loads and stores. The details in this section are specific to the course project. We start by introducing additional functions of the course project's DMEM block.

:::{note} Review Partial Loads and Stores

We recommend you review a [previous section](#sec-partial-load-store) on partial loads and stores before continuing.
:::

Recall from an [earlier section](#sec-rv-aligned) that according to the RISC-V standard, loads and stores of words should specify word-aligned addresses. DMEM memory accesses in this course (and in the course project) therefore follow the following conventions:

* All DMEM memory accesses are **word** accesses. Addresses must be 32-bits wide and a **multiple of 4**.
* Loads read a word (4 bytes) at a time.
* Stores write at most 4 bytes at a time, specified by a [bitmask](#sec-bitmasks).

Consider @fig-aligned-memory, which shows each byte in memory, referred to by its 32-bit address.

* In a single access, DMEM can access a set of 4 bytes in one of the red boxes in the diagram, e.g., bytes at memory addresses `0-1-2-3` or `12-13-14-15`.
* In a single access, DMEM cannot access a set of 4 bytes across two red boxes in the diagram, e.g., bytes at memory addresses `13-14-15-16`. This would take two accesses.

:::{figure} images/aligned-memory.svg
:label: fig-aligned-memory
:width: 30%
Diagram of aligned memory (Red boxes around every 4 bytes).
:::

:::{note} Don't think about endianness
Endianness is relevant when you're trying to interpret a set of 4 bytes as a word (e.g. integer, address) to do some calculation on it. At this level of abstraction, we only need to worry about which bits are loaded and stored, not what they mean.
:::

(sec-datapath-dmem-details)=
### Word-aligned DMEM

* **DMEM forces memory accesses to be with addresses of multiples of 4 bytes.** DMEM always zeros out the bottom 2 bits of any address you provide (i.e., round down to the nearest multiple of 4), and then accesses 4 bytes starting at this modified address.

    For example, if you give DMEM the address `19` = `0b010011`, DMEM will zero out the bottom 2 bits to get `16` = `0b010000`, and then start at this modified address to access 4 bytes (`16-17-18-19`).

    You don't need to zero out the bottom 2 bits yourself--the provided DMEM implementation will automatically do this for any address you provide.

* **Assume memory accesses in instructions do not cross word boundaries**. All instructions should follow RV32I standard convention and will not cross a word boundary in memory (i.e., a single access will never cross a red line in @fig-aligned-memory).
  * All `lw` and `sw` instructions will use memory addresses that end in `0b00` (i.e. are a multiple of 4).
  * All `lh`, `lhu`, `sh` instructions will use memory addresses that end in `0b00`, `0b01`, or `0b10` (never an address that ends in `0b11`[^why]).
  * All `lb`, `lbu`, `sb` instructions use any memory addresses.[^why]

* **DMEM uses only the lower 16 bits**. Due to Logisim size limitations, the memory unit only uses the lower 16 bits of the provided address, discarding the upper 16 bits. This means that the memory can only store $2^16$ bytes of data.

    The provided tests will always set the upper 16 bits of addresses to 0, and any tests you write should avoid using the upper 16 bits when interacting with memory.

* **Partial Stores**: See the section below for partial-store-specific details, e.g., unit tests.

[^why]: We leave it to you to determine why these cases would/would not cross 32-bit word boundaries.

### Partial Load

The `partial_load.circ` circuit in the course project is designed to take the 32 bits of data read from DMEM, extract the relevant data, then process the data to put into a 32-bit register. The signals for this subcircuit are in @tab-partial-load.

:::{table} Signals for the course project partial load subcircuit.
:label: tab-partial-load

| **Name** | **Direction** | **Bit Width** | **Description** |
| :--- | :--- | :--- | :--- |
| `Instruction` | Input | 32 | The load instruction being executed. |
| `MemAddress` | Input | 32 | The memory address to read from.[^addr-vs-access] |
| `DataFromMem` | Input | 32 | The data read from DMEM. |
| `DataToReg` | Output | 32 | The data to put in the register. |
:::

[^addr-vs-access]: Important: The bottom two bits of the `MemAddress` address (e.g., computed from the instruction) are NOT zeroed. However, DMEM will convert the address to a multiple of 4 before accessing memory.

**Behavior**: For loads, DMEM will always read 32 bits of memory starting at an address that is a multiple of 4 bytes. The partial load subcircuit then uses the instruction itself to determine what bytes to extract.

**Example 1**. Suppose we had a `lb` instruction on address `6` = `0b000110`.

* DMEM will read the 4 bytes at addresses `4-5-6-7`.
* We want just the byte at address `6` (again, a `lb` instruction).
* The bottom 2 bits of the address `6` are `0b10`, so we want the 2nd byte (zero-indexed, i.e., bits 16-23) of the data read from DMEM.

**Example 2**. Suppose we had a `lh` instruction on address `9` = `0b001001`.

* DMEM will read the 4 bytes at addresses `8-9-10-11`. 
* We want the two bytes at addresses `9-10` (again, a `lh` instruction).
* The bottom 2 bits of the address `9` are `0b01`, so we want to start extracting at the 1st byte (zero-indexed) and extract two bytes, i.e., bits 8-23 of the data read from DMEM.

:::{table} If useful, all scenarios you should handle in the partial load subcircuit for the course project. `SignExt` means sign-extend.
:label: tab-partial-load-details

| Instruction | `MemAddress[1:0]`[^addr-vs-access] | Value to put in `DataToReg` |
| :--- | :--- | :--- |
| `lb` | `00` | `SignExt(DataFromMem[7:0])` |
| `lb` | `01` | `SignExt(DataFromMem[15:8])` |
| `lb` | `10` | `SignExt(DataFromMem[23:16])` |
| `lb` | `11` | `SignExt(DataFromMem[31:24])` |
| `lh` | `00` | `SignExt(DataFromMem[15:0])` |
| `lh` | `01` | `SignExt(DataFromMem[23:8])` |
| `lh` | `10` | `SignExt(DataFromMem[31:16])` |
| `lw` | `00` | `DataFromMem` |

:::

### Partial Store

The `partial_store.circ` circuit in the course project is designed to take data from a register, process it, and store the relevant bytes to memory. The signals for this subcircuit are in @tab-partial-store.

:::{table} Signals for the course project partial store subcircuit.
:label: tab-partial-store

| **Signal Name** | **Direction** | **Bit Width** | **Description** |
| :--- | :--- | :--- | :--- |
| `Instruction` | Input | 32 | The store instruction being executed. |
| `MemAddress` | Input | 32 | The memory address to store to.[^addr-vs-access] |
| `DataFromReg` | Input | 32 | The data from the register. |
| `MemWEn` | Input | 1 | The control signal indicating whether writing to memory is enabled for this instruction. |
| `DataToMem` | Output | 32 | The data to store to memory. |
| `MemWriteMask` | Output | 4 | The write mask indicating whether each byte of `DataToMem` will be written to memory. |
:::

**Behavior**: For stores, DMEM will write bitmasked data to memory at an address that is a multiple of 4 bytes. Each bit in the 4-bit **write-mask** `MemWriteMask` corresponds to the 4 bytes of the word; if a bit in `MemWriteMask` is 0, DMEM will not store the corresponding byte of `DataToMem` to memory.

**Example 1**: Suppose we had a `sb` instruction on address `3` = `0b000011`.

* Of the word's byte addresses `0-1-2-3`, we actually want to just write one byte at address `3`, because the bottom 2 bits of the address `3` are `0b11` (and it is an `sb` instruction).
* Make a 32-bit value where bits 24-31 are the 8 bits we want to store to memory.[^doesnt-matter]
* Make a 4-bit writemask `0b0001`, which says to only write the zeroth byte to memory, leaving the other bytes in the memory word unchanged.

**Example 2**: Suppose we had a `sh` instruction on address `2` = `0b000010`.

* Of the word's byte addresses `0-1-2-3`, we actually want to write two bytes at addresses `2` and `3`, because the bottom 2 bits of the address `2` are `0b10` (and it is an `sb` instruction).
* Make a 32-bit value where bits 16-31 are the 16 bits we want to store to memory.[^doesnt-matter]
* Make a 4-bit writemask `0b1100`, which says to only write the second and third bytes to memory, leaving the other bytes in the memory word unchanged.

[^doesnt-matter]: The lower bits 0-23 can be all zeros, though in practice these bits don't matter beacuse of `MemWriteMask`.

Note that `sh` and `sb` instructions specify data as the lower bits of a 32-bit value, i.e., bottom 16 bits and bottom 8 bits, respectively. See @tab-partial-store-details.

:::{table} If useful, all scenarios you should handle in the partial store subcircuit for the course project. (Also recall [no sign-extension for stores](#sec-partial-load-store).) 
:label: tab-partial-store-details

| Instruction | `MemAddress[1:0]`[^addr-vs-access]  | `DataToMem[31:24]` | `DataToMem[23:16]` | `DataToMem[15:8]` | `DataToMem[7:0]` | `MemWriteMask` |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| `sb` | `00` | `0` | `0` | `0` | `DataFromReg[7:0]` | `0001` |
| `sb` | `01` | `0` | `0` | `DataFromReg[7:0]` | `0` | `0010` |
| `sb` | `10` | `0` | `DataFromReg[7:0]` | `0` | `0` | `0100` |
| `sb` | `11` | `DataFromReg[7:0]` | `0` | `0` | `0` | `1000` |
| `sh` | `00` | `0` | `0` | `DataFromReg[15:8]` | `DataFromReg[7:0]` | `0011` |
| `sh` | `10` | `DataFromReg[15:8]` | `DataFromReg[7:0]` | `0` | `0` | `1100` |
| `sw` | `0b00` | `DataFromReg[31:24]` | `DataFromReg[23:16]` | `DataFromReg[15:8]` | `DataFromReg[7:0]` | `1111` |

:::

Tips/reminders for the course project:

* Recall that **we should not write** when our instruction is not a store. When `MemWEn` control signal is 0, `MemWriteMask` should be set to `0b0000`.
* The bytes in `DataToMem` that aren't being written to the file (i.e. where `MemWriteMask` is 0) can technically be any value[^doesnt-matter], but @tab-partial-store-details lists them as 0s in the table. The unit test for this part also assumes that those bytes will be 0.