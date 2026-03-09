---
title: "Summary"
---

## And in Conclusion$\dots$

A **finite state machine** is a type of simple automaton where the next state and output depend only
on the current state and input. Each state is represented by a circle, and every proper finite state
machine has a starting state, signified either with the label “Start” or a single arrow leading into
it. Each transition between states is labeled [input]/[output].
For example, Figure 2 below is a finite state machine with two states (0 and 1). It outputs 1 when the state
changes, and 0 when the state stays the same.
The machine starts in state 0. When the input is 0, it stays in its current state and outputs 0. When
the input is 1, it switches to the other state and outputs 1.
When in state 1, the machine behaves the same way: it stays in state 1 and outputs 0 when the
input is 0, and switches back to state 0 with an output of 1 when the input is 1.

:::{figure} images/FSM_Precheck_Disc8.png
:label: fig-swap-string-after
:width: 60%
:alt: "TODO"

FSM diagram for the description above
:::
With combinational logic and registers, any FSM can be implemented in hardware!
## Textbook Readings

P&H A.3-A.6

## Additional References

* [Intro to SDS Handout](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/sds.pdf) - Clocks, Delay
* [State Handout](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/state.pdf) - Registers, FSMs

## Exercises
Check your knowledge!

### Conceptual Review

1. Question

:::{note} Solution
:class: dropdown

Solution

See: [Lecture 2 Slide 13](https://docs.google.com/presentation/d/1dmCk2fZz-P8VedzAXnVmJiYPKszVka5NKmTuLJ6hqZc/edit?slide=id.g2af3b38b3e2_1_154#slide=id.g2af3b38b3e2_1_154)
:::

### Short Exercises

1. **True/False**: “clk-to-q” delay is the time between the rising edge of the clock signal and the time it takes for the register’s output to reflect the new input.

:::{note} Solution
:class: dropdown
**False** “clk-to-q” delay is the time between the rising edge of the clock signal and the time it takes for the register’s output to reflect the new input.
::: 

2. **True/False**: State elements only update their output on the rising edge of the clock, even if the inputs change between clock rising edges.

:::{note} Solution
:class: dropdown
**True** State elements will update their output on the rising edge of the clock signal. Between rising edges, the state element’s output will remain constant regardless of the inputs
:::
