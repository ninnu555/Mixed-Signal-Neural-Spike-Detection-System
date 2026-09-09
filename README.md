<div align="center">
  <h1>🧠 Real-Time Spike Detection Pipeline</h1>
  <p><strong>MSCS Final Project - Università degli Studi di Cagliari (UNICA)</strong></p>
  <p><em>Implantable Brain-Computer Interface (BCI) Application</em></p>
</div>

## 📖 Project Overview

This repository contains the design and implementation of a **Real-Time Spike Detection Pipeline** for implantable Brain-Computer Interfaces (BCIs). The project involves the custom design of both the **Analog Front-End (AFE)** and the **Digital Pre-Processing** stages. 

The primary design focus is achieving **high accuracy** with **ultra-low power consumption**, meeting the strict constraints required for neural implants used in applications such as prosthetic control, motorized wheelchairs, and text decoders.

---

## ⚙️ System Architecture

The system takes an analog signal from a neural sensor, digitizes it, processes the features, and sends commands to an application decoder. The main constraints include a **sampling frequency of 24 kHz**, recognizing that neural activity characteristics typically lie in the range of a few kHz.

### 1. 🔌 Analog Front-End (AFE)

The analog section is responsible for signal conditioning and digitization.

*   **Anti-Aliasing Filter:** 
    *   1st order active Low-Pass Filter (LPF)
    *   **Parameters:** R1 = R2 = 3 MΩ, C = 10 pF
    *   **Cut-off Frequency (fc):** 5 kHz
*   **Sample & Hold (S&H):**
    *   Must remain stable for t = Ts / 2 = 20.83 µs
    *   **Capacitance:** C_S&H = 100 nF
*   **Flash ADC (8-bit):**
    *   **Resistor Network (ResNet):** Bipolar power supply (V_REF = ± 1.5V) for an input excursion of -1.22V to 0.88V. First and last resistors are R/2 to reduce quantization error.
    *   **Comparator Network (CmpNet):** Sequential comparators to prevent glitch propagation, utilizing Thermometer Encoding.
    *   **NAND Network (NandNet):** 3-input NANDs for One-Hot Encoding and basic Bubble Fixing.
    *   **Encoder:** Maps output to a centered interval [-128, 127] with overvoltage correction (saturates to extremes).

#### 🫧 Bubble Error Correction
*   **Type "1" bubbles (any order):** Solved by the 3-input NAND configuration.
*   **Type "0" bubbles (order > 1):** Solved by the encoder's reading direction.
*   *Note:* 1st order type "0" bubbles are the only unsolvable errors in this specific architecture.

---

### 2. 💻 Digital Pre-Processing

The digital domain extracts the spike features from the raw ADC output. The pipeline operates efficiently under a throughput constraint of 100 channels × 24 kHz.

*   **Filtering Stage (MAD Filter):** High-pass filter that removes the 0-400 Hz frequency band. Designed with a **Parallel** structure to achieve the lowest power consumption compared to folded or L=3 parallel architectures.
*   **Emphasis Stage (ABS):** Applies an absolute value to the input to make the spike waveform easily distinguishable from background noise.
*   **Threshold Computation:** Computes a dynamic threshold using the Root Mean Square (RMS²) value over a window of N samples, multiplied by a corrective coefficient.
*   **Spike Detection:** Compares the emphasized signal against the computed threshold to flag neural spikes.

---

## 🛠️ Hardware Optimizations & Synthesis

To achieve ultra-low power consumption, several RTL optimizations were applied, including fixed weights, clock gating, pipelining, voltage scaling, registered outputs, and targeted truncation. 

Five distinct versions were synthesized and compared:

1.  **BASE:** Worst-case version, no optimizations.
2.  **OPT:** Architectural optimizations and low-power techniques applied.
3.  **OPT_T2:** Truncation of 2 LSBs in the "RMS" and "Spike Detector" modules.
4.  **EXT:** Output-aware version, dimensioned by profiling 10s of input values for bit-width reduction.
5.  **EXT_T2:** Extreme optimization combining output-aware reduction and truncation.

### 📊 Synthesis Comparison

| Version | Power [µW] | Area [µm²] | Timing [ps] |
| :--- | :--- | :--- | :--- |
| **BASE** | 22.321 | 135,705 | 381,060 |
| **OPT** | 17.749 | 24,982 | 385,334 |
| **OPT_T2** | 16.660 | 24,199 | 388,372 |
| **EXT** | 13.120 | 15,292 | 395,724 |
| **EXT_T2** | 12.032 | 14,370 | 398,390 |

*The EXT_T2 version achieves an area reduction of ~89% and a power reduction of ~46% compared to the BASE implementation.*

---

## 📈 Simulation & Results

Mixed-signal simulations demonstrate robust spike detection:
*   **OPT Version:** Successfully detected **11/11** spikes (100% accuracy, 0 False Positives).
*   **OPT_T2 Version:** Detected 13/11 spikes (Introduced 2 False Positives due to aggressive truncation).

---

## 👥 Authors
**Students:**
*   Matteo Matta
*   Fabio Piras

**Professors / Supervisors:**
*   Prof. Gianluca Leone
*   Prof. Francesco Ratto

*MSc in Computer Science (MSCS) - Università degli Studi di Cagliari*
