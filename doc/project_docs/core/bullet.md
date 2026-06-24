# Module: bullet
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Decides how bullet should move


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **GRAVITY** | `int` | `10` |
| **TERRAIN_WIDTH** | `int` | `1024` |
| **TERRAIN_HEIGHT** | `int` | `768` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **sync** |
| input | `logic` | **enable** |
| input | `logic signed [7:0]` | **wind** |
| input | `logic [7:0]` | **aim_angle** |
| input | `logic [7:0]` | **shot_power** |
| input | `logic [10:0]` | **worm_pos_x** |
| input | `logic [10:0]` | **worm_pos_y** |
| input | `logic signed [7:0]` | **x_component** |
| input | `logic signed [7:0]` | **y_component** |
| input | `logic` | **conv_done** |
| output | `logic` | **conv_start** |
| output | `logic [7:0]` | **conv_phi** |
| output | `logic [7:0]` | **conv_length** |
| output | `logic` | **start_exposion** |
| interface | `memory_if.out` | **ram_client** |
| output | `logic` | **enable_draw** |
| output | `logic [10:0]` | **pos_x** |
| output | `logic [10:0]` | **pos_y** |
