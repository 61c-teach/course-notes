---
title: "Linked List: Full Implementation"
---

(sec-ll-full)=
## Learning Outcomes

* Implement a linked list data structure in C.
* Use header (`.h`) files to abstract the linked list interface from the linked list implementation.

We build on the [previous section](#sec-ll-add-front) to implement a full set of features for a linked list.

:::{warning} Different code, different learning goals

The code in this section and the [previous section](#sec-ll-add-front) differ in their declaration of the linked list head. This is intentional to focus on different learning outcomes:

* The [previous section](#sec-ll-add-front) is practice with double pointers.
* This section deliberately abstracts the linked list definition from its implementation.

The big takeaway of this section is separation of header and source files. At least as of Spring 2026, we do not expect in this course that you will need to define your own headers.[^temperature]

[^temperature]: If you are curious, [Wikibooks](https://en.wikibooks.org/wiki/C_Programming/Headers_and_libraries) has a comprehensive up-to-date example of a simple temperature library with more explanation than what is provided here.
:::

## The Linked List Library

In this section, we want to implement a linked list in C for use by others.

* **create** a linked list.
* **add** a new node (with a copy of a provided string) to the front of the linked list.
* **print** all strings in the linked list.
* **free** and delete the linked list.

### Headers and Source Files

Ideally, we would like to hide the internal details of the implementation from how we advertise the linked list. C provides a simple convention for doing so: **headers** (`.h` header files) and **source files*** (`.c` files).

* Headers: Declare `struct` names or `typedef`s, declare function signatures, etc.
* Source: Implement functions, etc.

By doing so, we can compile the source file and distribute our linked list as its header file and a compiled source binary. Another programmer would then need to include the header file (e.g., with `#include <linked_list.h>`) but would not need to recompile the source binary.

We will discuss this compilation and linking process in a later chapter.

## Specify: `linkedlist.h`

To avoid polluting the global namespace, we will prepend `list_` to our function names. The header file below defines the linked list interface:

(card-ll-header)=
:::{card}
Header file: `linkedlist.h`
^^^

```{code} c
:linenos:
#ifndef LINKEDLIST_H
#define LINKEDLIST_H

typedef struct _node node_t;           // forward declaration
typedef struct _linked_list linked_list_t;  // opaque list type

// Create a new empty list
linked_list_t* list_create(void);

// Add a node to the front of the list
void list_add_front(linked_list_t *list, const char* data);

// Print the list
void list_print(const linked_list_t *list);

// Free the list and all associated memory
void list_free(linked_list_t *list);

#endif
```

:::

Notes:

* Lines 1-2: These macros prevent double includes, e.g., if this header were included by multiple C files in the project.
* Line 4: This is a **forward** declaration. It is "forward" because  “Forward” since haven’t defined `struct _node` yet (we define it in the source file along with implementation).
* Lines 4-5: The struct names `struct _node` and `struct _linked_list` are opaque because library users will not need to use `_node` and `_linked_list` explicitly, hence why we prepend `_` to the names.

## Implement: `linkedlist.c`


(card-ll-source)=
:::{card}
Source file: `linkedlist.h`
^^^

```{code} c
:linenos:

#include "linkedlist.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct _node {
   char *data;
   node_t *next;
};

struct _linked_list {
   node_t *head;
};

// Create a new empty list
linked_list_t *list_create(void) {
   linked_list_t *list = malloc(sizeof(linked_list_t));
   if (!list) return NULL;
   list->head = NULL;
   return list;
}

// Add a node to the front, assumes list not NULL
void list_add_front(linked_list_t* list, const char* data) {
   node_t* node = malloc(sizeof(node_t));
   if (NULL == node) { printf("Error in list_add_front: Couldn't allocate node_t\n"); exit(1);}
   node->data = (char *) malloc(strlen(data) + 1); // extra byte
   if (NULL == node->data) { printf("Error in list_add_front: Couldn't allocate string\n"); exit(1);}
   strcpy(node->data, data);
   node->next = list->head;
   list->head = node; // different from before
}

// Print the list
void list_print(const linked_list_t *list) {
   node_t *current = list->head;
   while (current) {
       printf("%s -> ", current->data);
       current = current->next;
   }
   printf("NULL\n");
}

// Free the list storage and the data
void list_free(linked_list_t *list) {
   node_t *current = list->head;
   while (current) {
       node_t *next = current->next;
       free(current->data);
       free(current);
       current = next;
   }
   free(list);
}
```

:::

Notes:

* Lines 6 - 13: Because the header has defined `typedef`s, we can directly use `typedef`s in function declaration. However, the `struct _node` and `struct _linked_list` definitions must still use their opaque `struct` names.
* Lines 31: As noted earlier, this implementation is slightly different from `add_to_front` in the [previous section](#sec-ll-add-front).
* Lines 49-50: We must free the heap-allocated `data` string before free-ing the node `current` itself, not the other way around. Doing so avoids us using `current` after free-ing.

## Use: `list_demo.c`

Let's now use this linked list interface in the program below.


(card-ll-demo)=
:::{card}
Example program `list_demo.c`
^^^

```{code} c
:linenos:
#include "linkedlist.h"
#include <stdio.h>

int main(void) {
   linked_list_t *list = list_create();
   if (NULL == list) { printf("Error in main: Couldn't allocate linked_list_t`\n"); return(1);}

   list_add_front(list, "Alice");
   list_add_front(list, "Bob");
   list_add_front(list, "Cara");

   list_print(list);  // Cara -> Bob -> Alice -> NULL

   list_free(list);
   return 0;
}
```

:::

Notes:

* Line 1: We do not include the `linkedlist.c` source file! Including the header file `linkedlist.h` is sufficient to forward-declare the needed structs and function names for use in `main`.
* Line 4: The `void` in `main`'s parameter specifies that `main` doesn't take any command-line arguments.[^main-void]

[^main-void]: Whether such a declaration is preferred over, say, `int main()` is debated. See [StackOverflow](https://stackoverflow.com/questions/12225171/difference-between-int-main-and-int-mainvoid).

### Run Demo

The below demo is for reference.

```bash
$ ls
linkedlist.c linkedlist.h list_demo.c Makefile
$ make
gcc -Wall -Wextra -std=c17 -c list_demo.c -o list_demo.o
gcc -Wall -Wextra -std=c17 -c linkedlist.c -o linkedlist.o
gcc -Wall -Wextra -std=c17 -o list_demo list_demo.o linkedlist.o
$ ./list_demo 
Cara -> Bob -> Alice -> NULL
```

We won't expect you to write Makefiles in this class, so click below if you're curious.

:::{note} Expand for `Makefile` contents
:class: dropdown

```bash
# Compiler
CC = gcc

# Compiler flags
CFLAGS = -Wall -Wextra -std=c17

# Target executable
TARGET = list_demo

# Source files
SRC = list_demo.c linkedlist.c

# Object files (replace .c with .o)
OBJ = $(SRC:.c=.o)

# Default rule
all: $(TARGET)

# Link object files into executable
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ)

# Compile .c files to .o and generate dependencies
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Include dependency files (if they exist)
-include $(DEP)

# Clean up build files
clean:
	rm -f $(OBJ) $(TARGET) $(DEP)
```
:::

## Conclusion

We can implement library APIs (application program interfaces) using C.

* Headers in `.h` file specify the API. Watch your naming to avoid cluttering the global namespace!
* Implement the API in `.c` files (which should `#include` the `.h` file)
* Use them in other `.c` files (which should also `#include` the `.h` file)
