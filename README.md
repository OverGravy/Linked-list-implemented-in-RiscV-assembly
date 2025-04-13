# Linked-list-implemented-in-RiskV-assembly

## Project overview

Small university project that implements a Singly Linked List Manager in RISC-V assembly. It handles basic dynamic list operations using RISC-V instructions and works entirely on a memory-based structure. The project feature a small command sistem based on a pre decided tring contained on .data

## Features

The program supports the following operations:

- `ADD(x)` – Add a node with data `x` to the end of the list.
- `DEL(x)` – Delete **all** nodes with data `x` from the list.
- `PRINT` – Print the entire list in order (recursively).
- `SORT` – Sort the list based on ASCII values, with a custom category-based precedence.
- `REV` – Reverse the list order (using the stack).
- `SDX` / `SSX` – Right/Left rotate the list (circular shift).

Each list node contains:
- 1 byte: ASCII character (`DATA`)
- 4 bytes: pointer to the next element (`PAHEAD`, 32-bit)

## ASCII Ordering Rules

Custom sorting is applied according to the following hierarchy:

1. **Uppercase letters** (A–Z)
2. **Lowercase letters** (a–z)
3. **Digits** (0–9)
4. **Other printable characters** (e.g., `;`, `,`, `.`)

> Characters outside ASCII 32–125 are not considered valid and will be ignored.

Within each category, standard ASCII order applies (e.g., `A < B`, `a < b`, `0 < 1`, etc.)

---

## Input Format

All operations are parsed from a single input string called `listInput`, defined in the `.data` section:

```assembly
listInput: .asciiz "ADD(a)~ADD(B)~PRINT~SORT~DEL(a)~REV~PRINT"

## Actual implemented feature

- 'COMMAND INPUT' works parsing the string and understang if the command is properly formatted