# Module: draw_sprite
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Draws sprite, modifies it according to flags


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **WIDTH** | `int/logic` | `32` |
| **HEIGHT** | `int/logic` | `32` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [11:0]` | **x_pos** |
| input | `logic [11:0]` | **y_pos** |
| input | `logic [2:0]` | **modifier** |
| input | `logic [12:0]` | **rgb_pixel** |
| output | `logic [$clog2(WIDTH*HEIGHT)-1:0]` | **pixel_address** |
| interface | `interface` | **vga_in** |
| interface | `interface` | **vga_out** |
