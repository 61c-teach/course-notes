---
title: "Function Pointers"
---

## Learning Outcomes

* Understand function pointer syntax.
* Declare and initialize function pointers, and call functions pointed to by function pointers.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/PlIYbp0fgY4
:width: 100%
:enumerated: false
:title: "Lecture 04.4 - C Intro: Pointers, Arrays, Strings: Function Pointer Example"
:::
::::


### Function Pointers

In a [previous chapter](#sec-pointers) we briefly mentioned **function pointers**.

```c
int (*fn) (void *, void *) = &foo;
(*fn)(x, y);
```

In the first line, `fn` is a function that accepts two `void *` pointers and returns an `int`. With this declaration, we set it to pointing to the function `foo`. The second line then calls the function with arguments `x` and `y`.

Function pointers allow us to define **higher-order functions**, such as map, filter, and generic sort.

Normally a pointer can only point to one type. In a [future chapter](#sec-generics) we discuss the `void *` pointer, a **generic pointer** that can point to anything. In this course we will use the generic pointer sparingly to help avoid program bugs...and security issues...and other things... That being said, we will encounter generic pointers when working with memory management functions in the C standard library (`stdlib`).

## Example Code and Output

This program implements `mutate_map`, which maps a given function onto each element of an `int` array. Notably, `mutate_map` defines a function pointer parameter.

(card-code-fn-ptr)=
:::{card}
Example program `map_func.c`
^^^
(code-fn-ptr)=
```{code} c
:linenos:
#include <stdio.h>

/* map function onto int array */
void mutate_map(int arr[], int n, int(*fp)(int)) {
    for (int i = 0; i < n; i++)  
        arr[i] = (*fp)(arr[i]);
}

/* prints int arrays */
void print_array(int arr[], int n) {
    for (int i = 0; i < n; i++)  
        printf("%d ", arr[i]);
    printf("\n");
}

int multiply2 (int x) {  return  2 * x;    }
int multiply10(int x) {  return 10 * x;   }

int main() {
    int arr[] = {3,1,4}, n = sizeof(arr)/sizeof(arr[0]);
    print_array(arr, n);

    mutate_map(arr, n, &multiply2);
    print_array(arr, n);

    mutate_map(arr, n, &multiply10);
    print_array(arr, n);

    return 0;
}
```

:::

This code multiplies the integer array `arr` by two, then multiplies `arr` again by ten, with two successive calls to `mutate_map`. The two `mutate_map` calls pass in different function pointers to `multiply2` and `multiply10`, respectively.

Running the compiled `map_func` executable produces the following output:

```bash
$ ./map_func
3 1 4 
6 2 8 
60 20 80 
```

:::{note} More explanation
:class: dropdown

* **Line 4: Declare parameter `fp`.** The `fp` parameter is a function pointer. It accepts one `int` argument and returns an `int`.
* **Lines 23, 26: Pass in function pointer argument**. The function calls in Lines 23 and 26 pass in `multiply2` and `multiply10`, respectively as function pointer arguments. The address operator (`&`) is used for readability but is technically not needed.[^fn-reference]
* **Line 6: Call `fp`**. The syntax `(*fp)(arr[i])` calls the function pointed to by `fp` and passes in the argument `arr[i]`. Like before, the dereference operator (`*`) is used for readability but is technically not needed for function pointers.[^fn-reference]

:::

[^fn-reference]: `(*fp)(arg)` and
`fp = &fname` are stylistic choices and are not required by the C standard. However, their use is strongly recommended for readability. StackOverflow has multiple [multiple](https://stackoverflow.com/questions/7518815/function-pointer-automatic-dereferencing) [articles](https://stackoverflow.com/questions/7518815/function-pointer-automatic-dereferencing) on this topic.





