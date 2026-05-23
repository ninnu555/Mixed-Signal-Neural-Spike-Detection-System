# 🧠 Real-Time Spike Detection Pipeline (STILL UNDER REVIEW)
**MSCS Final Project** · Analog-Mixed Signal IC Design · Cadence Suite

> End-to-end neural spike detection pipeline for an implantable Brain-Computer Interface, from analog signal acquisition to digital spike classification.

---

## Overview

This project implements the **Analog-to-Digital Converter** and **signal pre-processing module** of a brain-computer interface targeting an implantable integrated circuit. The system acquires, filters, and detects neural spike activity in a simulated environment using the Cadence suite.

| Tool | Purpose |
|---|---|
| **Virtuoso** | Analog & mixed-signal schematic design |
| **Spectre** | Circuit simulation |
| **XCelium** | Digital logic simulation |
| **Genus** | Synthesis & optimization analysis |

---

## Architecture

### Analog Front-End

```
Input Signal (amplified)
        │
        ▼
 ┌─────────────┐
 │  Low-Pass   │  fc ≈ 5.29 kHz  (anti-aliasing)
 │   Filter    │  R = 3 MΩ, C = 5 pF
 └──────┬──────┘
        │
        ▼
 ┌─────────────┐
 │  Sample &   │  fs = 24 kSample/s
 │    Hold     │  RS&H = 1 kΩ, CS&H = 11.68 nF
 └──────┬──────┘
        │
        ▼
 ┌─────────────┐
 │  8-bit      │  Vref = 3 V → VLSB ≈ 11.72 mV
 │  Flash ADC  │  Output range: [−128, 127]
 └─────────────┘
```

**Key choices:**
- 1st-order RC low-pass filter for simplicity and minimal component count
- Flash ADC with 3-input NAND bubble-suppression logic (heals "1"-type bubbles in the thermometer code)
- Half-valued edge resistors to center the ADC transfer characteristic and minimize quantization error
- Clock-synchronized registers on comparator outputs to prevent glitch propagation

### Digital Back-End

```
ADC Output (Q2.6)
        │
        ▼
 ┌─────────────┐
 │ MAD Filter  │  Removes 0–400 Hz band
 │  (FIR)      │  y[n] = 2x[n] − x[n−1] − x[n−2]
 └──────┬──────┘  Parallel architecture (lower energy vs. folded)
        │
        ▼
 ┌─────────────┐
 │  ABS Unit   │  Emphasizes spikes, drops sign bit
 └──────┬──────┘
        │
        ├──────────────────────────────┐
        ▼                              ▼
 ┌─────────────┐               ┌──────────────┐
 │   Signal²   │               │   Signal²    │
 │             │               │  Accumulate  │  N = 2^k samples
 └──────┬──────┘               │  × correction│
        │                      │  >> shift    │
        │                      └──────┬───────┘
        │                             │ Threshold
        ▼                             ▼
 ┌──────────────────────────────────────┐
 │              COMPARE                 │  Spike detected if signal² > threshold
 └──────────────────┬───────────────────┘
                    │
                    ▼
              Spike Output
          (dead time: 0.5 ms)
```

---

## Fixed-Point Optimization

Three progressive optimization stages reduce hardware cost while preserving detection accuracy.

| Stage | Strategy | Result |
|---|---|---|
| **Worst-case** | Full bit-width from arithmetic propagation | Baseline (no overflow) |
| **Approx. opt.** | Clip input −128 → −127; drop ABS sign bit; truncate 3 LSBs of squared signal | Narrower datapaths, same accuracy |
| **Sim.-based opt.** | Bit-widths sized to actual observed signal values (MAD max: ±37) | Final threshold stored in **4 bits** |

Notable savings: accumulator shrinks to 18 bits; post-shift threshold fits in 7 bits; after 3-bit truncation, only 4 bits needed for the final comparison.

---

## Critical Path Optimization

Sequential registers were inserted at three points to break the combinational critical path and reduce glitches:

1. Adder output inside the MAD filter
2. First multiplier output inside the RMS module
3. Shifter output

The resulting critical path is bounded by the loop boundary.

---

## Parameters

| Parameter | Value |
|---|---|
| Sampling rate | 24 kSample/s |
| Anti-aliasing cutoff | ≈ 5.29 kHz |
| ADC resolution | 8 bit |
| ADC reference voltage | 3 V (VLSB ≈ 11.72 mV) |
| Spike dead time | 0.5 ms |
| RMS window size | Power-of-2 samples (e.g. 2¹⁴) |
| Correction factor (max) | 31 |
| MAD filter weights | b0 = 2, b1 = −1, b2 = −1 |

---

## Tools & Technologies

![Cadence](https://img.shields.io/badge/Cadence-Virtuoso%20%7C%20Spectre%20%7C%20XCelium%20%7C%20Genus-blue)
![Language](https://img.shields.io/badge/HDL-Verilog-orange)
![Domain](https://img.shields.io/badge/Domain-Mixed--Signal%20IC%20Design-green)

---

## Project Structure

```
.
├── analog/          # Virtuoso schematics & Spectre simulation configs
├── digital/         # Verilog RTL source files
│   ├── mad_filter/
│   ├── abs_unit/
│   ├── rms_threshold/
│   └── spike_detector/
├── synthesis/       # Genus scripts & reports
├── sim/             # Testbenches & simulation waveforms
└── docs/            # Report and figures
```

---

## Author

**[Il tuo Nome e Cognome]** · MSCS Final Project · May 2026
