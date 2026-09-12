---
title: "GDB Guide"
---
Here are the key commands from this lab. **You will need these throughout the semester** --- especially for project debugging.

# Using GDB

## Compiling and Opening GDB

## Views
The **TUI** transforms GDB from a simple command line into a visual debugger. Use these commands to see your code, assembly, and registers in real-time as you step through a program.

### Example:
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

Running `layout asm` will show only the assembly code (not the original source code) and running `layout regs` will show the assembly and the values of all the regs. As you step through the program the registers will update.

:::{figure} images/gdb-layout-split.png
:label: gdb-layout-split
:width: 100%
:alt: "TODO"
:::

**TODO: layout split and layout regs images**

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

### Condtional Breakpoints:
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

### Example:
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

TODO: add image

Next, if we run `layout regs` we will see the value of `a0` is `0xc`. If we run the `continue` command again, the program will run until the next call to `count_ones`. The the value of `a0`, `ra`, and `sp` all change. 

TODO: add image

Then run this command to break at the final recursive call of `count_ones`. (Be sure to run `d 1` so our original unconditional breakpoint is deleted)
```
(gdb) b count_ones if $a0 == 0
```

TODO: add image

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

## Backtrace

TODO

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
- To continue execution after pausing at breakpoint, type `c` or `continue`.

# Apendix

## GDB Commands
| Command | Shortcut | Description |
|---------|----------|-------------|
| `layout split` | | Source + disassembly side by side |
| `layout regs` | | Registers + assembly |
| `layout asm` | | Assembly only |
| `tui disable` | | Exit the TUI views |
| `step` | `s` | Execute one instruction (steps over runtime helpers) |
| `next` | `n` | Execute one instruction, stepping over all function calls |
| `continue` | `c` | Resume execution until next breakpoint |
| `info registers` | `info reg` | Show all registers |
| | `info reg t0` | Show just `t0` |
| | `info reg t0 t1 t2` | Show multiple specific registers |
| `print/x $a0` | `p/x $a0` | Print register in hex |
| `print/d $a0` | `p/d $a0` | Print register in decimal |
| `print/t $a0` | `p/t $a0` | Print register in binary |
| `x/xw $pc` | | Machine code of current instruction (one hex word) |
| `x/dw <addr>` | | Read an integer at an address (one signed decimal word) |
| `x/xb <addr>` | | One byte in hex at an address |
| `x/4xw $sp` | | 4 words in hex at stack pointer |
| `x/10i $pc` | | Disassemble 10 instructions from current PC |
| `disassemble <label>` | | Disassemble a whole function/label |
| `quit` | | Exit GDB |
TODO: focus and bt
