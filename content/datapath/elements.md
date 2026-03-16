---
title: "State Elements"
subtitle: TODO
---

(sec-state-elements)=
## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/8Dv725H2-Os
:width: 100%
:title: "[CS61C FA20] Lecture 18.2 - Single-Cycle CPU Datapath I: Building a RISC-V Processor"
:::

::::

As mentioned in the previous section, a CPU has two types of elements, reflecting the design of many digital logic systems.

* [State elements](#sec-state-elements) that contain state: registers and memory
* Combinational Logic Blocks that operate on data values: [ALU](#sec-alu), other combinational logic, etc.

In this section, we discuss the **state elements** needed in a RISC-V processor. We will discuss and introduce the combinational logic blocks as we build out the full datapath.

(sec-element-pc)=
### Program Counter

The Program Counter is a 32-bit register in @fig-element-pc and holds the value of the **current instruction**, i.e., instruction to execute in the current clock cycle.

:::{figure} images/element-pc.png
:label: fig-element-pc
:width: 50%
:alt: "TODO"

The Program Counter, `PC`, is a single 32-bit register in the CPU.
:::

**Input**:

* _Data_: N-bit data input bus
* _Control_: Write Enable bit. 1: asserted/high, 0: deasserted/low.
* Clock signal.

**Output**:

* _Data_: N-bit data output bus

**Behavior**:

* _Read_: At all other times, Data Out will not change; it will output its current value.
* _Write_: **Rising-edge triggered**. On rising clock edge, if Write Enable is 1, set Data Out to Data In (delay of clk-to-q).

(sec-element-regfile)=
### `RegFile`: Register File

The **Register File** (RegFile, or `Reg[]`) has 32 registers: register numbers `x0` to `x31`.

:::{figure} images/element-regfile.png
:label: fig-element-regfile
:width: 50%
:alt: "TODO"

The RegFile is symbolically written as `Reg[]` and is composed of registers `x0` to `x31`.
:::

**Input**:

* _Data_: One 32-bit input data bus, `wdata`.
* _Control_: Three 5-bit select busses, `rs1`, `rs2`, and `rd`.
* _Control_: `RegWEn` control bit.
* Clock signal.

**Output**:

* _Data_: Two 32-bit output data busses, rdata1 and rdata2.

**Behavior**:

* Registers are accessed via their 5-bit register numbers:
  * `R[rs1]`: `rs1` selects register to put on `rdata1` bus out.
  * `R[rs2]`: `rs2` selects register to put on `rdata2` bus out.
  * `R[rd]`: `rd` selects register to be written via `wdata` when `RegWEn` is set to 1.
* _Read_: As long as `rs1` and `rs2` are valid, then `rdata1` and `rdata2` are valid after access time, _regardless of what `RegWEn` is set to_.
* _Write_: **Rising-edge-triggered write**. On rising clock edge, if `RegWEn` is set to 1, write `wdata` to `R[rd]`.

:::{warning} The clock signal is only a factor on write!

For _read_ operations, the RegFile behaves like **a combinational logic block**. Put another way, the read operation is _not_ timed to the rising clock edge and constantly occurs, updating data outputs based on inputs (after some access time delay). This is a necessary assumption to ensure our single-cycle datapath executes all phases of an instruction within one cycle.
:::

(sec-element-dmem)=
### `DMEM`: Data Memory

For this class, memory is "magic." Assume a 32-bit byte-addressed memory space, and memory access occurs with 32-bit words. We go into a bit more detail in one of our course projects.

For our single-cycle datapath, we must access memory **twice**: once during `IF` (instruction fetch) to read the instruction from memory, and once during `MEM` if we load/store data from/to memory. We therefore need two memory blocks: `IMEM` and `DMEM` for instruction memory and data memory, respectively.[^imem-dmem-cache]

[^imem-dmem-cache]: Under the hood, `IMEM` and `DMEM` are placeholders for L1 caches: `L1i`, `L1d`.

The Data Memory block `DMEM` has edge-triggered writes, just like `Reg[]`.

:::{figure} images/element-dmem.png
:label: fig-dmem-block
:width: 50%
:alt: "TODO"

The Data Memory block `DMEM`. Read operations behave like combinational logic, whereas write operations occur on the rising clock edge.
:::

**Input**:

* _Data_: Two 32-bit input data busses, `addr` and `dataW`.
* _Control_: `MemRW` control bit.
* Clock signal.

**Output**:

* _Data_: One 32-bit output data bus, `dataR`.

**Behavior**:

* Read: Address `addr` selects word to put on `rdata` bus. If `MemRW` is 0 and `addr` is valid, then `rdata` is valid after access time.
* Write: **Rising-edge-triggered write**. On rising clock edge, if `MemRW` is set to 1, write `wdata` to address `addr`. 

Just like with RegFile, `DMEM` behaves like a combinational logic with read operations, which occur constantly; provided that `addr` is valid, this means that `rdata` is updated constantly after some access time.

(sec-element-imem)=
### `IMEM`: Instruction Memory

The Instruction Memory block `IMEM` is a **read-only memory** that fetches instructions.[^imem-foot]

[^imem-foot]: We will need to write the instruction memory when we load the program, which we ignore for simplicity.

:::{figure} images/element-imem.png
:label: fig-element-imem
:width: 50%
:alt: "TODO"

In our CPU, the Instruction Memory block `IMEM` is read-only and behaves like combinational logic.
:::

::::{table} IMEM signals. Course project signal names, if different, are in parentheses.
:label: tab-dmem-signals
:align: center

| Name | Direction | Bit Width | Description |
| :-- | :-- | :-- | :-- |
| `addr` (N/A) | Input | 32 | The address in memory to read from |
| `inst` (`Instruction`) | Output | 32 | The instruction at memory address `addr`(`ProgramCounter`) |

::::

**Behavior**:

* Read: Address `addr` selects word to put on `inst` bus. If `addr` is valid, then `inst` is valid after access time.

:::{warning} IMEM is not clocked!

In our CPU, we assume IMEM is a read-only state element and is **not clocked**. It therefore _always_ behaves like a combinational logic block.

:::

:::{warning} IMEM is not clocked!

In our CPU, we assume IMEM is a read-only state element and is **not clocked**. It therefore _always_ behaves like a combinational logic block.

:::
