# Module: explosion_conseqences
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Calculates damage and kickback from explosion


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **TERRAIN_WIDTH** | `int/logic` | `1024` |
| **TERRAIN_HEIGHT** | `int/logic` | `768` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [$clog2(TERRAIN_WIDTH)-1:0]` | **worm_pos_x** |
| input | `logic [$clog2(TERRAIN_HEIGHT)-1:0]` | **worm_pos_y** |
| input | `logic [$clog2(TERRAIN_WIDTH)-1:0]` | **explosion_pos_x** |
| input | `logic [$clog2(TERRAIN_HEIGHT)-1:0]` | **explosion_pos_y** |
| input | `logic [10:0]` | **explosion_r** |
| input | `logic` | **start** |
| output | `logic signed [7:0]` | **velocity_x** |
| output | `logic signed [7:0]` | **velocity_y** |
| output | `logic [5:0]` | **damage** |
| output | `logic` | **done** |
