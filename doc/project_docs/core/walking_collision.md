# Module: walking_collision
[⬅️ Back to Directory Index](../index.md)

## Overview
**Description:** No active functional description found.

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
| input | `logic [10:0]` | **pos_x** |
| input | `logic [10:0]` | **pos_y** |
| input | `logic` | **start** |
| interface | `memory_if.out` | **ram_client** |
| output | `logic [20:0]` | **collisions** |
| output | `logic` | **done** |
