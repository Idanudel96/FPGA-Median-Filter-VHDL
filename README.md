# FPGA Median Filter for Image Noise Reduction

A VHDL implementation of a **3×3 median filter for FPGA-based image processing**, developed to reduce salt-and-pepper noise while preserving image edges.

The project implements a complete RTL processing pipeline including image memory, row buffering, parallel filtering logic, FSM-based control, and output storage.

## Project Overview

The system processes a 256×256 RGB image with 5-bit resolution per color channel.

The architecture is designed around parallel row processing and a dedicated control FSM that coordinates memory reads, filtering latency, and output writes.

## Processing Flow

**Input Image**
→ **ROM**
→ **Row Buffering**
→ **3×3 Sliding Windows**
→ **Median Filtering**
→ **FSM-Controlled Output Timing**
→ **RAM**
→ **Filtered Image**

## Main Features

- 3×3 median filtering for salt-and-pepper noise reduction
- RGB image processing
- 256×256 pixel image resolution
- 5-bit representation per RGB channel
- Parallel filtering architecture
- FSM-controlled read/write sequencing
- Row buffering for 3×3 neighborhood generation
- ROM-based input image storage
- RAM-based filtered output storage
- FPGA-oriented RTL implementation
- ModelSim-based functional verification

## Hardware Architecture

### Top-Level Module

`Image_Procesing_Top.vhd`

The top-level entity integrates:

- Input ROM
- Output RAM
- Row buffers
- Parallel filtering logic
- Filter control FSM
- RGB processing paths

### Row Buffering

`Buffer1.vhd`

The buffering logic maintains the image rows required to construct the 3×3 pixel neighborhoods used by the median filter.

The design maintains the neighboring rows required for spatial filtering and handles image-boundary conditions.

### Parallel Filter

`Parallel_Filter_Row.vhd`

This module applies the median-filter operation across the image row using multiple parallel filtering units.

VHDL `generate` constructs are used to instantiate the repeated filtering logic.

### Median Computation

`Image_Pkg.vhd`

The project uses a hierarchical median-selection approach based on smaller sorting operations rather than performing a complete 9-element sort for every 3×3 window.

### Control FSM

`Filter_FSM.vhd`

The FSM coordinates:

- Input memory reads
- Row-buffer updates
- Filter execution
- Pipeline latency
- Output memory writes

Separate control of read and write timing is used to account for the processing delay through the filtering pipeline.

## Memory Architecture

The project uses FPGA memory blocks for image storage:

- **ROM** – stores the input image
- **RAM** – stores the filtered output image

Memory-related modules include:

- `ROM_1280_256_Port_1.vhd`
- `ram_1280_256.vhd`

## Project Structure

- `Image_Procesing_Top.vhd` – Top-level system integration
- `Filter_FSM.vhd` – Control FSM for memory and processing synchronization
- `Buffer1.vhd` – Image row buffering
- `Parallel_Filter_Row.vhd` – Parallel median-filter processing
- `Image_Pkg.vhd` – Shared image-processing functions and median logic
- `ROM_1280_256_Port_1.vhd` – Input image ROM
- `ram_1280_256.vhd` – Output image RAM
- `input image.jpg` – Input image containing salt-and-pepper noise
- `output image.jpg` – Filtered output image
- `RTL.jpeg` – RTL architecture view
- `README.md` – Project documentation

## Visual Results

### Input Image

The input image contains salt-and-pepper noise and is used as the source data for the FPGA processing pipeline.

![Noisy Input Image](input%20image.jpg)

### Filtered Output

The output image demonstrates the effect of the 3×3 median filter after hardware processing.

![Filtered Output Image](output%20image.jpg)

## Tools & Technologies

- VHDL
- Intel / Altera Quartus
- ModelSim
- FPGA RTL Design
- Finite State Machines
- Digital Image Processing
- ROM / RAM Interfacing
- Parallel Hardware Architecture

## Engineering Topics

This project provided hands-on experience with:

- RTL architecture design
- FPGA-based image processing
- Median filtering
- Parallel hardware implementation
- Finite State Machine design
- Pipeline timing
- Memory read/write synchronization
- Row and line buffering
- FPGA memory blocks
- ModelSim verification
- Hardware resource trade-offs
- Debugging timing-related RTL issues

## Result

The implemented hardware pipeline successfully processes the input image and produces a filtered output with reduced salt-and-pepper noise.

The project demonstrates how an image-processing algorithm can be translated from a software-style operation into a parallel RTL architecture suitable for FPGA implementation.
