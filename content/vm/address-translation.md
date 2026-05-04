---
title: "Address Translation"
---

(sec-vm-address-translation)=
## Learning Outcomes

* Use a pre-populated page table to translate virtual addresses into physical addresses.
* Define a page fault and identify when an address translation scenario triggers a page fault.
* Explain, at a high-level, the operating system's role in address translation and handling page faults with context switches.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/jpMigarDfh4
:width: 100%
:title: "[CS61C FA20] Lecture 29.3 - Virtual Memory I: Memory Manager"
:::

::::

:::{note} Address translation
:label: block-address-translation

A "memory manager" (see [this section](#sec-memory-manager)) translates virtual addresses to physical addresses as follows:

1. A process requests a memory access at a given virtual address (VA).
1. Translate the virtual address to the physical address:
    * Extract virtual page number (VPN) from VA
    * Access the **page table entr**y corresponding to this VPN to look up the corresponding physical page number (PPN).
1. Construct the physical address (PA):
    * If the corresponding page table entry is valid, obtain the PPN from the page table entry and construct the PA by concatenating the PPN and the page offset.
    * If the corresponding page table entry is **not** valid, trigger a **page fault**. After the page is loaded from disk into memory, repeat this step.
1. Access memory at the physical address in memory and return to the process.

:::

In this section we discuss:

* How to do address translation when the data requested is in memory, i.e., no page fault occurs.
* How to do address translation when the data requested is **not** in memory, i.e., a page fault occurs.
* What is the "memory manager," i.e., the system performs address translation (see [this section](#sec-memory-manager)).

## Page Tables, Briefly

A page table keeps tracks of the VPN-to-PPN mappings for a given process. There is one page table per process.

* Each entry in a page table corresponds to a virtual page number (VPN) for this process. In this course, the number of entries in a process's page table is equivalent to the total number of virtual pages for the process.[^hierarchical-pt]
* If a page is in memory, the entry is valid and has the corresponding physical page number. Otherwise, it may have garbage, and accessing this entry should trigger a page fault.

[^hierarchical-pt]: We assume a single-level page table hierarchy in this course. In practice, multi-level (hierarchical) page tables are used to reduce the size of the page table. Read more in the [extra section](#sec-hierarchical-page-table).

We discuss the fine-grained details of page tables in [another section](#sec-page-table).

## Address Translation, Conceptually

### Case I: Page Is In Memory

Consider a scenario where a process has a 32-bit virtual address space, and physical memory is 16 KiB and paged into four 4 KiB pages. There are four steps to address translation, as shown by @fig-address-translation-i's animation. Fow now, conceptually, a page table entry is valid if it has a physical page number (PPN) and invalid if it is labeled "disk".

::::{figure}
:label: fig-address-translation-i
:alt: "Embedded slide deck animating address translation for virtual memory, Case I: the target page is in memory."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vQOMr3azgvCiLNd6mZyisZqT4gs0-P6I7phPyt7o5KNOE3fJCqPJ-yiyyKixNPxbyMF0CjazcKaAxEH/pubembed?start=false&loop=false
:width: 100%
:enumerated: false
:title: "Animation that steps through the enumerated text in this section about address translation . Access [original Google Slides](https://docs.google.com/presentation/d/1GtFuG_Oyo6V_ZrY37R5UM7arrzluN5nnuiUuSus-RLE/edit?usp=sharing)"
:::
Address Translation, Case I: The target page is in memory.
::::

:::{note} Explanation for @fig-address-translation-i
:class: dropdown

1. **Program requests a memory access at a virtual address (VA).** Here, load byte @ address `0xFFFF F004` to register `t0`. The value `0xFFFF F004` is a virtual address (VA).
2. **Translate the virtual address to physical address** (i.e., location in memory).
    * Extract the virtual page number (VPN) from the VA. The lower 12 bits of each address are reserved for the page offset (4 KiB pages = $2^{12}$ B pages), so the VPN is the upper 20 bits of VA, or `0xFFFFF`.
3. **Construct the physical address (PA).** The entry associated with VPN `0xFFFFF` has a valid page table entry. Access the entry for the physical page number (PPN, `0x2`) and concatenate it with offset `0x004` to construct physical address `0x1004`.
4. **Access memory at the physical address in memory and return to the process.** Here, the byte @ address `0x1004` is read and returned to the  process.
:::

This case is predicated on our page table entry being valid. A valid page table entry means that the virtual page has a corresponding physical page number, and therefore the page is in memory. Next, let's explore when the page is _not_ in memory.

### Case II: Page Fault

We continue our scenario with the same process. Now, suppose that the next memory access triggers a page fault, as shown in @fig-address-translation-ii's animation.

::::{figure}
:label: fig-address-translation-ii
:alt: "Embedded slide deck animating address translation for virtual memory, Case II: the target page is not in memory, triggering a page fault."
:::{iframe} https://docs.google.com/presentation/d/e/2PACX-1vTbLQECEMErmE2XPTIZjqwzMUdTYvmZWxYvMa1yvFqvBQ7ZG645I9nZdE2N8S8LLmkNUP16f2174XRQ/pubembed?start=false&loop=false
:width: 100%
:enumerated: false
:title: "Animation that steps through the enumerated text in this section about address translation. Access [original Google Slides](https://docs.google.com/presentation/d/1F5Y4renut4fcXZh05XArHGSJY4t_0QqvAhba5kAW8No/edit?usp=sharing)"
:::
Address Translation, Case II: The target page is not in memory, triggering a page fault. With demand paging, a page fault means the page is fetched from disk.
::::

:::{note} Explanation for @fig-address-translation-ii
:class: dropdown

1. **Program requests a memory access at a virtual address (VA).** Here, load byte @ address `0x6000 0030` to register `t0`. The value `0x6000 0030` is a virtual address (VA).
2. **Translate the virtual address to physical address** (i.e., location in memory).
    * Extract the virtual page number (VPN) from the VA. The lower 12 bits of each address are reserved for the page offset (4 KiB pages = $2^{12}$ B pages), so the VPN is the upper 20 bits of VA, or `0x60000`.
3. **Construct the physical address (PA).**
    * The entry associated with VPN `0x60000` does _not_ have a valid page table entry. An _invalid_ page table entry means that the physical page is not in memory.
    * Ask the OS to perform an interrupt to request the page from disk (see details in [this section](#sec-memory-manager)).
    * Once the page is loaded from disk into memory (about a million cycles later[^jim-gray]), resume the address translation.
    * The entry associated with VPN `0x60000` (now) has a valid page table entry. Access the entry for the physical page number (PPN, `0x2`) and concanate it with offset `0x030` to construct physical address `0x2030`.
4. **Access memory at the physical address in memory and return to the process.** Here, the byte @ address `0x2030` is read and returned to the  process.

[^jim-gray]: Jim Gray's [analogy figure](#fig-3-locality) for your reference.

:::

### Revisiting the Library Analogy

Let's understand virtual memory using our [library analogy](#sec-library) of the memory hierarchy.

* The book title is like a virtual address, and the [Library of Congress call number](https://ask.loc.gov/faq/396298) is like a physical address. We usually remember a book by its title (VA), and not its call number (PA).
* The card catalog is like a page table, which maps from book title to call number. If we went straight to the bookshelves to find a book number _without_ the call number, we likely wouldn't find the book. So the card catalog (page table) is important.
* The corresponding card entry in the catalog has useful information:
  * Valid bit: Does the book exist in this library? (Is the page in memory?) Or do you need to request a hold and be notified when the book is available in the library? (Trigger a page fault and notify when page is loaded from disk into memory?)
  * Access bit: Can you check out this book, or is it reference-only? (We discuss memory page access rights more in [this section](#sec-page-table).)

This analogy breaks down slightly because the page table is a **page number** lookup, not an address lookup. But we hope the weak analogy helps.

:::{tip} Quick Check

See [Spring 2025 Lecture 34 Slide 30](https://docs.google.com/presentation/d/1HXo7Adnk8eJZ53UVngsSEhPoneA-H02Qfpn8BjaAs1I/edit?slide=id.g34f3c4927f7_0_15#slide=id.g34f3c4927f7_0_15) for a practice exercise.

:::

(sec-memory-manager)=
## The "Memory Manager"

:::{hint} About the Operating System
:label: sec-os-overview

The **operating system (OS)** is likely the single largest piece of software on your system. It loads, manages, and runs programs (i.e., **processes**), providing

1. Isolation between processes, and
1. Interaction between processes and the outside world via I/O devices.

Most of the details of the operating system (OS) are out of scope for this course. Here are the sections that describe the key OS functions you should know:

* [Loader](#sec-loader)
* [Heap Memory Management](#sec-heap-allocator)
* [Context Switches](#sec-context-switch)
* [Virtual Memory Management](#sec-memory-manager)

We hope a future version of these course notes will discuss the operating system in more detail. To learn more about the OS, please check out [CS 61C Spring 2025 slides](https://docs.google.com/presentation/d/1sh0iTDWdZiH3dxVoeOs4Yxb4Kt369x80Sj3Y7Nnluwk/edit?usp=drive_link) and [the CS 61C Fall 2020 YouTube playlist](https://youtube.com/playlist?list=PLnvUoC1Ghb7ziIlgNnQ24Gb6HBmLQO4T4&si=fJiBnfbzKuOouZ8F).

:::

:::{note} Text from an [earlier section](#sec-memory-hierarchy)
```{embed} #block-hierarchy-management
```

:::

Virtual memory manages the two levels of the memory hierarchy represented by main memory and disk. The "memory manager" performs translation and data mangement and is a combination of hardware (in the CPU) and software (the OS).

There is address translation hardware in the CPU; it is called a [memory management unit](https://en.wikipedia.org/wiki/Memory_management_unit). This hardware unit splits the virtual address into the virtual page number and offset within the page and accesses the page table. If the page is not currently in memory, the hardware raises a **page fault exception**.

Upon this page fault exception, transfer control the **page fault exception handler**—a supervisor-level OS procedure that performs the following:

* Initiates transfer between memory and disk.
  * If out of memory, first select a page to replace in memory.
  * If needed, write the outgoing page to disk.
  * Load the requested page from disk into memory.
* Perform a **context switch** so that another user process can use the CPU while the disk transfer happens.
* Following the page fault, re-execute the instruction.

:::{warning} Page faults are extremely expensive!

On a page fault, the process cannot continue until the memory access finishes. If the physical page is not in memory, the page must be first fetched from disk and loaded into memory (and the page table must be updated), and _finally_ the instruction can be re-executed to successfully completes the memory access. The (time) cost of disk access [^jim-gray] means that page faults are extremely expensive—on the order of a million cycles.

**Context switches** amortize the cost of page faults across all processes. To keep the CPU busy, the OS performs a context switch and runs another process—while the original process that triggered a page fault "waits." Then, when the page in question is finally loaded into memory, the OS performs another context switch back to the original process.
:::

## Demand Paging

As mentioned in an [earlier section](#sec-loader), the OS also performs the **load** part of [CALL](#sec-call)—meaning, the OS loads a program into a new virtual address space and runs it. Upon starting this new process, what is its memory footprint? No matter what, the OS must allocate enough space in memory for a new page table for this process. But what about memory pages corresponding to data and instructions?

Preloading in numerous pages for every new process is wasteful. For example, with tiny programs like "Hello World", most pages are never used, so allocating the full virtual address space to memory at startup (i.e., assign every virtual page to a physical page in memory) seems nonsensical.

In a system that uses **demand paging**,[^demand-paging] a process begins execution with none of its pages in physical memory. In other words, all of its page table entries are invalid. Then, when a page is actually requested, load the page from disk into memory.

:::{figure} images/demand-paging.png
:label: fig-demand-paging
:width: 60%
Our VM abstraction allows a program to use the full virtual address space, but some programs use only a tiny amount of memory. **Demand paging** means that new processes have page tables that start with entries that are all invalid.
:::

Demand paging prevents over-allocating memory to a process (and thereby supports running many processes on a limited amount of memory), but the startup cost is high for new processes.

[^demand-paging]: Read more on Wikipedia about [demand paging](https://en.wikipedia.org/wiki/Demand_paging) and its counterpart, [anticipatory paging](https://en.wikipedia.org/wiki/Memory_paging#Anticipatory_paging).