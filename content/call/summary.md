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

## Additional References

