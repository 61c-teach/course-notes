---
title: "Exercises"
subtitle: "Check your knowledge before section"
---

## Conceptual Review

1. **True/False**: Memory sectors are defined by the hardware, and cannot be altered.

:::{note} Solution
:class: dropdown

**False.** The four major memory sectors, stack, heap, static/data, and text/code for any given process (application) are defined by the operating system and may differ depending on what kind of memory is needed for it to run.

What's an example of this process that might need significant stack space, but very little text, static, and heap space? (Almost any basic deep recursive scheme, since you're making many new function calls on top of each other without closing the previous ones, and thus, stack frames.)

What's an example of a text and static heavy process? (Perhaps a process that is incredibly complicated but has efficient stack usage and does not dynamically allocate memory.)

What's an example of a heap-heavy process? (Maybe if you're using a lot of dynamic memory that the user attempts to access.)

<!--See: [Lecture 5 Slide 16](https://docs.google.com/presentation/d/19FgFvcLQsK5PEMiVsSnzzwI3TrBmuZkwsjSjrHwFMzw/edit?slide=id.g32a33470376_1_68#slide=id.g32a33470376_1_68)-->
:::
