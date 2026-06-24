# Module: top_core
[⬅️ Back to Directory Index](../index.md)

## Overview
**Description:** No active functional description found.

---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **TERRAIN_WIDTH** | `int` | `1024` |
| **TERRAIN_HEIGHT** | `int` | `768` |
| **WORM_WIDTH** | `int` | `32` |
| **WORM_HEIGHT** | `int` | `32` |
| **GRAVITY** | `int` | `10` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **vsync** |
| input | `logic` | **space** |
| input | `logic` | **up** |
| input | `logic` | **down** |
| input | `logic` | **left** |
| input | `logic` | **right** |
| input | `logic` | **ram_value** |
| output | `logic [$clog2(TERRAIN_WIDTH * TERRAIN_WIDTH)-1:0]` | **ram_address** |
| output | `logic` | **ram_clear** |
| output | `logic` | **draw_worms** |
| output | `logic [10:0]` | **draw_worm_0_x_pos** |
| output | `logic [10:0]` | **draw_worm_0_y_pos** |
| output | `logic` | **draw_worm_0_orientation** |
| output | `logic [10:0]` | **draw_worm_1_x_pos** |
| output | `logic [10:0]` | **draw_worm_1_y_pos** |
| output | `logic` | **draw_worm_1_orientation** |
| output | `logic [10:0]` | **aim_x_pos** |
| output | `logic [10:0]` | **aim_y_pos** |
| output | `logic` | **aim_en** |
| output | `logic [10:0]` | **draw_bullet_x** |
| output | `logic [10:0]` | **draw_bullet_y** |
| output | `logic` | **draw_bullet_en** |
| output | `logic [10:0]` | **draw_explosion_x** |
| output | `logic [10:0]` | **draw_expolsion_y** |
| output | `logic [10:0]` | **draw_explosion_radius** |
| output | `logic` | **draw_explosion_en** |
