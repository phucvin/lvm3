# LVM-3

LVM-3 is a virtual machine (VM) that implements the [LC-3 architecture](https://www.cs.utexas.edu/~fussell/courses/cs310h/lectures/Lecture_10-310h.pdf) and can be used to run LC-3 programs on modern computers. The VM currently only supports Linux, but it can be easily ported to other operating systems with minor API changes.

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/smercer10/lvm3/blob/main/LICENSE)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/smercer10/lvm3/ci.yml?label=CI)](https://github.com/smercer10/lvm3/actions/workflows/ci.yml)

## Usage 

```bash
lvm3 <path to program file>
```

The VM expects files that have been written in LC-3 assembly and preassembled into machine code.
Two examples have been provided in the `programs` directory (credit to [Ryan Pendleton](https://github.com/rpendleton) and [Justin Meiners](https://github.com/justinmeiners)).

<img src="https://github.com/user-attachments/assets/7d6fc253-35c8-447f-a2ac-722299061a3b">  <img src="https://github.com/user-attachments/assets/b3f03a04-d0f5-4a74-8496-59fae4cf8242"> 

## Build Locally

### Prerequisites

* Linux
* Zig nightly build

### Commands

* Build the executable:

```bash
zig build
```

* Build and run the executable:

```bash
zig build run -- <path to program file>
```

* Run the tests:

```bash
zig build test
```
