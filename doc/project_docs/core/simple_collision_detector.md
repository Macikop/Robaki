# Module: simple_collision_detector
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Checks if collision is detected in current point


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **RAM_DELAY** | `int/logic` | `2` |
| **TERRAIN_WIDTH** | `int/logic` | `1024` |
| **TERRAIN_HEIGHT** | `int/logic` | `768` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [10:0]` | **pos_x** |
| input | `logic [10:0]` | **pos_y** |
| input | `logic` | **start** |
| input | `logic` | **is_occupied** |
| output | `logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0]` | **terrain_address** |
| output | `logic` | **collision** |
| output | `logic` | **done** |
