---
title: "Assembler: Object File"
---

(sec-assembler-details)=
## Learning Outcomes

* Identify basic components of the object file.
* Explain why the assembler can resolve PC-relative addresses but not absolute addresses.
* Explain why PC-relative address resolution requires a two-pass process.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/87YbZ9x8QEY
:width: 100%
:title: "[CS61C FA20] Lecture 13.3 - Compilation, Assembly, Linking, Loading: Assembler"
:::

1:26 onwards

::::

From [our overview](#sec-assembler):

> The assembler translates assembly code to machine modules. It translates **pseudoinstructions** to real instructions and produces an **object file**. The assembler uses assembly **directives** to produce the object file, which contains portions of an executable's **text segment**, **data segment**, and more.


## Object File

The final `.o` object file is a machine module, which is in **binary**:

1. **Object File Header**: size and position of other pieces of the object file. This is like the "table of contents".
2. **Text Segment**: machine code.
3. **Data Segment**: binary representation of static data in the source file.
4. **Symbol Table**: List of file’s labels, static data that can be referenced by other programs 
5. **Relocation Table:** Lines of code to fix later (by Linker)
6. Debugging Information.

The Text Segment and Data Segment (recall [program memory layout](#fig-c-mem-layout)) translates into machine code where possible. The last three items (Symbol Table, Relocation Table, Debugging Information) are used for the downstream Linker to resolve everything and create a single executable.

We highly recommend reading this section and then seeing the [example](#sec-call-example) at the end of this chapter.

## Text Segment

An [example text segment](#code-hello-o) is discussed in the [example](#sec-call-example) at the end of this chapter.

**Arithmetic, Logical Instructions**: For simple cases like `add` or `sub`, the 32-bit instruction contains all the information needed to build the machine code. This encompasses R-Format and some I-Format instructions.

**PC-Relative Branches and Jumps**, like `beq`/`bne`/etc. and `jal`. Once pseudoinstructions are replaced with real ones, all known **PC-relative addressing** _within the object file_ can be computed. Determine the offset to encode by counting the number of half-word instructions between current instruction and target instruction.

After replacing pseudoinstructions, the assembler performs **two passes** over the program to compute all offsets.

* **Record all labels in a symbol table**: The assembler records positions of labels by storing them in a **symbol table**.
* **Then, resolve references**: Use label positions to generate machine code and hardcode branch/jump offsets where possible.

If the assembler only made one pass (from earlier instructions to later), "forward references" (labels to locations later in the program) would have unknown PC-relative offsets.

:::{warning} The assembler cannot resolve all addresses

The assembler **only assembles the specific assembly code** and produces an object file, _not_ the final executable. It therefore does not know how to resolve:

* References to **other files**, e.g., calling `strlen` from the C string library with a `jalr`
* References to **static data**, e.g., the load address instruction `la` gets broken up into `lui` and `addi`. Resolving these two immediates requires knowing the full 32-bit **absolute address** of the data _in the executable_.

Because **absolute addresses** cannot be determined yet, the assembler defers to downstream (Linker) any references that depend on knowing other object modules. The assembler records unresolved references in the Relocation Table and Symbol Table.
:::

## Symbol Table

The **symbol table** is a list of labels (procedures) and data (like global arrays) in your file that could be used by other files. The Symbol Table is also used by the debugger `gdb`.

* **Instruction labels**: Used to compute machine code for PC-relative addressing in branches, function calling, etc.
  * If you want to call a function like `printf` from a library, the linker will eventually need this symbol (additionally, see the relocation table below).
  * Can use .globl [directive](#sec-directives) to allow labels can be referenced by other files.
* **Data segment**: anything in section marked by the `.data` directive. Recall that the data segment has global variables may be accessed/used by other files.

An [example symbol table](#tab-hello-symbol-table) is discussed in the [example](#sec-call-example) at the end of this chapter.

## Relocation Table

The **relocation table** is a "to-do list" of things to fix later (by the downstream **linker**). It contains placeholders for:

* **Absolute addresses for any external label** used by a jump, e.g., in lib files, `jal ext_label`
* **Absolute addresses for any data located in data segment**. e.g., static variables from the `la` load address instruction. The assembler doesn't know where the static section or the "final resting place" is; it delegates this "final resting place" resolution to the **linker**.

An [example relocation table](#tab-hello-symbol-table) is discussed in the [example](#sec-call-example) at the end of this chapter.