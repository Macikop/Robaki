# Module: draw_bg
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** Piotr Kaczmarczyk  
**Description:** 
Draw background.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **COLOR** | `[11:0]` | `12'h0_a_a` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [10:0]` | **vcount_in** |
| input | `logic` | **vsync_in** |
| input | `logic` | **vblnk_in** |
| input | `logic [10:0]` | **hcount_in** |
| input | `logic` | **hsync_in** |
| input | `logic` | **hblnk_in** |
| interface | `interface` | **vga_out** |
