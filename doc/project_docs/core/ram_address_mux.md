# Module: ram_address_mux
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Switches between modules that try to access RAM.
Uses Round-Robin, granted is immediate, data arrives after delay.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **ADDRESS_WIDTH** | `int` | `20` |
| **WORD_WIDTH** | `int` | `1` |
| **INPUTS_NUMBER** | `int` | `3` |
| **WRITE_CHANNEL** | `int` | `0` |
| **RAM_DELAY** | `int` | `2` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **clear** |
| input | `logic [WORD_WIDTH-1:0]` | **ram_value** |
| output | `logic [ADDRESS_WIDTH-1:0]` | **ram_address** |
| output | `logic` | **ram_clear** |
