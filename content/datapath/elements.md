---
title: "State Elements on the Datapath"
---

(sec-state-elements)=
## Learning Outcomes

* Describe the main state elements on the single-cycle RISC-V datapath.
* Identify when data is written on synchronous state elements on the RISC-V datapath.
* Compare and contrast read and write behaviors of RISC-V state elements.

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
:width: 100%
:alt: "TODO"

The Program Counter, `PC`, is a single 32-bit register in the CPU.
:::

:::{note} PC Signals
:class: dropdown

**Input**:

* _Data_: N-bit data input bus
* _Control_: Write Enable bit. 1: asserted/high, 0: deasserted/low.
* Clock signal.

**Output**:

* _Data_: N-bit data output bus

:::

**Behavior**:

* _Read_: At all other times, Data Out will not change; it will output its current value.
* _Write_: **Rising-edge triggered**. On rising clock edge, if Write Enable is 1, set Data Out to Data In (delay of clk-to-q).

(sec-element-regfile)=
### Register File (`Regfile`)

The **Register File** (regfile, or `RegFile`) has 32 registers: register numbers `x0` to `x31`.

:::{figure} images/element-regfile.png
:label: fig-element-regfile
:width: 50%
:alt: "TODO"

The RegFile is symbolically written as `RegFile` and is composed of registers `x0` to `x31`.
:::

::::{table} Regfile signals. Course project signal names, if different, are in parentheses.
:label: tab-regfile-signals
:align: center

| Name | Direction | Bit Width | Description |
| :-- | :-- | :-- | :-- |
| `rs1` (`ReadIndex1`) | Input | 5 | Determines which register's value is sent to the `rdata1` (`ReadData1`) output |
| `rs2` (`ReadIndex2`) | Input | 5 | Determines which register's value is sent to the `rdata2` (`ReadData2`) output |
| `rd` (`WriteIndex`) | Input | 5 | The register to write to on the next rising edge of the clock (if `RegWEn` is 1) |
| `wdata` (`WriteData`) | Input | 32 | The data to write into `rd` on the next rising edge of the clock (if `RegWEn` is 1) |
| `RegWEn` | Input | 1 | Determines whether data is written to the register file on the next rising edge of the clock |
| `clk` | Input | 1 | Clock input |
| `rdata1` (`ReadData1`) | Output | 32 | The value of the register identified by `rs1` (`ReadIndex1`) |
| `rdata2` (`ReadData2`) | Output | 32 | The value of the register identified by `rs2`(`ReadIndex2`) |
::::

**Behavior**:

* Registers are accessed via their 5-bit register numbers:
  * `R[rs1]`: `rs1` selects register to put on `rdata1` bus out.
  * `R[rs2]`: `rs2` selects register to put on `rdata2` bus out.
  * `R[rd]`: `rd` selects register to be written via `wdata` when `RegWEn` is set to 1.
* _Read_: As long as `rs1` and `rs2` are valid, then `rdata1` and `rdata2` are valid after access time, _regardless of what `RegWEn` is set to_.
* _Write_: **Rising-edge-triggered write**. On rising clock edge, if `RegWEn` is set to 1, write `wdata` to `R[rd]`.

:::{note} The clock signal is only a factor on write!

For _read_ operations, the RegFile behaves like **a combinational logic block**. Put another way, the read operation is _not_ timed to the rising clock edge and constantly occurs, updating data outputs based on inputs (after some access time delay). This is a necessary assumption to ensure our single-cycle datapath executes all phases of an instruction within one cycle.
:::

(sec-element-dmem)=
### `DMEM`: Data Memory

For this class, memory is "magic." Assume a 32-bit byte-addressed memory space, and memory access occurs with 32-bit words. We go into more detail with our course projects.

For our single-cycle datapath, we must access memory **twice**: once during `IF` (Instruction Fetch) to read the instruction from memory, and once during `MEM` (Memory Access) if we load/store data from/to memory. We therefore need two memory blocks: `IMEM` and `DMEM` for instruction memory and data memory, respectively.[^imem-dmem-cache]

[^imem-dmem-cache]: Under the hood, `IMEM` and `DMEM` are placeholders for L1 caches: `L1i`, `L1d`.

The Data Memory block `DMEM` has edge-triggered writes, just like `RegFile`.

:::{figure} images/element-dmem.png
:label: fig-dmem-block
:width: 50%
:alt: "TODO"

The Data Memory block `DMEM`. Read operations behave like combinational logic, whereas write operations occur on the rising clock edge.
:::


::::{table} DMEM signals. Course project signal names, if different, are in parentheses.
:label: tab-dmem-signals
:align: center

| Name | Direction | Bit Width | Description |
| :-- | :-- | :-- | :-- |
| `addr` (`MemAddress`) | Input | 32 | The address in memory to read from or write to |
| `wdata` (`MemWriteData`) | Input | 32 | Data to write to memory |
| `MemRW` (`MemWriteMask`) | Input | 4 | The write enable mask for writing data to memory |
| `clk` | Input | 1 | Clock input |
| `rdata` (`MemReadData`) | Output | 32 | Data at `addr` (`MemAddress`) from memory |

::::

**Behavior**: `DMEM` read/writes behave similarly to Regfile, though now we provide memory addresses as input, not register numbers.

* Read: Address `addr` selects word to put on `rdata` bus. If `MemRW` is 0 and `addr` is valid, then `rdata` is valid after access time.
* Write: **Rising-edge-triggered write**. On rising clock edge, if `MemRW` is set to 1, write `wdata` to address `addr`. 

:::{note} Partial Loads and Stores

We implement a more complicated DMEM block in our project; see the [Partial Loads and Stores section](#partial-loads-stores).
:::

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
