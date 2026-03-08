---
title: "Arithmetic Logic Unit"
subtitle: By John Wawrzynek, with edits by Lisa Yan
---

(sec-alu)=
## Learning Outcomes

* Design a basic Arithmetic Logic Unit (ALU).
* Use mux circuits in the ALU.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/oVc3yo3cZj8
:width: 100%
:title: "[CS61C FA20] Lecture 17.2 - Combinational Logic Blocks: ALU"
:::

::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/QFPvVUKTCFk
:width: 100%
:title: "[CS61C FA20] Lecture 17.4 - Combinational Logic Blocks: Subtractor Design"
:::

::::

Most processor implementations include a special combinational logic block called an arithmetic logic unit (ALU). In RISC-V, the ALU is used to compute the result in the R-type instructions, such as, `add`, `sub`, `and`, or `addi`, `ori`, etc.

## ALU Block

We are going to consider the design of a simpler version of the ALU than the one in our RISC-V processor. Ours will include only four basic functions:

* ADD
* SUB
* (bitwise) AND
* (bitwise) OR

This ALU is implemented as a combinational logic block in @fig-alu:

* two 32-bit wide data inputs, `A` and `B`;
* a 32-bit wide data output, `R`; and
* a 2-bit wide control input, `S`

:::{figure} images/alu.png
:label: fig-alu
:width: 55%
:alt: "TODO"

Basic ALU: ADD, SUB, AND, and OR
:::

:::{hint} What is the input S to an ALU?

S is a selector and is used to indicate which of the four possible operations the ALU is to perform (see [an earlier section](#sec-mux) on muxes). Typically, the S input will be controlled by the processor based on the operation of the instruction currently executing on the processor (for RISC-V R-type, the `func7` and `func3` fields).

:::

In our basic ALU, S is used to select R as one of the four operations:

```{math}
:label: eq-alu
:enumerated: true

\texttt{R} = 
\begin{cases}
\texttt{A + B} & \text{when } \texttt{S} = 00 \\
\texttt{A - B} & \text{when } \texttt{S} = 01 \\
\texttt{A \& B} & \text{when } \texttt{S} = 10 \\
\texttt{A | B} & \text{when } \texttt{S} = 11 \\
\end{cases}
```

## ALU Circuit

The internal design of our simple ALU is shown in @fig-alu-circuit:

:::{figure} images/simple-alu.png
:label: fig-alu-circuit
:width: 100%
:alt: "TODO"

Basic ALU circuit with three blocks (AND, OR, add/subtract) and a 4-to-1 mux.
:::

For our simple ALU we will need an add/subtract block, an AND block, and an OR block. Each of these blocks will take two 32-bit inputs and produce a 32-bit output. Read more about implementing these blocks [below](#sec-alu-internal).

:::{note} More Explanation
:class: dropdown

The high bit of `S` ($s_1$) and the low bit of `S` ($s_0$) are used to implement Equation @eq-alu:

* $s_1=0$: The add/subtract block
  * $s_0=0$: Specify add; note that $s_0$ is therefore used for both the MUX and the add/subtract block.
  * $s_0=1$: Specify subtract
* $s_1=1$: One of the AND or OR blocks
  * $s_0=0$: Specify AND
  * $s_0=1$: Specify OR
:::

:::{warning} In the ALU, all results are computed but exactly one is selected.

A common way to implement an ALU is to provide an instance of a combinational logic block for each of the possible ALU functions. The inputs, A and B, get distributed to all the blocks, and the output of the
proper block is selected with a mux.

In this configuration, every function of the ALU is computed internally to the ALU on every cycle, but only one of the results is sent to the output.

:::

(sec-alu-internal)=
### Implementing the Internal Blocks

The logical operations as defined by the RISC-V ISA are bitwise operations.

* AND: $r_i$, is $a_i$ `&` $b_i$, for the $i$-th bits of the output `R`, `A`, and `B`, respectively. Perform this bitwise operation as a collection of 32 AND gates, where each AND gate is responsible for one of the 32 resultant bits.
* OR: Similarly, the OR block is a collection of 32 OR gates.
* The add/subtract block is a significantly more complex block than the AND or OR blocks; its design is the subject of the [next section](#sec-adder-subtractor). For now, we note that a subtractor circuit is very similar to an adder, hence why we provide a single circuit that is capable of either operation.

case of the AND, the resultant bit ri is generated as ai AND bi. The circuit to perform this operation
is simply a collection of 32 AND gates. Each AND gate is responsible for one of the 32 resultant bits.
Similarly, the OR block is a collection of 32 OR gates.