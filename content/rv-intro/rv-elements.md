---
title: "Elements of Architecture"
---

## Learning Outcomes

* Understand that registers are extremely tiny, fast storage located within a processor. In the conceptual layout of a computer, the processor and memory are separately located.
* Know that the RISC-V 32I ISA specifies 32 32-bit-wide registers. Of these, the zero register `x0` is hardwired to zero.
* Compare and constrast assembly and higher-level languages.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/mIDxHr5_sxo
:width: 100%
:title: "[CS61C FA20] Lecture 07.2 - RISC-V Intro: Elements of Architecture: Registers"
:::

::::

## Conceptual Layout of a Computer

In order to learn an ISA, we must first understand @fig-von-neumann, which shows a conceptual layout of a computer:

* A **processor** (e.g., a **Central Processing Unit**, or CPU), responsible for computing. Inside the processor, there is a **control unit** and a **data path**. The main elements of the data path are the **registers** and the execution unit, typically called the **Arithmetic Logic Unit** (ALU). We will discuss all these details soon.
* **Main memory**, responsible for long-term data storage.
* **I/O Devices**, i.e., Input/Output Devices like keyboards, displays, etc.

:::{figure} ../great-ideas/images/von-neumann.png
:label: fig-von-neumann
:width: 100%
:alt: "TODO"

Basic computer layout (specifically, the [von Neumann architecture](https://en.wikipedia.org/wiki/Von_Neumann_architecture)).
:::

## Registers

Importantly, the processor is designed to be _fast_. Four example, if a processor runs at 4 GHz, then it can execute instructions on some data once per cycle, or every 0.25 ns (nanoseconds). This data must also be physically located close to the processor!

Consider that the speed of light (approximately $3.0 \times 10^8$ m/s), which physically defines the fastest speed with which to access data from a certain physical location. In other words, accessing something about 10 cm away will already take 0.3 ns (thankfully most of our integrated chips are much smaller than this distance). Nevertheless, in all modern architectures we have at least two pieces of hardware for data:

* **Registers**, located within the processor itself. These hardware objects have limited space[^register-rv32] are lightning fast; a processor performs operation on these data using the arithmetic logic unit.
* **Memory**, which is much larger[^memory-laptop] and located external to the processor. Memory access is often assumed to take approximately 100 ns (@fig-3-locality). The processor communicates with memory by issuing addresses to read or write data. The "enable" signal additionally ensures we don't accidentally alter memory values when we only intend to read; we discuss this more later.

[^register-rv32]: 32 x 4B = 128 B of register data on a RV32 architecture.

[^memory-laptop]: 2-64 GB of memory on modern laptops.

:::{figure} ../great-ideas/images/3-locality.png
:label: fig-3-locality
:width: 100%
:alt: "TODO"

Great Idea 3: The Principle of Locality / Memory Hierarchy
:::

Because registers must be deep in the hardware and right next to the execution cores to remain fast, we cannot have an infinite number of them. They are expensive, and we have limited space on-chip (@fig-3-memory-hierarchy).

:::{figure} ../great-ideas/images/3-memory-hierarchy.png
:label: fig-3-memory-hierarchy
:width: 100%
:alt: "TODO"

Great Idea 3: The Principle of Locality / Memory Hierarchy
:::

## RISC-V Registers

Each ISA specifies a predetermined number of hardware registers, defining how each of the registers should be used for instruction execution. A compiler then maps C variables to RISC-V registers across declarations, function calls, etc. The RISC-V ISA specifies **32 registers**.

:::{note} Why 32 registers?

This choice feels arbitrary but follows a "Goldilocks" principle.[^goldilocks] Too many registers would slow the machine down and be extremely expensive. However, too few registers would require (among other things) extremely complicated compiler logic. 32 registers, at least for the RISC-V architects, was considered "just right."
:::

### Register size

We now return to the [hardware word](#sec-words) concept we discussed earlier in the course. The hardware word also determines **register size**. In the RV32I ISA we teach in this course, the word size is 32 bits. Each RV32I register is **32 bits wide**.

[^goldilocks]: From the [British fairy tale](https://en.wikipedia.org/wiki/Goldilocks_and_the_Three_Bears): "This porridge is too hot; This porridge is too cold; this porridge is just right."

### Register names and numbers

Unlike high-level languages like C or Java, there are no variables in assembly. Instead, to operate on data, assembly instructions use **register names** or **register numbers**.

Registers are numbered from 0 to 31. To refer to a register by number, an assembly instruction can specify `x0`, `x1`, ..., `x31`. Registers can also be referred to by names. These register names are specified by the ISA and facilitate conventions when writing assembly. We discuss more later.

(sec-x0)=
#### The Zero Register

For now, we define one very important register: register number `x0`, which has register name `zero`. This special [zero register](https://en.wikipedia.org/wiki/Zero_register) is hardwired to zero, and you cannot change its value. Contrary to intuition, it is extremely helpful to have a register-sized representation of zero handy for a multitude of operations. The RISC-V architects thought so too, and were willing to sacrifice one fewer data register in order to specify zero directly on the processor.

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

## Assembly Language vs. Higher-Level languages

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