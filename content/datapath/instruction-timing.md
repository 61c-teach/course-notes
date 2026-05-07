---
title: "Instruction Timing"
---

(sec-instruction-timing)=
## Learning Outcomes

* Practice interpreting waveforms in timing diagrams.
* Given an instruction, identify the critical path through the single-cycle datapath.
* Approximate instruction timing based on the five phases of instruction execution.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/eLT0FOLdtn8
:width: 100%
:title: "[CS61C FA20] Lecture 20.3 - Single-Cycle CPU Control: Instruction Timing"
:::

::::

How should we time our single-cycle datapath? How should we set the clock frequency? In this section, we develop an approximation of instruction timing using the [five steps to a RISC-V instruction](#sec-five-steps).

```{embed} #sec-five-steps
```

## Timing Diagram for `add`

First, let's consider the delays in our beloved `add` instruction. Review the `add` datapath in @anim-datapath-add-full.

<!-- ::::{figure}
:label: anim-datapath-add-full
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-add-full.pptx
:width: 100%
:title: "Slides tracing through the `add` Datapath (Full)."
:::
The `add` datapath, updated from an [earlier section](#sec-datapath-r-type)'s simple `add`-only datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
:::: -->

::::{figure}
:label: anim-datapath-add-full
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vTNTZZVVOA6hREQLorL6y7AEwzfidYgLpsBBc9YEAda0Dxih_yFBL3ykPOPSysa7w/pubembed?start=false&loop=false
:width: 100%
:alt: "Full add datapath trace slide showing all major buses and control lines active for an add instruction across one cycle."
:title: "Slides tracing through the `add` Datapath (Full)."
:::
The `add` datapath, updated from an [earlier section](#sec-datapath-r-type)'s simple `add`-only datapath. Use the menu bar to trace through the animation or access the [original Google slides](https://docs.google.com/presentation/d/10ORU8oWu4rSY7J6uSWl_6OxrJLVLt9EQ/edit?usp=sharing).
::::

@fig-timing-add shows the waveforms for executing an `add x1 x2 x3` instruction at address `0x100`, followed by `add x6 x7 x9` at address `0x104`.

:::{figure} images/timing-add.png
:label: fig-timing-add
:alt: "Timing waveforms for two consecutive add instructions, showing PC, instruction, register read, ALU, and writeback stabilization within a clock period."

Timing diagram for `add`. Only relevant signal waveforms are shown.

:::

:::{note} Explanation of @fig-timing-add

1. **Instruction Fetch** (`IF`).

    * On the rising edge of the clock, update the program counter register with its input signal. After some delay $t_{clk-to-q}$, the value of the program counter `0x100` appears at the output signal `pc`.

    * Concurrently perform the following:[^concurrent]
    
        * Increment PC to the next instruction with the simple adder. After some delay, the signal `pc + 4` is ready with `0x104` at the input to the PCSel mux.[^bundle-delay].

        * Fetch an instruction from `IMEM`. After some delay, `inst[31:0]` is updated with the machine code for `add x1 x2 x3`.

1. **Instruction Decode** (`ID`). Concurrently perform the following:[^concurrent-2]
    * Retrieve the values of the source registers `rs1` and `rs2` from RegFile. After some delay, the output signals `R[rs1]` and `R[rs2]` are ready with the values of registers `x2` and `x3`.
    * Decode the instruction to determine the [control logic signals](#tab-control-truth-table).
1. **Execute** (`EX`).
    * Use the two muxes to select the appropriate input signals to the ALU. After some delay, these input signals carry the two source register values.[^mux-delay]
    * After some more delay, the ALU's output signal `alu` is set to the sum of the two source registers `x2` and `x3`.
1. **Memory** (`MEM`). (We don't access memory, so do not incorporate memory delay in our analysis.)
1. **Write Back** (`WB`). Use the `WBSel` mux to select the `alu` output signal as the `wb` signal to the `wdata` input of the RegFile. After some delay, the signal is set to the sum of the two source registers.

    Additionally, account for setup time needed to hold the `wb` signal stable before the rising clock edge.

[^concurrent]: These processes take a comparable amount of time, though which is longer depends on the specific technology. In @fig-timing-add, the adder happens to complete faster than the `IMEM` memory fetch.

[^concurrent-2]: In @fig-timing-add, the control logic decoding of the instruction happens to complete faster than the `RegFile` register read. We will assume this precedence in later analysis.

[^bundle-delay]:  Note that the waveform represent bundles of wires with a hexadecimal value (contrast this with the clock's binary high-low signal). The PC output `pc` bundle of wires update at the same time, because [flip-flops](#sec-flip-flops) are wired in parallel. By contrast, the `pc+4` output does not stabilize simultaneously. Because the [adder](#sec-adder-subtractor) cascades single-bit adders in series, the least significant bits stabilize sooner than the more significant bits. In timing diagrams, we always show the transition to the correct value. For `pc+4`, this occurs after the propagation delay of the most significant bit.

[^mux-delay]: There are two multiplexers controlled with ASel and BSel, respectively. Both propagation delays occur concurrently, so we only count for one mux's propagation delay.

:::

## Critical path delay by instruction

Different instructions use different components of the datapath. We now update our definition of [critical path](#sec-critical-path) to consider the path between clocked element inputs and outputs that _matter_ for the given instruction. For example, accessing DMEM does not matter for an `add`, whereas setting up the RegFile data to write back does not matter for `sw`.

:::{table} Timing descriptions of components.
:label: tab-timing

| Delay | Description |
| :-- | :-- |
| $t_{\texttt{clk-to-q}}$ | clk-to-q delay to transfer register input value to the output. |
| $t_{\texttt{setup}}$ | Setup time to hold the register input stable before the rising clock edge. |
| $t_{\texttt{mux}}$ | Propagation delay through a mux; assume the same delay for all muxes. |
| $t_{\texttt{add}}$ | Propagation delay through the simple adder that increments PC to the next instruction. |
| $t_{\texttt{RegFile}}$ | Delay to read a register value from RegFile. |
| $t_{\texttt{IMEM}}$ | Delay to read the instruction from IMEM. |
| $t_{\texttt{DMEM}}$ | Delay to read a word from DMEM. |
| $t_{\texttt{ALU}}$ | Propagation delay through the ALU. |
| $t_{\texttt{Imm}}$ | Propagation delay through the immediate generator. |
| $t_{\texttt{BrComp}}$ | Propagation delay through the branch comparator. |
:::

::::{tip} Compute the delay along the critical path for each instruction.

1. `add`
1. `lw`
1. `beq`

Options:
* **A.** $t_{\texttt{clk-to-q}} + t_{\texttt{Add}} + t_{\texttt{IMEM}} + t_{\texttt{RegFile}} + t_{\texttt{BrComp}} + t_{\texttt{ALU}} + t_{\texttt{DMEM}} + t_{\texttt{mux}} + t_{\texttt{Setup}}$
* **B.** $t_{\texttt{clk-to-q}} + t_{\texttt{IMEM}} + t_{\texttt{RegFile}} + 2 \cdot t_{\texttt{mux}} + t_{\texttt{ALU}} + t_{\texttt{Setup}}$
* **C.** $t_{\texttt{clk-to-q}} + t_{\texttt{IMEM}} + \max\{t_{\texttt{RegFile}}, t_{\texttt{Imm}}\} + t_{\texttt{ALU}} + 2 \cdot t_{\texttt{mux}} + t_{\texttt{DMEM}} + t_{\texttt{Setup}}$
* **D.** $t_{\texttt{clk-to-q}} + t_{\texttt{IMEM}} + \max\{t_{\texttt{RegFile}}, t_{\texttt{Imm}}\} + t_{\texttt{ALU}} + 3 \cdot t_{\texttt{mux}} + t_{\texttt{Setup}}$
* **E.** Something else

::::

::::{note} Show Answer for `add`
:class: dropdown

**B**. There are two "loops" that we consider:[^concurrent-2]

* The PC update loop, measured from the PC output to the PC input: $t_{\texttt{clk-to-q}} + t_{\texttt{Add}} + t_{\texttt{mux}} + t_{\texttt{setup}}$
* The loop through the ALU, measured from the PC output to the RegFile input: $t_{\texttt{clk-to-q}} + t_{\texttt{IMEM}} + t_{\texttt{Reg}} + t_{\texttt{mux}} + t_{\texttt{ALU}} + t_{\texttt{mux}} + t_{\texttt{setup}}$

```{math}
\begin{aligned}
\text{Critical path delay}
  =& t_{\texttt{clk-to-q}} \\
    & + \max \{ t_{\texttt{Add}} + t_{\texttt{mux}}, t_{\texttt{IMEM}} + t_{\texttt{Reg}} + t_{\texttt{mux}} + t_{\texttt{ALU}} + t_{\texttt{mux}} \} \\
    & + t_{\texttt{setup}} \\
  =& t_{\texttt{clk-to-q}} + t_{\texttt{IMEM}} + t_{\texttt{Reg}} + t_{\texttt{mux}} + t_{\texttt{ALU}} + t_{\texttt{mux}} + t_{\texttt{setup}} \\
  =&t_{\texttt{clk-to-q}} + t_{\texttt{IMEM}} + t_{\texttt{RegFile}} + 2 \cdot t_{\texttt{mux}} + t_{\texttt{ALU}} + t_{\texttt{Setup}}
\end{aligned}
```

The critical path uses the longer loop through the ALU.
::::

<!-- ::::{figure}
:label: anim-datapath-beq-full
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-beq-full.pptx
:width: 100%
:title: "Slides tracing through the `beq` Datapath (Full)."
:::
The `beq` datapath, updated from an [earlier section](#sec-datapath-b-type)'s simpler datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
:::: -->

::::{figure}
:label: anim-datapath-beq-full
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vRFDNojlD-1rvzMR9dQTJ8JZ2CllIZwaS6yYCdE1CumfoKjRXqeOekErcrTywda-w/pubembed?start=false&loop=false
:width: 100%
:alt: "Full beq datapath trace slide with branch comparator, PC target computation, and control-dependent PC selection paths."
:title: "Slides tracing through the `beq` Datapath (Full)."
:::
The `beq` datapath, updated from an [earlier section](#sec-datapath-b-type)'s simpler datapath. Use the menu bar to trace through the animation or access the [original Google slides](https://docs.google.com/presentation/d/1iI-seGm2A7lSpHoGKM81b67utfyINT1H/edit?usp=sharing).
::::

:::{note} Show Answer for `beq`
:class: dropdown

**E**. Something else.

We leave this derivation to you. Note you may need to make new placeholder delays for control logic...!
:::

<!-- ::::{figure}
:label: anim-datapath-lw-full
:::{iframe} https://view.officeapps.live.com/op/embed.aspx?src=https://github.com/61c-teach/course-notes/raw/refs/heads/main/content/datapath/pptx/datapath-lw-full.pptx
:width: 100%
:alt: "Full lw datapath trace slide including IMEM fetch, ALU address generation, DMEM read, and writeback mux path to RegFile."
:title: "Slides tracing through the `lw` Datapath (Full)."
:::
The `lw` datapath, updated from an [earlier section](#sec-datapath-load-store)'s simpler datapath. Use the menu bar to trace through the animation or download a copy of the PDF/PPTX file.
:::: -->

::::{figure}
:label: anim-datapath-lw-full
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQqpuC67HJ6YsCXhnQ5YA1zqtUPBy-KRSnwjJzHgYdry8wwPkA6fm5pvToseVpxhQ/pubembed?start=false&loop=false
:width: 100%
:alt: "Phase-based timing sketch labeling IF, ID, EX, MEM, and WB intervals used to approximate single-cycle instruction delay."
:title: "Slides tracing through the `lw` Datapath (Full)."
:::
The `lw` datapath, updated from an [earlier section](#sec-datapath-load-store)'s simpler datapath. Use the menu bar to trace through the animation or access the [original Google slides](https://docs.google.com/presentation/d/1QV6naVOhLr3PVoKszzY-ipUCigknXs3D/edit?usp=sharing).
::::

::::{note} Show Answer for `lw`
:class: dropdown

**C**. Load uses hardware in all five phases of the datapath. We still consider the two "loops" through the datapath[^concurrent-2]:

* The PC update loop, still measured from the PC output to the PC input.
* The much longer loop, measured from the PC output through the ALU _and_ DMEM, to the RegFile input. We now consider additional hardware for loads:
  * **Instruction Decode**: The immediate generation block sets `imm` concurrently with the RegFile retrieving the source register value `R[rs1]`. We denote this delay as the larger of the two, $\max\{t_{\texttt{RegFile}}, t_{\texttt{Imm}}\}$.
  * **Execute**: The ALU output computes the memory address, so we incur $t_{\texttt{ALU}}$.
  * **Memory**: The DMEM read now matters, so we incur DMEM read time, $t_{\texttt{DMEM}}$.

```{math}
\begin{aligned}
\text{Critical path delay}
  =& t_{\texttt{clk-to-q}} \\
   & + \max \{ t_{\texttt{add}} + t_{\texttt{mux}}, \\
   & t_{\texttt{IMEM}} + t_{\texttt{Imm}} + t_{\texttt{mux}} + t_{\texttt{ALU}} + t_{\texttt{DMEM}} + t_{\texttt{mux}}, \\
   & t_{\texttt{IMEM}} + t_{\texttt{RegFile}} + t_{\texttt{mux}} + t_{\texttt{ALU}} + t_{\texttt{DMEM}} + t_{\texttt{mux}} \} \\
   & + t_{\texttt{setup}} \\
  =& t_{\texttt{clk-to-q}} + t_{\texttt{IMEM}} + \max\{t_{\texttt{RegFile}}, t_{\texttt{Imm}}\} + t_{\texttt{ALU}} + 2 \cdot t_{\texttt{mux}} + t_{\texttt{DMEM}} + t_{\texttt{setup}}
\end{aligned}
```
::::



:::{warning} Load uses all [five steps](#sec-five-steps)!

While most all instructions use three or four of the five steps, loads are the only instructions that must both read from DMEM (Memory) _and_ Write Back to the RegFile.
:::

## The single-cycle datapath clock is slow

To determine the **clock frequency** for the single-cycle datapath, we compute delays of each instruction's critical path, then set the clock period as the **worst-case** delay incurred over all instructions.

To put some numbers to our earlier analysis, we will _simplify_ our time estimates with @tab-timing-steps, which assumes that the timing of each of the [five steps to a RISC-V instruction](#sec-five-steps) are dominated by the major functional hardware units.

:::{table} Assume each of the [five steps](#sec-five-steps) is dominated by a major hardware unit. Multiplexors, control unit, PC accesses, immediate generation, and branch prediction incur minimal delay.
:label: tab-timing-steps

| Step | Operation time | Major hardware unit |
| :--- | :--- | :--- |
| Instruction Fetch (`IF`) | 200 ps | Read an instruction word from IMEM. |
| Instruction Decode (`ID`) | 100 ps | Read register values from the RegFile. |
| Execute (`EX`) | 200 ps | Perform arithmetic/logical operations in the ALU. |
| Memory Access (`MEM`) | 200 ps | Read or write data from DMEM. |
| Write Back (`WB`) | 100 ps | Write back to the RegFile. For single-cycle, we assume this is the delay of the WBSel mux and setup time. |

:::

We can then produce the simplified timing diagram in @fig-timing-phases for an instruction that uses all phases—like our `lw` instruction from earlier. 
We can additionally construct
@tab-timing-instructions, which shows the time required for various instruction formats.

:::{figure} images/timing-phases.png
:label: fig-timing-phases
:alt: "Phase-based timing diagram labeling IF, ID, EX, MEM, and WB intervals used to approximate single-cycle instruction delay."

Approximate timing diagram for the [five steps to a RISC-V instruction](#sec-five-steps) in the single-cycle-datapath.

:::

:::{table} (P&H Figure 4.28). Total time for each instruction calculated from the simplified time for each phase.
:label: tab-timing-instructions

| Instruction | IF (200ps) | ID (100ps) | EX (200ps) | MEM (200ps) | WB (100ps) | Total |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| `add` | X | X | X | | X | 600ps |
| `beq` | X | X | X | | | 500ps |
| `jal` | X | X | X | | | 500ps |
| `lw` | X | X | X | X | X | 800ps |
| `sw` | X | X | X | X | | 700ps |
:::

While @tab-timing-instructions above shows the shortest time to complete each instruction, we note that the single-cycle datapath, like all synchronous digital systems, shares a single clock.

:::{warning} The single-cycle datapath is timed to the slowest instruction

Even though some instructions can be as fast as 500 ps, our single-cycle datapath design requires that the time for every instruction is **800 ps**, because we must set the clock period to allow for the slowest instruction: **loads**.

In our single-cycle datapath, this means a **maximum clock frequency of 1.25 GHz**—despite each individual phase taking at most 200 ps.
:::

We further note that each instruction's critical path often involves accessing major hardware units in _sequence_. In other words, for most of each clock period, much of our hardware is idle and not computing additional data!

We address these performance issues and more in our _pipelined_ datapath design up next. Stay tuned!