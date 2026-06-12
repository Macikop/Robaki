# Module: worm
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
It allows to move worm, and applies damage when hit.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **WORM_WIDTH** | `int/logic` | `32` |
| **WORM_HEIGHT** | `int/logic` | `32` |
| **TERRAIN_WIDTH** | `int/logic` | `1024` |
| **TERRAIN_HEIGHT** | `int/logic` | `768` |
| **GRAVITY** | `int/logic` | `10` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **active_turn** |
| input | `logic` | **sync** |
| input | `logic [10:0]` | **explosion_x** |
| input | `logic [10:0]` | **explosion_y** |
| input | `logic [7:0]` | **explosion_radius** |
| input | `logic` | **walking_en** |
| input | `logic` | **explosion_en** |
| input | `logic` | **left** |
| input | `logic` | **right** |
| input | `logic [7:0]` | **wind** |
| interface | `interface` | **terrain_ram** |
| output | `logic` | **explosion_done** |
| output | `logic [10:0]` | **pos_x** |
| output | `logic [10:0]` | **pos_y** |
| output | `logic` | **direction** |
| output | `logic [6:0]` | **worm_hp** |
| output | `logic` | **worm_hit** |
