---
title: "Linked List"
---

## Learning Outcomes

* Build the linked list, a recursive data structure, in dynamic memory.
* Write code that uses structs and typedefs.
* Practice allocating memory on the heap with `malloc`
* Write code that uses a function with a double pointer.

Let's look at an example of using structures, pointers, and dynamic memory (the heap) to implement a linked list of strings.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/sJaSIlZzBPk?si=4Ar6Alh95EZZrdg
:width: 100%
:title: "[CS61C FA20] Lecture 05.2 - C Memory Management: Linked List Example"
:::

::::

The code discussed in this course note differs slightly from the video below:

* Naming convention has been updated to be more C-like (e.g., `snake_case`; typedefs as suffixed with `_t`)
* Course note code presents a realistic linked list scenario, where a `head` pointer is declared in `main` and then updated via the `add_to_front` function (hence, the double pointer parameter)

## The `node_t` struct


A **linked list** is a data structure that can be described recursively, as defined [below](#code-ll-def):

(code-ll-def)=
```{code} c
:linenos:
typedef struct _node node_t;
struct _node {
    char *data;
    node_t *next;
};
```

Each `node_t` is has two fields: `data`, which has a pointer (e.g., the node "stores" a string), and `next`, which is a pointer to another `node_t`. The recursive structure means that a node's`next` pointer points to another `node_t`, which then points to the next `node_t`, and so on, until the last node's `next` member is `NULL`, signifying the end of the list.

To make our code cleaner, we use `typedef`. Line 1 declares `node_t` as an alias of `struct _node`, which has been forwardly declared but not defined. Lines 2 onwards then define the fields of the `struct _node`.[^typedef-struct]

[^typedef-struct]: Read about `typedef` and `struct` conventions on [StackOverflow](https://stackoverflow.com/questions/71270954/how-to-properly-use-typedef-for-structs-in-c).

## Linked List Code: `add_to_front`

Let's look at code that adding a string to an existing linked list.

In the code [below](#code-ll-add), `head` is defined as a pointer to the first node in a linked list. The list starts empty, i.e., `head` points to nothing (`NULL`). Then, Line 4 calls `add_to_front`. Once we return from this call, we expect that `head` should now point to a node that has a *copy* of the string passed in.[^ll-str-malloc]

[^ll-str-malloc]: Students often ask why `add_to_front` makes a node that points to a _copy_ of the string. After all, the string already exists, so why not point to it? Here's my take: `add_to_front` is making a new node, and ideally that node's data is its own to control. If we push allocation/deallocation of node memory to node functions, then we reduce the risk that node data will contain dangling pointers. Finally, most linked list applications involve mutating node data; we copy string constants to dynamic memory first to modify them.

(code-ll-add)=

```{code} c
:linenos:

# include <string.h>
int main() {
  node_t *head = NULL;
  add_to_front(&head, "abc");
  …  // free nodes, strings here…
}

void add_to_front(node_t **head_ptr, char *data) {
  node_t *node = (node_t *) malloc(sizeof(node_t));
  node->data = (char *) malloc(strlen(data) + 1); // extra byte
  strcpy(node->data, data);  // strcpy also copies null terminator
  node->next = *head_ptr;
  *head_ptr = node;
}
```

Consider the `add_to_front` function above. The function takes in two pointers: one to a linked list (a **double pointer** `node_t head_ptr`) and a string, `char * data`.
Recall that pointers are lightweight ways to pass data into a function, even if the linked list or the string itself is quite large.

But why a double pointer? We will discuss this once we trace through the code, line by line.

### [Line 4](#code-ll-add): `main`

The first argument passed in is an address (`&head`); in other words, `head_ptr` is a **pointer** to `head`. The second argument passed in is a string constant (i.e., a read-only array). While C is pass-by-value, array arguments decay to pointers to the first element, so `data` is a pointer to the first character in the string constant.

:::{figure} images/ll-line04.png
:label: fig-ll-line04
:width: 100%
:alt: "TODO"

`add_to_front` argument assignment
:::


### [Line 9](#code-ll-add): Allocate heap space for new node

This `malloc` call makes a new `node_t` struct in dynamic memory (i.e., the heap). In the toy diagram, `node` points to a newly allocated `node_t` at heap address `0x300`. At this point, the contents of that node—both the value and the next fields—are just garbage because C does not initialize them for you.

:::{figure} images/ll-line09.png
:label: fig-ll-line-09
:width: 100%
:alt: "TODO"

Line 9
:::

### [Line 10](#code-ll-add): Allocate heap space for new node's string

Right-hand side: This `malloc` call makes a new character array in dynamic memory. Before we copy the string, we make room for it[^ll-str-malloc] on the heap.

Strings are defined as null-terminated character arrays; therefore `malloc`-ing space for strings always involves `strlen(string) + 1`. We use `strlen(string)` to find out how long the string is, but recall that `strlen` does not include the null terminator. If the string is `"abc"`, `strlen` says three, but you really need four to include the `'\0'`.

Left-hand side: The pointer returned by `malloc` is then set as the `value` field of `node` using the arrow notation (`node->value`), which is the pointer-based way to follow the node to its `data` field.

:::{figure} images/ll-line10.png
:label: fig-ll-line-10
:width: 100%
:alt: "TODO"

Line 10
:::

### [Line 11](#code-ll-add): `strcpy` string data

Once we have that uninitialized space reserved, we call `strcpy` (string copy) to bring the value over. This copies the characters `'a'`, `'b'`, `'c'`, and a null terminator into our newly allocated space.[^ll-str-strcpy]

[^ll-str-strcpy]: `strcpy` is a terrifying function. From `man` pages: "`strcpy(dst, src)`copy the string pointed to by `src`, into a string at the buffer pointed to by `dst`.  The programmer is responsible for allocating a destination buffer large enough, that is, `strlen(src) + 1`."

:::{figure} images/ll-line11.png
:label: fig-ll-line-11
:width: 100%
:alt: "TODO"

Line 11
:::

### [Line 12](#code-ll-add): Update new node's next pointer

Next, we set the `next` field of `node`. This is a great example of sharing; the new node’s next pointer now points to the original head of the list. Note that we dereference with `*head_ptr` because is a double pointer to a node. In this case, the `head_ptr` points to `NULL`, so dereferencing `head_ptr` gives us the address `NULL`, which we copy into the struct.

:::{figure} images/ll-line12.png
:label: fig-ll-line-12
:width: 100%
:alt: "TODO"

Line 12
:::

### [Line 13](#code-ll-add): Update head of linked list

Finally, we must update the head of the list, which is defined as a pointer to the first node in the linked list. The "head" is currently `NULL` but should be updated to `0x300`, which is the address of the struct we just created, which by definition is what `node` points to. It is therefore is sufficient to set `*head_ptr` (the value that `head_ptr` points to) to `node` (0x300).

:::{figure} images/ll-line13.png
:label: fig-ll-line-13
:width: 100%
:alt: "TODO"

Line 13
:::

### [Line 4](#code-ll-add) Return to `main` after function call

Recall that variables declared in a function are reclaimed by the stack once the function exits. The heap-allocated `node_t` struct and string persist, but the local pointer `node` disappears. However, we can still keep track of the node we created because the double pointer allowed us to directly update the value of our `head` variable.

:::{figure} images/ll-line05.png
:label: fig-ll-line-05
:width: 100%
:alt: "TODO"

Return from function call at Line 4
:::

## Conclusion

This example shows how to fluently work with structs and pointers in C. We will keep showing you more examples so you get more comfortable with how memory management works. Good luck, and see you in the next sectoin!