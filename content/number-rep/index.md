---
title: "Introduction"
subtitle: "How do we represent digital data?"
---

## Digital data not necessarily born Analog$\dots$

<!-- digitally-generated art (not real, something about AI -->

:::::{tab-set}

::::{tab-item}   The Last Guardian, Johnny Yip

  :::{image} images/guardian.jpg
  :label: fig-art1
  :alt: "A digital illustration depicts an underwater scene with a large marine reptile swimming past a shipwreck on a coral reef. Shafts of sunlight  enetrate the deep blue water, illuminating a massive school of fish above  the wreckage."
  :width: 40%

  :::

::::

::::{tab-item}  My First CGSphere, Robert McGregor

  :::{image} images/rwmcgsphere2_final.jpg
  :label: fig-art2
  :alt: "A digital rendering illustrates a metallic gold sphere with circular perforations nested inside a larger, translucent amber-colored lattice. The structure is situated on a reflective tiled surface within a curved gray grid environment and is surrounded by wisps of white vapor."
  :width: 40%

  :::

::::

:::::

## Data input: Analog $\rightarrow$ Digital

* Real world is analog!
* To import analog information, we must do two things
  * Sample
    * E.g., for a CD, every 44,100ths of a second, we ask a music signal how loud it is.
  * Quantize
    * For every one of these samples, we figure out where, on a 16-bit (65,536 tic-mark) “yardstick”, it lies.

<!-- add qualifier about possible digital procedure, but not the entire picture (or rather, what we do in practice) First, a signal is discretized in time with sampling. Then, it is quantized in amplitude. Finally, these datapoints become a digital representation of a signal. -->

:::{figure} images/a2d-signal.png
:label: fig-signal
:width: 70%
:alt: "Four sequential line graphs demonstrate the process of converting an original analog wave into a digital representation through time discretization and amplitude quantization. The diagrams illustrate how continuous signals are sampled at specific intervals and mapped to discrete values to create a final digital data set."er

One translation of an analog signal into a digital representation.
:::

<!-- this is not the entire picture—must start smaller. we start with a number. -->

## Nibbles and Bytes

* 4 Bits
  * 1 “Nibble”
  * 1 Hex Digit = 16 things
* 8 Bits
  * 1 “**Byte**”
  * 2 Hex Digits = 256 things

## BIG IDEA: Bits can represent anything!!

* Logical values? 1 bit
  * One possible convention: 0 → False, 1 → True
* Characters? Several options:
  * A, ..., Z: 26 letters $\rightarrow$  5 bits (26 $\leq$ 32)
  * [ASCII](https://en.wikipedia.org/wiki/ASCII): upper/lower case + punctuation $\rightarrow$ 7 bits $\rightarrow$ round to 1 byte
  * Unicode ([www.unicode.com](http://www.unicode.com)): standard code to cover all the world’s  languages $\Rightarrow$ 8, 16, 32 bits

* Colors?
  * HTML color codes: 24 bits (3 bytes)
* Locations / addresses? Commands?
  * IPv4 (32 bit), IPv6 (64 bit), etc.

With N bits, you can represent at most $2^N$ things.

:::{figure} images/hex-colors.png
:label: fig-hex-colors
:width: 70%
:alt: "A diagram features a horizontal gold abstraction line separating the word Numeral at the top from the word Number at the bottom. This visual layout reinforces the caption by positioning numerals as the symbolic representations above the line and numbers as the underlying abstract concepts below it."
:align: center

HTML Color Codes
:::

## Pop quiz??

1. How many “things” can be represented by 4 bits?

    A. 4

    B. 8

    C. 16

    D. 64

    E. Something else

2. How many bits do you need to represent π (pi)?

    A. 1

    B. 9 ($\pi=3.14$, so `0.011 "." 001100`)

    C. 64 (Macs are 64-bit machines)

    D. Every bit the machine has

    E. $\infty$

3. What does this particular 4-bit pattern represent? `1011`
