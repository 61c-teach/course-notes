---
title: "Logic Gates"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/vX8BhDk3qhc
:width: 100%
:title: "[CS61C FA20] Lecture 16.2 - Combinational Logic: Logic Gates"
:::

::::

## Visuals

:::{figure} images/and-gate.png
:label: fig-and-gate
:width: 100%
:alt: "TODO"

AND gate symbol.
:::

```{code} c
:linenos:
y = AND(a,b)
  = 1 iff both a, b are 1 (0 otherwise)
```

:::{table} AND Truth Table.
:label: tab-and
:align: center
| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

:::

:::{figure} images/or-gate.png
:label: fig-or-gate
:width: 100%
:alt: "TODO"

OR gate symbol.
:::

```{code} c
:linenos:
y = OR(a,b)
  = 0 iff both a, b are 0
```

:::{table} OR Truth Table.
:label: tab-or
:align: center
| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

:::

:::{figure} images/and-gate-n.png
:label: fig-and-gate-n
:width: 100%
:alt: "TODO"

Depiction of AND and OR gate symbols extended to n inputs.
:::

:::{figure} images/not-gate.png
:label: fig-not-gate
:width: 100%
:alt: "TODO"

NOT gate symbol.
:::

```{code} c
:linenos:
y = NOT(a)
  = 1 iff a is 0
```

:::{table} NOT Truth Table.
:label: tab-not
:align: center
| a | y |
| :--: | :--- |
| 0 | 1 |
| 1 | 0 |

:::

:::{figure} images/nand-gate.png
:label: fig-nand-gate
:width: 100%
:alt: "TODO"

NAND gate symbol.
:::

```{code} c
:linenos:
y = NAND(a,b)
  = 1 iff AND(a,b) = 0
```

:::{table} NAND Truth Table.
:label: tab-nand
:align: center
| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

:::

:::{figure} images/nor-gate.png
:label: fig-nor-gate
:width: 100%
:alt: "TODO"

NOR gate symbol.
:::

```{code} c
:linenos:
y = NOR(a,b)
  = 1 iff OR(a,b) = 0
```

:::{table} NOR Truth Table.
:label: tab-nor
:align: center
| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 0 |

:::

:::{figure} images/xor-gate.png
:label: fig-xor-gate
:width: 100%
:alt: "TODO"

XOR gate symbol.
:::

```{code} c
:linenos:
y = XOR(a,b)
  = 1 iff a not = b
```

:::{table} XOR Truth Table.
:label: tab-xor
:align: center
| a | b | y |
| :--: | :--- | :--- |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

:::