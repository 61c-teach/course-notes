---
title: "Function Pointer Example"
---

## Learning Outcomes

* Trace an example involving function pointers.
* Declare and initialize function pointers, and call functions pointed to by function pointers.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/PlIYbp0fgY4
:width: 100%
:enumerated: false
:title: "Lecture 04.4 - C Intro: Pointers, Arrays, Strings: Function Pointer Example"
:::
::::

## Example Code and Output

This program implements `mutate_map`, which maps a given function onto each element of an `int` array. Notably, `mutate_map` defines a function pointer parameter.

(card-fn-ptr-code)=
:::{card}
Example program `map_func.c`
^^^

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

    mutate_map (arr, n, &multiply2);
    print_array(arr, n);

    mutate_map (arr, n, &multiply10);
    print_array(arr, n);

    return 0;
}

```

:::

When running the compiled `map_func` executable;

```bash
$ ./map_func
3 1 4 
6 2 8 
60 20 80 
```

## More soon!
