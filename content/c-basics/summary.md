---
title: "Summary"
---

## And in Conclusion$\dots$

* C was chosen to exploit underlying features of HW. 
  * We will begin discussiong memory management in a lot more detail next time with pointers and arrays.
* C is compiled and linked to make executable.
  * Pro: Speed
  * Con: Slow edit-compile cycle
* C looks mostly like Java, except no object oriented programming
  * Abstract Data Types are defined through structs; more next time
  * `bool`: `0` and `NULL` are false. Everything else is true.
  * Use `intN_t` and `uintN_t` for portable code!
* Uninitialized variables contain **garbage**.
  * “Bohrbugs” (repeatable) vs “Heisenbugs” (random)

## Textbook Reading

K&R Ch. 1-5

## Additional References

* [C reference Slides](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/garcia_c_reference_slides.pdf)
* [Brian Harvey's Intro to C](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/HarveyNotesC1-3.pdf)

## Exercises
Check your knowledge!

### Conceptual Review

1. **True/False**: In compiled languages, the compile time is generally pretty fast, however the run-time is significantly slower than interpreted languages.

:::{note} Solution
:class: dropdown

**False.** Reasonable compilation time, excellent run-time performance. It optimizes for a given processor type and operating system.

<!--See: [Lecture 3 Slide 18](https://docs.google.com/presentation/d/1Wx65MzIzJa-dJvrE2IwTm7EGNP0DmiXi1haFtBj69No/edit?slide=id.g32e1ad37bb7_0_314#slide=id.g32e1ad37bb7_0_314)-->
:::