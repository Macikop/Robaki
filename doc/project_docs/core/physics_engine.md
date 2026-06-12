# Module: physics_engine
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP (Modified for pre-collision fallback)  
**Modified:** for pre-collision fallback)  
**Description:** 
Moves object and applies wind and gravity to it.
Object stops moving when it hits terrain (cd_hit) or map border.
If a collision occurs, it rewinds to the last valid step position.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **GRAVITY** | `int/logic` | `10` |
| **MAP_WIDTH** | `int/logic` | `1024` |
| **MAP_HEIGHT** | `int/logic` | `768` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **sync** |
| input | `logic` | **start** |
| input | `logic signed [7:0]` | **wind** |
| input | `logic signed [7:0]` | **velocity_x_init** |
| input | `logic signed [7:0]` | **velocity_y_init** |
| input | `logic [10:0]` | **pos_x_init** |
| input | `logic [10:0]` | **pos_y_init** |
| input | `logic [7:0]` | **cd_hit** |
| input | `logic` | **cd_done** |
| output | `logic` | **cd_start** |
| output | `logic` | **done** |
| output | `logic [10:0]` | **pos_x** |
| output | `logic [10:0]` | **pos_y** |
