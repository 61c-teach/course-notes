---
title: "Jumps and Stack Frames"
---

(sec-jump-rv-stack)=
## Learning Outcomes

* Identify use cases for unconditional jump instructions and pseudoinstructions–in particular, know how to jump to procedures and return from procedures.
* Compare RISC-V stack frames to C stack frames.
* Write RISC-V instructions that allocate and deallocate stack frames.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/XPlSOQKV8mM
:width: 100%
:title: "[CS61C FA20] Lecture 10.3 - RISC-V Procedures: Memory Allocation"
:::

::::
::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/XZAHwb7Smj0
:width: 100%
:title: "[CS61C FA20] Lecture 09.3 - RISC-V Decisions II: RISC-V Function Calls"
:::

9:10 onwards

::::

(sec-jumps)=
## Jump instructions

Transferring control between procedures simply means unconditional jumps to different program instructions. Notably, if one procedure (**caller**) calls another (**callee**), the callee must know how to **return** to the caller.

Recall that unconditional jumps are instructions that, when executed, set PC to a different instruction. We therefore need jump instructions that keep track of instruction **return addresses**.

:::{note} An important instruction pair

Use the register named `ra` (actually register number `x1`) with the following instructions:

* **Transfer control to procedure.** `jal ra fnLabel` to simultaneously save the return address in register `ra` and jump to the address of `fnLabel`, transferring control to the callee.
* **Return control to point of origin.** `jr ra` to jump to the return address, saved in register `ra`.

:::

Above, "save the return address" means to save the address of the **next instruction**, `PC + 4`, into the named register `ra`. "Jump to an address" means to update the `PC` so that on the next cycle, the computer executes a different, out-of-order instruction.

Let's discuss this in more detail below.

### Jump pseudoinstructions vs. real instructions

Unconditional jumps are not particularly tricky to understand (we hope). However, it is important to note that of their many use cases, there are only two **real** unconditional jump instructions shown in @tab-rv-jumps: `jal` and `jalr`. The rest (`jr`, `ret`, `j,` another `jal`) are **pseudoinstructions**.

:::{table} Unconditional jumps; see RISC-V green card for [Control](#tab-rv32i-control) and [Pseudoinstructions](#tab-rv32i-pseudoinstructions).
:label: tab-rv-jumps
:align: center

| Instruction or Pseudoinstruction | Name | Description | If pseudo, translation |
| --- | --- | --- | --- |
| `jal rd label` | Jump And Link | `R[rd] = PC + 4;`<br/>`PC = PC + offset` |  - |
| `jalr rd rs1 imm` | Jump And Link Register | `R[rd] = PC + 4;`<br/>`PC = R[rs1] + imm` | - |
| `j label` | Jump | `PC = PC + offset` | `jal x0 label` |
| `jal label` | Jump And Link (Pseudo) | `R[ra] = PC + 4`<br/>`PC = PC + offset` | `jal ra label` |
| `jr rs1` | Jump Register | `PC = R[rs1]` | `jalr x0 rs1 0` |
| `ret` | RETurn (`jr ra`) | `PC = R[ra]` | `jalr x0 ra 0` |

:::

There are two real instructions above.

**J**ump **a**nd **L**ink (`jal rd label`). Write the address of the **next instruction**, `PC + 4`, to register `rd`. Then perform an unconditional jump to `label` by setting `PC` to the address of the instruction with label `label`. The **linking** means that we form a link that can be used to return to the caller. (In this respect, `jal` should really be called "Link and Jump").

* Pseudoinstruction `j label` is used to implement conditional statements and loops, as discusssed in an [earlier section](#sec-branches). `jal x0 label` effectively discards the link/return addresss, because register `x0` is hardwired to zero.
* Pseudoinstruction `jal label` is expanded to `jal ra label`, where register name `ra` is the **return address** or register number `x1`. We discuss this reasoning below.

**J**ump **a**nd **L**ink **R**egister (`jalr rd rs1 imm`). Link the "return address" (`PC + 4`) to a register `rd`. Then perform an unconditional jump by setting `PC` to `R[rs1] + imm`.

* Pseudoinstruction `jr rs1` is instruction `jalr x0 rs1 0`, meaning that we discard the link and jump directly to the address in register `rs1`.
* Pseudoinstruction `ret` is instruction `jalr x0 ra 0` and is equivalent to `jr ra`. Discard the link and jump directly to the return address in named register `ra`.

:::{tip} Quick Check

Why have both `jal` and `jalr`?

:::

:::{note} Show Explanation
:class: dropdown

`jal` specifies a jump target by **label**. `jal` supports procedure calls because presumably, you should know the name of the procedure you are calling.

`jalr` specifies a jump target by **register**. `jalr` supports procedure returns because you don't necessarily know the name of procedure called you (nor should you expect that you were called at the beginning of said procedure); rather you should just know the address to return to. We will see in a later chapter how `jalr` facilitates jumps with *absolute addressing*.
:::

## `leaf` Function Example

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/THhKfRlQTyU
:width: 100%
:title: "[CS61C FA20] Lecture 10.1 - RISC-V Procedures: Function Call Example"
:::
::::

(sec-rv-stack)=
## RISC-V Stack Frames

In a [previous section](#sec-example-sp) we have already seen how we can store and load arrays to and from the stack. In this section we discuss how stack frames get allocated and deallocated between **function calls**.

When we discussed [the C stack](#sec-stack), we saw [an animation](#fig-c-stack-anim) that pushed and popped stack frames between function calls. Importantly:

> The stack grows downward. The stack pointer (`sp`) points to the top of the stack, i.e., the address of the current stack frame.

RISC-V stack frames (mostly) operate like C stack frames. As discussed in an [earlier section](#sec-register-conventions), the **stack pointer** holds the address of the top of the stack. By [RV32I register convention], this value is stored in the **`sp` register**, which is register number `x2`.

A RISC-V proedure can choose to use a stack frame by manipulating sp:

* When the callee gains control, set up in the **prologue** allocate/push the stack frame by **decrementing** `sp` (again, the stack grows downward).

* When the callee wraps up in the **epilogue**, deallocate/pop the stack frame by **incrementing** `sp`.

The slidedeck in @fig-rv-stack-anim animates allocation and deallocation on the stack via the stack pointer.

::::{figure}
:label: fig-rv-stack-anim
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vRmZPYooswNdpDJwrvmnf4LB5h0emERgb162lLWy88ytNPuWI-qcS0X_HiNt5XQgIPvtQ4Ed-6nW2I2/pubembed?start=false&loop=false
:width: 100%
:enumerated: false
:title: "Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1Ns11j8poIPDE7Bwg-qg5Dk6pokKuU-LdP_c8SwWpFTU/edit?usp=sharing)"
:::
An extended animation of stack memory management in RISC-V.
::::

:::{note} Explanation of @fig-rv-stack-anim
:class: dropdown

1. `main` allocates 12B of space for its stack frame by decrementing `sp` by `12`. This happens in the first line of `main`, implying that stack frame allocation is part of `main`'s prologue. From the perspective of `main`, the stack pointer `sp` holds `0xFFFFFFD4`, which is the bottom of `main`'s stack frame. At some point, `main` calls `fooA`.
1. In `fooA`'s prologue, `fooA` allocates 8B of stack space by decrementing `sp` by `8`. From the perspective of `fooA`, the stack pointer `sp` holds `0xFFFFFFCC`, which is the bottom of `foo`'s stack frame.
1. In `fooA`'s epilogue, it deallocates the same 8B of space by incrementing `sp` by `8`. Before returning with `jr ra`, `fooA` (as the callee) has restored `main`'s stack pointer to `0xFFFFFFD4`.
1. When `main` regains "control," it sees the right stack pointer, `0xFFFFFFD4`.

Across function calls, the caller `main`'s stack pointer is preserved. We discuss this register calling convention in [another section](#sec-rv-calling-convention).
:::

```{warning} Not all RISC-V procedures need stack space!

Some procedures have small local storage footprint; perhaps their equivalent C code uses just a few 32-bit variables. When translating these procedures, we can avoid expensive load/store memory operations and use [register conventions](#tab-calling-convention) to limit logic to volatile/temporary registers.
```

Like in C, pushing and popping stack frames simply corresponds to decrementing and incrementing the the stack pointer. A previous callee's data may therefore stay in memory that is marked as "free" for the next callee to scribble over it. Refer to the [C stack discussion](#sec-stack) for potential security issues.

