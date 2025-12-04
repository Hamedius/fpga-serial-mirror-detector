# EPS LAB 09 – Serial Mirror Detector & Data Extractor (VHDL)

This project implements the **LAB09** assignment from  
**Electronics Programmable Systems (EPS), University of Palermo**, based on the official exam specifications. fileciteturn7file0

The objective is to design a fully synchronous VHDL entity capable of:

- Analyzing two **16‑bit serial inputs** (`DIN1`, `DIN2`)
- Detecting **mirror patterns** across the two 16‑bit words
- Detecting **mirror patterns inside each word** (between byte 1 and byte 2)
- Generating one‑cycle or two‑cycle **BINGO pulses**
- Emitting:
  - `DOUT16` → the 16‑bit word received on `DIN2`
  - `DOUT_BYTE` → the first byte of `DIN1`
- Supporting high‑speed operation **> 1 Mbit/s**
- Implementing a **DISABLE** signal placing all outputs in **high‑impedance**

---

## 📁 Repository Structure

```text
eps-lab09-serial-mirror-detector/
├── README.md
├── docs/
│   └── EPS_LAB09_20240524.pdf
└── src/
    ├── LAB09.vhd
    └── tb_LAB09.vhd
```

---

## 🎯 Functional Specification (Summary)

Based on the official lab sheet: fileciteturn7file0

### 1. **Input Acquisition**
- The entity receives two serial streams of 16 bits each:
  - `DIN1`
  - `DIN2`
- Bits are shifted in synchronously with `CLK`.
- A **RESET (active-low)** pulse (100–140 ns) initializes the system.

---

### 2. **Mirror Detection (Condition A)**  
If the first 16‑bit word on `DIN1` is the **mirror** of the first 16‑bit word on `DIN2`  
(example: `0x00FF` and `0xFF00`):

→ Emit **1‑clock‑cycle BINGO pulse**  
→ Immediately start outputting `DOUT16` = the 16‑bit word received on `DIN2` (serial)

---

### 3. **Internal Byte-Mirroring (Condition B)**  
If either input also satisfies internal mirroring:

```
Byte1: 01010101
Byte2: 10101010
```

→ Emit **2‑clock‑cycle BINGO pulse**  
→ After BINGO ends, output `DOUT_BYTE` = the first byte received from `DIN1`

---

### 4. **High‑Impedance Mode**
If neither mirror condition is valid:

- `DOUT16` → high‑impedance
- `DOUT_BYTE` → high‑impedance  
(This does **not** affect the BINGO pulses.)

---

### 5. **Timing Requirement**
The entity must maintain **output speed > 1 Mbit/s**, even in the worst case.

The design therefore uses:

- Synchronous logic  
- Deterministic FSM  
- Shift-register pipelines  
- No combinational loops  

---

## 🧩 Entity Ports (Reconstructed)

```vhdl
CLK        : in  std_logic;
RESET_N    : in  std_logic; -- active low
DISABLE    : in  std_logic;
DIN1       : in  std_logic;
DIN2       : in  std_logic;

BINGO      : out std_logic;
DOUT16     : out std_logic;               -- serial output
DOUT_BYTE  : out std_logic_vector(7 downto 0);
```

---

## 🧠 Internal Architecture (Conceptual)

### ✔ 1. Shift registers  
Two 16‑bit shift registers collect serial data:

```text
SR1 ← DIN1
SR2 ← DIN2
```

### ✔ 2. Mirror comparators  

- **External Mirror Check**
  ```
  SR1 = reverse(SR2)
  ```

- **Internal Mirror Check**
  ```
  SRx[15:8] = reverse(SRx[7:0])
  ```

### ✔ 3. State Machine

```
IDLE → LOAD16 → CHECK → 
  → OUTPUT_16      (if condition A)
  → OUTPUT_BYTE    (if condition B)
```

### ✔ 4. Tri‑state Output Drivers

```
if DISABLE = '1' → outputs = 'Z'
```

---

## ⏱ Waveform Diagram (ASCII)

### **Case A: External Mirror Detected (1‑cycle BINGO)**

```
CLK     : ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ...
          │ │ │ │ │ │ │ │ │ │ │ │ │ │ │ │
RESET_N : ────────┐___________________________
                  │
DIN1    : <------ 16 bits ------>
DIN2    : <------ 16 bits ------>
BINGO   : _____________________┌─┐____________
                               │ │ 1 clock
                               └─┘
DOUT16  :  ←──── serial output of DIN2 ─────→
```

---

### **Case B: Byte Mirror Present (2‑cycle BINGO)**

```
BINGO     : ____________________┌───────┐______
                                │       │ 2 cycles
                                └───────┘
DOUT_BYTE : (byte extracted from DIN1) → after BINGO
```

---

## ▶️ Synthesis Notes

- Written in synthesizable VHDL-93  
- Suitable for Spartan‑3, XC3S200, VQ100, -4  
- Meets timing > 1 MHz by construction  
- No inferred latches  
- Fully synchronous to `CLK`

---

## 👤 Author

**Hamed Nahvi**

---

# 💡 Suggested Repository Names

### **Professional & Clean**
- `fpga-serial-mirror-detector`  ⭐ *best*
- `vhdl-mirror-checker`
- `eps-lab09-serial-detector`

### **More Technical**
- `fpga-serial-analyzer-lab09`
- `serial-mirror-engine-fpga`
- `vhdl-bingo-detector-lab09`

### **Academic Style**
- `LAB09-EPS-VHDL`
- `EPS_LAB09_SerialLogic`

**Recommended:**  
## ⭐ `fpga-serial-mirror-detector`

Clean, descriptive, and looks excellent on a CV or portfolio.

