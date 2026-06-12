# Module: aim
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Gets up and down key and outputs position of aim marker (and aim_angle to bullet).


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **AIM_DISTACNE** | `logic [7:0]` | `50` |
| **X_OFFSET** | `logic [10:0]` | `16` |
| **Y_OFFSET** | `logic [10:0]` | `16` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **sync** |
| input | `logic` | **up** |
| input | `logic` | **down** |
| input | `logic signed [7:0]` | **x_aim** |
| input | `logic signed [7:0]` | **y_aim** |
| input | `logic [10:0]` | **x_pos** |
| input | `logic [10:0]` | **y_pos** |
| input | `logic` | **orientation** |
| input | `logic` | **calc_done** |
| output | `logic` | **start_calc** |
| output | `logic [7:0]` | **aim_angle** |
| output | `logic [7:0]` | **length** |
| output | `logic [10:0]` | **x_out** |
| output | `logic [10:0]` | **y_out** |
| input | `logic` | **enable** |
