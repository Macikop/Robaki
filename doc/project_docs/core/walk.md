# Module: walk
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Moves worm according to the input and checks for worm collisions.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **SPEED** | `int/logic` | `10` |
| **GRAVITY** | `int/logic` | `4` |
| **TERRAIN_WIDTH** | `int/logic` | `1024` |
| **TERRAIN_HEIGHT** | `int/logic` | `768` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **enable** |
| input | `logic` | **sync** |
| input | `logic` | **left** |
| input | `logic` | **right** |
| input | `logic [10:0]` | **pos_x_init** |
| input | `logic [10:0]` | **pos_y_init** |
| input | `logic [7:0]` | **collisions** |
| input | `logic` | **detector_done** |
| output | `logic` | **start_check** |
| output | `logic [10:0]` | **detector_pos_x** |
| output | `logic [10:0]` | **detector_pos_y** |
| output | `logic [10:0]` | **pos_x** |
| output | `logic [10:0]` | **pos_y** |
