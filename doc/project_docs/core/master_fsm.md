# Module: master_fsm
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Decides the game flow


---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **space_bar** |
| input | `logic` | **vsync_in** |
| output | `logic` | **vsync_out** |
| output | `logic` | **state_output** |
