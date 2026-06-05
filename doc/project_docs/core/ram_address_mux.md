# Module: ram_address_mux
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Switches between modules that tries to access RAM
Only one at the time is allowed


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **ADDRESS_WIDTH** | `int/logic` | `20` |
| **INPUTS_NUMBER** | `int/logic` | `3` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [ADDRESS_WIDTH-1:0] addresses` | **** |
| output | `logic [ADDRESS_WIDTH-1:0]` | **ram_address** |
