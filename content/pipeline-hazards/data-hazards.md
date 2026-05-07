---
title: "Data Hazards"
short_title: "Data Hazards, Forwarding"
---

(sec-data-hazards)=
## Learning Outcomes

* Given instruction sequences and a processor architecture, identify potential control hazards.
* Explain why a write-then-read register file reduces pipeline stalls due to potential data hazards.
* Explain how forwarding (i.e., bypassing) reduces pipeline stalls due to potential data hazards.
* Implement two forwarding paths, one from `MEM` to `EX` and one from `WB` to `EX`, in the five-stage pipelined processor.
* Explain why data hazards involving load instructions in a given instruction sequence can incur an inevitable pipeline stall.

::::{note} 🎥 Lecture Video: Data Hazards
:class: dropdown

:::{iframe} https://www.youtube.com/embed/iOKJ-oW1urY
:width: 100%
:title: "[CS61C FA20] Lecture 22.4 - Pipelining II: Data Hazards"
:::

::::

::::{note} 🎥 Lecture Video: Load Data Hazard
:class: dropdown

:::{iframe} https://www.youtube.com/embed/VWCAqieFkHI
:width: 100%
:title: "[CS61C FA20] Lecture 23.1 - Pipelining III: Load Data Hazard"
:::

::::

From [earlier](#sec-pipeline-hazards):

:::{embed} #block-def-hazard-data
:::

Data hazards occur because instructions read from and write to the same registers and memory. From P&H 4.6:

> Suppose you found a sock at the folding station for which no match existed. One possible strategy is to run down to your room and search through your clothes bureau to see if you can find the match. Obviously, while you ar edoing the search, loads that have completed drying are ready to fold and those that have finished are ready to dry.

In this section, we discuss how the five-stage pipelined processor can be modified to mitigate performance hits due to data hazards.

Consider the following [waterfall diagram](#sec-waterfall) in @tab-data-hazard-1. The `add` and `sub` instructions have a data hazard because the former writes to _and_ the latter reads from register `s0`. 

```{list-table} Example 1. Data hazard.
:header-rows: 1
:label: tab-data-hazard-1

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0 t0 t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `sub t2 s0 t0`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  -
* - `or  t3 t4 t5`
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
```

The `sub` instruction must read the updated value of `s0` after the `add` instruction completes. In cycle 5, the `add` instruction writes to register `s0`. However, in cycle 3, `sub` reads from register `s0`, which gets the stale value of `s0`, before `add` has updated it. Then `sub` performs the incorrect subtraction of this stale value before writing the incorrect result.

(sec-data-hazards-stall)=
## Stalling

To resolve the data hazard in @tab-data-hazard-1, we can **stall** the pipeline until resources are "ready," i.e., `add` has written the correct value to register `s0`. Pipeline stalls, or **bubbles**, are effectively "no-ops" (nops) where affected pipelines do nothing.

The below diagram illustrates a three-stall solution. In @tab-data-hazard-1-stall, `sub` will most certainly read the correctly updated value of register `s0` by the end of cycle 6.

```{list-table} Example 1: Resolving data hazards with stalls. A dash (–) indicates that the pipeline is flushed and affected instructions do "nothing."
:label: tab-data-hazard-1-stall
:header-rows: 1

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
  - 10
* - `add s0 t0 t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
  - 
* - `sub → nop`
  - 
  - IF
  - ID
  - –
  - –
  - –
  - 
  - 
  - 
  - 
* - `nop`
  - 
  - 
  - –
  - –
  - –
  - –
  - –
  - 
  - 
* - ` nop`
  - 
  - 
  - 
  - –
  - –
  - –
  - –
  - –
  - 
  - 
* - `sub t2 s0 t0`
  - 
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 

* - `or t3 t4 t5`
  - 
  - 
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
```

Because performance suffers with stalling, we will discuss ways to avoid stalling where possible (though it is always a good last resort).

### Implementing Stalls

The details in this subsection are out of scope.
For more information, read P&H 4.8.

Implementing stalls in hardware requires control and extra pipeline state to prevent unintended state changes in stalled stages, e.g. writes to the program counter, register, or memory.

One approach described in P&H 4.8 is a hazard detection unit. For data hazards, this detection unit can be implemented in the `ID` stage to determine if the source registers of this instruction depend on the destination register of register(s) still in the pipeline.[^stall-pipeline-regs] To stall an instruction, we could deassert all control signals (by setting them to 0[^control-note]) so that when the instruction passes through later stages, the stages effectively do nothing.[^stall-instruction]

We illustrate this in @tab-data-hazard-1-stall, where in cycle 2, the hazard detection unit detects that the instruction in the `ID` stage, `sub`, has a source register that depends on the `add` instruction. The hazard detection unit then bubbles nops through the pipeline and preserves the `sub` instruction until it can be safely completed.[^stall-stages]

[^stall-pipeline-regs]: How do we check destination registers? The hazard detection unit checks the pipeline registers. For example, if register `rd` specified in the `ID/EX` pipeline registers is one of the source registers for the instruction in the `ID` stage, then stall the instruction in the `ID` stage.

[^control-note]: This is somewhat of an overstatement; read P&H 4.9 for more details.

[^stall-instruction]: If the instruction in the `ID` stage is stalled, then the instruction in the `IF` stage must also be stalled, etc. We can accomplish this by (1) preventing the PC register from incrementing, and (2) preventing the `IF/ID` pipeline register from changing. From P&H 4.8: "It's as if you restart the washer with the same clothes, and let the dryer continue tumbling empty. Of course, like the dryer, the back half of the pipeline starting with the EX stage must be doing something; what it is doing is executing instructions that have no effect: nops."

[^stall-stages]: We note that in @tab-data-hazard-1-stall, the `sub` instruction is really fetched and decoded in cycles 2 and 3, but its `EX` stage is delayed until cycle 7. Likewise, the `or` instruction is fetched in clock cycle 3 but its `ID` stage is delayed until cycle 7.

## RegFile: Write-Then-Read

Consider the waterfall diagram in @tab-data-hazard-2. Does the dependency between `add` and `sw` incur a data hazard?

```{list-table} Example 2. Data hazard...?
:header-rows: 1
:label: tab-data-hazard-2

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add t0 t1 t2`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `lw  t0 8(t3)`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
* - `or  t3 t4 t5`
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
* - `sw  t0 4(t6)`
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
* - `sll t6 t0 t3`
  - 
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
```

What is happening in cycle 5? If we are assuming our [original RegFile design](#sec-element-regfile), then the `add` instruction in the `WB` stage only sets up the MUX, so that the write to `t0` occurs at the _next_ rising clock, edge, or cycle 6. This would mean that in the same cycle 5, the `sw` instruction in the `ID` stage would indeed read a stale value, causing a data hazard.[^not-structural]

[^not-structural]: We note this hazard is **not a structural hazard**. After all, the [RegFile design](#sec-element-regfile) _does not prevent_ `add` and `sw` from reading/writing to the same register in the same cycle, because there are sufficient input ports. However, what is concerning is that the _value_ `sw` reads must be the correct value that `add` writes.

The RISC-V five-stage pipeline therefore "ups" the **hardware requirement** on the register file. We leverage the high speed of the register file (100 ps for each of read/write) to assume that the hardware unit supports **write-then-read**:

* `WB` stage instruction updates value in first half of cycle, e.g., on _falling_ edge.
* `ID` stage reads new value.

::::{hint} New hardware assumption: RegFile is write-then-read

This assumption is further illustrated by the shading of the `ID` and `WB` stages in the high-level pipeline processor diagram discussed in an [earlier section](#sec-processor-hl):

:::{figure} #fig-pipelined-processor-hl
:alt: "Reprint of the high-level pipelined processor diagram: WB stage left half shaded for register-file write in the first half-cycle and ID stage right half shaded for register read in the second half, illustrating write-then-read timing."

The left half of the `WB` stage is shaded, indicating that the RegFile is written in the first half of the clock cycle. Similarly, the right half of the `ID` stage is shaded, indicating that the RegFile is read in the second half of the clock cycle. Reprinted from an [earlier section](#sec-processor-hl).
:::

Note that it **might not always be possible** to support a register file with write-then-read capabilities, especially in high-frequency designs. Always check processor design assumptions beforehand, particularly when answering homework questions.
::::

If we assume our RegFile supports write-then-read, then in cycle 5, the read of the `sw` instruction in the `ID` stage delivers what is written by the `add` instruction in the `WB` stage, so there is **no data hazard**.

::::{tip} Quick Check
Let's visit our [earlier simple example](#tab-data-hazard-1).

:::{figure} #tab-data-hazard-1
:alt: "Reprint of the pipeline diagram table for the simple add then dependent instructions example, showing IF through WB stage occupancy per cycle before stalls are applied."
:::

If we assume the RegFile supports write-then-read, how many cycles do we need to stall to avoid data hazards?

::::

:::{note} Show Answer
:class: dropdown
We can just stall _two_ cycles, as shown in @tab-data-hazard-1-stall-fast. In the first half of cycle 5, the `add` instruction writes to register `s0`; in the second half, the `sub` instruction reads `s0`.

```{list-table}  Example 1: Resolving data hazards with stalls **and** an assumption that the register file supports write-then-read in the same cycle. A dash (–) indicates that the pipeline is flushed and affected instructions do "nothing."
:header-rows: 1
:label: tab-data-hazard-1-stall-fast

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0, t0, t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `sub → nop`
  - 
  - IF
  - –
  - –
  - –
  - –
  - 
  - 
  - 
* - `nop`
  - 
  - 
  - –
  - –
  - –
  - –
  - –
  - 
  - 
* - `sub t2, s0, t0`
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
```
:::

(sec-data-hazards-forward)=
## Forwarding

So far, we have discussed some solutions to some hazards by (1) specifying appropriate hardware requirements, and, if all else fails, (2) stalling the pipeline until there are no hazards.

However, we observe that with data hazards, we don't need to wait for the instruction to complete before trying to resolve the data hazard. In other words, the data in question is ready _much earlier_ than the `WB` stage of the earlier instruction.

Consider the example in @tab-data-hazard-3, which has two data hazards because the `sub` and `or` instructions depend on the result of the `add` instruction writing to register `s0`. 

:::{list-table} Example 3.
:label: tab-data-hazard-3
:header-rows: 1

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0 t0 t1`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `sub t2 s0 t0`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
* - `or  t6 s0 t3`
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
:::

The result of adding `t0` and `t1` is ready at the beginning of cycle 4, once the `add` instruction completes the `EX` stage in cycle 3. So we could add extra hardware to supply this sum as the input for the `sub` instruction _and_ the `or` instruction.

Wiring more connections in the datapath to use results when computed is a process known as **forwarding** or **bypassing**.[^forwarding-bypassing] Instead of waiting for the value to be written into the RegFile, we can instead grab the operand directly from the _next_ pipeline stage.

[^forwarding-bypassing]: From P&H 4.6: "The name _forwarding_ comes from the idea that the result is passed forward from an earlier instruction to a later instruction. _Bypassing_ comes from passing the result around the register file to the desired unit."

We use @fig-forwarding-hl to describe at a high-level what data is forwarded.

:::{figure} images/forwarding-hl.png
:label: fig-forwarding-hl
:width: 80%
:alt: "High-level five-stage pipeline visual with three instructions in flight: ADD writing s0, SUB consuming s0, and OR also consuming s0. Colored bypass arrows show the ADD’s ALU result forwarded from the EX/MEM boundary straight into the SUB’s EX-stage operand mux, and a second bypass from MEM/WB into the OR’s EX-stage mux so neither dependent instruction waits for register file write-back. Stage labels IF through WB bracket each instruction row so viewers can see cycle alignment."

Forwarding adds extra connections between [pipeline registers](#sec-pipeline-registers) and other components in the datapath.
:::

Notes:

* At the beginning of cycle 4, the ALU result from the `add` instruction is forwarded from its `EX/MEM` pipeline register directly to the ALU (for the `sub` instruction's `EX` stage).
* At the beginning of cycle 5, the ALU result from the `add` instruction is forwarded from its `MEM/WB` pipeline register directly to the ALU (for the `or` instruction's `EX` stage).
* The value of register `s0` is still updated in cycle 5, from the stale value 5 to the new value 9. The `ID` stages of the `sub` and `or` instructions still read the stale value of register `s0` in cycles 2 and 3, respectively. What matters is that the correct operands are fed into ALU during the `EX` stage for both of these instructions.
* Note that with hardware forwarding, we do not need to update the waterfall diagram in @tab-data-hazard-3 because no stalls occur.

:::{hint} Forward data from pipeline registers

In this course, we discuss **two** types of forwarding paths (i.e., bypasses) from pipeline registers to **each** of the two ALU inputs, as described in @fig-forwarding-all-hl.

1. **`MEM` to `EX` forwarding**. Forward data from the `EX/MEM` pipeline registers to ALU input (e.g., in @tab-data-hazard-3, to resolve the `add`/`sub` data hazard).
1. **`WB` to `EX` forwarding**. Forward data from the `MEM/WB` pipeline registers to ALU input (e.g., in @tab-data-hazard-3, to resolve the `add`/`or` data hazard).  

:::

:::{figure} images/forwarding-all-hl.png
:label: fig-forwarding-all-hl
:width: 100%
:alt: "Expanded forwarding schematic with every pipeline stage labeled and two highlighted bypass nets. Purple path: from the register after MEM/WB back to the ALU mux feeding operand B, annotated as WB-to-EX forwarding. Pink path: from the register after EX/MEM to the same mux, annotated as MEM-to-EX forwarding. Pipeline registers between stages are drawn explicitly so students can trace where forwarded values are tapped relative to the register file read ports."

Forwarding bypasses for the ALU's B input signal. For simplicity, we do not draw the bypasses for the A input signal, though they are certainly needed. With the exception of the PC, registers between stages are pipeline registers. Adapted from Spring 2026 CS 152.[^cs152-diagram]
:::

[^cs152-diagram]: [Original diagram](https://inst.eecs.berkeley.edu/~cs152/exams/pdfs/mt1/sp26-mt1-sols.pdf) by Wen Cao, Spring 2026 CS 152/252 TA. The CS 152/252 diagram is for a different pipelined datapath with different forwarding paths (e.g., see the MUX into the ID/EX pipeline register). Please use @fig-forwarding-all-hl for this course.

::::{tip} Quick Check
Let's visit our [earlier simple example](#tab-data-hazard-1).

:::{figure} #tab-data-hazard-1
:alt: "Reprint of the pipeline diagram table for the simple add then dependent instructions example, showing IF through WB stage occupancy per cycle before stalls are applied."
:::

Suppose the RegFile supports write-then-read, _and_ we implement the described forwarding paths from `MEM` to `EX` and `from WB` to `EX`. How many cycles do we need to stall to avoid data hazards?

::::

:::{note} Show Answer
:class: dropdown

We **do not need to stall the pipeline**. The ALU result from the `add` instuction is available at the beginning of cycle 4. We can leverage the `MEM` to `EX` forwarding path to forward the `add` instruction's ALU result directly from the `EX/MEM` pipeline registers to the ALU for the `sub` instruction's `EX` stage, also in cycle 4.
:::

### Implementing Forwarding

Forwarding is implemented by adding bypass wires between pipeline registers and other components, inserting muxes, and including additional control logic.

@fig-forwarding-ex-mem shows an implementation of the `MEM` to `EX` forwarding path. The forwarding path (e.g., **bypass**) connects the output of the ALU from the `EX/MEM` pipeline register to the ALU input muxes. These two muxes are now wider to account for the additional bypass option. The control signals `ASel` and `BSel` now must also use the instruction bits to determine if the bypass should be used for either input to the ALU.

:::{figure} images/forwarding-ex-mem.png
:label: fig-forwarding-ex-mem
:width: 100%
:alt: "Full five-stage pipeline diagram with labeled stages showing the highlighted EX-MEM forwarding case. The yellow path indicates the forwarding path taken by values output from the EX stage pipeline registers, back into the muxes within the Execute stage for the following instruction to use during its EX stage to resolve a read-after-write dependency."

:::

We omit the full `MEM/WB` forwarding circuitry, leaving this for you to work out.

:::{hint} Quick Check

In @tab-data-hazard-4, which potential data hazards are resolved by inserting the described forwarding paths from `MEM` to `EX` and from `WB` to `EX`?

```{list-table}
:header-rows: 1
:label: tab-data-hazard-4

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0 t1 t2`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `lw  s1 8(s0)`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
* - `or t3 s1 t5`
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
* - `and t4 s1 t2`
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
* - `sll t0 t1 t2`
  - 
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
```

* **A.** `add`-`lw` hazard with register `s0`
* **B.** `lw`-`or` hazard with register `s1`
* **C.** `lw`-`and` hazard with register `s1`
* **D.** None of the above

:::

:::{note} Show Answer
:class: dropdown

* **A.** The `add`-`lw` data hazard is **resolved** by `MEM` to `EX` forwarding. The `add` instruction result (of adding `t1` and `t2`) is available in the `EX/MEM` pipeline registers at the beginning of cycle 4. Cycle 4 is also the `lw` instruction's `EX` stage. In this cycle, the correct value is forwarded from the `EX/MEM` pipeline registers to the A input of the ALU, overriding the stale value of register `s0` fetched during the `lw` instruction's `ID` stage in cycle 4.
* **C.** The `lw` `and` data hazard is **resolved** by `WB` to `EX` forwarding. The memory read result from the `lw` instruction is available from the `MEM/WB` pipeline registers at the beginning of cycle 6. Cycle 6 is also the `and` instruction's `EX` stage. In this cycle, the correct value is forwarded from the `MEM/WB` pipeline registers to the A input of the ALU, overriding the stale value of register `s1` fetched during the `and` instruction's `ID` stage in cycle 5.
:::

The `lw`-`or` data hazard in option B is **not resolved** by the proposed forwarding logic. Cycle 5 is the `or` instruction's `EX` stage. However, the `lw` instruction does not finish reading the value from DMEM (to be loaded into register `s1`) until the end of cycle 5. The result of this memory read is not available in the `MEM/WB` pipeline registers until _cycle 6_.

(sec-data-hazards-load)=
## Load Data Hazards

The `lw`-`or` data hazard described above is an example of a **load-use data hazard**. The hazard stems from an instruction's `EX` stage depending on a memory read from an immediately preceding load instruction's `MEM` stage **in the same clock cycle**.

### Approach 1: Stall

:::{hint} Loads can result in an unavoidable pipeline stall.

If an instruction immediately after a load instruction (i.e., in the **load delay slot**) uses the result of the load, the hardware must **stall for one cycle** _and_ leverage the `WB` to `EX` forwarding.
:::

Consider the [instruction sequence](#tab-data-hazard-4) in the previous Quick Check. As shown in @data-hazard-4-load, the pipeline must stall for one cycle to avoid the `lw`-`or` data hazard.


:::{list-table} With a hazard detection unit in the ID stage, a bubble is inserting beginning in cycle 5, changing the `or` instruction to a nop. The `or` instruction is fetched and decoded in cycles 3 and 4, but its `EX` stage is delayed until clock cycle 6.
:label: data-hazard-4-load
:header-rows: 1

* - Instruction
  - 1
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
  - 9
* - `add s0 t1 t2`
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
  - 
* - `lw  s1 8(s0)`
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
  - 
  - 
* - `or → nop`
  - 
  - 
  - IF
  - ID
  - —
  - —
  - —
  - 
  - 
* - `or  t3 s1 t5`
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
  - 
* - `and t4 s1  t2`
  - 
  - 
  - 
  - 
  - IF
  - ID
  - EX
  - MEM
  - WB
:::

### Approach 2: Code scheduling

Consider the [instruction sequence](#tab-data-hazard-4) in the previous Quick Check. We observe that if the `or` and `sll` instructions were switched, we could avoid the inevitable stall due to the potential `lw`-`or` data hazard.

From P&H 4.8:

> Although the compiler generally relies upon the hardware to resolve hazards and thereby ensure correct execution, the compiler must understand the pipeline to achieve the best performance. Otherwise, unexpected stalls will reduce the performance of the compiled code.

In other words, if the compiler knows how the processor resolves data hazards, it can design instruction sequences to avoid unavoidable stalls, e.g., due to `loads`. This approach is called **code scheduling**. With knowledge of the underlying processor architecture, the compiler reorders code to improve performance.

Consider the below C code.

```c
A[3] = A[0] + A[1];
A[4] = A[0] + A[2];
```

Suppose that the address of array `int A[]` is in register `a0` and the 0th to 4th elements of `A` are in `t0` through `t4`, respectively.

A simple compilation would result in inevitable stalls due to instructions in the load delay slots needing the load results. If the pipeline implements `WB` to `EX` forwarding, stalling incurs _two additional cycles_, as below.

```bash
lw  t0 0(a0)
lw  t1 4(a0)
add t2 t0 t1    # stalled one cycle
sw  t2 12(a0)
lw  t3 8(a0)    # stalled one cycle
add t4 t0 t3
sw  t4 16(a0)
```

A compiler could use code scheduling by inserting instructions into the load delay slots that are unrelated to the load results. With forwarding, the new  seven-instruction sequence below _does not incur any performance loss due to stalling_.

```bash
lw  t0 0(a0)
lw  t1 4(a0)
lw  t3 8(a0)
add t2 t0 t1
sw  t2 12(a0)
add t4 t0 t3
sw  t4 16(a0)
```

<!-- :::{figure} images/read-write-data-hazard.png
:label: fig-data-hazard
:width: 100%
:alt: "Pipeline waterfall diagram table with 5 instructions in the first column. The sequence of instructions illustrates a read-after-write data hazard between dependent instructions 1 and 4."

Waterfall diagram for read-write data hazard.
:::

:::{figure} images/alu-hazard-result.png
:label: fig-alu-hazard
:width: 100%
:alt: "ALU-result hazard waterfall diagram table showing three sequential instructions that rely on the ALU output of dependent combinations of registers. The second and third instructions need the updated value of register s0, which is the destination register of the add operation in instruction 1, before the normal write-back stage of instruction 1 is complete."

Waterfall diagram for ALU problem: WB in `inst1` must happen before EX in `inst2`.
:::

:::{figure} images/stalling.png
:label: fig-stalling
:width: 100%
:alt: "Waterfall diagram table illustrating stalling. This solution inserts two nop instructions between two dependent instructions to delay the second instruction until data from the first is ready."

Solution 1: Stalling pipeline with `nop`.
:::



:::{figure} images/forwarding-pipeline-table.png
:label: fig-forwarding-table
:width: 100%
:alt: "Forwarding pipeline table showing hazard resolution by bypassing values instead of stalling. The EX stages of both instructions in the table are highlighted, and the output of the EX stage of instruction 1 is connected to the input of the EX stage of instruction 2 via a vertical arrow."

Waterfall diagram for forwarding with EX hazard.
::: -->

## Summary: Detecting Data Hazards and Implementing Forwarding

Again, data hazards occur between different stages, when an instruction reads a register before a previous instruction has finished writing to the same register.

Suppose we have the `rs1`, `rs2`, `RegWEn`, and `rd` signals for two instructions (instruction *n* and instruction *n + 1*) and we wish to determine if a data hazard exists between the instructions. We can check to see if register `rd` for instruction *n* matches either register `rs1` or `rs2` of instruction *n + 1*, indicating a data hazard.

We could then use our hazard detection to determine which forwarding paths/number of stalls (if any) are necessary to take to ensure proper instruction execution. In pseudocode, part of this could look something like the following:

```pseudo-code
if (rs1(n + 1) == rd(n) && RegWen(n) == 1) {
    set ASel for (n + 1) to forward ALU output from n
}
if (rs2(n + 1) == rd(n) && RegWen(n) == 1) {
    set BSel for (n + 1) to forward ALU output from n
}
```

Read P&H 4.8 for more information.
