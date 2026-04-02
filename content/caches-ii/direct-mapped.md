---
title: "Direct Mapped Example"
subtitle: TODO
---

## Learning Outcomes

* TODO
* TODO

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/-OtUM6j6_xE
:width: 100%
:title: "[CS61C FA20] Lecture 26.1 - Caches III: Direct Mapped Example"
:::

::::

## Visuals
:::{figure} images/hardware-direct-mapped-cache.png
:label: fig-hardware-direct-mapped-cache
:width: 70%
:alt: "TODO"
Hardware implementation of a direct-mapped cache.
:::

:::{figure} images/direct-mapped-cache-1.png
:label: fig-direct-mapped-cache-1
:width: 60%
:alt: "TODO"
A direct-mapped cache with four color-coded cache lines.
:::

:::{figure} images/direct-mapped-cache-2.png
:label: fig-direct-mapped-cache-2
:width: 60%
:alt: "TODO"
A direct-mapped cache example with 4-byte blocks.
:::

:::{figure} images/direct-mapped-cache-address.png
:label: fig-direct-mapped-cache-address
:width: 70%
:alt: "TODO"
How a memory address is split into tag, index, and byte offset fields.
:::

:::{figure} images/direct-mapped-16b-cache.png
:label: fig-direct-mapped-16b-cache
:width: 60%
:alt: "TODO"
A 16-byte direct-mapped cache.
:::

:::{figure} images/memory-direct-mapped-16b-cache.png
:label: fig-memory-direct-mapped-16b-cache
:width: 100%
:alt: "TODO"
Memory layout for a 16-byte direct-mapped cache example.
:::

:::{figure} images/direct-mapped-4b-memory.png
:label: fig-direct-mapped-4b-memory
:width: 100%
:alt: "TODO"
Memory layout for a 4-byte direct-mapped cache example.
:::

:::{figure} images/direct-mapped-8b-cache.png
:label: fig-direct-mapped-8b-cache
:width: 50%
:alt: "TODO"
A direct-mapped cache with 2-byte blocks.
:::

:::{figure} images/memory-direct-mapped-4b-cache.png
:label: fig-memory-direct-mapped-4b-cache
:width: 100%
:alt: "TODO"
Memory layout for a 4-byte direct-mapped cache showing tag groupings.
:::

:::{figure} images/direct-mapped-cache-address.png
:label: fig-direct-mapped-cache-address-2
:width: 70%
:alt: "TODO"
Address fields mapped to tag and data regions of a cache line.
:::

:::{figure} images/memory-direct-mapped-8b-cache.png
:label: fig-memory-direct-mapped-8b-cache
:width: 100%
:alt: "TODO"
Memory layout for an 8-byte direct-mapped cache example.
:::

:::{figure} images/blank-cache-terminology-12b-addresses.png
:label: fig-blank-cache-terminology-12b-addresses
:width: 60%
:alt: "TODO"
A blank cache table for practicing cache terminology with 4-byte blocks.
:::

:::{figure} images/memory-address-terminology-12b-addresses.png
:label: fig-memory-address-terminology-12b-addresses
:width: 70%
:alt: "TODO"
A 12-bit memory address broken into tag, index, and offset fields.
:::

:::{figure} images/tio-example-direct-mapped.png
:label: fig-tio-example-direct-mapped
:width: 60%
:alt: "TODO"
A binary address decomposed into tag (0xFE), index (0x0), and offset (0x2).
:::

:::{figure} images/cache-example-direct-mapped-cache.png
:label: fig-cache-example-direct-mapped-cache
:width: 60%
:alt: "TODO"
A direct-mapped cache with a valid first line (tag 0xFE) and the remaining lines invalid.
:::

:::{figure} images/memory-example-direct-mapped.png
:label: fig-memory-example-direct-mapped
:width: 50%
:alt: "TODO"
A 12-bit memory address split into tag (bits 11–4), index (bits 3–2), and offset (bits 1–0).
:::

:::{figure} images/placement-policies-next-time.png
:label: fig-placement-policies-next-time
:width: 75%
:alt: "TODO"
The spectrum of cache placement policies, with set-associative as the in-between approach to be covered next.
:::