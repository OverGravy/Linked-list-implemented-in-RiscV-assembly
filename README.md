# Linked-list-implemented-in-RiskV-assembly

## Project overview

Small university project that implements a Singly Linked List Manager in RISC-V assembly. It handles basic dynamic list operations using RISC-V instructions and works entirely on a memory-based structure. The project feature a small command sistem based on a pre decided tring contained on .data

## Emulator

The chosen emulator is RIPES that allow a great memory view and an eay interpretation of the data flow. The processor used is **Single-cycle** and need to be setted to run the program.

[Ripes page](https://github.com/mortbopet/Ripes).

## Features

The program supports the following operations:

- `ADD(x)` – Add a node with data `x` to the end of the list.
- `DEL(x)` – Delete **all** nodes with data `x` from the list.
- `PRINT` – Print the entire list in order (recursively).
- `SORT` – Sort the list based on ASCII values, with a recursive bubble sort precedence.
- `REV` – Reverse the list order (using the stack).

Each list node contains:
- 1 byte: ASCII character (`DATA`)
- 4 bytes: pointer to the next element (`PAHEAD`, 32-bit)

---
## Input Format

All operations are parsed from a single input string called `listInput`, defined in the `.data` section:

```assembly
listInput: .asciiz "ADD(a)~ADD(B)~PRINT~SORT~DEL(a)~REV~PRINT"
```
## Actual implemented feature

- `COMMAND INPUT` works parsing the string and understang if the command is properly formatted.
- `ADD` works, adds a new element on the list.
- `DEL` works, removes all the occurrences of an element mantaining the integrity of the list.
- `PRINT` work, it print all the list element.
- `SORT`, the procedure works and use a bubble-sort recursive algorithm adapted to work with this type of lists.

---
## ASCII Ordering Rules

Custom sorting is applied according to the following hierarchy:

1. **Uppercase letters** (A–Z)
2. **Lowercase letters** (a–z)
3. **Digits** (0–9)
4. **Other printable characters** (e.g., `;`, `,`, `.`)

> Characters outside ASCII 32–125 are not considered valid and will be ignored.

Within each category, standard ASCII order applies (e.g., `A < B`, `a < b`, `0 < 1`, etc.)


## Sort function focus 

The function for sorting the simple list by request must be implemented recursively with a custom sorting order, as opposed to the ASCII order. The chosen algorithm is bubble sort, whose recursive implementation is not difficult and fits well with the Risc5 assembly. The main part of the sorting procedure is where the position of the currently checked node and the next node in the order are determined.

---
## The program working 

<video width="640" height="360" controls>
  <source src="https://github.com/OverGravy/Linked-list-implemented-in-RiscV-assembly/raw/main/Doc/linkedList%20resized.mp4" type="video/mp4">
  Il tuo browser non supporta il tag video.
</video>