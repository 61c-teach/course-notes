---
title: "C vs. Java"
---


## Learning Outcomes

* Use a "Hello World" program to intuit C program structure.
* Do a cursory comparison of C and Java.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/A6ELzsvVEnE?si=PjlUZ4Aisa0PJjle
:width: 100%
:title: "[CS61C FA20] Lecture 03.3 - C Intro: C v. Java and C Syntax"
:::

::::

## Hello World

(hello_world_c)=
:::{card}
C program: `hello_world.c`
^^^

```c
#include <stdio.h>
int main(int argc, char *argv[]) {
  printf("Hello World!\n");
  return 0;
}
```

:::

(hello_world_java)=
:::{card}
Java program: `hello.java`
^^^

```java
public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello world!");
  }
}
```

:::

### Highlights

* In C, we import libraries using `#include`. Here, we include `stdio` for `printf()`, which prints to stdout (here, the command-line).
* There is a `main` function.
  * C is **function-oriented**; unlike Java, this is not an object's method.
  * The return type of `main` is not `void`; it's an integer.
  * By convention, C programs return `0` on success. (The main rationale is it is easier to check equality to zero; we return to this soon)

### Run Demo

The below instructions are mostly for reference.  Refer to [this section](#compile-vs-interpret-sec) to understand details.

:::{note} Compile and run C
:class: dropdown

To run this program, use the command-line program, `gcc`, to compile the program. This creates a binary program with the default name `a.out` ([why the naming?](https://en.wikipedia.org/wiki/A.out#:~:text=out%20is%20a%20file%20format,'s%20PDP%2D7%20assembler.)). Then, run the binary program.

```bash
$ gcc hello_world.c
$ ./a.out
Hello World!
```

In practice, rename the binary to something more meaningful, like `hello_world`:

```bash
$ gcc -o hello_world hello_world.c
$ ./hello_world
Hello World!
```

You will also find it useful to generate debugging symbols for `gdb`, our debugger.

```bash
$ gcc -d -o hello_world hello_world.c
$ gdb hello_world
```

:::

(c-vs-java-sec)=
## C vs. Java

@tbl-c-vs-java below is adapted from the [C Programming vs. Java Programming](https://introcs.cs.princeton.edu/java/faq/c2java.html) table, created for Princeton University's introductory CS sequence. Hover over the footnote for more information about each row.

:::{table} (a) C vs. Java; (b) similar operators
:label: tbl-c-vs-java
:align: center

| Feature | C | Java |
| :--- | :--- | :--- |
| Language Paradigm[^language-paradigm] | Function Oriented (programming unit: function) | Object Oriented (programming unit: Class = Abstract Data Type) |
| Compilation[^compile-vs-interpret] | `gcc hello.c` creates machine language code | `javac Hello.java` creates Java virtual machine language bytecode |
| Execution[^compile-vs-interpret] | `./a.out` loads, executes program | `java Hello` interprets bytecodes |
| Dynamic Memory Management[^dmm] | Manual (malloc, free) (more later) | Automatic garbage collection; new both allocates and initializes |
| Variable declaration | Typed declaration; declare before you use it | (same) |
| Function declaration | Use curly braces. `void` means no return value | (same) |
| Accessing a library | `#include <stdio.h>` | `import java.util.*` |
| Comments | Multiline: `/* ... */`, end-of-line: `// ...` | (same) |

| Operator | C and Java |
| :--- | :--- |
| arithmetic | `+`, `-`, `*`, `/`, `%` |
| assignment | `=` |
| augmented assignment | `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `\|=`, `^=`, `<<=`, `>>=` |
| bitwise logic | `~`, `&`, `\|`, `^` |
| bitwise shifts | `<<`, `>>` |
| boolean logic | `!`, `&&`, `\|\|` |
| equality testing | `==`, `!=` |
| subexpression grouping | `()` |
| order relations | `<`, `<=`, `>`, `>=` |
| increment and decrement | `++`, `--` |
| member selection[^member-selection] | `.`, `->` |
| conditional evaluation[^conditional-evaluation] | `? :` |
:::

[^language-paradigm]:
    Java is an object-oriented language; C is mostly a functional language. In C, the core idea is the function, whereas in Java, it’s the class or abstract data type. While it is possible to write object-like code in C, if programs required objects then you should really be using C++.
  
[^compile-vs-interpret]:
    We've discussed this in detail in a [previous section](#compile-vs-interpret-sec).

[^dmm]:
    Java manages memory for you with garbage collection. In C, all the safety belts and padded rooms are gone; you do all the memory management yourself, and you can get in trouble very quickly. More next time.

[^member-selection]: Slightly different than Java because there are both structures and pointers to structures, more next time

[^conditional-evaluation]: `cond ? body_true : body_false`

We highlight some more differences below.

**1. Variable naming convention**: In C, use `snake_case`[^snake-case], NOT `camelCase` [^camelcase].

[^snake-case]: [Wikipedia](https://en.wikipedia.org/wiki/Snake_case)

[^camelcase]: [Wikipedia](https://en.wikipedia.org/wiki/Camel_case)

**2. Command-line arguments**: In our [`hello_world.c`](#hello_world_c) program, the `main` function can take in command-line arguments with two parameters:

* `argc` is an integer count of how many arguments you have. The executable itself counts as one argument. If you run something like `./hello_world my_file`, `argc` is `2`.
* `argv`: is a pointer to an array of the arguments themselves, as C strings. We discuss pointers, arrays, and strings in more detail next time. For now, if you run `./hello_world my_file`, the first[^zero-index] argument is the name of the program itself (`hello_world`) and the second argument is the string `my_file`.

[^zero-index]: Like Python, C arrays and string are zero-indexed.

**3. Curly braces**: The C language allows for some omission of curly braces for single-line statements—even for control structures like if-else and for. This is the same as in Java, but we didn't tell you. :-)

But just because you can, doesn't mean you should. Because subsequent lines the control structure are considered outside of the body, omitting curly braces leads to many debugging errors[^curly-braces]:

[^curly-braces]: Stack Overflow: [Is it a bad practice to use an if-statement without curly braces?](https://stackoverflow.com/questions/2125066/is-it-a-bad-practice-to-use-an-if-statement-without-curly-braces)

:::{card}
**Omitting curly braces**: Which lines are printed?
^^^

```c
#include <stdio.h>
int main(int argc, char *argv[]) {
    int x = 0;
    if (x == 0)
        printf("x is 0\n");
    if (x != 0) // careful!
        printf("x not 0 line 1\n");
        printf("x not 0 line 2\n");
    return 0;
}
```

:::