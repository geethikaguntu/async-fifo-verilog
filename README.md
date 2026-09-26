# Asynchronous FIFO Design in Verilog

An 8×8 asynchronous FIFO implemented and verified using Verilog RTL.

## Overview

This project implements a First-In-First-Out (FIFO) buffer designed to transfer data between two independent clock domains.

The design uses separate write and read clocks and includes clock-domain crossing synchronization to safely transfer pointer information between the two domains.

## Features

* 8-bit data width
* 8-entry FIFO depth
* Independent read and write clock domains
* Binary read and write pointers
* Gray-coded pointers for clock-domain crossing
* Two-stage pointer synchronization
* Full and empty status detection
* Self-checking Verilog testbench

## Architecture

The FIFO consists of:

* Dual-clock memory
* Write pointer and write control logic
* Read pointer and read control logic
* Gray-code conversion logic
* Clock-domain synchronizers
* Full and empty detection logic

The write and read domains operate independently using separate clocks.

## Verification

The testbench uses independent asynchronous clocks:

* Write clock period: 10 ns
* Read clock period: 14 ns

The testbench writes 32 sequential values into the FIFO and reads them back, checking that the data is received in the correct order.

Simulation result:

```text
ASYNC FIFO TEST PASSED
```

All 32 transmitted values were successfully verified.

## Files

| File              | Description             |
| ----------------- | ----------------------- |
| `async_fifo.v`    | FIFO RTL implementation |
| `async_fifo_tb.v` | Verification testbench  |

## Tools

* Verilog HDL
* EDA Playground
* Icarus Verilog
* GitHub

## Key Concepts

This project demonstrates concepts including:

* FIFO architecture
* RTL design
* Clock-domain crossing (CDC)
* Gray-code pointers
* Synchronizer design
* Full/empty detection
* Verilog testbench development
* Simulation-based verification
