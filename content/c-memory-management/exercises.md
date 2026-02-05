---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. **True/False**: Memory sectors are defined by the hardware, and cannot be altered.

:::{note} Solution
:class: dropdown

**False.** The four major memory sectors, stack, heap, static/data, and text/code for any given process (application) are defined by the operating system and may differ depending on what kind of memory is needed for it to run.
:::

2. What's an example of this process that might need significant stack space, but very little text, static data, and heap space?

:::{note} Solution
:class: dropdown

(Almost any basic deep recursive scheme, since you're making many new function calls on top of each other without closing the previous ones, and thus, stack frames.)

:::

3. What's an example of a text- and static data- heavy process?

:::{note} Solution
:class: dropdown
(Perhaps a process that is incredibly complicated but has efficient stack usage and does not dynamically allocate memory.)
:::

4. What's an example of a heap-heavy process?

:::{note} Solution
:class: dropdown
(Maybe if you're using a lot of dynamic memory that the user attempts to access.)
:::