---
title: "Iron Law of Processor Performance"
---

(sec-iron-law)=
## Learning Outcomes

* Explain the equation components of the "iron law" of processor performance.
* Apply the "iron law" of processor performance to compare processor architectures on program benchmarks.

::::{note} 🎥 Lecture Video
:class: dropdown

:::{iframe} https://www.youtube.com/embed/4vLGgSuP27E
:width: 100%
:title: "[CS61C FA20] Lecture 21.2 - Pipelining I: Processor Performance Iron Law"
:::

::::

One of the primary metric to measure processor performance is the time it takes to execute a program, also known as **program execution time**. However, there are generally many parameters that affect this performance metric.

To disentangle these parameters, we break them down into what we will call the **"iron law" of processor performance**. Equation @eq-iron-law shows this classic CPU performance equation:

```{math}
:enumerated: true
:label: eq-iron-law
\frac{\text{time}}{\text{program}} = \frac{\text{instructions}}{\text{program}} \cdot \frac{\text{cycles}}{\text{instructions}} \cdot \frac{\text{time}}{\text{cycles}}
```

This equation uses fractions to expand the **program execution time** ($\text{time}/\text{program}$ measured in s, ms, ns, etc.) into the product of three components that involve instruction count, cycles per instruction, and clock period. From P&H 1.6:

> This formula is particularly useful because they separate [three] key factors that affect performance. We can use these formulas to compare two different implementations or to evaluate a design alternative if we know its impact on these three parameters.

### Instructions per program

$$\frac{\text{instructions}}{\text{program}}$$

The first component of Equation @eq-iron-law is the count of instructions in the **program benchmark**. The program benchmark is determined by the following:

* The task specification. For example, performing image compression is very different from trying to play a game of Go.
* The algorithm and its runtime, e.g., O(N{sup}`2`) or O(N)[^big-o].
* The programming language. Higher-level languages provide a compact description of a task but may "blow up" into very many assembly instructions; it might be more efficient to code in assembly, but we have seen that coding in assembly is tedious.
* The compiler, tightly coupled with the programming language. Some compilers (or compiler options) generate assembly code with a minimal set of instructions, or assembly code with a minimal set of potential control or data hazards.
* The instruction set architecture (ISA). Most RISC architectures require more assembly-level instructions than CISC-type processors, though this cannot be a "fixed" expectation in isolation.

[^big-o]: For Big-O notation, see CS 61B or an equivalent Data Structures and Algorithms course.

### Cycles per Instruction (CPI)

$$\frac{\text{cycles}}{\text{instructions}}$$

The second component in Equation @eq-iron-law is **cycles per instruction**, or CPI. From P&H 1.6:

> Since different instructions may take different amounts of time depending on what they do, CPI is an average of all the instructions executed in the program.

Examples:
* RISC-V [single-cycle processor](#sec-single-cycle): CPI = 1.
* RISC-V [five-stage pipelined processor](#sec-five-stage-pipeline) discussed in this chapter: CPI $\approx$ 1. CPI is often slightly greater than 1 because of stalls due to [pipeline hazards](#sec-pipeline-hazards).
* **Complex instructions**: CPI >> 1, if used in a program benchmark. For example, take an ISA that specifies the C `strcpy` function as an assembly-level `strpcy`. The assembly-level `strcpy` will necssarily incur more cycles to than, say, an assembly-level `add`.
* [Superscalar processors](#sec-superscalar): CPI < 1.

To measure CPI, run a processor on a program benchmark. On the same program benchmark, processors will have different CPI because of differences in the ISA and the processor implementation. Nevertheless, CPI provides one way of comparing **two different implementations of the same ISA**, since the program benchmark (and number of instructions in the program) will be the same.

### Clock period

$$ \frac{\text{time}}{\text{cycles}}$$

The clock period is the time it takes for a single clock cycle and is the inverse of the clock frequency and is measured in seconds (or ms, ns, etc.). The clock period is determined by the following:[^ee-105]

* Processor implementation, e.g., the [critical path](#sec-critical-path) through combinational logic.
* The delay through logic gates, determined by the technology (e.g., 5nm vs. 14nm vs. 28nm)
* The power budget. For example, desktop processors run at clock frequencies like 4GHz but burn much more energy than phones, who run at frequencies closer to 2-2.5 GHz. Power is also determined by supply voltage. Lower voltage reduces transistor speed but improves energy efficiency. For more information, read the [optional section](#sec-energy-efficiency) on energy efficiency.

[^ee-105]: For more information, take upper-division courses like EE 105.

## Using the Iron Law

From P&H 1.6:

> Always bear in mind that the only complete and reliable measure of computer performance is time. For example, changing the instruction set to lower the instruction count may lead to an organization with a slower clock cycle time or higher CPI that offsets the improvement in instruction count. Similarly, because CPI depends on the type of instructions executed, the code that executes the fewest number of instructions may not be the fastest.

For example, imagine trying to reduce the variance in the instructions per program component. This is harder than it seems and will depend on what you want to compare:

* Compare a processor's performance on **two different tasks**, like image compression vs. Go. Keep the programming language and compiler the same. The ISA will necessarily be the same if you are using one processor.
* Compare **two implementations** of an ISA, keep the assembly instruction program the same (this fixes the task, the algorithm, the programming language, and the compiler).
* To compare two ISAs, keep the high-level language implementation of the task the same. Try to find a compiler with similar optimizations for both ISAs.

### Instruction Throughput

**Instruction throughput** can be measured as instructions completed per unit of time and is the product of the inverse of the last two components. Equivalently, it is the inverse of CPI multiplied by the clock frequency $f$.

```{math}
:enumerated: true
:label: eq-throughput
\begin{aligned}
\text{throughput} &= \frac{\text{instructions}}{\text{time}} \\
&= \frac{\text{instructions}}{\text{cycles}} \cdot \frac{\text{cycles}}{\text{time}} \\
&= \frac{f}{\text{CPI}}
\end{aligned}
```

We note that instruction throughput is embedded into the Iron Law as the product of the inverse of the last two components of Equation @eq-iron-law:

```{math}
\begin{aligned}
\frac{\text{time}}{\text{program}} &= \frac{\text{instructions}}{\text{program}} \cdot \frac{\text{cycles}}{\text{instructions}} \cdot \frac{\text{time}}{\text{cycles}} \\
&= \frac{\text{instructions}}{\text{program}} \cdot \frac{1}{\text{throughput}} \\
\end{aligned}
```

```{math}
:enumerated: true
:label: eq-throughput-2
\begin{aligned}
\frac{1}{\text{throughput}} &= \frac{\text{cycles}}{\text{instructions}} \cdot \frac{\text{time}}{\text{cycles}}
\end{aligned}
```

::::{exercise} Quick Check
:label: ex-processor-speed
Suppose we have two processors, A and B, and we evaluate performance on a task like image compression. Which processor will execute this program faster?

:::{table} Processor Performance Comparison Example.
:label: tab-processor-speed
:align: center

|  | Processor A | Processor B |
| :--- | :--- | :--- |
| # Instructions | 1 million | 1.5 million |
| Average CPI | 2.5 | 1 |
| Clock rate | 2.5 GHz | 2 GHz |
:::

::::

::::{solution} ex-processor-speed
:label: ex-processor-speed-sol
:class: dropdown

Despite executing more instructions and having a slower clock rate, **Processor B is faster for this task**! Processor B's significantly better CPI helps it overcome other disadvantages.

:::{table} Processor Performance Comparison Example.
:label: tab-processor-example
:align: center

| Measure | Processor A | Processor B |
| :--- | :--- | :--- |
| # Instructions | 1 million | 1.5 million |
| Average CPI | 2.5 | 1 |
| Clock rate, `f` | 2.5 GHz | 2 GHz |
| **Program execution time** | 1 ms | 0.75 ms |
| **Instruction throughput (per ns)** | 1 inst/ns | 2 inst/ns |
:::

Program execution time for Processor A:

$$10^6 \times 2.5 \times 1/(2.5 \times 10^9) = 2.5 \times 10^{-3} = 1 \text{ms}$$

Program execution time for Processor B:
$$(1.5 \times 10^6 )\times 1 \times 1/(2 \times 10^9) = 1.5/2 \times 10^{-3} = 0.75 \text{ms}$$

::::

::::{exercise} Quick Check
:label: ex-cpi-tf

A related metric to CPI is IPC, or instructions per cycle. Which of the following statements are true? Select all that apply.

1. IPC is the average number of instructions that will complete with one additional clock cycle.
1. CPI is the average number of cycles needed to complete one additional instruction.
1. CPI is the average number of clock cycles needed to execute each instruction.

::::

::::{solution} ex-cpi-tf
:label: ex-cpi-tf-sol
:class: dropdown

1. True
1. True
1. **False**. If multiple instructions are executing, this definition of CPI would "double-count" time. This definition describes **instruction latency**.
::::