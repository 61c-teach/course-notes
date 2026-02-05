---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Short Exercises

1. Fill in the memory contents for each system after initializing `arr`. Assume `arr` begins at memory address `0x1000`.

```
uint32_t arr[2] = {0xD3ADB33F, 0x61C0FFEE};
```

**(a)** Little-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` |       |       |       |       |
| `0x1004` |       |       |       |       |
|        | ...                   |

**(b)** Big-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` |       |       |       |       |
| `0x1004` |       |       |       |       |
|        | ...                   |

:::{note} Solution
:class: dropdown

**(a)** Little-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` | `0x3F` | `0xB3` | `0xAD` | `0xD3` |
| `0x1004` | `0xEE` | `0xFF` | `0xC0` | `0x61` |
|        | ...                   |

**(b)** Big-Endian System

|        | +0    | +1    | +2    | +3    |
|--------|-------|-------|-------|-------|
|        | ...                   |
| `0x1000` | `0xD3` | `0xAD` | `0xB3` | `0x3F` |
| `0x1004` | `0x61` | `0xC0` | `0xFF` | `0xEE` |
|        | ...                   |

:::
