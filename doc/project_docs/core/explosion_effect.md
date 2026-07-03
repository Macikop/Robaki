# Module: explosion_effect
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Generates signals to draw exploison (using draw_circle)


---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **sync** |
| input | `logic` | **explosion_enable** |
| input | `logic [10:0]` | **explosion_x** |
| input | `logic [10:0]` | **explosion_y** |
| input | `logic [7:0]` | **expolsion_radius** |
| output | `logic` | **draw_enable** |
| output | `logic [10:0]` | **pos_x** |
| output | `logic [10:0]` | **pos_y** |
| output | `logic [10:0]` | **radius** |
| output | `logic [11:0]` | **color** |
| output | `logic` | **done** |
