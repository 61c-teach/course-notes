---
title: "Summary"
---

## And in Conclusion$\dots$



## Textbook Readings

P&H 1.7, 1.8, 2.11, 4.10, 4.11, 5.10, 6.1-6.3, 6.5, 6.7

## Additional References

## Exercises
Check your knowledge!

### Conceptual Review

:::{exercise}
:label: parallel-01
1. **True/False?** Using write-through caches removes the need for cache coherence.
:::

:::{solution} parallel-01
:label: parallel-01-sol
:class: dropdown

**False.** You have a copy. I do a write (through, to memory). How do you get updated when you do a read?
:::

:::{exercise}
:label: parallel-02
2. **True/False?** Every processor store instruction must check contents of other caches.
:::

:::{solution} parallel-02
:label: parallel-02-sol
:class: dropdown

**False.** That's the point of these protocols, to know if others have copies and whether I need to just do a store or do other work.
:::

:::{exercise}
:label: parallel-03
3. **True/False?** Only one processor can cache any memory location at one time.
:::

:::{solution} parallel-03
:label: parallel-03-sol
:class: dropdown

**False.** What if they're all doing reads? That would be inefficient.
:::

### Short Exercises