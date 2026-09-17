---
title: "GDB Guide"
---

# Using GDB

## Views
The **TUI** transforms GDB from a simple command line into a visual debugger. Use these commands to see your code, assembly, and registers in real-time as you step through a program.

### Example
Let's walk through example program `count_ones.s ` adapted from [Su24 Exam Question](https://inst.eecs.berkeley.edu/~cs61c/exams/pdfs/su24-final-blank.pdf#page=4). This will count the number of ones in a numbers binary represention you can see full code in the dropdown:

::::{note} Full `count_ones.s` code
:class: dropdown

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
::::

Once you open it with gdb we get this output. `debug.sh` will automatically add a breakpoint to the `main` function. We get this output:
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

:::{figure} images/gdb-layout-split.png
:label: gdb-layout-split
:width: 100%
:alt: "TODO"
:::

Running `layout asm` will show only the assembly code (not the original source code) and running `layout regs` will show the assembly and the values of all the regs. As you step through the program the registers will update.

:::{figure} images/gdb-layout-asm.png
:label: gdb-layout-asm
:width: 100%
:alt: "TODO"
:::

:::{figure} images/gdb-layout-regs.png
:label: gdb-layout-regs
:width: 100%
:alt: "TODO"
:::



### Commands 

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

Before you start your program running, you want to set up your breakpoints. The `break` or `b` command allows you to do so. You can specfiy the line of the breakpoint using function name, line number, or address. If there are multiple files you can also use the file name. 

Example: 
```
(gdb) b 10
(gdb) b my_func
(gdb) b *0x10000
(gdb) b other_file.s:15
```
If you want to delete a breakpoint, just use the `delete` or `d` command and specify the breakpoint number to delete.

To delete the breakpoint numbered 2:
```
(gdb) delete 2
```
If you lose track of your breakpoints, or you want to see their numbers again, the info break command lets you know the breakpoint numbers:
```
(gdb) info break
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x000101e0         countone.s:15
```

### Condtional Breakpoints
You can also set breakpoints to only trigger when a certain condition is met. This is helpful when trying to debug something in a large loop. 

Command:
```
(gdb) break <line> if <condition>
```
For example:
```
(gdb) break 10 if $s0 == 0
```
*Note:* `$` is necessary when using register value in the condition

### Example
In our example we can run 
```
(gdb) b count_ones
```
Equivalently:
```
(gdb) b 15
(gdb) b *0x101e0
```
which will create a breakpoint at line 15 (the start of the `count_ones` function). See the `b+` on the left side of the display. Then run the `continue` or `c` command which will continuing running the program until the breakpoint is hit.

:::{figure} images/gdb-breakpoint-line15.png
:label: gdb-breakpoint
:width: 100%
:alt: "TODO"
:::

Next, if we run `layout regs` we will see the value of `a0` is `0xc`. If we run the `continue` command again, the program will run until the next call to `count_ones`. The the value of `a0`, `ra`, and `sp` all change. 

:::{figure} images/gdb-breakpoint-regs.png
:label: gdb-breakpoint-regs
:width: 100%
:alt: "TODO"
:::

We can run this command to break at the final recursive call of `count_ones`. (Be sure to run `d 1` so our original unconditional breakpoint is deleted)
```
(gdb) b count_ones if $a0 == 0
```

:::{figure} images/gdb-breakpoint-conditional.png
:label: gdb-breakpoint-conditional
:width: 100%
:alt: "TODO"
:::

### Commands 
| Command | Shortcut | Description |
|---------|----------|-------------|
| `break <line>` | `b <line>` | Break at a source line number (e.g., `b 12`) |
| `break <label>` | `b <label>` | Break at a label (e.g., `b fib`) |
| `break *0x<addr>` | `b *0x<addr>` | Break at a specific address |
| `delete` | | Delete all breakpoints |
| `delete <n>` | | Delete breakpoint number `n` |
| `info breakpoints` | | List all breakpoints |


## Registers

There are also 2 others ways to view values in registers. Using the `info registers` and `print` commands. 

**`info` command:**

```
(gdb) info registers
```

Equivalently:
```
(gdb) info reg
```

Will output the values of all the registers. It will output the regsister name, value in hex, and value in decimal. For registers that hold pointer values, the values will stay in hex and will show the offset to the closest preceding label.

:::{figure} images/gdb-info-reg.png
:label: gdb-info-reg
:width: 50%
:alt: "TODO"
:::

It is sometimes difficult to see the exact register value you need, you can also specify the register(s) you want to view with:
```
(gdb) info reg <reg 1> <reg 2> ...
```

For example:
```
(gdb) info reg a0
a0             0x1	1

(gdb) info reg sp t0 t1
sp             0x7ffffd90	0x7ffffd90
t0             0x1149c	70812
t1             0xf	15
```

**`print` command:**
You can also use the `print` or `p` command to print the value of a specific register. Where `f` is the specified print format. 

```
(gdb) print/<f> $<reg>
```

| Formats |  |
|---------|----------|
| `x` | print value as **hexadecimal** |
| `d` | print value as **signed decimal** |
| `u` | print value as **unsigned decimal** |
| `t` | print value as **binary** |
| `c` | print value as **char** |
| `a` | print value as an **address**, in hexadecimal and as an offset from the nearest preceding label |

For example:
```
(gdb) p/x $a0
$1 = 0xc

(gdb) p/d $a0
$2 = 12

(gdb) p/a $ra
$3 = 0x101d4 <main+16>
```

*Note: `$n` represents the `n`-th print that is done*

### Commands

| Command | Shortcut | Description |
|---------|----------|-------------|
| `info registers` | `info reg` | Show all registers |
| | `info reg t0` | Show just `t0` |
| | `info reg t0 t1 t2` | Show multiple specific registers |
| `print/<f> $a0` | `p/<f> $a0` | Print register in specified format |

## Examine Memory 

The examine `x` command is used for viewing memory contents at a given address. You can specify the format and size of the memory output.

The full format is `x/NFU` where **N** = count (default 1), **F** = format, **U** = unit size.

**Formats**: `x` hex, `d` signed decimal, `i` instruction, `s` string, `t` binary

**Unit sizes**: `b` byte, `h` halfword, `w` word

*Note: When you just want one value, you can leave out **N***

### Examples
The example below will print 16 words in hex starting at memory address `0x7ffffd90`
```
(gdb) x/16xw 0x7ffffd90
0x7ffffd90: 0x00000001 0x7ffffde0 0x00000000 0x0000000
0x7ffffda0: 0x00000009 0x000100f8 0x00000005 0x0000004
0x7ffffdb0: 0x00000004 0x00000020 0x00000003 0x7ffffe0
0x7ffffdc0: 0x00000006 0x00001000 0x00000017 0x0000000
```
Reminder: RISC-V is little endian so note the differences if we print 32 half-word starting at memory address `0x7ffffd90`
```
(gdb) x/32xh 0x7ffffd90
0x7ffffd90: 0x0001 0x0000 0xfde0 0x7fff 0x0000 0x0000 0x0000 0x0000
0x7ffffda0: 0x0009 0x0000 0x00f8 0x0001 0x0005 0x0000 0x0004 0x0000
0x7ffffdb0: 0x0004 0x0000 0x0020 0x0000 0x0003 0x0000 0xfe00 0x7fff 
0x7ffffdc0: 0x0006 0x0000 0x1000 0x0000 0x0017 0x0000 0x0000 0x0000
```

Below are more examples and their descriptions:
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

## Other GDB Tips
- Pressing **Enter** without typing a command repeats the last command you ran. This is especially useful with `s` and `c` --- just keep pressing Enter to keep stepping or continuing.
- If the graphical interface of gdb becomes distorted, type `Ctrl+L` to refresh it.
- By default, the arrow keys will scroll the assembly window. To switch the focus to the gdb
prompt so you can use the arrow keys to select previous commands, enter `focus cmd`. To
return focus to the assembly window, type `focus asm`.

# Apendix

## GDB Commands
| Command | Description |
|---------|-------------|
| `layout split` | Source + disassembly side by side |
| `layout regs` | Registers + assembly |
| `layout asm` | Assembly only |
| `tui disable` | Exit the TUI views |
| `step` or `s` | Execute one instruction (steps over runtime helpers) |
| `next` or `n` | Execute one instruction, stepping over all function calls |
| `continue` or `c` | Resume execution until next breakpoint |
| `info registers` or `info reg` | Show all registers |
| `info reg t0` | Show just `t0` |
| `info reg t0 t1 t2` | Show multiple specific registers |
| `print/<f> $a0` | `p/<f> $a0` | Print register in specified format |
| `x/xw $pc` | Machine code of current instruction (one hex word) |
| `x/dw <addr>` | Read an integer at an address (one signed decimal word) |
| `x/xb <addr>` | One byte in hex at an address |
| `x/4xw $sp` | 4 words in hex at stack pointer |
| `x/10i $pc` | Disassemble 10 instructions from current PC |
| `disassemble <label>` | Disassemble a whole function/label |
| `focus cmd` | Focus arrow keys and scrolling to the command line |
| `focus asm` | Focus arrow keys and scrolling to the assembly window |
| `quit` or `q` | Exit GDB |