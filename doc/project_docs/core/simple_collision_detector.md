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
| **RAM_DELAY** | `int` | `2` |
| **TERRAIN_WIDTH** | `int` | `1024` |
| **TERRAIN_HEIGHT** | `int` | `768` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| interface | `memory_if.out` | **ram_client** |
| input | `logic [10:0]` | **pos_x** |
| input | `logic [10:0]` | **pos_y** |
| input | `logic` | **start** |
| output | `logic` | **collision** |
| output | `logic` | **done** |
