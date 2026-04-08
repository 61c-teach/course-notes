---
title: "GDB Guide"
---
Here are the key commands from this lab. **You will need these throughout the semester** --- especially for project debugging.

> **Tip:** Pressing **Enter** without typing a command repeats the last command you ran. This is especially useful with `s` and `c` --- just keep pressing Enter to keep stepping or continuing.

## Views
The **TUI** transforms GDB from a simple command line into a visual debugger. Use these commands to see your code, assembly, and registers in real-time as you step through a program.

### Example:
Let's walk through example program `count_ones.s ` which will count the number of ones in a numbers binary represention (full code in appendix). Once you open it with gdb we get this output. `debug.sh` will automatically add a breakpoint to the `main` function. We get this output:
```bash
Reading symbols from count_ones...
The target architecture is set to "riscv:rv32".
0x00001000 in ?? ()

Program received signal SIGTRAP, Trace/breakpoint trap.
main () at count_ones.s:7
7	    la t3, n # load the address of the label n
(gdb)
```

We then can run `layout split` and we can see both the source RISC-V code and the disassemly of the instructions. The dissasembler will show the PC (memory address of the instructions) and the instructions themselves. There may be some changes in the disassembler, for example:
```s
# Original Instructions
la      t3 n

# Disassmbled Instructions
auipc	t3,0x13
addi	t3,t3,-436

# Original Instructions
beq     t3, x0, zero_case

# Disassmbled Instructions
beqz    t3, 0x10210 <zero_case>
```

Running `layout asm` will show only the assembly code (not the original source code) and running `layout regs` will show the assembly and the values of all the regs. As you step through the program the registers will update.

:::{figure} images/gdb-layout-split.png
:label: gdb-layout-split
:width: 100%
:alt: "TODO"
:::

<!-- :::{figure} images/gdb-start.png
:label: gdb-start
:width: 100%
:alt: "TODO" -->

| Command | Description |
|---------|-------------|
| `layout split` | Source + disassembly side by side |
| `layout regs` | Registers + assembly |
| `layout asm` | Assembly only |
| `tui disable` | Exit the TUI views |



## Stepping
Now we can step through the code instruction-by-instructions. `step` or `s` will step **into** each instructions and function calls. `next` or `n` will move to the next and instruction and skip over functions calls. 

**Note:** In this class, we will skip over `ecall`s and `printf` statments, so you cannot step into them.

| Command | Shortcut | Description |
|---------|----------|-------------|
| `step` | `s` | Execute one instruction (steps over runtime helpers) |
| `next` | `n` | Execute one instruction, stepping over all function calls |
| `continue` | `c` | Resume execution until next breakpoint |

## Breakpoints

Normally, your program only stops when it exits. Breakpoints allow you to pause your program's execution wherever you want, be it at a function call or a particular line of code, and examine the program state.

Before you start your program running, you want to set up your breakpoints. The `break` command (shorthand: `b`) allows you to do so.

### Example:
TODO

### Condtional Breakpoints:
TODO

| Command | Shortcut | Description |
|---------|----------|-------------|
| `break <line>` | `b <line>` | Break at a source line number (e.g., `b 12`) |
| `break <label>` | `b <label>` | Break at a label (e.g., `b fib`) |
| `break *0x<addr>` | `b *0x<addr>` | Break at a specific address |
| `delete` | | Delete all breakpoints |
| `delete <n>` | | Delete breakpoint number `n` |
| `info breakpoints` | | List all breakpoints |


## Registers

**`info` command:**

TODO

**`print` command:**

TODO

| Command | Shortcut | Description |
|---------|----------|-------------|
| `info registers` | `info reg` | Show all registers |
| | `info reg t0` | Show just `t0` |
| | `info reg t0 t1 t2` | Show multiple specific registers |
| `print/x $a0` | `p/x $a0` | Print register in hex |
| `print/d $a0` | `p/d $a0` | Print register in decimal |
| `print/t $a0` | `p/t $a0` | Print register in binary |

## Examine Memory --- the `x` command

The full format is `x/NFU` where **N** = count (default 1), **F** = format, **U** = unit size.

Formats: `x` hex, `d` signed decimal, `i` instruction, `s` string, `t` binary

Unit sizes: `b` byte, `h` halfword, `w` word
When you just want one value, you can leave out **N**:

### Example:

| Command | Description |
|---------|-------------|
| `x/xw $pc` | Machine code of current instruction (one hex word) |
| `x/dw <addr>` | Read an integer at an address (one signed decimal word) |
| `x/xb <addr>` | One byte in hex at an address |
| `x/4xw $sp` | 4 words in hex at stack pointer |
| `x/10i $pc` | Disassemble 10 instructions from current PC |


## Miscellaneous

| Command | Description |
|---------|-------------|
| `disassemble <label>` | Disassemble a whole function/label |
| `quit` | Exit GDB |


## Appendix
Full `count_ones.s` code, adapted from [Su24 Exam Question](https://inst.eecs.berkeley.edu/~cs61c/exams/pdfs/su24-final-blank.pdf#page=4)

```{code} s
:linenos:
.data
n: .word 12

.text
.globl main
main:
    la t3, n # load the address of the label n
    lw a0, 0(t3) # get the value that is stored at the address denoted by the label n
    jal count_ones
    jal print_int
    li   a0, 0
    jal  exit

count_ones:
    beq a0, x0, zero_case
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s7, 4(sp)
    slt s7, a0, x0
    slli a0, a0, 1
    jal ra, count_ones
    add a0, a0, s7
    lw ra, 0(sp)
    lw s7, 4(sp)
    addi sp, sp, 8
    jr ra
zero_case:
    li a0, 0
    jr ra
```

