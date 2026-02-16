---
title: "RISC-V ISA"
---

## Learning Outcomes

* Know that the RISC-V 32I ISA specifies 32 32-bit-wide registers. Of these, the zero register `x0` is hardwired to zero.
* Compare and constrast assembly and higher-level languages.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/mIDxHr5_sxo
:width: 100%
:title: "[CS61C FA20] Lecture 07.2 - RISC-V Intro: Elements of Architecture: Registers"
:::

::::

## Defining the RISC-V Instruction Set

The instruction set for a particular architecture (e.g. RISC-V) defines the set of instructions we can use in **assembly language** for that architecture.

Each line of assembly code represents one instruction for the computer. In RISC-V, an **assembly instruction** has an **operation name** (**opname**) and **operands** that specify source and destination registers, values, memory locations, other instructions, etc.

```
add x1 x2 x3
```

This instruction is the `add` operation. When executed, the processor will add the values of registers `x2` and `x3` together and store the result in register `x1`. We discuss this convention and _many more instructions_ in the next few lectures!

:::{hint} Comment your assembly code!

It is always important to have comments to make code readable. Comments in assembly are arguably more important than comments in higher-level languages. After all, in C and Java, we can specify variable names to create syntactically meaningful code. By contrast, there are no variable names in assembly, so uncommented RISC-V code is **practically impossible to debug** properly.

To write a comment in RISC-V,  use a hash mark (`#`)[^apollo]. Everything to the right of the hash is ignored by the assembler. Unlike in C, there are no multi-line comments (like `/* ... */` in C); you must use the hash style for each commented line.

:::

[^apollo]: The `#` commenting style has a long history. For example, the 1966 Apollo Guidance Computer code (written by lead programmer [Margaret Hamilton](https://www.smithsonianmag.com/smithsonian-institution/margaret-hamilton-led-nasa-software-team-landed-astronauts-moon-180971575/)) used similar commenting conventions. the printout of the code for the lunar lander was famously taller than Hamilton herself. You can actually find the Apollo landing code on GitHub. As reported on [ABC News](https://abcnews.go.com/Technology/apollo-11s-source-code-tons-easter-eggs-including/story?id=40515222), the [code](https://github.com/chrislgarry/Apollo-11/blob/247dd7d0d1b0e7f9f270750ec08983e0a72e73e1/Luminary099/THE_LUNAR_LANDING.agc#L245) has a [ton](https://github.com/chrislgarry/Apollo-11/blob/247dd7d0d1b0e7f9f270750ec08983e0a72e73e1/Luminary099/LUNAR_LANDING_GUIDANCE_EQUATIONS.agc#L179) of [easter eggs](https://github.com/chrislgarry/Apollo-11/blob/247dd7d0d1b0e7f9f270750ec08983e0a72e73e1/Luminary099/BURN_BABY_BURN--MASTER_IGNITION_ROUTINE.agc#L61) that belie the nature of early computer scientists.

(sec-rv32i-registers)=
## RV32I Registers

The RISC-V ISA specifies **32 registers**.

:::{note} Why 32 registers?

This choice feels arbitrary but follows a "Goldilocks" principle.[^goldilocks] Too many registers would slow the machine down and be extremely expensive. However, too few registers would require (among other things) extremely complicated compiler logic. 32 registers, at least for the RISC-V architects, was considered "just right."
:::

(sec-reg-size)=
### Register size

Remember a concept we discussed earlier in the course: the [hardware word](#sec-words). Word size also determines **register size**. In the RV32I ISA, the word size is 32 bits, meaning that each RV32I register is **32 bits wide**.

[^goldilocks]: From the [British fairy tale](https://en.wikipedia.org/wiki/Goldilocks_and_the_Three_Bears): "This porridge is too hot; This porridge is too cold; this porridge is just right."

(sec-register-names)=
### Register names and numbers

Unlike high-level languages like C or Java, there are no variables in assembly. Instead, to operate on data, assembly instructions use **register names** or **register numbers**.

In RV32I, registers are numbered from 0 to 31. To refer to a register by number, an assembly instruction can specify `x0`, `x1`, ..., `x31`. Registers can also be referred to by names. These register names are specified by the ISA and facilitate conventions when writing assembly. We discuss more later.

(sec-x0)=
#### The Zero Register

For now, we define one very important register: register `x0`, which has register name `zero`. This special [zero register](https://en.wikipedia.org/wiki/Zero_register) is hardwired to zero, and you cannot change its value. Contrary to intuition, it is extremely helpful to have a register-sized representation of zero handy for a multitude of operations. The RISC-V architects thought so too, and were willing to sacrifice one fewer data register in order to specify zero directly on the processor.

(sec-hll-vs-assembly)=
## Assembly Language vs. Higher-Level Language

You may find this section more helpful after you see some examples of assembly [in our next section](#sec-rv-arithmetic).

The compiler translates from higher-level languages like C and Java down to assembly, so RISC-V instructions are often **closely related** to common higher-level language operations. However, higher-level languages abstract away components of the architecture. @tab-hll-vs-assembly notes the key differences.

:::{table} Higher-level Languages vs. Assembly
:label: tab-hll-vs-assembly
:align: center

| Point |C, Java | RISC-V |
|:-: | :--- | :--- |
| 1 | Variables must be declared and typed. | Register contents are just bits. |
| 2 | Variable types determine operation. | Operations determine how to use register contents. |
| 3 | Each operator can denote multiple operations. | Operation names and operation are one-to-one. |
| 4 | Each statement can contain multiple operations. | Each line is a single instruction. |

:::

**Point 1**. In C (and most high-level languages), we declare variables of a specific type; these names can ONLY represent a value of the type it was declared as. By contrast, registers have no type, nor are they declared. They are simply storage containers–a small set of special data locations built directly into the processor hardware. In RV32, registers store 32 bits.

**Points 2 and 3**. In high-level languages, variable types determine operation. In the C code below, Line 1 uses the `+` operator as pointer arithmetic, whereas Line 4 uses `+` as integer arithmetic. Line 4 also has two uses of the `*` operator, for integer multiplication and pointer dereference.

```{code} c
:linenos:
int *p = …; 
p = p + 2;
int x = 42;
x = 3 * x + *p + 4;
```

By contrast, in assembly the operation is precisely determined by the opname. For example, there is only one `add` instruction in RV32I, and `add` always means signed integer addition. The opname further determines how register contents are treated. For example, in RV32I `add` means the contents of the register operands are signed integers. Other instructions treat register operands as unsigned integers, or even memory addresses.

**Point 4**. Each line of C (or more precisely, each _statement_) can contain multiple operations, e.g., `a = b * 2 - (arr[2] + *p);` By contrast, each line in assembly is exactly one computer instruction. A compiler would translate the complicated C code above into half a dozen lines of assembly. We leave this as an exercise to you once you learn more RISC-V.