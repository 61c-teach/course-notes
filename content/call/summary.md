---
title: "Summary"
---

## And in Conclusion$\dots$

We spent one chapter covering [one figure](#fig-call-flow):

:::{figure} images/call-flow.png
:width: 60%
:alt: "TODO"

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

1. How many passes through the code does the Assembler have to make? Why?

:::{note} Solution
:class: dropdown
**Two**: The first finds all the label addresses, and the second resolves forward references while
using these label addresses.
:::

2. Which step in CALL resolves relative addressing? Absolute addressing?

:::{note} Solution
:class: dropdown

The **assembler** usually handles relative addressing. The **linker** handles absolute addressing,
resolving the references to memory locations outside.
:::

3. Describe the six main parts of the object files outputted by the Assembler (Header, Text, Data,
Relocation Table, Symbol Table, Debugging Information).

:::{note} Solution
:class: dropdown
* **Header**: Sizes and positions of the other parts
* **Text**: The machine code
* **Data**: Binary representation of any data in the source file
* **Relocation Table**: Identifies lines of code that need to be “handled” by the Linker (jumps to external labels (e.g. lib files), references to static data)
* **Symbol Table**: List of file labels and data that can be referenced across files
* **Debugging Information**: Additional information for debuggers
:::