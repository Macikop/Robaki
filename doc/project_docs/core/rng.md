# Module: rng
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Generates pseudorandom numbers using a pipelined 32-bit XORSHIFT.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **OUTPUT_WIDTH** | `int` | `8` |
| **SEED** | `[31:0]` | `32'hACE1` |
| **SPREAD** | `[31:0]` | `32'h5555_5555` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **capture** |
| output | `logic [OUTPUT_WIDTH-1:0]` | **random_number** |
