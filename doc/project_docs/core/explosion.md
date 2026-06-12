# Module: explosion
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 



---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **RADIUS** | `logic [7:0]` | `50` |
| **TERRAIN_WIDTH** | `int/logic` | `1024` |
| **TERRAIN_HEIGHT** | `int/logic` | `768` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **enable** |
| input | `logic` | **sync** |
| input | `logic [10:0]` | **explosion_x** |
| input | `logic [10:0]` | **explosion_y** |
| output | `logic` | **explosion_done** |
| output | `logic [7:0]` | **explosion_radius** |
| output | `logic [10:0]` | **draw_explosion_x** |
| output | `logic [10:0]` | **draw_explosion_y** |
| output | `logic [10:0]` | **draw_explosion_r** |
| output | `logic` | **draw_explosion_en** |
| output | `logic [11:0]` | **draw_explosion_color** |
| output | `logic` | **ram_clear** |
| interface | `interface` | **terrain_ram** |
