---
title: "Bitwise Operations"
---

## Learning Outcomes

* Understand how bitwise operations "flip" or "keep" bits from operands.
* Identify use cases for AND, OR, XOR, and NOT.

::::{note} 🎥 Walkthrough Video
:class: dropdown

Please access [this YouTube video](https://www.youtube.com/watch?v=Q7w9wXs8ZBM) using UC Berkeley login.

Our sincerest thanks for this video recording go to Adelson Chua, one of our Fall 2022 CS 61C course staff members.
::::

So far, we have learned about arithmetic operations involving [binary numbers](#sec-integer-reps). In this section, we will learn about **bitwise operations**.

## Bitwise Operations

We denote the bitwise operations AND, OR, XOR, and NOT as the operators `&`, `|`, `^`, and `~`, respectively. Supposing `a` and `b` are single-bit values, the following **truth tables** specify the result `y` of each operation.[^bool-logic]

[^bool-logic]: The name "truth table" comes from boolean logic itself. We discuss this later in logic design, when it is useful to represent signals as "high" or "low".

@tab-and is bitwise AND. `a & b` is `1` only if **both** `a` **and** `b` are 1. Otherwise, it is `0`.

:::{table} AND: `y = a & b`
:label: tab-and
:align: center

| `a` | `b` | `y` |
| :--: | :--: | :--: |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |
:::

@tab-or is bitwise OR. `a | b` is `1` only if **either** `a` **or** `b` are 1. Otherwise, it is `0`.

:::{table} OR: `y = a | b`
:label: tab-or
:align: center

| `a` | `b` | `y` |
| :--: | :--: | :--: |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |
:::

@tab-not is bitwise NOT. It is a unary operator because it only takes one operand. `~a` is `1` only if `a` is 0. If `a` is 1, then `~a` is 0.

:::{table} NOT: `y = ~a`
:label: tab-not
:align: center

| `a` |`y` |
| :--: | :--: |
| 0 | 1 |
| 1 | 0 |
:::

@tab-xor is bitwise XOR ("exclusive OR"). `a ^ b` is `1` only if **one of** `a` and `b` is 1. Otherwise if both `a` and `b` are `0` or `1`, `a^b` is `0`.

:::{table} XOR: `y = a ^ b`
:label: tab-xor
:align: center

| `a` | `b` | `y` |
| :--: | :--: | :--: |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |
:::

(sec-bitwise-props)=
### Properties of Bitwise Operations

The below properties in @tab-bitwise-props hold for a single-bit value `x`. We leave the proofs to you.

:::{table} Properties of bitwise operations AND, OR, and XOR.
:label: tab-bitwise-props
:align: center

| Bitwise Operation | Example | Result | Colloquially |
| :--: | :--: | :--: | :-- |
| AND | `x & 0` | `0` | set to 0 |
| AND | `x & 1` | `x` | keep/pass-through |
| OR | `x \| 0` | `x` | keep/pass-through |
| OR | `x \| 1` | `1` | set to 1 |
| XOR | `x ^ 0` | `x` | keep/pass-through |
| XOR | `x ^ 1` | `~x` | flip/invert |
:::

Because of its behavior, we also call XOR a "conditional inverter". We discuss this more when we design logic gates.

## C: Bitwise Operations vs. Logical Operations

The bitwise operators `&`, `|`, and `~` are used in C. With n-bit operands, bitwise operations are performed on the binary numeral(s) **one bit at a time**; the result's bitwidth depends on the input operands. See @tab-bitwise for examples on 8-bit `char` values.

:::{table} Bitwise operation examples with 8-bit `char` values.
:label: tab-bitwise
:align: center

| Bitwise Operation | C example | Result |
| :---: | :--- | :--- |
| AND| `0b00001001 & 0b00000011` | `0b00000001` |
| OR | `0b00001001 \| 0b00000011` | `0b00001011` |
| XOR | `0b00001001 ^ 0b00000011` | `0b00001010` |
| NOT | `~0b00001001` | `0b11110110` |
:::

However, note that C bitwise operators should **not** be confused with the C **logical operators** `&&`, `||`, and `!`.  By contrast, **Logical operations**  translate bit values to truthy and and falsy values. These types of operations are also known as **boolean compound operators**[^python-bool].

[^python-bool]: In Python, the boolean operators are `and`, `or`, and `not`. Python also supports bitwise operators `&`, `|`, `~`, and `^`.

:::{note} Example

Given the 4-bit signed integers `0b0101` and `0b0100`:

* Bitwise AND: `0b0101 & 0b0100` is `0b0100`, or 4.
* Logical AND: `0b0101 && 0b0100` is true, because both values are true.
* Bitwise NOT: `~0b0101` is `0b1010`.
* Logical NOT: `!0b0101` is false.
:::

## Bitmasks

This is our first foray into bitwise operations. Why do we care?

Remember that `n` bits can represent $2^n$ things, and we often want to use bits to represent many more things than just numbers. Suppose we wanted to use bit patterns to represent whether `n` things were present. We could then use each of our `n` bits to represent whether each thing was present (`1`) or not `0`.

Using bitwise operations (and the [properties of such bitwise operations](#sec-bitwise-props)) will be very convenient for updating state using bit patterns called **bitmasks**.

:::{note} Example 1

Suppose the state of four things A, B, C, D is represented by the 4-bit pattern `x`, where A is represented by the leftmost bit, B by the second left, and so on.

* If `x` is `0b0110`, then B and C are present.
* Suppose we wanted to update `D` to present. `x | 0b0001` does this. `0b0001` is called a bitmask.
* Suppose we wanted to reset A, B, C to not present. `x & 0b0001` does this. `0b000` is also called a bitmask.
:::

:::{note} Example 2
Suppose that `N` is a 32-bit value (i.e., 4 bytes). We can get the least significant byte (LSB) of `N` by using the bitmask `0xFF`: `N & 0xFF`. Verify this works with any 32-bit value of `N`!

:::

Bitwise operations will be very useful for boolean logic later on when we introduce logic gates.

## More C Bitwise Operators: Left and Right Shift

Two additional operations describe **bit shifts**. 
We will revisit bit shifting operations later in the course. For now, we define them for the sake of being comprehensive.

Suppose you have the 8-bit bit patterns (where we put spaces between nibbles for readability):

* `x`, with bit pattern `0001 0001`
* `y`, with bit pattern `1111 0001`

**Left shift** `x << n` shifts the bits of `x` left by `n` bytes, filling the lower bits coming in from the right with `0`'s. Mathematically, this is equivalent to multiplying `x` by $2^{\texttt{n}}$. For example, `x << 3` gives the bit pattern `0000 1000`, where the leftmost `1` gets "shifted out."

**Right shift**, `x >> n` shifts the bits of `x` right by `n` bytes. Mathematically, this is equivalent to taking the floor of a division by $2^{\texttt{n}}4 We will still need to fill in the top bits coming in from the right somehow, but the precise operation in C depends on `x`'s type.

* **Logical right shift** "zero-extends" and fills the top bits with `0`. If `x` is an unsigned 8-bit integer, then `x >> 2` gives the bit pattern `0000 0100`, where the rightmost `1` gets shifted out. This is equivalent to `(unsigned char) 17 >> 2` yielding `4`.

* **Arithmetic right shift** "sign-extends" and fills the top bits with the sign bit of `x`. Arithmetic right shift therefore preserves the sign bit of the result when using signed operands.

:::{note} Example

If `y` is a two's complement 8-bit signed integer with bit pattern `1111 0001`, then `y >> 2` gives the bit pattern `1111 1100`, where the rightmost `1` gets shifted out. This is equivalent to `(char) -15 >> 2` yielding `-4`.

:::

:::{tip} Quick check

Why do we not define logical and arithmetic for _left_ shift?
:::

:::{note} Show answer
:class: dropdown

Logically, left-shifting shifts a bit pattern left and inserts zeros. Arithmetically, left-shifting a number (regardless of its sign) multiplies it by a power of two, which also inserts zeros. Arithmetic and logical left shifts are therefore equivalent.
:::

:::{tip} Practice
After the below code is executed, what is `y`?

```c
uint32_t N = 0x34FF;
uint32_t y = N & ((N << 0x10) >> 0x8);
```

* **A.** `0x0`
* **B.** `0x3400`
* **C.** `0x4F0`
* **D.** `0xFF00`
* **E.** `0x34FF`
* **F.** Something else

:::

::::{note} Explanation

**B.** `0x3400`.

* `N` is `0x000034FF`
* `N << 0x10` is `0x34FF 0000`. We left shift `N` by 16.
* `(N << 0x10) >> 0x8` is `0x0034 FF00`. Because `N` is an unsigned integer, arithmetic right shift by 8 inserts zeros and is equivalent to logical right shift.
* `N & (N << 0x10) >> 0x8` is `0x0000 3400`, as per @fig-bit-shift. Note that `0x34 & 0x00` and `0xFF & 0x00` are both zero, because AND-ing anything with 0 sets all bits to zero.


:::{figure} images/bit-shift.png
:label: fig-bit-shift
:width: 50%
:alt: "TODO"

Result of `N & (N << 0x10) >> 0x8`, i.e., `0x000034FF & 0x0034 FF00`
:::



 

::::
