# Module: draw_terrain
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Draws terrain from ram, ram is driven by core


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **TERRAIN_WIDTH** | `int/logic` | `1024` |
| **TERRAIN_HEIGHT** | `int/logic` | `768` |
| **X_OFFSET** | `int/logic` | `0` |
| **Y_OFFSET** | `int/logic` | `0` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [11:0]` | **color** |
| input | `logic` | **data_in** |
| output | `logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0]` | **address** |
| interface | `interface` | **vga_in** |
| interface | `interface` | **vga_out** |
