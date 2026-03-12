---
title: "The Stack"
---

(sec-stack)=
## Learning Outcomes

* Understand how the stack pointer automatically allocates and deallocates stack frames.
* Understand when it is safe to pass pointers into the stack between functions.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/Keducx5bp-g
:width: 100%
:enumerated: false
:title: "[CS61C FA20] Lecture 05.3 - C Memory Management: Memory Locations"
:::

8:37 onwards
::::


## How the Stack Works

The Stack is a contiguous block of memory that starts from high addresses and grows downwards. Every time a function is called, a new **stack frame** is allocated on the stack as a contiguous block of memory. This stack frame includes space for the following:

* local variables declared within the function
* a **return address**, i.e., the instruction address in the text segment that should be next accessed after this function finishes execution [^stack-info]
* function arguments [^stack-info]

[^stack-info]: (same exact footnote as in an [earlier section](#sec-mem-layout)) Because parameters and return addresses are critical to function call and return, they are stored directly in the CPU where possible–on special hardware called registers (which we talk about later). Because there are only a limited number of such registers, additional parameters and return addresses are stored in memory on the stack until they are needed.

Allocation and deallocation is incredibly fast on the stack thanks to the **stack pointer**. The **stack pointer** is an internally tracked value[^sp-reg] that tells us the address of the "top of the stack", i.e., the start of the current frame, and thereby determins allocation and deallocation on the stack.

[^sp-reg]: The stack pointer itself must live somewhere. Instead of living in memory, it lives on the CPU in a special hardware register, so that it can be read and updated quickly. This is a detail we handwave for now and discuss in detail later.

The Stack segment manages stack frames like a stack data structure: **Last In, First Out (LIFO)**.
"_Grow_" the stack by moving the stack pointer down to a lower address, thereby pushing on a "new stack frame" (i.e., a new block of memory). "_Shrink_" the stack by moving the stack pointer back up to a higher address, thereby popping off the current stack frame.

In @fig-c-stack, notice the stack's **downward** growth means that `fooB()`’s local variables have lower byte addresses than the variables in its caller `fooA()`, and so on.

:::{figure} images/c-stack.png
:label: fig-c-stack
:width: 80%
:alt: "TODO"

The stack grows downward. The stack pointer (`sp`) points to the top of the stack, i.e., the address of the current stack frame.
:::

The slidedeck in @fig-c-stack-anim animates allocation and deallocation on the stack via the stack pointer.

::::{figure}
:label: fig-c-stack-anim
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vT4VF2QQM8HQDb84y2sg6Bie_PURuJfOZ5yyrFh3AWCJY2lay45Vqy33iN7XIrV1fO2tIb3G7590KcW/pubembed?start=false&loop=false
:width: 100%
:enumerated: false
:title: "Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/12ZVT3XK4WGY7nm_Z_9FKaTT1h6YxtwCu-sZMBnAROCc/edit?usp=sharing)"
:::
An extended animation of stack memory management in C.
::::

:::{note} Explanation of @fig-c-stack-anim
:class: dropdown

1. `main()` is called as soon as the program loads. One stack frame for `main` is allocated by moving stack pointer `sp` down to the start of this new frame (recall: blocks of memory are referred to by their lowest address).
2. `a(0)` is called by `main`. `sp` moves down. Local variables for `a` are initialized in stack memory starting from `sp` and going upwards. `sp` creates enough space to store local variables, whose sizes are known at compile-time. So there is no risk that initializing these variables will spill into `main`'s frame.
3. `b(1)` is called by `a`. Stack frame for `b` is allocated right below stack frame of `b`. Stack pointer `sp` moves down to the start of this new frame.
4. `c(2)` is called by `b`, etc.
5. `d(3)` is called by `c`, etc.
6. When `d` finishes executing, "return" control to the caller function `c` by (1) setting the next instruction to execute to the return address[^stack-info], and (2) popping off the stack frame, i.e., updating `sp` to the end of stack frame for `d`, which is also the start of the stack frame for `c`. `c` is now the function to continue executing.
7. When `c` finishes executing, return control to `b`, etc.
8. When `b` finishes executing, return control to `a`, etc.
9. When `a` finishes executing, return control to `main`, etc.
10. When `main` finishes executing, `sp` now points to the highest address of the stack, and there are no stack frames left on the stack. End the program.

:::

:::{warning} The stack's secret to fast memory management

When a function returns and the stack pointer moves up, the system _**does not** erase the memory_. There is "no time" to zero it out; C is too busy.
:::

Consider @fig-c-stack-anim. If you had a secret password like `"Bosco"` stored in a local variable in function `d()`, and function `d()` returns, that `"Bosco"` string is still in memory even though you aren't supposed to access it. You can see this if you follow a pointer to a returned local variable; the first time you print it, it might still show the old value (like `3`), but the next time you call a function like `printf`, that new function call creates its own stack frame and clobbers the old data.

## Passing pointers into the stack

At this point in your programming livelihoods, you have likely found it useful to pass data from one function to another function. We now also know that pointers into the stack may point to _stale data_, if the corresponding local variable's function has already finished executing! In these cases, C will not throw an error, but your program may have undefined behavior.

:::{warning} Declared array names only refer to arrays in their local scope.

Recall that [arrays in C](@sec-array) are a way of locally declaring a large block of memory. Now we know that this local declaration means that array declarations allocate space on the stack, and therefore must factor into the fixed size of a function's stack frame. Locally-declared arrays must have known size at compile-time, as shown in [this `sizeof` example](@sec-array-sizeof).
 
When array names are passed as arguments to other functions, they **decay** to pointers to memory. Now, we know that arrays will decay to pointers to memory on the _stack_.
:::

:::{hint} Addresses higher in the stack

It is fine to use pointers into the stack as _function arguments_.
:::

The code snippet below corresponds to the stack memory layout in @fig-c-stack-buf-ok. This code structure is common when `load_buf` loads data from, say, a file into a particular memory **buffer**. `main` first allocates `len` bytes of space[^size_t-info] for the buffer in its local variable `buf`, then calls `load_buf`, then processes the data in `buf`.

[^size_t-info]: unsigned integer type big enough to "count" memory bytes.

```{code} c
:linenos:
void load_buf(char *ptr, size_t len) {
  ...
}

int main() {
  ...
  char buf[...];
  load_buf(buf, BUFLEN);
  ...
}
```

:::{figure} images/c-stack-buf-ok.png
:label: fig-c-stack-buf-ok
:width: 70%
:alt: "TODO"

`main` passes its own local variable `buf` into a function call `load_buf`.
:::

All stack frames currently on the stack correspond to function calls that have not finished executing. In @fig-c-stack-buf-ok, the `main` stack frame exists until `load_buf` (which `main` calls) returns, and then some. `load_buf` can "trust" that the `len` bytes of stack memory starting at `ptr` will persist throughout execution of the function and can confidently write to this area of the stack.

:::{danger} Addresses lower in the stack

It is catastrophic to return a pointer into the stack!
:::

The code snippet below corresponds to the perilous stack memory layout in @fig-c-stack-buf-bad. Here, `main` still wants to load and process data from a file, but it does so by first making the buffer in a `make_buf` function call, then calls `foo` to process the data.

```{code} c
:linenos:
char *make_buf(size_t len) {
    char buf[len];
    return buf;
}
void foo(char *ptr2, size_t len) { ... }
int main(){
   char *ptr = make_buf(BUFLEN); 
   foo(ptr, BUFLEN);
   ...
}
```

:::{figure} images/c-stack-buf-bad.png
:label: fig-c-stack-buf-bad
:width: 70%
:alt: "TODO"

Left: Stack layout when `make_buf` returns. Right: Stack layout when `foo` is executing.
:::

`main` has a local variable pointer `ptr`. In Line 7, `ptr` is updated to an address within `make_buf`, which has _already returned_. We call this a **dangling reference**, because `ptr` points to deallocated memory.

The address stored in `ptr` is a location of the stack _below_ the `main` stack frame. When `foo` gets called in Line 8, the `foo` stack frame will reference the memory below the `main` stack frame, right where `ptr` supposedly points to! There is no guarantee that the `len` bytes at the address `ptr` will not be used for other data. 

While we _could_ hack together something that works for this toy example, consider that there may be many additional functions called between `main` and `foo`. If `foo` itself calls a system function, say, `printf`, then there is even less chance that `ptr` is not corrupted by other function calls.

Above all, remember that memory lower in the stack is overwritten when other functions are called.