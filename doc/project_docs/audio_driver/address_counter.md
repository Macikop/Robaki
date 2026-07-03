# Module: address_counter
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Adress counter for DDS.


---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic[31:0]` | **phase_increment** |
| input | `logic` | **sync_in** |
| output | `logic [7:0]` | **sine_addr** |
| output | `logic` | **sync_out** |
