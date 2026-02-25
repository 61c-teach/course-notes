---
title: "Linker: Resolve References"
subtitle: TODO
---

(sec-linker-details)=
## Learning Outcomes

* Explain why the linker can resolve absolute addresses.
* Identify when branch/jump instruction addresses are resolved by the assembler or the linker.
* Compare and contrast statically-linked and dynamically-linked libraries.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/2lVYrK7spaw
:width: 100%
:title: "[CS61C FA20] Lecture 13.4 - Compilation, Assembly, Linking, Loading: Linker"
:::

1:38 onwards
::::

At this point, the compiler has finished and given you a `.s` file, and the assembler has finished to produce a `.o` file (object file). You might have a lot of `.o `files, plus library files like `.a` files—which are just big packages of `.o` files wrapped together (see [earlier figure](#fig-call-flow)). The linker’s job[^link-editor] is to gather all of these together at the table and produce an `a.out` executable file.

[^link-editor]: The linker is also historically called the "link editor" because it "edits" or fixes all the links on the relocation table.

Again, we like that the linker enables separate compliation of different parts of our program. We discuss some tradeoffs later in this section.

From [our overview](#sec-linker):

> The linker patches together multiple object modules to produce an executable. It resolves all the assembler's "TODO items," including **relocating** everything for the final executable:
> 
> 1. Put together **text segments** from each `.o` file.
> 1. Put together data segments from each `.o` file, then  concatenate this onto the end of Step 1’s segment.
> 1. Resolve references, i.e., addresses that the assembler wasn't able to resolve.

:::{figure} images/linker-flow.png
:label: fig-linker-flow
:width: 40%
:alt: "TODO"

Flow chart for linker components.
:::

## Resolving References

:::{hint} Which Addresses Need Relocating?

We have three types of addresses:

1. PC-Relative Addressing: `beq`, `bne`, `jal`, etc.

2. External Function Reference, e.g., `jal` or `auipc`/`jalr`

3. Static Data Reference, e.g., `lw`, `sw` (of static data), `lui`/`addi` (when part of `la` pseudoinstruction).

The first, PC-relative addressing within the object module, has already been completed by the assembler. The linker resolves the latter two, because

* The assembler does not know where external functions are because at the time of assembling, addresses to other object modules are unknown.
* At the time of assembling, the final location of static data is unknown because data segment may be **relocated** as a result of multiple object modules.
:::

::::{hint} Which instructions must be **edited for relocation**?

See @fig-linker-instructions:

* J-Format External jumps (e.g., to C library):
* `lui`/`addi`; `auipc`/`jalr` (for `li` or `la` pseudoinstructions)
* Loads/stores that access `.data` variables[^gp]

[^gp]: Global pointer (`gp`) is a pointer to the data (static) segment. Out of scope for this course

(again, B-Type don’t need editing, because such conditional jumps are within each module)

:::{figure} images/linker-instructions.png
:label: fig-linker-instructions
:width: 100%
:alt: "TODO"

The linker "resolves references" by replacing the appropriate placeholders in machine code instructions.
:::

::::

We will likely not test the details of resolving references, but for those who are curious:

1. For RV32, linker assumes first text segment starts at address `0x10000`.

1. The linker knows the **length** of each text and data segment and the **ordering** of text and data segments. The linker then **calculates the absolute address** of (1) each label to be jumped to, and (2) each piece of static data referenced.

1. The linker then **resolves references**. It searches for each reference (data or label) in all "user" symbol tables. If not found, it then searches librari files (e.g., for `printf`). Once the absolute address is determined, it fills in the machine code appropriately by editing specific instructions for relocation.

Finally, the linker outputs an executable containing text and data along with header/debugging info.

## [Aside] Static vs. Dynamic Linking

So far, we’ve described the traditional way: **statically-linked libraries**. The executable includes the entire library, even if not all of it is used by the user program. The library is now part of the executable–if the library updates, we won’t get the fix unless we recompile the user program.

An alternative is **dynamically-linked libraries** (DLL), common Windows and UNIX platforms. The prevailing approach in this model is to link at the machine code level _at loadtime_: the loader makes room for the library, stuffs it in, and runs it.

Tradeoffs:

* **Space vs. Time**:
  * With statically-linked libraries, we get a self-contained executable that ultimately is very large. 
  * With DLL, storing a program requires less disk space; less time to send a program. Furthermore, two programs requires less memory (if they share a library). However, there is now **runtime overhead**; there is extra time needed do dynamically link libraries.
* **Reasonable handling of upgrades**
  * With statically-linked libraries, if a library has a security hole or a bug fix, every single developer has to recompile and resend updates to their users because the old, broken library is baked into their `a.out`.
  * With DLL. replacing libXYZ.so upgrades every program using library XYZ. However, DLL introduces complexity: we now need **multiple files** to run a single program. Having the program executable isn’t enough anymore!

Overall dynamic linking adds complexity to compiler, linker and OS. However, its benefits outweigh its complexities.