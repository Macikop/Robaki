# Module: top_vga
[⬅️ Back to Directory Index](../index.md)

## Overview
**Description:** No active functional description found.

---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **TERRAIN_WIDTH** | `int` | `1024` |
| **TERRAIN_HEIGHT** | `int` | `768` |
| **SPRITE_WIDTH** | `int` | `32` |
| **SPRITE_HEIGHT** | `int` | `32` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **start_screen_en** |
| input | `logic` | **draw_worms** |
| input | `logic` | **end_screen_en** |
| input | `logic [10:0]` | **draw_worm_0_x_pos** |
| input | `logic [10:0]` | **draw_worm_0_y_pos** |
| input | `logic` | **draw_worm_0_orientation** |
| input | `logic [10:0]` | **draw_worm_1_x_pos** |
| input | `logic [10:0]` | **draw_worm_1_y_pos** |
| input | `logic` | **draw_worm_1_orientation** |
| input | `logic [10:0]` | **aim_x_pos** |
| input | `logic [10:0]` | **aim_y_pos** |
| input | `logic` | **aim_en** |
| input | `logic [10:0]` | **draw_bullet_x** |
| input | `logic [10:0]` | **draw_bullet_y** |
| input | `logic` | **draw_bullet_en** |
| input | `logic [10:0]` | **draw_explosion_x** |
| input | `logic [10:0]` | **draw_expolsion_y** |
| input | `logic [10:0]` | **draw_explosion_radius** |
| input | `logic` | **draw_explosion_en** |
| input | `logic [11:0]` | **draw_explosion_color** |
| input | `logic` | **terrain_present** |
| output | `logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0]` | **address_terrain** |
| output | `logic` | **vs** |
| output | `logic` | **hs** |
| output | `logic [3:0]` | **r** |
| output | `logic [3:0]` | **g** |
| output | `logic [3:0]` | **b** |
