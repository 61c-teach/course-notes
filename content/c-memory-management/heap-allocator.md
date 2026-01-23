---
title: "Implementing Memory Management"
subtitle: "This content is not tested"
---

## Learning Outcomes

This section is included as bonus content and is not tested. If you are curious about implementing your own heap allocator, take CS 162: Operating Systems!

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/5rmB4SvfDPo?si=7YF8BXMnDpFCQiCH
:width: 100%
:title: "[CS61C FA20] Lecture 02.2 - Number Representation: Conversions"
:::

::::

## Designing a Heap Allocator

Managing the heap is tricky. While you don't have to worry about the OS moving things around, you do have to manage your own size requests and how you work with that memory.

An ideal design:
* Has fast implementations of `malloc` and `free`
* Produces minimal memory fragmentation, i.e., the "bookkeeping" required to track memory.
* Avoids **fragmentation**, i.e., where most of free memory is in many small chunks. This implies many free bytes but an inability to satisfy a large request since the free bytes are not contiguous in memory.

**External fragmentation**: If you request 100 bytes (R1) and then 1 byte (R2), and then you free R1, your memory is now fragmented into two separate areas. When a third request (R3) comes in, the system has to be smart about where to put it based on past patterns.

## The K&R Malloc/Free Implementation

One implementation of a heap allocator is from Section 8.7 of K&R. This code uses some C language features we haven’t discussed and is written in a very terse style; don’t worry if you can’t decipher the code.

Bookkeeping: Each block of memory has a header that contains the **size** of the block and a **pointer to the next block**. This creates a **circular linked list** of all free blocks.

`malloc()`: When you make a request, the system searches this free list to see if it can serve the memory you want. If it walks the whole list and finds nothing, more memory is requested from the operating system. If the OS can’t satisfy the request, it returns `NULL`, signaling that the request failed.

`free()`: Checks if the blocks adjacent to the freed block are also free. If so, the adjacent free blocks are merged (**coalesced**) into a single, larger free block. Otherwise, the freed block is just added to the free list.

It’s important to realize that malloc is not "instant" like a stack array allocation, which takes about one clock cycle. malloc is a function call, meaning the stack has to grow just to call it, and then malloc has to perform the internal mechanics of walking that circular list. In the worst case, it might take a long time to search the entire list only to return `NULL`, causing your program to stall.

## Choosing a block in `malloc`

If there are multiple free blocks of memory that are big enough for some request, how do we choose which one to use? There are three common strategies:

1. **Best Fit**: This searches the entire list to find the block whose size is closest to what you asked for. While this provides the tightest fit, it often leaves behind tiny "slivers" of memory (like a 4-byte gap if you asked for 100 bytes from a 104-byte block), which makes the free list grow longer and longer.
2. **First Fit**: You grab the first block you find that is big enough. It’s fast, but it tends to create a lot of small "pebbles" or slivers at the beginning of the list that you have to skip over later.
3. **Next Fit**: This is like First Fit, but instead of starting at the beginning of the list every time, it resumes searching from where it stopped last time. This helps distribute the "pebbles" more evenly throughout the list.
