# Module: terrain_destruction
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Deletes terrain where explosion occurs using a filled Midpoint Circle Algorithm.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **TERRAIN_WIDTH** | `int` | `1024` |
| **TERRAIN_HEIGHT** | `int` | `768` |
| **RAM_DELAY** | `int` | `2` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **start** |
| input | `logic [10:0]` | **pos_x** |
| input | `logic [10:0]` | **pos_y** |
| input | `logic [7:0]` | **radius** |
| interface | `memory_if.out` | **v_ram** |
| output | `logic` | **ram_clear** |
| output | `logic` | **done** |
