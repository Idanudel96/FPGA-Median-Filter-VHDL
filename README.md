# FPGA Hardware Median Filter (VHDL) 🖥️

## Overview
A complete hardware description logic (RTL) implementation of a digital image processing pipeline in VHDL. The system is designed to effectively remove salt-and-pepper noise from images using a 3x3 Median Filter, a method chosen specifically for its ability to clean extreme pixel values while preserving image edges and sharpness. 

## Key Features
* **Image Resolution & Depth:** Processes 256x256 pixel images with a 5-bit color depth per RGB channel.
* **Vector Processing (Massive Parallelism):** The system processes an entire row of 256 pixels in a single clock cycle. This is achieved by utilizing VHDL `generate` statements to instantiate 256 parallel median filter units.
* **Resource-Efficient Sorting:** Instead of a resource-heavy 9-element full sort, the architecture utilizes a "Median of Medians" approach. It performs three small independent Even-Odd sorts (3 elements each) for the rows, and one final sort for the results, drastically reducing the Logic Elements required and shortening the critical path.
* **Latency-Compensated FSM:** The dedicated `Filter_FSM` orchestrates the pipeline. To account for the 4-clock-cycle processing delay, the FSM manages separate read and write counters, ensuring perfect synchronization between the extracted data and the processed output written to RAM.
* **RGB Channel Separation:** Independent processing paths for Red, Green, and Blue channels operating simultaneously.

## Hardware Architecture
* **Top-Level Entity (`Image_Procesing_Top.vhd`):** Integrates the FSM, Altera megafunction ROM/RAM blocks, row buffers, and the parallel filtering units.
* **Line Buffers (`Buffer1.vhd`):** A shift-register structure that maintains the *low*, *mid*, and *high* rows required for the 3x3 spatial filter, including dynamic pixel padding for edge cases.
* **Filter Logic (`Parallel_Filter_Row.vhd` & `Image_Pkg.vhd`):** Extracts 3x3 sliding windows from the padded rows and applies the median computation using the custom combinational sorting package.
* **Memory Blocks:** Utilizes Altera `altsyncram` for robust 256x1280 memory management (ROM for input, RAM for output).

## Visual Results
The system takes a heavily noised image (salt-and-pepper interference) and outputs a clean, normalized 8-bit equivalent representation.
* **Before:** `input image.jpg` - Noised image.
* **After:** `output image.jpg` - Filtered image.

## Tools & Technologies
* VHDL (IEEE STD_LOGIC_1164, NUMERIC_STD)
* Altera Quartus / Cyclone IV E[cite: 13]
* RTL Viewer & ModelSim[cite: 8, 15]
