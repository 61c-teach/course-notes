---
title: "Binary, Decimal, Hex"
---

(bin-dec-hex)=
## Learning Outcomes

* Translate between binary, decimal, and hexadecimal number representations
* Use hexadecimal as shorthand for binary
* Know when each representation is useful

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/5rmB4SvfDPo?si=7YF8BXMnDpFCQiCH
:width: 100%
:title: "[CS61C FA20] Lecture 02.2 - Number Representation: Conversions"
:::

::::

## Introduction

In this section, we discuss how computer architects and computer scientists translate between the rich world that humans see and information that computers store. The former is framed by how humans think—after all, we have ten fingers, also known as "digits". The latter is in bits.


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

The alien, the astronaut, and the pile of rocks use three different representations of the number *four*. The astronaut uses the numeral 4 to represent four as a base-10 integer. The alien uses the numeral 10 to represent four as a base-4 integer. The pile of rocks uses four rocks to represent four as, well, a pile of rocks.

## Binary, Decimal, and Hexadecimal Representations

While there are an infinite number of bases with which to represent numbers, we discuss three will be the most useful to us, as computer scientists: **decimal**, **binary**, and **hexadecimal** representations.

@tbl-dec-hex-bin probably makes little sense to you at the moment, but we present it first so you can make some educated guesses.

:::{table} Decimal, binary, and hexadecimal digits.
:label: tbl-dec-hex-bin
:align: center

| System | \# Digits | Digits |
| :--- | :-: | :--- |
| Decimal | 10 | `0, 1, 2, 3, 4, 5, 6, 7, 8, 9` |
| Binary | 2 | `0, 1` |
| Hexadecimal | 16 | `0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A,  B,  C,  D,  E,  F` |

:::


### Decimal: Base 10 (Ten) Numbers

First, consider **decimal** numerals. The decimal numeral $3271$ is written in that order, because it describes how to count powers of **ten** corresponding to the equation below (note the superscript $10$ denotes a base-10 numeral):

$$
\begin{align}
3271
&= 3271_{10} \\
&=  (3 \times 10^3) + (2 \times 10^2) + (7 \times 10^1) + (1 \times 10^0)
\end{align}
$$

Each of the four digits specify a *count* of a power of ten. We add these up to get the number three thousand, two hundred seventy-one.

:::{note} Explanation
:class: dropdown

* The **rightmost** digit, *1*, corresponds to the **smallest** power of 10 that composes a non-negative integer. This is the zero-th power, or $10^0 = 1$. We include *one*.
* The next digit, $7$, corresponds to the next smallest power of 10, which is $10^1 = 10$, or ten. We include *seven* tens.
* The next digit, $2$, corresponds to the next smallest power of 10, which is $10^2 = 100$, or one hundred. We include *two* hundreds.
* The final **leftmost** digit, corresponds to the **largest** power of 10 for this number, which is $10^3 = 1000$, or one thousand. We include *three* thousands.
:::

This process will seem natural to you—because we humans think in base ten—but we will see that we can apply this understanding to represent numbers in other bases. Nevertheless, we highlight a few implicit assumptions:

* For now, we only consider powers of 10 needed to compose non-negative integers; we will discuss how to represent fractions later. The smallest such power of 10 is $10^0 = 1$.
* The "largest" power of 10 for this number can be more precisely defined as the largest power of 10 corresponding to a non-zero digit. In other words, the decimal $0 \dots 03271$ with leading zeros (on the left) and the decimal $3271$ represent the same number.
* Base ten uses the ten digits `0` to `9` to create unique decimal representations. In other words, to form the decimal $10$, instead of using ten of $10^0$, we use one $10^1$ and zero $10^0$. [Wikipedia](https://en.wikipedia.org/wiki/Radix) provides a more formal discussion of uniqueness.

### Base 2 (Two) Numbers, Binary

Binary numbers like `1101` are written in that order to describe how to count powers of **two**. Notably, the two **bi**nary digi**ts**, `0` and `1`, are the namesake of the **b**it (which takes on those two values).

> What does the binary numeral `1101` represent? 

Because humans think in decimal, we convert this binary value to decimal with a similar process as above: 

$$
\begin{align}
\texttt{0b1101}
&= 1101_{2}	\\
&= (1 \times 2^3) + (1 \times 2^2) + (0 \times 2^1) + (1 \times 2^0) \\
&=  8         +  4        +  0         +  1 \\
&=  13
\end{align}
$$

:::{note} Explanation
:class: dropdown

* The **rightmost** digit, *1*, corresponds to the **smallest** power of **2** that composes a non-negative integer. This is *still* the zero-th power, or $2^0 = 1$. We include *one* one.
* The next digit, *0*, corresponds to $2^1 = 2$, or two. We include *zero* twos.
* The next digit, *1*, corresponds to $2^2 = 4$, or four. We include *one* four.
* The final **leftmost** digit, *1* corresponds to $2^3 = 8$, or eight. We include *one* eight.

Adding up one one, zero twos, one four, and one eight gives thirteen, or the decimal $13$.
:::

Other notes:

* We prepend the prefix `0b` to denote that the numeral `1101` should be interpreted in base 2; the **shorthand** `0b1101` is equivalent to the mathematical notation $1101_2$ but can be written with a standard keyboard.
* Like before, `0b0...01101` and `0b1101` represent the same nunber, thirteen.
* Because there are just two binary digits `0` and `1`, in binary we are always either including a value (here, a specific power of two), or not including it. `1` or `0`, `True` or `False`. This idea of binary representing "inclusion" or "exclusion" will show up repeatedly in this course.

### Base 16 (Sixteen) #s, Hexadecimal

Finally, we consider hexadecimal numbers.

> What does the hexadecimal numeral `A5` represent? 

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

We prepend the prefix `0x` to denote that the numeral `A5` should be interpreted in base 16. Like before, the shorthand `0xA5` is equivalent to $A5_{16}$ but can be written with a standard keyboard.

Hexadecimal digits are useful as shorthand for representing groups of four binary digits. We discuss more [at the end of this section](#which-base).

## Convert between representations

:::{tip}
Memorize @tbl-dec-hex-bin-16. As you will soon see, it will be useful to quickly convert between decimal, binary, and hexadecimal representations.

:::

:::{table} First sixteen numbers as decimal, hexadecimal, and binary representations.
:label: tbl-dec-hex-bin-16
:align: center

| Number | Hexadecimal | Binary |
| :--- | :- | :--- | 
| 0 | `0` | `0000` |
| 1 | `1` | `0001` |
| 2 | `2` | `0010` |
| 3 | `3` | `0011` |
| 4 | `4` | `0100` |
| 5 | `5` | `0101` |
| 6 | `6` | `0110` |
| 7 | `7` | `0111` |
| 8 | `8` | `1000` |
| 9 | `9` | `1001` |
| 10 | `A` | `1010` |
| 11 | `B` | `1011` |
| 12 | `C` | `1100` |
| 13 | `D` | `1101` |
| 14 | `E` | `1110` |
| 15 | `F` | `1111` |

:::

Let's discuss conversion in more detail. We only consider "unsigned" numerals, i.e., non-negative numbers.

If we have an $n$-digit unsigned numeral $d_{n-1}$ $d_{n-2}$...$d_0$ in radix (or base) $r$, then the value of that numeral is:
$$
\sum_{i=0}^{n-1} r^i d_i
$$
which is just fancy notation to say that instead of a 10's or 100's place we have an $r$'s or $r^2$'s place. For the three radices binary, decimal, and hex, we just let $r$ be 2, 10, and 16, respectively. 

### Decimal $\rightarrow$ Binary

The slidedeck below shows how we can convert the decimal $13$ into its binary representation, `0b1101`.

<html>
  <head>
    <title>Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1aihcZDiAEMCarSs-QIzRE_ixW5mACYYTykdmRyqIZUc/edit?usp=sharing)</title>
  </head>
  <iframe src="https://docs.google.com/presentation/d/e/2PACX-1vSRRi1DDwigsxmr5R_fPwZ1uAOKKJ-fblPQg6GFNICf9he20UUYX_gZLwdrMG4HRvrtcD3e9nkBwk29/pubembed?start=false&loop=false" frameborder="0" width="480" height="400" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
  <br/>
</html>

Let `val` be $13$ in the explanation below. Click to show.

:::{note} Explanation
:class: dropdown

Make columns 1, 2, 4, 8, which correspond to increasing integer powers of two. These columns also correspond to a 4-digit binary number, e.g., `0b _ _ _ _`.

1. Take the largest power of two: $2^3 = 8$, or eight. This "fits" into `val`, so "use" it. "Using" means we need the binary digit `1`. Set the 4th-from-the-right space to `1`, i.e., populate `0b 1 _ _ _`. Because we have now "used up" eight, subtract it and update `val` to 5. This is the remainder we have to represent.
1. Take the next power of two: $2^2 = 4$, or four. "Use" it by setting the 3rd-from-the-right space to `1`, i.e., populate `0b 1 1 _ _`. Update `val` to 1.
1. Take the next power of two: $2^1 = 2$, or two. We cannot "use" it because it is too big. "Not using" means we need the binary digit `0`. Set the second-from-the-right space to `0`, i.e., populate `0b 1 1 0 _`. `bal` is unchanged and is still 1.
1. Take the next power of two, which is also the smallest: $2^0 = 1$, or one. "Use" it by setting the rightmost space to `1`, i.e., populate `0b 1 1 0 1`. Update `val` to 0.

The resulting **binary string** is `0b1101`. By yourself, practice going the other way and check that `0b1101` represents the decimal number $13$.

:::

The process above relies on a few colloquial observations:

* The largest power of two we could possibly need is less than the number `val` itself.
* The smallest power of two we could possibly need is always the zero-th power, i.e., $2^0 = 1$.
* Start with larger power of twos first. Otherwise you may run into scenarios where you count beyond the number of digits available (here, only `0` and `1`).

Here is one attempt at colloquially describing the algorithm to convert a number `val` into its binary representation:

* Make a set of columns, one for each power of two. This corresponds to your $n$-digit binary number, e.g., `0b _ _ ... _ _`, with $n$ blanks.
* Start from the leftmost column and go right (i.e., for $i$ from $n-1$ to $0$, inclusive):
  * For the current column $i$, corresponding to $2^i$:
    * Is the current column less than or equal to `val`?
        * If yes, count how many $2^i$ fit into `val`. For base 2, the count is `1`, so subtract $1 \times 2^i$ from `val`. Keep going.
        * If no, put `0` and keep going.
* Stop this process once `val` hits zero.

### Decimal $\rightarrow$ Hexadecimal

The slidedeck below converts $165$ into its hexadecimal representation, `0xA5`.

<html>
  <head>
    <title>Animation that steps through the enumerated text in this section. Access [original Google Slides](https://docs.google.com/presentation/d/1rHScPLQLom3OzhZyGzhct8vpXtO-AWRiXyr5C-9Qszs/edit?usp=sharing)</title>
  </head>
  <iframe src="https://docs.google.com/presentation/d/e/2PACX-1vTWgqxt2kl5ip7bRfRY7P81WiQGDJSrAuKmkqE1m3mnrerVBeN2s9PGJVVaIQu0aDlsNfuvcRCK09q9/pubembed?start=false&loop=false" frameborder="0" width="480" height="400" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true" ></iframe>
</html>

Let `val` be $165$ in the explanation below. Click to show.

:::{note} Explanation
:class: dropdown

Make columns 1, 16, 256, 4096 which correspond to increasing integer powers of sixteen. These columns also correspond to a 4-digit binary number, e.g., `0x _ _ _ _`.

1. Take the largest power: $16^3 = 4096$. This does not fit into `val`, so we set the 4th-from-the-right space to `0`, e.g., `0x 0 _ _ _`.
1. Take the next power: $16^2 = 256$. This does not fit into `val`, so we set the 3rd-from-the-right space to `0`, e.g., `0x 0 0 _ _`.
1. Take the next power: $16^1 = 16$. Count how many times you can "use" it; at most ten $16$'s fit into `val`, which is currently $165$. Ten is the hexadecimal digit `A`, so we set the 2nd-from-the-right space to `A`, e.g., `0x 0 0 A _`. Subtract $10 \times 16^1$ from $165$ and update `val` to $5$.
1. Take the next power, which is also the smallest: $16^0 = 1$, or one. Count how many times you can "use" it; at most five $1$'s fit into `val`, which is currently $5$. Se the rightmost space to `5`, e.g., `0x 0 0 A 5`. Update `val` to $0$.

The resulting hexadecimal numeral is `0x00A5`, or equivalently, `0xA5` if we dropped leading zeros.

You may have noticed that we included $16^3$ and $16^2$, which are both too large for representing $165$. This is to show you that leading zeros are alright and can be dropped once you have gotten your result.

:::

We leave it to you to translate the binary conversion process we described colloquially into a hexadecimal conversion process.

### Binary $\leftrightarrow$ Hexadecimal Is Straightforward

Given the above, consider the following process for converting to binary to hexidecimal, which composes the processes we've discussed above:

1. Convert binary to decimal.
1. Convert decimal to hexadecimal.

This process is tedious—computing powers of twos is doable, but does every computer architect memorize powers of sixteen? Instead, we can _directly_ convert between binary and hexadecimal with the observation:

> There exists a one-to-one mapping between the set of hexadecimal digits and the set of length-four binary strings.

The above observation implies that a $4k$-length binary string can be translated into a $k$-length hexadecimal string by independently converting each length-4 binary string into a hexadecimal digit, then concatenating the result. (We leave the proof of this to those of you that are enthusiastic mathematicians.) This makes conversion between binary and hexadecimal much easier:

To convert `0x1E` to binary:

* `1` in hexadecimal is `0001` in binary
* `E` in hexadecimal is `1110` in binary
* Concatenate: `0001 1110` (we include the spaces to make visualizing easier)
* Drop leading zeros and compress spaces. (Optional) Add the `0b` prefix to denote binary: `0b11110`

To convert `0b11110` to hexadecimal:

* First group into full 4-bit strings, left-padding with zeros where necessary: `0001 1110`
* `0001` in binary is `1` in hexadecimal
* `1110` in hexadecimal is `E` in hexadecimal
* Concatenate: `0x1E` (we add the `0x` prefix to denote hexadecimal)


:::{tip}
Again, memorize @tbl-dec-hex-bin-16!
:::

## The computer knows it, too

At this point, it's worthwhile to remind first-time readers that the two-character prefix `0b` and `0x` denote that the digits should be interpreted as binary and hexadecimal representations, respectfully. The `0` in `0b` and `0x` doesn't mean anything by itself.

These prefixes allow computers to parse strings of digits and interpret them in their intended base.

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

We don't expect you to understand this code at this time. We will discuss C syntax, compilers, literals, etc. very soon. We also will not cover octal literals in this course; most standard C compilers will recognize hexadecimal and binary literals.

(which-base)=
## Which base do we use?

Remember that there is only ever one number that can be represented in multiple ways. These are all the same number, thirty-two:

* $32_{10}$, or simply $32$. We recommend you write $32_{ten}$ if you're writing by hand.
* `0x20`, or the hexadecimal numeral `20`
* `0b10000`, or the binary numeral `10000`
* $20_{16}$. We recommend $32_{hex}$ if you're writing by hand.
* $10000_{2}$. We recommend $10000_{two}$ if you're writing by hand.

Different representations serve different purposes:

* **Decimal**: Great for humans, especially when doing arithmetic. We hope you won't ever forget base-10 :-)
* **Binary**: What computers use. To a computer, numbers are stored as binary data, regardless of how numbers are specified.
* **Hex**: Hopefully you have realized by now that long strings of binary numbers are hard to parse. Hexadecimal is terrible for arithmetic on paper, but it is much more compact than binary while also being much much easier than decimal as a more compact way of representing binary values.

    We use two strategies in this course to more easily visualize strings of 32 bits, 64 bits, etc.:
    * Group 4 bits at a time
    * Convert each group of 4 bits to its hexadecimal digit

Above all, remember that computers operate in binary, but humans don't. So it's good to get more comfortable with converting between these representations before we move further.

