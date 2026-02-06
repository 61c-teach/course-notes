---
title: "Data Transfer Instructions"
---

## Learning Outcomes

* Use load and store assembly instructions and compute memory addresses as base register plus immediate offset.
* Sign-extend signed partial loads with `lb` and `lh`.
* Explain why partial stores do not need to sign- or zero-extend.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Vo2WL9acC5M
:width: 100%
:title: "[CS61C FA20] Lecture 08.2 - RISC-V lw, sw, Decisions I: Data Transfer Instructions"
:::

5:00 onwards

::::

## RISC-V Data Transfer Basics

Consider the memory access syntax for loading and storing words shown in @tab-lw-sw:

:::{table} RV32I Instructions: Load word (`lw`), Store word (`sw`).
:label: tab-lw-sw
:align: center

| Instruction | Name | Description |
| :--- | :--- | :--- |
| `lw rd imm(rs1)` | Load Word | `R[rd] = M[R[rs1] + imm][31:0]`[^verilog] |
| `sw rs2 imm(rs1)` | Store Word | `M[R[rs1] + imm][31:0] = R[rs2][31:0]`[^verilog] |

[^verilog]: Like before, we use Verilog syntax to more precisely define the operation, but you aren't expected to learn Verilog for this course.

:::

### Load Word

The **load word** instruction:

* **Computes a memory address** `R[rs1]+imm`
* **Load a word** from this address in memory, `M[R[rs1] + imm][31:0]`...
* ...into a **destination register**, `rd`.

The memory address is computed with register and immediate arithmetic. `rs1` is called the **base register**. The immediate `imm` is called the **offset** and is a numeric constant that must be known at assembly time.

:::{hint} Memory access reflects array access

You may be wondering why the RISC-V ISA decided to format memory instructions to involve an arithmetic computation of the address (base register plus offset), then some memory access. The intuition comes from array accesses in high-level languages.

Remember C arrays? In C, [square-bracket indexing](#sec-array-indexing) was syntactic sugar for **pointer arithmetic**, then dereference (i.e., memory access). With the design of `lw`, we can translate array access with one instruction: the base register `rs1` functions like a pointer to the start of the array, and the offset is the (byte-wise) stride. Wow!!!
:::

Let's look at an example:

```
lw x10 12(x5)
```

In @fig-lw-example, executing this `lw` instruction loads the word `0x00564253` from memory (at address `0x10C`) into register `x10`.

:::{figure} images/lw-example.png
:label: fig-lw-example
:width: 100%
:alt: "TODO"

Illustration of `lw x10 12(x5)`.
:::

:::{note} Show Explanation
:class: dropdown

`lw x10 12(x5)` fields:

* Operation: Load word (4 bytes on RV32I)
* Base register: `x5`, where the value at this register is `R[x5]` or `0x100`.
* Offset: the immediate `12`
* Destination register: `x10`.

Read an [earlier section](#sec-address-space) for how to read the little endian memory layout.

1. Compute address: `0x100 + 12` is `0x10C`.
2. Read the word at address `0x10C`. Starting from this address, the bytes are `0x53`, `0x42`, `0x56`, and `0x00`.
3. If we assume the memory layout is showing a **little endian** architecture, we construct the 32-bit value `0x00564253`. Set `x10` to this 32-bit word.
:::

### Store Word

The **store word** instruction:

* **Computes a memory address** `R[rs1]+imm` from the base register `rs1` and the offset `imm`.
* **Store the word** in the **source register** `rs2` ...
* ...to the word in memory, `M[R[rs1] + imm][31:0]`.

Let's look at an example:

```
sw x10 0(x5)
```

In @fig-sw-example, executing this `sw` instruction stores the word `0x12345678` in register `x10` to memory (at address `0x100`).

:::{figure} images/sw-example.png
:label: fig-sw-example
:width: 100%
:alt: "TODO"

Illustration of `lw x10 12(x5)`.
:::

:::{note} Show Explanation
:class: dropdown

`sw x10 0(x5)` fields:

* Operation: Store word (4 bytes on RV32I)
* Base register: `x5`, where the value at this register is `R[x5]` or `0x100`.
* Source register: `x10`.
* Offset: the immediate `0`

Read an [earlier section](#sec-address-space) for how to read the little endian memory layout.

1. Compute address: `0x100 + 0` is `0x100`.
2. The word in register `x10` is `0x12345678`.
3. Store this word at address `0x100`. Starting from this address, the bytes should be `0x78`, `0x56`, `0x34`, and `0x12` (again, assuming a little endian architecture).
:::

### Endianness and Alignment

This section is a good time to step back and realize that we have now learned enough to interpret the _actual RISC-V specification_!

From the [RV32I Specification](https://docs.riscv.org/reference/isa/unpriv/rv32.html#ldst):

>  In RISC-V, endianness is byte-address invariant.
> 
> In a system for which endianness is byte-address invariant, the following property holds: if a byte is stored to memory at some address in some endianness, then a byte-sized load from that address in any endianness returns the stored value.

RISC-V therefore supports **both little-endian and big-endian architectures**, and loads and stores are consistent with the endianness of the architecture. As an example:

> In a little-endian configuration, multibyte stores write the least-significant register byte at the lowest memory byte address, followed by the other register bytes in ascending order of their significance. Loads similarly transfer the contents of the lesser memory byte addresses to the less-significant register bytes.

From the [RV32I Specification](https://docs.riscv.org/reference/isa/unpriv/rv32.html#ldst):

> Regardless of EEI[^eei], loads and stores whose effective addresses are naturally aligned shall not raise an address-misaligned exception. Loads and stores whose effective address is not naturally aligned to the referenced datatype (i.e., the effective address is not divisible by the size of the access in bytes) have behavior dependent on the EEI.
> ...
> Misaligned accesses are occasionally required when porting legacy code...

According to the RISC-V standard, loads and stores of words **should specify word-aligned addresses**. For RV32I, this means `R[rs1] + imm` should be a multiple of 4. Addresses that are not word-aligned produce behavior that is implementation-dependent. Put another way, while RISC-V technically allows misaligned accesses to support legacy code, it is very slow and messy. You should treat the "should" as a "must" to avoid "scribbling" all over the memory. :-)

[^eei]: The execution environment interface (EEI). We do not discuss the EEI in this course.

## Partial Loads and Stores

We often work with data types smaller than 32 bits, like 8-bit characters[^colors]. It would be wasteful to use a full word for these, so RISC-V supports instructions for **bytewise** data transfers.

[^colors]: Additionally, RGB colors are 24-bit values; each of the three color channels is 8-bit wide.

Recall that registers are themselves are **word-sized**. The RV32I specification therefore defines what to do with the other bytes when loading or storing **byte-sized** or **half-word-sized** data.

### Store

:::{table} RV32I store instructions.
:label: tab-rv32i-store
:align: center

| Instruction | Name | Description |
| :--- | :--- | :--- |
| `sb rs2 imm(rs1)` | Store Byte | `M[R[rs1] + imm][7:0] = R[rs2][7:0]` |
| `sh rs2 imm(rs1)` | Store Half-word | `M[R[rs1] + imm][15:0] = R[rs2][15:0]` |
| `sw rs2 imm(rs1)` | Store Word | `M[R[rs1] + imm][31:0] = R[rs2][31:0]` |
:::

@tab-rv32i-store demonstrates the [RV32I Specification](https://docs.riscv.org/reference/isa/unpriv/rv32.html#ldst):

> The SW, SH, and SB instructions store 32-bit, 16-bit, and 8-bit values from the low bits of register rs2 to memory.

Consider the instruction:

```
sb x10 0(x5)
```

As shown in @fig-rv-storebyte, this store byte instruction then ignores the upper bytes in the source register `x10` and only considers the **least significant byte** `R[x10][7:0]` (the value `0xEF`). This single byte is then stored to memory at address `0x100`.

:::{figure} images/storebyte.png
:label: fig-rv-storebyte
:width: 100%
:alt: "TODO"

Example store byte instruction in memory.
:::

### Load

The Load Byte instruction `lb` plucks a single byte from memory and (analogous to `sb`) places the byte in `R[rd][7:0]`, the lowest byte position of the destination register `rd`. However, unlike `store`s, `load`s of sub-word widths must consider what to put in the upper bits, or `R[rd][31:8]` (see `x10` in @fig-rv-loadbyte).

:::{figure} images/loadbyte.png
:label: fig-rv-loadbyte
:width: 100%
:alt: "TODO"

Example load byte instruction in memory. `lb x10 0(x5)` loads in `0xEF` but _also_ must determine how to fill the upper 24 bits of `x10`.
:::

Because assembly _operations_ determine how to interpret operands, we therefore define **two** "load byte" operations: Load Byte `lb` and Load Byte Unsigned `lbu`.

* `lb`: If the target value should be a signed two's complement number, **sign extend**. The most significant bit of the byte loaded from memory determines if the number is negative. In @fig-rv-loadbyte, `0xEF` (`0b11101111`) has sign bit `1` yields a result `R[x10]` of `0xFFFFFEF`. If the byte loaded in were, say, `0x73` (`0b01110011`), we fill in upper bits with `0` to yield a result `R[x10]` of `0x00000073`.[^avocado]
* `lbu`: If the target value should be an unsigned number, simply zero-extend. If the instruction in @fig-rv-loadbyte were instead `lbu x10 0(0x5)`, then the result `R[x10]` would be `0x000000EF`, regardless of the bits of `0xEF`.

[^avocado]: In the lecture video, Professor Nikolic makes the analogy that sign extension is like putting a dollop of avocado on one side of toast, then smearing the top bit all over the upper bits.

:::{table} RV32I load instructions.
:label: tab-rv32i-load
:align: center

| Instruction | Name | Description |
| :--- | :--- | :--- |
| `lb rd imm(rs1)` | Load Byte | `R[rd] = M[R[rs1] + imm][7:0]` (Sign-extend) |
| `lbu rd imm(rs1)` | Load Byte (Unsigned) | `R[rd] = M[R[rs1] + imm][7:0]` (Zero-extend) |
| `lh rd imm(rs1)` | Load Half-word | `R[rd] = M[R[rs1] + imm][15:0]` (Sign-extend)|
| `lhu rd imm(rs1)` | Load Half-word (Unsigned)| `R[rd] = M[R[rs1] + imm][15:0]` (Zero-extend)|
| `lw rd imm(rs1)` | Load Word | `R[rd] = M[R[rs1] + imm][31:0]` |


:::{warning} Why is there no "Store Byte Unsigned"?

When you store a byte to memory, you just pluck the byte and put it at a specific location in _memory_. No filling or extension is required, nor is it preferred e.g., maybe you are updating one single character in a C string). By contrast, with `load`s put data into _registers_.

Remember in assembly, all register values are just treated as bits. There is therefore no guarantee about how future instructions will use the destination register, so our partial loads should write all 32 bits of the destination register.

:::
