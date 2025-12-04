# EPS LAB 09 – Serial Mirror Detector & Data Extractor (VHDL)

This project implements the **LAB09** assignment from the  
**Electronics Programmable Systems (EPS)** course at the University of Palermo.  
The system receives two 16-bit serial data streams and examines their structure to detect various “mirror” patterns as required by the official lab specification.

The design is fully synchronous and is suitable for FPGA implementation.

---

## 📁 Repository Structure

```text
eps-lab09-serial-detector/
├── README.md
├── docs/
│   └── EPS_LAB09_20240524.pdf
└── src/
    └── LAB09.vhd
```

- `LAB09.vhd` — VHDL implementation of the serial mirror detector  
- `docs/EPS_LAB09_20240524.pdf` — official lab specification  

---

## 🎯 Functional Overview

The system processes two input serial streams:

- **DIN1** — first 16-bit serial word  
- **DIN2** — second 16-bit serial word  

Once both words are received, two mirror checks are performed:

### **1. External Mirror Check (Condition A)**  
If:

```
DIN1 = reverse(DIN2)
```

Then:

- Emit a **1-clock BINGO pulse**
- Begin serial transmission of `DIN2` on `DOUT16`

---

### **2. Internal Mirror Check (Condition B)**  
If inside either word:

```
Upper Byte (bits 15..8) = reverse(Lower Byte (bits 7..0))
```

Then:

- Emit a **2-clock BINGO pulse**
- After the pulse, output the **first byte** of `DIN1` on `DOUT_BYTE`

---

### **DISABLE Mode**

If `DISABLE = '1'`:

- `DOUT16` → high-impedance  
- `DOUT_BYTE` → high-impedance  
- `BINGO` output remains active  

---

### **RESET Requirement**

`RESET_N` is **active LOW** and must be asserted for **100–140 ns** to properly initialize:

- Shift registers  
- Output drivers  
- Internal FSM  
- Counters and pipelines  

---

## 🔌 Entity Ports

```vhdl
CLK        : in  std_logic;
RESET_N    : in  std_logic;   -- Active low
DISABLE    : in  std_logic;
DIN1       : in  std_logic;
DIN2       : in  std_logic;

BINGO      : out std_logic;
DOUT16     : out std_logic;                  -- Serial output
DOUT_BYTE  : out std_logic_vector(7 downto 0);
```

---

## 🧠 Internal Architecture

### ✔ 1. Shift Register Stage

Two synchronous 16-bit shift registers are used:

```
SR1 ← DIN1
SR2 ← DIN2
```

---

### ✔ 2. Mirror Detection Logic

#### **External Mirror Condition**
```
SR1 = reverse(SR2)
```

#### **Internal Byte-Mirror Condition**
```
SR1[15:8] = reverse(SR1[7:0])
SR2[15:8] = reverse(SR2[7:0])
```

---

### ✔ 3. Finite State Machine (FSM)

Core FSM:

```
IDLE
  ↓
LOAD16
  ↓
CHECK
  ↙            ↘
OUTPUT_16    OUTPUT_BYTE
```

- `OUTPUT_16` handles Condition A  
- `OUTPUT_BYTE` handles Condition B  

---

### ✔ 4. Output Drivers

- `DOUT16` serializes the full 16 bits of `DIN2`
- `DOUT_BYTE` outputs byte 0 from `DIN1`
- `DISABLE` forces outputs to `'Z'`

---

## ⏱ Waveform Diagrams

### **Case A – External Mirror Detection**

```
CLK       : ┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐...
DIN1      : <-------- 16 bits -------->
DIN2      : <-------- 16 bits -------->

BINGO     : ____________________┌─┐__________________
                                │ │ 1 cycle
                                └─┘

DOUT16    : ---- serial output of DIN2 (16 cycles) ----
```

---

### **Case B – Internal Mirror Detection**

```
BINGO     : ___________________┌───────┐_____________
                              │       │ 2 cycles
                              └───────┘

DOUT_BYTE : -------- first byte of DIN1 -------->
```

---

## ▶️ Simulation & Synthesis Notes

- Fully synchronous to `CLK`  
- No combinational loops  
- Output throughput exceeds **1 Mbit/s**  
- Suitable for FPGA synthesis (Spartan-3 XC3S200)

---

## 👤 Author

**Hamed Nahvi**
