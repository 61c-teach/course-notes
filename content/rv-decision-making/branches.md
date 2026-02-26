---
title: "Conditional Branches"
---

(sec-branches)=
## Learning Outcomes

* Write conditional statements in RISC-V.
* Use `bne` instructions for if-conditions that compare on equality.
* Differentiate between conditional branch instructions and unconditional jump instructions.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/OWxcAqFNkpo
:width: 100%
:title: "[CS61C FA20] Lecture 08.3 - RISC-V lw, sw, Decisions I: Decision Making"

Until 8:50
::::

In the past few chapters, we have learned how to use RISC-V as a calculator. We have learned [arithmetic](#sec-rv-arithmetic) and [bitwise](#sec-rv-bitwise) operations and [data transfers instructions](#sec-data-transfer) for accessing memory.
To support modern programming languages, however, we need to support **decision-making**–meaning, the computer should be able to _conditionally_ execute certain instructions based on the results of other instructions.

## Review: Control Flow

In C and higher-level languages, we specify decision-making with **control flow** syntax. Recall that in C, typically we execute statements sequentially. Control flow syntax creates structures that "jump" to other lines of code:

* `if` statements (and `if-else`, `if-else-elif`, etc.)
* `for` and `while` loops
* Function calls[^fn-call]

[^fn-call]: More later!

If we consider the processor as a central component, we **transfer** control to subsequent statements for their execution. Control flow can specify **conditional** or **unconditional** transfer to out-of-order statements. Consider the C code in @fig-c-control-flow:

:::{figure} images/c-control-flow.png
:label: fig-c-control-flow
:width: 60%
:alt: "TODO"

Illustration of unconditional and conditional control flow transfer.
:::

The conditional `if` statement conditionally executes Line 4 only if `n > 5`; otherwise, it executes the next statement, on Line 6. By contrast, the call to `foo` in Line 11 unconditionally transfers control to the first statement in `foo` on Line 2; then, when `foo` returns on Line 6, control unconditionally transfers back to Line 12.

(sec-branches-jumps)=
## Branches and Jumps

RISC-V implements control flow by changing the order of execution in the code. Specifically, such instructions **transfer control** by updating the [program counter](#sec-program-counter) not to the next instruction as is the default, but _another_ instruction. There are two types[^philosophy] of such instructions in RV32I: **unconditional jumps** and **conditional branches**.

[^philosophy]: If jumps are defined as unconditional, are there _conditional_ jumps? What about _unconditional_ branches? Both of these can probably be defined using the other, and you will see this overlap in terminology in lecture, in conversation, and in the literature. The [RISC-V ISA](https://docs.riscv.org/reference/isa/unpriv/rv32.html#2-6-control-transfer-instructions) is careful to refer to both "control transfer instructions" and, in almost all cases, associates the adjectives "unconditional" and "conditional" solely with "jump" and "branch," respectively.

**Unconditional jump**. Always set PC to a different instruction. We introduce the primary jump instruction here:

```bash
j Label
```

When run, this instruction will unconditionally **J**ump to the instruction labeled `Label`.

**Conditional branch**. Condition on the comparison of two register values. If the condition is met, set PC to a different instruction. Otherwise, the condition is not met, so set PC to the next instruction. The general format for branch instructions is `bxx rs1 rs2 Label`, where "`xx`" specifies the type of comparison to make.

(sec-labels)=
:::{hint} What are labels?
Labels are identifiers to specific lines of code (in C) or assembly instructions (in RISC-V). Labels do not themselves define a line of code, though they must have **unique names**. In assembly, labels are associated with specific instruction addresses. They are then used by the assembler to translate branch and jump instructions into their machine code counterparts.[^labels] 
[^labels]: More later.
:::

### Branch Example

How do we use branch instructions? Let's check out `beq` and `bne` in @tab-rv-beq-bne:

:::{table} Two RV32I conditional branch instructions.
:label: tab-rv-beq-bne
:align: center
| Instruction | `beq rs1 rs2 Label` | `bne rs1 rs2 Label` |
| :--: | :--- | :--- |
| Mnemonic | **B**ranch if **eq**ual | **B**ranch if **n**ot **e**ual |
| Comparison condition | Register values are equal:<br/>`R[rs1] == R[rs2]` | Register values are not equal:<br/>`R[rs1] != R[rs2]` |
| Condition is met | `PC = <addr of Label>` |  `PC = <addr of Label>` |
| Condition is not met | `PC = PC + 4` | `PC = PC + 4` |

:::

:::{hint} 
For readable, efficient RISC-V programs, you may need to **negate the branch** condition.
:::

Consider the two examples below, which assume the following mapping of C integer variables to registers:

```bash
x    y    z    i    j
x10  x11  x12  x13  x14
```

(sec-branch-ex1)=
:::{tip} Example 1

```{code} c
:linenos:
if (i == j) {
  x = y + z;
} else {
  x = y - z;
}
// …
```

Two reasonable translations of this code to RISC-V assembly are below and leverage two instruction labels, `If` and `End`.

```bash
# Choice A
       beq x13 x14 If
       sub x10 x11 x12
       j End
If:    add x10 x11 x12
End:   # …
```

Choice A uses `beq`. If `i` and `j` are equal, jump to the `If` label to execute the conditional `add` instruction. Otherwise, the processor naturally moves to the "else" condition, which is the `sub` instruction, after which it unconditionally jumps with `j End` to skip over the `If`-labeled instruction.

```bash
# Choice B
       bne x13 x14 Else
       add x10 x11 x12
       j End
Else:  sub x10 x11 x12
End:   # …
```

Choice B uses `bne` to _invert_ the inequality condition in Line 1 of the C code. If `i` and `j` are not equal, _skip_ the conditional `add` instruction, and go to the `Else` label to execute the `sub` instruction. If the branch is _not_ taken (`i` and `j` are equal), then the processor naturally moves into the next instruction—the `add`, which is exactly what we want–and unconditionally jumps with `j End` to skip over the `Else`-labeled instruction.
:::

(sec-branch-ex2)=
:::{tip} Example 2

```{code} c
:linenos:
if (i == j)	{
	x = y + z;
}
// …
```

```bash
# Choice A
       beq x13 x14 If
       j End
If:    add x10 x11 x12
End:   # …
```

```bash
# Choice B
       bne x13 x14 End
       add x10 x11 x12
End:   # …
```

Again, both choices are valid. Again, Choice B uses `bne` and more closely represents the original C structure. Choice B also produces fewer instructions and will be better for performance in the long run.
:::

## Branch Instructions Summary

@tab-rv-branch lists the conditional branch instructions from the [RISC-V green card Control table](#tab-rv32i-control):

:::{table} RV32I conditional branch instructions.
:label: tab-rv-branch
:align: center

| Instruction | Name/Description |
|:--- |:---|
| `beq rs1 rs2 Label` | Branch if Equal |
| `bne rs1 rs2 Label` | Branch if Not Equal |
| `blt rs1 rs2 Label` | Branch if Less Than (signed) (rs1 < rs2) |
| `bge rs1 rs2 Label` | Branch if Greater or Equal (signed) (rs1 >= rs2) |
| `bltu rs1 rs2 Label` | Branch if Less Than (unsigned) |
| `bgeu rs1 rs2 Label` | Branch if Greater Than or Equal (unsigned) |
:::

This set[^mnemonic] is sufficient to describe the C comparators: `==`, `!=`, `>`, `<`, `>=`, `<=` for signed and unsigned integers. From the [RV32I Specification](https://docs.riscv.org/reference/isa/unpriv/rv32.html#2-6-2-conditional-branches):

[^mnemonic]: Here is Professor Bora Nikolic's tip for remembering which branch instructions are supported: "There exists a BLT sandwich (Bacon, Lettuce, Tomato), but I have never seen a BGT sandwich."

> Note, BGT, BGTU, BLE, and BLEU can be synthesized by reversing the operands to BLT, BLTU, BGE, and BGEU, respectively.

In other words, `bgt`, `bgtu`, `ble`, `bleu` are pseudoinstructions! We leave their translation as an exercise to you :-)

We have also discussed one jump **pseudo**instruction in @tab-rv-jump. We will explain this pseudoinstruction in more detail in a [future section](#sec-jumps).

:::{table} RV32I unconditional jump pseudoinstruction
:label: tab-rv-jump
:align: center

| Instruction | Name/Description |
|:--- |:---|
| `j Label` | Unconditional jump |

:::


<!--
| Instruction | Name/Description |
|:--- |:---|
| <pre># Choice B<br/>bne x13 x14 End<br/>add x10 x11 x12<br/>End:   # …</pre> | asdf | -->