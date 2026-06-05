# Module: worm
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 



---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **WORM_WIDTH** | `int/logic` | `32` |
| **WORM_HEIGHT** | `int/logic` | `32` |
| **GRAVITY** | `int/logic` | `10` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **active_turn** |
| input | `logic` | **sync** |
| input | `state_t` | **current_state** |
| interface | `interface` | **explosion_in** |
| interface | `interface` | **keyboard_in** |
| input | `logic [7:0]` | **wind** |
| interface | `interface` | **terrain_ram_conn** |
| output | `logic [10:0]` | **pos_x** |
| output | `logic [10:0]` | **pos_y** |
| output | `logic` | **direction** |
| output | `logic [7:0]` | **aim_angle** |
