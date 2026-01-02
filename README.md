# Kappa Language Compiler

**Course:** Theory of Computation (PLH 402)  
**Institution:** Technical University of Crete (TUC)  
**Semester:** Spring 2023

> A source-to-source compiler (transpiler) that analyzes source code written in the **Kappa** programming language and generates equivalent **C99** code.

---

## 🏗️ Project Overview

This project implements the initial stages of a compiler using **Flex** for lexical analysis and **Bison** for syntactic analysis.

The compiler accepts a `.ka` file as input, verifies the syntax based on the Kappa grammar, and translates it into a C file (`C_file.c`) which can then be compiled using GCC.

### Supported Language Features
The compiler supports the following features of the Kappa language:
* **Data Types:** `integer`, `scalar` (double), `str` (string), `boolean`.
* **Constants & Variables:** `const` declarations and typed variable declarations.
* **Control Flow:**
    * `if` / `else` / `endif` statements.
    * `for` loops (range-based and iterator-based).
    * `while` loops.
    * `break` and `continue` statements.
* **Functions:** Definition using `def ... enddef` with return types and parameters.
* **Complex Types:**
    * Arrays (e.g., `a[10]: integer`).
    * List Comprehensions/Compact Arrays (e.g., `[expr for elm:size]`).
* **Operators:** Arithmetic (`+`, `-`, `*`, `/`, `**`), Relational (`<`, `>`, `==`, `!=`), and Logical (`and`, `or`, `not`).

---

## 📂 Project Structure

* **`mylexer.l`**: The Flex specification file containing regular expressions for token recognition (Keywords, Identifiers, Operators, Strings).
* **`myanalyzer.y`**: The Bison grammar file defining the syntax rules and C code generation templates.
* **`cgen.c` / `cgen.h`**: Helper library for string manipulation and code generation (referenced in analyzer).
* **`kappalib.h`**: Header file implementing Kappa's built-in functions (e.g., `writeInteger`, `readStr`) for the target C code.
* **`correct1.ka`**: Test file implementing the Fibonacci sequence.
* **`correct2.ka`**: Test file implementing a Factorial calculator.

---

## 🛠️ Build Instructions

To build the compiler, you need `flex`, `bison`, and `gcc` installed on your system.

Run the following commands in your terminal:

1.  **Generate the Parser:**
    This generates `myanalyzer.tab.c` and `myanalyzer.tab.h`.
    ```bash
    bison -d -v -r all myanalyzer.y
    ```
   

2.  **Generate the Lexer:**
    This generates `lex.yy.c`.
    ```bash
    flex mylexer.l
    ```
   

3.  **Compile the Compiler:**
    This links the lexer, parser, and helper library to create the executable `mycompiler`.
    ```bash
    gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl
    ```
   

---

## 🚀 Usage

### 1. Run the Parser
Run your parser against the source file. The expected behavior is as follows:

* **Success:** Prints `"Your program is syntactically correct!"` and generates `C_file.c`.
* **Failure:** Prints syntax errors with specific line numbers.

### 2. Compile the Output C Code
Use GCC to compile the generated C code into an executable.

```bash
gcc -std=c99 -Wall -o myprogram C_file.c

### 3. Run the Program

```bash
./myprogram 
