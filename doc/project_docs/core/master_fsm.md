# Module: master_fsm
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Decides the game flow


---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **space_bar** |
| input | `logic` | **vsync_in** |
| input | `logic [6:0] [0:1]` | **worm_health** |
| input | `logic [0:1]` | **worms_on_ground** |
| input | `logic` | **bullet_impact** |
| input | `logic` | **explosion_done** |
| output | `logic` | **sync_out** |
| output | `logic` | **start_screen_en** |
| output | `logic` | **walking_en** |
| output | `logic` | **shooting_en** |
| output | `logic` | **bullet_en** |
| output | `logic` | **explosion_en** |
| output | `logic` | **end_screen_en** |
| output | `logic` | **capture_wind** |
| output | `logic` | **current_player** |
