---
title: "Interpretation vs Translation"
subtitle: "This content is not tested"
---

## Learning Outcomes

This section is included as bonus content and is not tested. If you are curious about these concepts, take CS 164: Compilers and Programming Languages!

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/DFEe0uRAm7o
:width: 100%
:title: "[CS61C FA20] Lecture 13.1 - Compilation, Assembly, Linking, Loading: Interpretation vs Translation"
:::

::::

## Language Execution Continuum

Interpretation and translation are two ways to running a program written in a specific source language.

* **Interpretation**: Directly executes a program in the source language. An interpreter is a program that executes other programs.
* **Translation**: Converts a program from the source language to an equivalent program in another language. Translating/compiling to lower-level languages almost always means higher efficiency, higher performance.

In general, we **interpret** a high-level language when efficiency is not critical. We **translate** to a lower-level language to increase performance. The latter is what we typically do with C code; we translate it into machine code and store it as an executable.

Consider @fig-language-continuum. On the left are higher-level languages; on the right are lower-level languages.

:::{figure} images/language-continuum.png
:label: fig-language-continuum
:width: 100%
:alt: "TODO"

Language execution continuum.
:::

* **Python**: On the far left, Python is incredibly easy to write in but is fully interpreted and therefore the slowest.
* **Java**: This is a bit harder to write than Python. Java isn't a fully interpreted language; you compile it down to bytecode and then interpret that bytecode, allowing it to run on many machines.
* **C**: Somewhere in the middle. C is considered a high-level language but is not as easy to work with as others (as we have seen); nevertheless, when compiled down it is much faster.
* **Assembly and Machine Code**: On the far right, is machine code–what people had to work in back in the early days of the computer (see the [EDSAC](#sec-stored-program)). [As we have seen](#sec-machine-instructions), machine code is hard to write by hand but very easy to interpret–because there is pretty much no interpretation! Machine code can be executed directly on the hardware.

### Interpretation

You may be familiar with Python, which is a high-level interpreted language. The Python interpreter is just a program that reads a Python program `foo.py` and performs the functions of that Python program, generating output as needed.

:::{figure} images/python-interpreter.png
:label: fig-python-interpreter
:width: 50%
:alt: "TODO"

Python interpreter.
:::

Why would you ever interpret machine code in software? C programs and even RISC-V are also interpreted under specific circumstances.

One reason is **simulation**; for example, in Venus, we have a RISC-V simulator where you can take assembly and interpret it to get much more debugging information. The Venus simulator helps us learn RISC-V because we can step through the machine code.

Another reason is **conversion** of a program from one ISA to another ISA. Consider the Apple Macintosh ISA conversion back in the day. Apple moved from 680x0 ISA to PowerPC, then to x86 (and now to ARM). Instead of requiring all programs to be re-translated from a high-level languages, instead the designers let executables contain old and/or new machine code, then **emulate**–by interpreting the old code in software if necessary. This slower process supported backward compatibility by  using software to interpret the old ISA onto the new hardware.

In 2020, Apple moved again onto an ARM-based Apple silicon. To support this transition, Apple released [Rosetta](https://support.apple.com/en-us/102527), an app that runs Intel-based apps on Apple chips. The link in the previous sentence uses the word "translation" quite liberally; we know now that this process is actually interpretatoni.

## Interpretation vs. Translation

From the point of view of the program, it doesn't know—and doesn't care—whether it is running on an interpreter (software) or raw silicon (hardware). When you give it an "add" instruction, it does the add. Nevertheless, there are a pros and cons to choosing interpretation vs. translation:

* **Implementation**: It is generally easier to write an interpreter; you may have done so in CS 61A (Structure and Interpretation of Computer Programs).
* **Debugging**: Interpreters are close to the high level, so you get great error messages and debugging support (see Venus). Translators can also support some debugging but requires encoding line numbers and variable names for debugging use; we will see this later.
* **Performance**: Interpreter is slower by about 10x or greater. Translation is almost always faster because it targets particular hardware.
* **Portability**: Code that can be interpreted is smaller and provides instruction set independence as it can be interpreted (and consequently run) on any machine.
* **Intellectual Property**: Translation/compilation helps “hide” the program “source” from the users.