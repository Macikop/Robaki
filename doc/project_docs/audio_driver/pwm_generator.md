# Module: pwm_generator
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Generates pwm pulse at every sync signal, pulse is 256 clk long and specified width


---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **sync** |
| input | `logic [7:0]` | **width** |
| output | `logic` | **wave_out** |
