# Module: collision_detector
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
> Checks colision with terrain.
> Check is performed on specific points - each side and each corner, according to this pattern.
>
> [0]--[7]--[6]
> |         |
> [1]       [5]
> |         |
> [2]--[3]--[4]
>
>

---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **WIDTH** | `int/logic` | `32` |
| **HEIGHT** | `int/logic` | `32` |
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
| input | `logic` | **start_check** |
| interface | `interface` | **ram_client** |
| output | `logic [7:0]` | **collisions** |
| output | `logic` | **done** |
