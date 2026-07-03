# Module: sprite_rom
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** Robert Szczygiel  
**Modified:** Piotr Kaczmarczyk  
**Description:** 
This is the ROM for the 'AGH48x64.png' image.
The image size is 48 x 64 pixels.
The input 'address' is a 12-bit number, composed of the concatenated
6-bit y and 6-bit x pixel coordinates.
The output 'rgb' is 12-bit number with concatenated
red, green and blue color values (4-bit each)


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **WIDTH** | `int` | `32` |
| **HEIGHT** | `int` | `32` |
| **SPRITE_PATH** | `string` | `"../../rtl/vga_driver/sprite_bank/arrow.dat"` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [$clog2(WIDTH * HEIGHT)-1:0]` | **address** |
| output | `logic [12:0]` | **rgb** |
