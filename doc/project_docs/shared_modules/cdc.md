# Module: cdc
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Clock Crossing Domain - multibit, multistage


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **STAGES** | `int/logic` | `2` |
| **WIDTH** | `int/logic` | `8` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk_a** |
| input | `logic` | **clk_b** |
| input | `logic` | **rst_n** |
| input | `logic [WIDTH-1:0]` | **data_in** |
| input | `logic` | **send_data** |
| output | `logic [WIDTH-1:0]` | **data_out** |
