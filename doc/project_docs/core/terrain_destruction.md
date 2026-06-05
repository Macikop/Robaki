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
| **TERRAIN_WIDTH** | `int/logic` | `1024` |
| **TERRAIN_HEIGHT** | `int/logic` | `768` |
| **RAM_DELAY** | `int/logic` | `2` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **start** |
| input | `logic [10:0]` | **pos_x** |
| input | `logic [10:0]` | **pos_y** |
| input | `logic [7:0]` | **radius** |
| output | `logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0]` | **ram_address** |
| output | `logic` | **ram_clr** |
| output | `logic` | **done** |
