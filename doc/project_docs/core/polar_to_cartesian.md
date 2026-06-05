# Module: polar_to_cartesian
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Calculates X and Y component of the vector according to length and angle


---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **start** |
| input | `logic [7:0]` | **phi** |
| input | `logic [7:0]` | **length** |
| input | `logic [7:0]` | **lut_value** |
| output | `logic [7:0]` | **lut_address** |
| output | `logic signed [15:0]` | **x_component** |
| output | `logic signed [15:0]` | **y_component** |
| output | `logic` | **done** |
