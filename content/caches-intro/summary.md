---
title: "Summary"
---

## And in Conclusion$\dots$

### AMAT (Average Memory Access Time)
Recall that AMAT stands for Average Memory Access Time. This is a way to measure the performance of a cache system. The formula for AMAT is:

$\text{AMAT} = (\text{Hit Time}) + (\text{Miss Rate}) * (\text{Miss Penalty})$

In a multi-level memory hierarchies (e.g. multi-level caches), we can separate miss rates into two types that we consider for each level.
* **Global**: Calculated as the number of accesses that missed at that level divided by the total number of accesses **to the memory system**.
* **Local**: Calculated as the number of accesses that missed at that level divided by the total number of accesses **to that memory level**.

## Textbook Readings

P&H 5.1-5.4, 5.8, 5.9, 5.13

## Additional References

* [Cache Flowchart](https://inst.eecs.berkeley.edu/~cs61c/sp21/resources-pdfs/caches.pdf)

## Exercises

Check your knowledge!

### Short Exercises

**True/False**: If a piece of data is both in the cache and in memory, reading it from cache is faster than reading from memory

:::{note} Solution
:class: dropdown
**True.** The cache is smaller and faster than memory.
:::

<!-- **Conversions**: Convert the following numbers into the quantity of bytes each term represents (you may leave
your answer in terms of powers of 2). (See precheck section on IEC Prefixes for assistance)

**a) 4 KiB**

:::{note} Solution
:class: dropdown
One KiB is $2^{10}$ and $4 = 2^2$, so $4 \text{ KiB} = 2^2 \times 2^{10} = 2^{12}$ bytes.
:::

**b) 2 MiB**

:::{note} Solution
:class: dropdown
One MiB is $2^{20}$ and $2 = 2^1$, so $2 \text{ MiB} = 2^1 \times 2^{20} = 2^{21}$ bytes.
:::

**c) 8 Kib**

:::{note} Solution
:class: dropdown
Notice how the unit is Kib (Kibibits) and not KiB (Kibibytes). One Kib is $2^{10}$ bits, so $8 \text{ Kib} = 2^3 \times 2^{10} = 2^{13}$ bits. Because there are $8 = 2^3$ bits in one byte, we divide our answer to get $8 \text{ Kib} = 2^{10}$ bytes.  
*(Note that $8 \text{ Kib} = 1 \text{ KiB}$)*
:::

**d) 24 GiB**

:::{note} Solution
:class: dropdown
We can factor $24 = 4 \times 6 = 2^2 \times 2 \times 3 = 2^3 \times 3$. One GiB = $2^{30}$, so we can write $24 \text{ GiB} = 2^3 \times 3 \times 2^{30} = 3 \times 2^{33}$ bytes (alternatively, just $24 \times 2^{30}$ bytes).
:::

**e) 19 TiB**
:::{note} Solution
:class: dropdown
Note that 19 cannot be factored or easily representable in powers of 2. Following the same process as above, we can simplify to $19 \text{ TiB} = 19 \times 2^{40}$ bytes $\approx 19$ trillion bytes.
::: -->