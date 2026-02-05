---
title: "IEC and Base-10 Prefixes"
---

## Learning Outcomes

* Use base-10 prefixes to characterize powers of ten.
* Use binary prefixes to characterize powers of two.
* Get comfortable with mathematics involving powers of two.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/IObh0p5Qe_A
:width: 100%
:title: "[CS61C FA20] Lecture 24.1 - Caches I: Binary Prefix"
:::

::::

It is unwieldy to use numbers like 4,294,967,296 to describe the $2^32$ bytes of address space on 32-bit architectures. Instead, we much prefer terminology like 2 GiB ("gibibytes").

This short reference introduces prefixes for numbers in powers of ten and two This terminology helps us describe quantites, from sizes of caches and hard drives to network transmission rates.

### Base-10 Prefixes

We will find it very convenient to use prefixes like "kilo", "giga", etc. to refer to large base-10 numbers.  @tab-base-10-prefixes describes the base-10 prefixes commonly used in this class.


:::{table} Base-10 prefixes for numbers.
:label: tab-base-10-prefixes
:align: center

| Prefix | Abbreviation | Power |Value |
| :--- | :--- | :--- | :--- |
| Kilo | K | $10^3$ | 1,000 |
| Mega | M | $10^6$ | 1,000,000 |
| Giga | G | $10^9$ | 1,000,000,000 |
| Tera | T | $10^12$ | 1,000,000,000,000 |
| Peta | P | $10^15$ | 1,000,000,000,000,000 |
| Exa | E | $10^18$ | 1,000,000,000,000,000,000 |
| Zetta | Z | $10^21$ | 1,000,000,000,000,000,000,000 |
| Yotta | Y | $10^24$ | 1,000,000,000,000,000,000,000,000 |
:::

The abbreviations are then used as prefixes to units: 4 KB (four kilobytes), 10 Mbps (ten megabits per second), etc.

These "Common-use prefixes" are close to those used by SI (the [International System of Units](https://en.wikipedia.org/wiki/International_System_of_Units)), with the exception of "kilo" (which is lowercase "k" in SI but uppercase "K" in computing).

:::{tip} Quick Check

What is 4 KB?
:::

:::{note} Show answer
:class: dropdown

4,000 bytes. 4 KB = $ 4 \times 10^3 $ B
:::

## IEC (Binary) prefixes

The IEC (International Electrotechnical Commission) defined binary prefixes like "kibi", "mebi", etc., to describe large binary numbers. @tab-binary-prefixes describes the binary prefixes commonly used in this class.


:::{table} Binary (IEC) prefixes for numbers.
:label: tab-binary-prefixes
:align: center

| Prefix | Abbreviation | Power | Numeric Value |
| :--- | :--- | :--- | :--- |
| Kibi | Ki | $2^10$ | 1,024 |
| Mebi | Mi | $2^20$ | 1,048,576 |
| Gibi | Gi | $2^30$ | 1,073,741,824 |
| Tebi | Ti | $2^40$ | 1,099,511,627,776 |
| Pebi | Pi | $2^50$ | 1,125,899,906,842,624 |
| Exbi | Ei | $2^60$ | 1,152,921,504,606,846,976 |
| Zebi | Zi | $2^70$ | 1,180,591,620,717,411,303,424 |
| Yobi | Yi | $2^80$ | 1,208,925,819,614,629,174,706,176 |
:::

Like before, abbreviations can be used as prefixes to units: 4 GiB (four _gibi_-bytes, pronounced "ghee-bee"). The "bi" in each prefix likely stands for binary but is pronounced "bee." 

:::{tip} Quick Check

What is 4 KiB?
:::

:::{note} Show answer
:class: dropdown

4,096 bytes. 4 KiB = $ 4 \times 2^10 $ B
:::

## Get familiar with conversions

At small numbers, base-two and base-ten are comparable because one thousand (kilo, $10^3$) is close to 1,024 (kibi, $2^10$). This 2.4% difference compounds exponentially, with the binary prefix always indicating larger numbers than its base-ten counterpart.[^comparison].

[^comparison]: See [Wikipedia](https://en.wikipedia.org/wiki/Binary_prefix#Comparison_of_binary_and_decimal_prefixes)

In any case, to remember which binary prefixes correspond to which base-ten prefixes, we recommend remembering the approximation:

$$ 2^{10} \approx 10^3 $$

:::{tip} Quick Check

What is $2^{34}$ B?

:::

:::{note} Show answer
:class: dropdown

$$
\begin{align}
2^{34} &= 2^{4} \times 2^{30} \\
&= 16 \times 2^{30}
\end{align}
$$

$2^{34}$ B is 16 GiB.
:::

Knowing your prefix conversions helps identify the amount of memory or storage you will need for a particular application.

:::{tip} Quick Check

How many bits are needed at minimum to address 2.5 TiB of memory?
:::

:::{note} Show Answer
:class: dropdown

2.5 TiB is:

\begin{align}
2.5 \times 2^{40} &= 2^{40+x} \\
&= 2^x \times 2^{40}
\end{align}

The total number of bits we need is the sum of the following:

* 40 bits, to address bytes within each tibibyte chunk; and
* $x$ bits, to specify which of the 2.5 chunks we are in. To represent 0 to 2.5 with the smallest number of bits, we round up to the closest power of 2, $2.5 \leq 4 = 2^2$ chunks. So $x = 2$ (the power of two).

We need 22 bits at minimum to address 2.5 TiB of memory.
:::

## Mnemonics

You should become very familiar with both base-10 and binary prefixes. Here are some mnemonics, courtesy of previous students and instructors:

* Kid meets giant Texas people exercising zen yoga. – Rolf O
* Kind men give ten percent extra, zestfully, youthfully. – Hava E
* Kindness means giving, teaching, permeating excess zeal yourself. – Hava E
* Kindergarten means giving teachers perfect examples (of) zeal (&) youth
* Kissing Mel Gibson, Teddy Pendergrass exclaimed: “Zesty, yo!” – Dan G
* Kissing mom gives ten percent extra zeal & youth!

## Which to use?

**Base-10** prefixes are often used by hard disk manufacturers & telecommunications. For example, a Mbit/s connection transfers $10^6$ bits per second.

**Binary** prefixes are often used for RAM and Caches because they are conceptually closer to the architecture.

Operating Systems alternate between the two but seem to have settled on base-10.

Aside: Remember, base-10 numbers are smaller than their binary counterparts, e.g., 1TB is about 90% of 1TiB. This numeric difference has been the subject of numerous lawsuits against storage manufacturers accusing them of [false advertising](https://en.wikipedia.org/wiki/Vroegh_v._Eastman_Kodak_Co.), among other things.

In this course, we will specify numbers with the abbreviations in @tab-base-10-prefixes and @tab-binary-prefixes.
