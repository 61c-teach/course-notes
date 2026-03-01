---
title: "The Program Counter"
---

(sec-rv-pc)=
## Learning Outcomes

* Understand how the program counter (PC) register updates between instructions.
* Understand how the processor uses the PC to determine which instruction to load and execute.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/X6SbnHmeN6w
:width: 100%
:title: "[CS61C FA20] Lecture 09.2 - RISC-V Decisions II: A Bit About Machine Program"
:::

::::

So far, we have seen that during execution, values are stored in **registers**. **Assembly instructions** operate on registers and load/store values between registers and memory.

We discuss the basics of the RISC-V memory model across the next two chapters.

## Stored Program, Revisited

In an [earlier section](#sec-stored-program) we discussed the concept of the **stored-program** computer, which is effectively used for all general-purpose computers today:

> Data doesn't just have to represent numbers; it can represent the program itself.

When we discussed the [C memory layout](#fig-c-mem-layout), we expanded on this concept. In a C program, the **text** segment stores the program code.

Additionally,[^call] recall that assembly language is typically produced by a compiler. An assembler then produces the machine-readable code. Typically, this is stored as an executable file, which is then loaded in to the text segment of memory.

[^call]: We expand on the compiler-assembler-linker-loader process later.

RISC-V has a similar memory model. Each RISC-V assembly instruction is stored as **machine code**, i.e., bits. Each assembly instruction translates to a 32-bit machine instruction (in RV32I, our word size is 32 bits). For example, the instruction `slli x12 x10 0x10` translates to the bits `0x01051613`.[^instruction-formats]. These 32-bit machine instructions then compose the machine code executable file.

The machine code executable is too large to fit in registers, so it resides in **memory** (in C, this would be the text segment). The program itself is essentially a sequence of RISC-V instructions, each 32 bits wide, which are usually executed in order until the processor hits a [branch or a jump](#sec-branches).

[^instruction-formats]: We see how to do this translation later.

(sec-program-counter)=
## The Program Counter (PC)

How does a computer know which instruction to execute? The processor also keeps track of this value in a **register**! From the [RV32I Specification](https://docs.riscv.org/reference/isa/unpriv/rv32.html#2-2-programmers-model-for-base-integer-isa):

> There is one additional unprivileged register: the program counter `PC` holds the address of the current instruction.

The **Program Counter** (PC[^pc]) is effectively a pointer to memory[^intel-pc] and is a register named `pc`[^pc-name]. The `pc` register is **not** one of the 32 registers numbered `x0` to `x31`. It is a _separate_ register that generally is not explicitly specified as a read/write destination for instructions.

[^pc]: Program Counter, not Personal Computer. 
[^intel-pc]: Intel calls the program counter an Instruction Pointer (PC).

[^pc-name] Verilog syntax is PC, though the [RISC-V Unprivileged Manual](https://docs.riscv.org/reference/isa/unpriv/rv32.html) calls it `pc`.


We revisit our [conceptual computer layout](#fig-von-neumann) from earlier and focus on the program counter in @fig-program-counter.

:::{figure} images/program-counter.png
:label: fig-program-counter
:width: 80%
:alt: "TODO"

The program counter holds the address of the current instruction.
:::

The processor on the left consists of a control unit and a datapath. The memory sits on the right. Inside the datapath, we have our 32 registers and our PC, which is a register internal to the processor that holds the **byte address** of the next instruction ot to be executed.

The control unit[^control] uses the PC as follows:

1. Read the PC,
1. Fetch an instruction from memory,
1. Execute the instruction using the datapath, and
1. Update the PC to point to the next instruction.

(sec-rv32i-pc-4)=
:::{warning} Instructions are word-sized
Each RV32I instruction is one word wide, so consecutive instructions are located 4 bytes away from one another. This design choice follows the simplicity of RISC-V by keeping pretty much everything to word-width (e.g., register width and memory access with `lw` and `sw`).

By default, the PC is incremented by 4 bytes, corresponding to the next sequential instruction.
:::

[^control]: We discuss the control unit later when we design our processor. For now, we introduce the program counter to explain the full set of assembly instructions.

### Example: Arithmetic Instruction

The below animation traces through a toy example of how a executing arithmetic instruction updates **both** the destination register **and** the program counter register.

:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vRzEG3hI-o7XL7oL1njxPvQq0jr7uR3pVlBTtBX6KM82YUC1wROduPqaLwCiS7iU_y9p0hbTTiooPYn/pubembed?start=false&loop=false
:width: 100%
:title: "Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1nt1Qum-w_TcAtcdsT9iVIBhmDbTvjEuiFnK4bv7NeRE/edit?usp=sharing)"
:::

Above, the processor executes one instruction as follows:

1. The processor reads `pc`, which currently holds `0x00000008`.
1. The processor reads the instruction in memory at address `0x00000008`, which is `slli x12 x10 0x10`.
1. The processor executes this instruction by reading and writing registers. If `x10` holds `0x0000 34FF`, then `x12` is updated to `0x34FF0000`.
1. The processor updates `pc` to hold `0x00000008 + 4`, or `0x0000000c`.

Certain instructions will request that the PC be updated differently. These instructions are called **branches** and cause a completely new address to be loaded into the PC. This is the topic of the next two chapters.