---
title: "Pointers and Bugs"
---

(sec-pointers)=
## Learning Outcomes

* Know C pointer syntax, including struct pointer syntax.
* Know what the `NULL` pointer is and why having a `NULL` pointer is useful
* Understand that because C is **pass-by-value**, pointers facilitate updates to values in memory when performing function calls.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/tS3MOTQraL4
:width: 100%
:enumerated: false
:title: "Lecture 04.1 - C Intro: Pointers, Arrays, Strings: Pointers and Bugs"
:::
1:39 - 4:22
::::

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/LvewxVYZ2vg
:width: 100%
:enumerated: false
:title: "[CS61C FA20] Lecture 04.2 - C Intro: Pointers, Arrays, Strings: Using Pointers Effectively"
:::
::::

As we shall see in this section, pointers are incredibly powerful abstractions that help make C efficient. But with power comes great responsibility and lots of bugs. In this section, we will first get familiar with pointer syntax in C in order to understand when and where bugs pop up.

## Pointer Syntax

(code-ptr-syntax)=
```{code} c
:linenos:
int *p;
int x = 3;
p = &x;
printf("p points to %d\n", *p);
*p = 5;
```

### [Lines 1-2](#code-ptr-syntax): Pointer Declaration

To declare a pointer, use the syntax:

```c
int *p;
```

This line tells the compiler that the variable `p` is the address of an `int`. Like with all C variables, uninitialized variables contain garbage, as represented with question marks in @fig-ptr-syntax-line1.


:::{figure} images/ptr-syntax-line1.png
:label: fig-ptr-syntax-line1
:width: 60%
:alt: "TODO"
Declare a pointer variable.
:::

### [Line 3](#code-ptr-syntax): The address operator, `&`

To get the address of any variable, use the syntax:

```c
p = &x;
```

The ampersand (`&`) is the **address operator**. Colloquially, we can describe Line 3 as "set `p` to point to `x`" or "set `p` equal to the address of `x`."

In @fig-ptr-syntax-line4, two visual cues show this assignment. First, there is a blue arrow going from the box for the variable `p` and pointing at the box for the variable `x`. Second, because diagram arrows don't particularly translate well into bits, the value of `p` has been updated to the address of `x`, or `0x104`.

:::{figure} images/ptr-syntax-line3.png
:label: fig-ptr-syntax-line3
:width: 60%
:alt: "TODO"

Set `p` to point to `x`.
:::

### [Line 4](#code-ptr-syntax): The dereference operator, `*`

Consider the next line:

```c
printf("p points to %d\n", *p);
```

We haven't discussed format strings in much detail. Briefly, `%d` marks an integer placeholder in the format string. `printf` then interprets the first parameter as an integer to put into the placeholder, then prints the updated string to stdout.

The star (`*`) is ([also](#deref-two-ways)) the **dereference operator**. Colloquially, dereferencing means that we follow the pointer and get the value it points to. As shown in @fig-ptr-syntax-line4, dereferencing `p` gets the integer value at `0x104`, which is the integer `3`.

:::{figure} images/ptr-syntax-line4.png
:label: fig-ptr-syntax-line4
:width: 60%
:alt: "TODO"

Follow the pointer `p`, i.e., access the value that `p` points to.
:::

The string printed to stdout is

```
p points to 3
```

### [Line 5](#code-ptr-syntax): Dereference and assign

The final line:

```c
*p = 5;
```

This syntax also uses the star `*` to dereference. Here, because it is on the left-hand-side of an assignment statement (`=`), C interprets Line 5 as **setting** the value that `p` points to. As shown in @fig-ptr-syntax-line5, this updates the value at `0x104` to the integer `5`.

:::{figure} images/ptr-syntax-line5.png
:label: fig-ptr-syntax-line5
:width: 60%
:alt: "TODO"

Update the value that `p` points to.
:::

Because this is a toy example, note that we could have also updated the value at `0x104` by assigning `x` to 3, e.g., `x = 3;`.
Up next, let's see cases in which values _must_ be updated with pointers.

(deref-two-ways)=
:::{warning} The star (`*`) is used in two ways:

* **Declaration**: Define the variable `p` as a pointer (Line 1)
* **Dereference**: Read (Line 4) or write (Line 5) the value pointed to by p
:::

## C is Pass-by-Value

The C programming language is **pass-by-value**, meaning that function parameters get a **copy** of the argument value.[^java-pass-by-value] While this property is useful to help evalute arguments before they are passed in as parameters, it restricts the values we can update.

[^java-pass-by-value]: Java is also pass-by-value, though we should note that in Java, variables holding objects are inherently object-handles, i.e., references. This distinction explains the behavior of primitive Java types vs. Java "objects" when passed in as arguments. See more on [Stack Overflow](https://stackoverflow.com/questions/40480/is-java-pass-by-reference-or-pass-by-value).

Consider the code. Updating the value of `x` within the `add_one` function does not update the value of `y` within `main`.

```{code} c
:linenos:
void add_one(int x) {
  x = x + 1;
}
int main() {
  int y = 3;
  add_one(y);
}
```

::::{note} Explanation
:class: dropdown

* Line 5: Declare a variable `y` and set its value to `3`.
* Line 6: Pass a copy of `y`'s value in and set it to the parameter `x` for the function `add_one`.
* Line 2: Update `x` to `x + 1`, i.e., set `x` to 4. Return from the function.
* Line 6, returned: the value at `y` is still `3`.

:::{figure} images/pass-by-value.png
:label: fig-pass-by-value
:width: 30%
:alt: "TODO"

`y` is not updated.
:::

::::

To change a value from within a subroutine, we must use pointers. Consider the updated code below. `main` passes in the _address_ of variable `y`, and `add_one` now has a pointer-typed parameter. The subroutine `add_one` now dereferences the pointer to modify the value at the original address of `y`.

```{code} c
:linenos:
void add_one(int *p) {
  *p = *p + 1;
}
int main() {
  int y = 3;
  add_one(&y);
}
```

::::{note} Explanation
:class: dropdown

* Line 5: Declare a variable `y` and set its value to `3`.
* Line 6: `add_one` now expects a pointer argument. Use the address operator (`&`) to get the address of `y` and pass that in. This is the value `0x100`, which gets set to the parameter `p`.
* Line 7:
  * Right-hand-side: Dereference `p` to get `3`, then add one to get `4`.
  * Left-hand-side: Assign the value pointed to by `p` to `4`, i.e., set the 4 bytes starting at address `0x100` to the bit-representation for the integer `4`. Return from the function.
* Line 6, returned: the value at `y` is now updated `4`. This is because `y` is located at memory address `0x100`, and the `add_one` subroutine updated the value at this address, in memory.

:::{figure} images/pass-by-value-ptr.png
:label: fig-pass-by-value-ptr
:width: 30%
:alt: "TODO"

`y` is updated from within the `add_one` function.
:::

::::

## Pointers: The Good, the Bad, and the Ugly

At the time C was invented (early 1970s), compilers didn’t produce efficient code, so C was designed to give human programmer more flexibility. Given the pass-by-value paradigm, it was much easier to pass a pointer to a function instead of a large struct or array.

Nowadays, computers are hundreds of thousands of times faster than early computers, and compilers are much more efficient. That being said, pointers are still incredibly useful for understanding low-level system code, as well as implementation of “pass-by-reference” object paradigms in other languages.

While pointers can often allow cleaner, more compact code, they are often the single largest source of bugs in C. Be careful! They surface most often when [managing dynamic memory](#sec-heap) and cause dangling references and memory leaks. Why? Because pointers give you the ability to access values in memory, _even when you shouldn't have access_.

### Garbage Addresses

Here's one example. Like all local variables in C, declaring a local pointer variable **does not initialize it**. It just allocates space to hold the pointer!

The example in @fig-garbage-addresses shows code that will compile (albeit with a few warnings). In this case, `ptr` is allocated to space that should be interpreted as an `int *`, or as an address that has an `int`. Whatever bytes are there at the time of declaration are then interpreted as the address to store the value `5` in. Your program then exhibits undefined behavior. Wacko!

:::{figure} images/garbage-addresses.png
:label: fig-garbage-addresses
:width: 60%
:alt: "TODO"

The bytes stored at `ptr` are interpreted as an address of an `int`. This code could potentially update `5` in a random part of memory.
:::

## Using Pointers Effectively

At this "point," we hope we haven't scared you. You should still look forward to playing with pointers, despite their rough edges! Let's discuss using pointers effectively.

### Pointers to Different Data Types

Pointers are used to point to a variable of a particular data type:

```c
int *xptr;
char *str;
struct llist *foo_ptr;
```

:::{note} Explanation
:class: dropdown

* `int *xptr` declares a variable called `xptr` that points to an `int`.
* `char *str` declares a variable called `str` that points to a `char`.
* `struct llist *foo_ptr` declares a variable called `foo_ptr` that points to a `struct llist`.
:::

Declaring the type of a pointer determines how the **dereferencing operator** (`*`) works, i.e., how many bytes to read/write when we "follow" pointers.

Normally a pointer can only point to one type. In a [future chapter](#sec-generics) we discuss the `void *` pointer, a **generic pointer** that can point to anything. In this course we will use the generic pointer sparingly to help avoid program bugs...and security issues...and other things... That being said, we will encounter generic pointers when working with memory management functions in the C standard library (`stdlib`).

We can also have pointers to functions, which we discuss in a [future chapter](#sec-generics). For now, if you are curious about the syntax:

```c
int (*fn) (void *, void *) = &foo;
(*fn)(x, y);
```

In the first line, `fn` is a function that accepts two `void *` pointers and returns an `int`. With this declaration, we set it to pointing to the function `foo`. The second line then calls the function with arguments `x` and `y`.

### `NULL` pointers

Regardless of pointer type, the pointer to the all-zero address is special. This is the `NULL` pointer, like Python's `None` or Java's `null`.

:::{figure} images/null.png
:label: fig-null
:width: 40%
:alt: "TODO"

The compiler resolves `NULL` to an address of all zeros, i.e., where all bits are 0.
:::

The address `0x0...0` is **reserved**, meaning that it is not permitted to read or write to that address; doing so causes a runtime error. While you may think that read/writing to a "null pointer" is bad news–because it causes your program to crash–this is actually incredibly useful as a "sentinel value." What we mean is that setting a pointer to `NULL` tells us that it doesn't point to a valid value in memory. 

Recall that the boolean value `false` is all zeros. This means that it is _very_ easy to check if a pointer is `NULL` or not! In the code below, `!p` will only resolve to `true` iff `p` is `NULL`.

```c
if(!p) { /* p is a null pointer */ }
if(q) { /* q is not a null pointer */ }
```

(sec-pointer-arithmetic)=
### Pointer Arithmetic

Pointers can handle some arithmetic operations: addition and substraction. You can increment or decrement pointers by integer values with a paradigm called **pointer arithmetic**.

In pointer arithmetic, the compiler uses the data type to determine how far to "stride" across memory to reach the next value. For example, if `ptr` is a pointer variable and you write `ptr + 5`, C will not always add 5 to `ptr`. Instead, C will add 5 times the size of the datatype that `ptr` points to. If ptr was an `int *` and `int`s take up 4 bytes in memory, `ptr + 5` adds 20 to the address held in ptr.

Remember that pointers store addresses of our byte-addressable memory:

* `ptr + n` adds `n*sizeof(*ptr)` bytes to the memory address stored in `ptr`.

* `pointer - n` subtracts `n*sizeof(*ptr)` bytes from the memory address stored in `ptr`.

Pointer arithmetic is particularly useful for accessing elements of arrays with [square-bracket indexing](#sec-array-indexing).

Note you cannot add two pointers together (what is it mean to add two addresses??), but you can subtract two pointers[^pointer-subtraction].

[^pointer-subtraction]: Pointer subtraction also depends on pointer type; read more on [StackOverflow](https://stackoverflow.com/questions/3238482/pointer-subtraction-confusion).

(foot-multiple-declarations)=
### Struct pointer syntax

We often like to use struct pointers because structs themselves can get quite large in size. There are a few useful pieces of "syntactic sugar" we use with structs and pointers.

The code below declares two pointers[^multiple-declarations] `ptr1` and `ptr2` to structs `coord1` and `coord2`, respectively:


[^multiple-declarations]: You may notice that Line 8 declares two pointers by mashing the `*` next to `ptr1` and `ptr2`, respectively. We didn't discuss it, but a single-declaration `coord_t* ptr1;` is also valid. Most modern C programmers try to avoid declaring multiple variables on a single line where possible. But you'll see it often in legacy C applications. Read more on [Reddit](https://www.reddit.com/r/cpp/comments/vm8bwm/how_do_you_declare_pointer_variables/).

```{code} c
:linenos:
typedef struct {
    int x;
    int y;
} coord_t;

/* declarations */
coord_t coord1, coord2;
coord_t *ptr1, *ptr2;

... /* instantiations go here... */

/* dot notation */
int h = coord1.x;
coord2.y = coord1.y;

/* arrow notation = deref + struct access*/
int k;
k = (*ptr1).x;
k = ptr1->x;  // equivalent
```

* The **dot operator** `.` is used to access struct members.
* The **arrow** notation `->` is "syntactic sugar" (i.e., shorthand) for a dereference (`*`) and access (`.`). Here, we get value of the `x` member of the struct pointed to by `ptr1`. 

::::{tip} Quick Check

Suppose that we start with the variable state shown in @fig-struct-pointers-q. What is the state after executing the below (compilable) code?

```c
/* This compiles, but what does it do? */
ptr1 = ptr2;
```

:::{figure} images/struct-pointers-q.png
:label: fig-struct-pointers-q
:width: 100%
:alt: "TODO"

Starting state before executing the line `ptr1 = ptr2;
:::

::::

::::{note} Show Answer
:class: dropdown

The state is updated to @fig-struct-pointers-choiceb. Colloquially, pointers `ptr1` and `ptr2` now point to the same struct in memory @ address `0x100`.

:::{figure} images/struct-pointers-choiceb.png
:label: fig-struct-pointers-choiceb
:width: 100%
:alt: "TODO"

Starting state before executing the line `ptr1 = ptr2;
:::

Sometimes it is easier to return to our definition of pointers as variables that store **addresses**. In this case, we are reading the value at `ptr2` (`0x100`) and storing it into `ptr1`.

::::

## Double Pointers ("Handles")

How might a function change the value of a **pointer**? Let's see a (natural but) faulty approach before a solution.

**A strawman[^strawman] approach**: Consider @code-pointer-handles-fail. Suppose that when compiled, the memory layout _before Line 10_ is in @fig-ptr-indexing.

[^strawman]: Wikipedia: [Straw Man](https://en.wikipedia.org/wiki/Straw_man)

(code-pointer-handles-fail)=
```{code} c
:linenos:
#include <stdio.h>

void increment_ptr(uint32_t *p) {
    p = p + 1;
}

int main() {
    uint32_t arr[] = {50, 60, 70};
    uint32_t *q = arr;
    increment_ptr(q);
    printf("*q is %d\n", *q);
  return 0;
}
```


:::{figure} images/array-indexing.png
:label: fig-ptr-indexing
:width: 80%
:alt: "TODO"

Memory layout before executing Line 10 in @code-pointer-handles-fail. We discuss arrays [later in this chapter](#sec-array).
:::

Print output: `*q is 50`

:::{note} Faulty: @code-pointer-handles-fail does not update `q`
Remember–C is **pass-by-value**. When we call `increment_ptr(q)`, the value of `q` gets passed in. As shown in the below diagram, this means that the parameter `p` gets a copy of q's value (the **address** `0x100`), then `p` gets updated to `0x104`. When the function returns, however, `q` remains unchanged.
:::

**A better approach**. The code in @code-pointer-handles-success fixes this issue by passing in a _pointer to a pointer_, also known as a **double pointer** or a **handle**. Running the below code will print: `*q is 60`.

(code-pointer-handles-success)=
```{code} c
:linenos:
#include <stdio.h>

void increment_ptr(uint32_t **h) {
    *h = *h + 1;
}

int main() {
    uint32_t arr[3] = {50, 60, 70};
    uint32_t *q = arr;
    increment_ptr(&q);
    printf("*q is %d\n", *q);
  return 0;
}
```

:::{figure} images/pointer-handles-success.png
:label: fig-pointer-handles-success
:width: 70%
:alt: "TODO"

@code-pointer-handles-success: Memory layout (top) during `increment_ptr` call and (bottom) after returning to `main`.
:::

:::{note} Success: @code-pointer-handles-success updates `q` with a double pointer

* Line 10, function call (@fig-pointer-handles-success, top): `&q` passes in the **address* of `q`, `0x120`, as the argument to `increment_ptr`.
* Line 3: The parameter `h` is assigned to `0x120`. `h` is a **double pointer**, meaning that following it twice should get us to a 32-bit unsigned integer:
  * `h` is the value `0x120`.
  * ("follow once") `*h` accesses the value at address `0x120`, which is itself an address, `0x100`.
  * ("follow twice") `**h` is `*(*h)`, which access the value at address `0x100`, which is the 32-bit unsigned integer `50`.
* Line 4, right-hand-side: `*h + 1` increments `0x100`, which is _typed_: it has an address of a 32-bit unsigned integer. Incrementing `0x100` therefore gives the next address of such a value, which is `0x104`.
* Line 4, left-hand-side: Assign the value `0x104` to whatever `h` points to, which is the value at `0x120`. In other words, the value at memory address `0x120` gets updated to `0x104`.
* Line 10, return (@fig-pointer-handles-success, bottom): The update in memory persists!
:::