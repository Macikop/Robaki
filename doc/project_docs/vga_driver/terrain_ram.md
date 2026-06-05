# Module: terrain_ram
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 



---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **WIDTH** | `int` | `1024` |
| **HEIGHT** | `int` | `768` |
| **TERRAIN_FILE_PATH** | `string` | `"../../rtl/vga_driver/maps/map1.dat"` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk_vga** |
| input | `logic` | **clk_core** |
| input | `logic` | **rst_n** |
| input | `logic [$clog2(WIDTH * HEIGHT)-1:0]` | **address_vga** |
| input | `logic [$clog2(WIDTH * HEIGHT)-1:0]` | **address_core** |
| input | `logic` | **clear** |
| output | `logic` | **data_out_vga** |
| output | `logic` | **data_out_core** |
