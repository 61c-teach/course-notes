---
title: "Introduction"
subtitle: "How do we represent digital data?"
---

## Learning Outcomes

* Know the terms: bits, bytes, bitstrings
* Compute how many bits you need to represent $k$ items.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/mGgOK9ShS6g?si=OJZv82-TwMgnC-KY
:width: 100%
:title: "[CS61C FA20] Lecture 02.0 - Number Representation: Intro, Bits can be anything"
:::

::::

## Digital data

Data live all around us.

### Example: Storing data as digital

The real world is analog—everything you hear and see and smell is all analog. For example, real numbers are a great way to represent the world, but in order for us to use a computer to work with these numbers, we typically need to convert or find equivalent numbers that can be represented digitally.

:::{figure} images/a2d-signal.png
:label: fig-signal
:width: 50%
:alt: "Four sequential line graphs demonstrate the process of converting an original analog wave into a digital representation through time discretization and amplitude quantization. The diagrams illustrate how continuous signals are sampled at specific intervals and mapped to discrete values to create a final digital data set."

Translating an analog signal to a digital representation.
:::

In order to convert analog data to digital data, we must do two things:

1. **Sample**: We ask the signal at every time step: "What's your value?" This usually occurs at a regular interval. For example, for music on CDs, that's 44,100 times a second we're asking it what its height is.
2. **Quantize**: Because the height might come out at some fractional number, we need to divide it up in its amplitude using a "yardstick." We divide it up into a 16-bit number, which is $2^{16} = 65,536$ possible tick marks. Then, the sample "snaps" to the closest tick mark.

When we're all done, we have a set of 16-bit samples that we can work with. There is a *lot* of engineering that goes into this process. In other classes, you will learn how to sample signals, build analog-to-digital converters, and more. In this class, we focus on designing systems to represent real numbers with a limited number of bits.

### Example: Inherently digital data

Not all digital data are necessarily boring analog; sometimes you can create art, music, or videos completely without any analog reference. For example, the software [POV-Ray](https://www.povray.org/) is a rendering software that creates beautiful digital images that existed only in the artist's head. Nowadays, there are entire fields of artificial intelligence around generating digital images and video, often entirely from digital data sources.

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

## Bits, Bytes, and Nibbles

A **bit** is a *binary digit*. It takes on the value `0` or `1`. 
We use the phrases **binary string**, **bitstring**, **bit sequence**, etc. to refer to sequences of binary digits. For example, the set of length-four binary strings refers to the $2^4 = 16$ bitstrings `0000`, `0001`, `0010`, ..., `1111`.

A **byte** is a bitstring of length 8. We will find that it is useful to have a standard grouping of bits, so that groups of bits can represent more information. A byte can represent $2^8 = 256$ things.

How should we colloquially discuss bytes? Instead of always writing out eight bits (and having to say, "zero zero one zero one one one one" for `00101111`), we can write two hexadecimal digits for shorthand (and simply say `2F`). Read the [next section](#bin-dec-hex) to learn about how to convert between hexadecimal vs binary values, and why having a hexadecimal shorthand is useful.

If you're curious, 4 bits is called a "nibble" (or "nybble") and can represent $2^4 = 16$ things. This is equivalent to one hexadecimal digit.

## BIG IDEA: Bits can represent anything!

The big idea in this first lecture is:

> Bits can represent _anything_.

**Logical Values**: Commonly, `0` is false and `1` is true.

**Characters**: We have 26 characters (A-Z). If we use 5 bits, $2^5 = 32$, so we can have a bit pattern for each character, with six left over for other information.

* The [ASCII](https://en.wikipedia.org/wiki/ASCII) standard is an expanded 8-bit representation that can represent uppercase, lowercase, and punctuation as used in standard American English.
* The [Unicode](http://www.unicode.com) standard represents all the world's symbols and languages, including emojis. There are 8-bit, 16-bit, and 32-bit versions of Unicode.

**Colors**: HTML color codes are 24-bit (3-byte) representations. @fig-hex-colors shows the HTML color code for [California Gold](https://brand.berkeley.edu/visual-identity/colors/), `0xFDB515`. You will read more about hexadecimal and binary in the [next section](#bin-dec-hex).

:::{figure} images/hex-colors.png
:label: fig-hex-colors
:width: 70%
:alt: "A diagram features a horizontal gold abstraction line separating the word Numeral at the top from the word Number at the bottom. This visual layout reinforces the caption by positioning numerals as the symbolic representations above the line and numbers as the underlying abstract concepts below it."
:align: center

HTML Color Codes
:::

:::{tip} Explaining color codes
:class: dropdown

Revisit this explanation once you've read more about hexadecimal and binary in the [next section](#bin-dec-hex). You can use this example as practice for converting between hexadecimal, binary, and decimal.

* `FDB515` is hexadecimal shorthand (as denoted by the prefix `0x`) for the bitstring `0b111111011011010100010101` (as denoted by the prefix `0b`). We insert spacing below for readability, grouping bits by nibbles:

  `1111 1101 1011 0101 0001 0101`

* These 32 bits are then grouped together into three groups of eight bits to represent the amount of red, green, and blue, respectively, in California Gold. These _RGB_ values are each on a scale of 0 to 255.
  * Red: "Leftmost" byte, `0xFD` or `0b11111101` or 253.
  * Green: "Middle" byte, `0xB5` or `0b10110101` or 181.
  * Blue: "Rightmost" byte, `0x15` or `0b00010101` or 21.
  
:::

**Locations/Addresses**: IPv4 and IPv6 are 32-bit and 64-bit representations of device addresses on the Internet, also known as Internet Procotol addresses. Read more about [IP Addreses](https://en.wikipedia.org/wiki/IP_address) if you're curious.

**Many types of data** You can even represent emotions, like "happy" as `00` or "grumpy" as `01`. We note that a 2-bit representation is likely not sufficient for representing the diverse range of human emotions. In fact, attempts to quantify human emotions (often for the purpose of processing data via computers) is a huge area of research. What are the implications of using computers to sample and discretize human experience? For more, we recommend you look into sociotechnical coursework that explores the human contexts and ethics of data.

## Anything you can itemize, you can digitize

The big idea of this lecture to memorize:

> With N bits, you can represent at most $2^N$ things.

Put another way, you can represent $k$ things in at minimum $N$ bits, where $N = \lceil \log_2 k \rceil$.

:::{card}
**How many bits are needed to represent lowercase letters in English?**
^^^
There are 26 lowercase letters in the English language:  `a`, `b`, ..., `z`.

$\log_2 (26) = \log_{10}(26)/\log_2(2) \approx 4.7$

We therefore need at least **5 bits**.

_Double check_: 5 bits represents $2^5 = 32$ things, so we can definitely represent 26 letters (and six other things, if you want). 32 is the smallest power of 2 bigger than the number of things we want to store.
:::

:::{tip} Quick Check
How many “things” can be represented by 4 bits?

* 4
* 8
* 16
* 64
* Something else
:::

:::{note} Answer
:class: dropdown

$2^4 = 16$
:::

:::{tip} Quick Check
How many bits do you need to represent $\pi$ (pi)?

* 1
* 9 ($\pi=3.14$, so `0.011 "." 001100`)
* 64 (Macs are 64-bit machines)
* Every bit the machine has
* $\infty$

:::

:::{note} Answer
:class: dropdown

Trick question (sorry). We use bits to represent *sets* of things, not just a single thing. All answers are possible, depending on how many things beyond $\pi$ you are looking to represent.

To use 1 bit, consider representing the two things:

* $\pi$
* not $\pi$
:::