# Module: vga_timing
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** Piotr Kaczmarczyk  
**Modified:** on lab classes  
**Description:** 
Vga timing controller.

Modified on lab classes


---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| output | `logic [10:0]` | **vcount** |
| output | `logic` | **vsync** |
| output | `logic` | **vblnk** |
| output | `logic [10:0]` | **hcount** |
| output | `logic` | **hsync** |
| output | `logic` | **hblnk** |
