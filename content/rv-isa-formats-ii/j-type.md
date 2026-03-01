---
title: "J-Type"
subtitle: TODO
---

(sec-j-type)=
## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/hkVUmw460Kw
:width: 100%
:title: "[CS61C FA20] Lecture 12.3 - RISC-V Instruction Formats II: J-Format"
:::

::::

More coming soon!

## Conditionally Branching Far Away

Conditional Branches are typically used for if-else statements, for/while loops. In general, because these control structure are usually _pretty small_ (<50 lines of C code), we can use **B-Type instructions**. However, as we saw earlier, B-Type instructions have limited range: $\pm 2^{10}$ instructions from the current instruction (PC).

To jump even further, we can use **J-Type unconditional jumps** in combination with B-Type instructions.

:::{note} `beq x10 x10 far`

To branch to a far location, e.g., `beq x10 x10 far`, we can equivalently specify the assembly with one more instruction:

```{code}bash
    bne  x10 x0 next
    j far
next:
    # next instr
```
:::

Admittedly, J-Type instructions also have a limited range: $\pm 2^{18}$ instructions from the currrent insturction (PC).

If we wanted to jump to **any** address, RISC-V opts for jumping with [absolute addressing](#sec-absolute-addressing) and `jalr`. As discussed in a [previous section](#sec-jalr-itype), `jalr` is an I-Type instruction that sets PC to `PC = R[rs1] + imm`, where `imm` specifies a 12-bit immediate `imm`.

* To call functions with absolute addressing, instead of `jal ra Label`[^simultaneous]:

    ```{code} bash
    lui  ra <hi20bits*>
    jalr ra ra <lo12bits>
    ```

[^simultaneous]: The `jalr` instruction will save the jump address to the PC and save the current `PC + 4` to the `ra` in the same cycle (effectively, "simultaneously")

* To break out of loops using absolute addressing, instead of `j Label` (e.g., `jal x0 Label`):

    ```{code} bash
    auipc ra <hi20bits*>
    jalr  x0 ra <lo12bits>
    ```

See the discussion of [U-Type instructions](#sec-u-type) `lui` and `auipc`. Just like with resolving [`li` pseudoinstructions](#sec-li-lui), `jalr` sign-extends immediates. So if `lo12bits` has sign bit set, increment `hi20bits` by 1.

<!--

## Visuals



:::{figure} images/jal-isa.png
:label: fig-jal-isa
:width: 100%
:alt: "TODO"

jal instruction format.
:::

|   |   | opcode |   |
| :-- | -- | -- | --: |
| `imm[20\|10:1\|11\|19:12]` | `rd` | `1101111` | `jal` |

---
title: "A Bit About Machine Program"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO


TODO: unconditional branch "definition" -- include this later when we discuss instruction formats

You might wonder if you can just make an unconditional branch using a conditional one, like beq x0, x0, label. While that would always jump, there is a catch: the range of a branch is shorter. Because RISC-V uses 32-bit instructions, we have to fit the instruction type, the registers being compared, and the label (an immediate value) into those 32 bits. A dedicated jump instruction doesn't need to specify registers to compare, so its immediate value can be larger, allowing it to reach farther in the program.

-->