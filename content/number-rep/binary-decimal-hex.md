---
title: "Binary, Decimal, Hex"
subtitle: "How do we represent a number?"
---

Historically, computers were used as scientific calculators. We therefore dedicate most of our time to understanding how a string of bits (a **bit string**) can represent a number. In this section, we discuss a system for translating between **bits and numbers** (specifically, non-negative integers) grounded in math.

While this mathematical system is not the only representation, it is a system that computer architects and computer scientists use frequently---to translate between the rich world that human sees and information, represented as bits.

Learning Outcomes:

* Translate between binary, decimal, and hexadecimal number representations
* Understand that the hexadecimal representation is an easy shorthand for binary representations

## Numerals as a representation of Numbers

Let's discuss the idea of formally representing a **number** with many possible **numerals**, i.e., symbols.

* **Numeral**: A symbol (or series of symbols) or name that stands for a number, e.g., 4 , four , quatro , IV , IIII , …. Numerals are composed of multiple symbols called **digits**.
* **Number**: The “idea” in our minds, e.g., the concept of "4". There is only ONE concept of a number, but there can be many possible numeric representations via many possible numerals.

:::{figure} images/numeral-number.png
:label: fig-numeral-number
:alt: "A diagram features a horizontal gold abstraction line separating the word Numeral at the top from the word Number at the bottom. This visual layout reinforces the caption by positioning numerals as the symbolic representations above the line and numbers as the underlying abstract concepts below it."
:align: center

Numerals (and therefore digits) are representations of numbers.
:::

@fig-every-base-is-base-10 is a motivating (and humorous) example. An alien and an astronaut are discussing how to represent the number of rocks in a pile.

:::{figure} images/every-base-is-base-10.png
:label: fig-every-base-is-base-10
:alt: "A astronaut talking to an alien with 2 fingers per hand and there are 4 rocks on the ground. Alien says  'There are 10 rocks.' Astronaut says 'Oh, you must be using base 4. See, I use base 10.' Alien says 'No. I use base 10. What is base 4?' Caption reads 'Every base is base 10'"
:align: center

Every base is base 10 ([web.archive.org](https://web.archive.org/web/20160505151914/http://cowbirdsinlove.com/43))
:::

The alien, the astronaut, and the pile of rocks use three different representations of the same number. The astronaut uses the numeral 4 to represent four as a base-10 integer. The alien uses the numeral 10 to represent four as a base-4 integer. The pile of rocks uses four rocks to represent four as, well, a pile of rocks.

## Binary, Decimal, and Hexadecimal Numbers

While there are an infinite number of bases with which to represent numbers, we discuss three will be the most useful to us, as computer scientists: **decimal**, **binary**, and **hexadecimal** representations.

@tbl-dec-hex-bin probably makes little sense to you at the moment, but we present it first so you can make some educated guesses. We will expand this table at the end of this section.

:::{table} Decimal, binary, and hexadecimal digits.
:label: tbl-dec-hex-bin
:align: center

| System | \# Digits | Digits |
| :--- | :-: | :--- |
| Decimal | 10 | `0, 1, 2, 3, 4, 5, 6, 7, 8, 9` |
| Binary | 2 | `0, 1` |
| Hexadecimal | 16 | `0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A,  B,  C,  D,  E,  F` |

:::

Let us first understand how the three representations above are rooted in mathematics. Then we will answer each of the following questions:

1. What does the binary representation `1101` represent? What about the hexadecimal representation `A5`?
1. How do we represent the number 3271? What about 165?
1. How do we differentiate between binary, decimal, and hexadecimal digits?
1. Why do we care? Why is hexadecimal useful?

### Decimal: Base 10 (Ten) Numbers

First, consider **decimal numbers**. The decimal value $3271$ is written in that order, because it describes how to count powers of **ten** to create the number three thousand, two hundred seventy-one.

In the equation below, the superscript $10$ denotes a base-10 value. We then see how each of the four digits determine the number of times each power of ten is included in the number. Note that the smallest power of 10 we consider is $10^0 = 1$, because we are only considering non-negative integers at this time.

$$
\begin{align}
3271
&= 3271_{10} \\
&=  (3 \times 10^3) + (2 \times 10^2) + (7 \times 10^1) + (1 \times 10^0)
\end{align}
$$

### Base 2 (Two) Numbers, Binary

Similarly, binary numbers like `1101` are written in that order to describe how to count powers of **two**. The two **bi**nary digi**ts**, `0` and `1`, are the namesake of the **b**it (which takes on those two values).

Let's address question 1:

> 1. What does the binary representation `1101` represent? 

Because humans think in decimal, we convert this binary value to decimal. We prepend the prefix `0b` to denote that the numeral `1101` should be interpreted in base 2; the **shorthand** `0b1101`is equivalent to the mathematical notation $1101_2$ but can be written with a standard keyboard.

$$
\begin{align}
\texttt{0b1101}
&= 1101_{2}	\\
&= (1 \times 2^3) + (1 \times 2^2) + (0 \times 2^1) + (1 \times 2^0) \\
&=  8         +  4        +  0         +  1 \\
&=  13
\end{align}
$$

## Base 16 (Sixteen) #s, Hexadecimal

TODO: GOT TO HERE

Digits:

```
0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A,  B,  C,  D,  E,  F
                              10, 11, 12, 13, 14, 15
```

Example: Hexadecimal number “A5”

Convert to decimal:

$$
\begin{align}
\texttt{0xA5}
&= A5_{16} \\
& = (10 \times 16^1) + (5 \times 16^0) \\
& =  160        +  5 \\
& =  165
\end{align}
$$

“Hex” for short. Common hex shorthand: `0xA5`

## Convert from Decimal to Binary

The following @tbl-dec-hex-bin will not make much sense to you at first. It shows each of the first sixteen numbers in three different representations: decimal (as two digits), hexadecimal (as one digit), and binary (as four digits):

:::{table} First sixteen numbers as decimal, hexadecimal, and binary representations.
:label: tbl-dec-hex-bin-16
:align: center

| Number | `Dec` | `Hex` | `Bin` |
| :--- | :--- | :- | :--- | 
| 0 | `00` | `0` | `0000` |
| 1 | `01` | `1` | `0001` |
| 2 | `02` | `2` | `0010` |
| 3 | `03` | `3` | `0011` |
| 4 | `04` | `4` | `0100` |
| 5 | `05` | `5` | `0101` |
| 6 | `06` | `6` | `0110` |
| 7 | `07` | `7` | `0111` |
| 8 | `08` | `8` | `1000` |
| 9 | `09` | `9` | `1001` |
| 10 | `10` | `A` | `1010` |
| 11 | `11` | `B` | `1011` |
| 12 | `12` | `C` | `1100` |
| 13 | `13` | `D` | `1101` |
| 14 | `14` | `E` | `1110` |
| 15 | `15` | `F` | `1111` |

:::

One way to view these representations is as a symbol lookup table, where you memorize each row, then translate back and forth. However, this approach is not particularly scalable---for example, how would you represent the number 20?---so instead we describe how these representations are grounded in mathematics.

E.g., 13 to binary?
Start with the columns

<html>
  <head>
    <title>Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1aihcZDiAEMCarSs-QIzRE_ixW5mACYYTykdmRyqIZUc/edit?usp=sharing)</title>
  </head>
  <iframe src="https://docs.google.com/presentation/d/e/2PACX-1vSRRi1DDwigsxmr5R_fPwZ1uAOKKJ-fblPQg6GFNICf9he20UUYX_gZLwdrMG4HRvrtcD3e9nkBwk29/pubembed?start=false&loop=false" frameborder="0" width="480" height="400" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</html>

Left to right, is (column) ≤ number n? 

* If yes, put how many of that column fit in n, subtract col * that many from n, keep going. 
* If not, put 0 and keep going. (and Stop at 0)

## Convert from Decimal to Hexadecimal

Left to right, is (column) ≤ number n? 

* If yes, put how many of that column fit in n, subtract col * that many from n, keep going. 
* If not, put 0 and keep going. (and Stop at 0)

<html>
  <head>
    <title>Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1rHScPLQLom3OzhZyGzhct8vpXtO-AWRiXyr5C-9Qszs/edit?usp=sharing)</title>
  </head>
  <iframe src="https://docs.google.com/presentation/d/e/2PACX-1vTWgqxt2kl5ip7bRfRY7P81WiQGDJSrAuKmkqE1m3mnrerVBeN2s9PGJVVaIQu0aDlsNfuvcRCK09q9/pubembed?start=false&loop=false" frameborder="0" width="480" height="400" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true" ></iframe>
</html>

## Convert Binary -> Hexadecimal

* Binary -> Hex? Easy!
  * **Left-pad** with 0s
  * (Group into full 4-bit values)
  * Look it up
  * `0b11110`
  * `→ 0b00011110`
  * `(→ 0b0001 1110)`
  * `→ 0x1E`

* Hex -> Binary? Easy!
  * Just look it up
  * `0x1E`
  * `→ 0b00011110` 
  * `→ 0b11110` (drop leading 0s)

Binary odometer

:::{figure} images/odometer.jpg
:label: fig-odomter
:alt: ""
:width: 70%

Car odometer
:::

## Which base do we use?

* **Decimal**: great for humans, especially when doing arithmetic
* **Hex**: if human looking at long strings of binary numbers, its much easier to convert to hex and see 4 bits/symbol
  * Terrible for arithmetic on paper
* **Binary**: what computers use
  * To a computer, numbers are always binary
  * Regardless of how number is written:
  * 32~ten~ == 32~10~ == `0x20` == 100000~2~ == `0b100000`

* To avoid confusion:


| System | \# Digits | Subscript (informal) | Prefix | Digits | 
| :--- | :-: | :--- | :-- | :----- |
| Decimal  | 10 | "ten" | (none) | `0, 1, 2, 3, 4, 5, 6, 7, 8, 9` |
| Binary  | 2 | "two" | `0b` | `0, 1` | 
| Hexadecimal | 16 | "hex" | `0x` | `0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A,  B,  C,  D,  E,  F` | 
: Expanded view of @tbl-dec-hex-bin, with notation for informal math subscripts (if useful to avoid confusion) and numeral prefixes. {#tbl-dec-hex-bin-expanded}

## The computer knows it, too

```c
#include <stdio.h>
int main() {
  const int N = 1234;
  printf("Decimal: %d\n",N);
  printf("Hex: 	  %x\n",N);
  printf("Octal:   %o\n",N);

  printf("Literals (not supported by all compilers):\n");
  printf("0x4d2         = %d (hex)\n", 0x4d2);
  printf("0b10011010010 = %d (binary)\n", 0b10011010010);
  printf("02322         = %d (octal, prefix 0 - zero)\n", 0x4d2);
  return 0;
}
```

Output:

```
Decimal: 1234
Hex:     4d2
Octal:   2322
Literals (not supported by all compilers):
0x4d2         = 1234 (hex)
0b10011010010 = 1234 (binary)
02322         = 1234 (octal, prefix 0 - zero)
```
