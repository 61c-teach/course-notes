---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

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

