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
| **TERRAIN_WIDTH** | `int` | `1024` |
| **TERRAIN_HEIGHT** | `int` | `768` |
| **X_OFFSET** | `int` | `0` |
| **Y_OFFSET** | `int` | `0` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **enable** |
| input | `logic [11:0]` | **color** |
| input | `logic` | **data_in** |
| output | `logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0]` | **address** |
| interface | `vga_if.in` | **vga_in** |
| interface | `vga_if.out` | **vga_out** |
