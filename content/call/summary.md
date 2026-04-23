---
title: "Summary"
---

## And in Conclusion$\dots$

We spent one chapter covering [one figure](#fig-call-flow):

:::{figure} images/call-flow.png
:width: 60%
:alt: "Vertical flowchart of the translation and load pipeline: C source foo.c is compiled to assembly foo.s, assembled to object file foo.o, linked with lib.o to produce executable a.out, then loaded into memory. Each stage appears as a color-coded box with arrows showing inputs and outputs between files and the Compiler, Assembler, Linker, and Loader."

Flow chart for steps for compiling and running a C program.
:::

* The [Compiler](#sec-compiler) converts a single high-level language file into a single assembly language file.
* The [Assembler](#sec-assembler) removes pseudoinstructions, converts what it can to machine language, creates checklist for the linker (relocation table).
  * These details are stored in an [object file](#sec-assembler-details).
  * The assembler does 2 passes to resolve addresses in the text segment, handling internal references to position-independent code.
* The [Linker](#sec-linker) combines several `.o` files and resolves absolute addresses.
  * The linker enables separate compilation, libraries that need not be compiled, and resolves remaining addresses ([more details](#sec-linker-details))
* The [Loader](#sec-loader) loads executable into memory and begins execution.

## Textbook Readings

P&H 2.12

<!-- ## Additional References -->

## Exercises
Check your knowledge!

### Conceptual Review

:::{exercise}
:label: call-01
1. How many passes through the code does the Assembler have to make? Why?
:::

:::{solution} call-01
:label: call-01-sol
:class: dropdown
**Two**: The first finds all the label addresses, and the second resolves forward references while
using these label addresses.
:::

:::{exercise}
:label: call-02
2. Which step in CALL resolves relative addressing? Absolute addressing?
:::

:::{solution} call-02
:label: call-02-sol
:class: dropdown

The **assembler** usually handles relative addressing. The **linker** handles absolute addressing,
resolving the references to memory locations outside.
:::

:::{exercise}
:label: call-03
3. Describe the six main parts of the object files outputted by the Assembler (Header, Text, Data, Relocation Table, Symbol Table, Debugging Information).
:::

:::{solution} call-03
:label: call-03-sol
:class: dropdown
* **Header**: Sizes and positions of the other parts
* **Text**: The machine code
* **Data**: Binary representation of any data in the source file
* **Relocation Table**: Identifies lines of code that need to be “handled” by the Linker (jumps to external labels (e.g. lib files), references to static data)
* **Symbol Table**: List of file labels and data that can be referenced across files
* **Debugging Information**: Additional information for debuggers
:::