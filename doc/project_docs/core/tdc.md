# Module: tdc
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Time-Digital Converter - converts time of holding key to value.
Measurement with accuracy to sync. Sets done on falling edge of pulse.


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **MAX_TIME** | `int/logic` | `255` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **sync** |
| input | `logic` | **enable** |
| input | `logic` | **pulse** |
| output | `logic [$clog2(MAX_TIME + 1)-1:0]` | **value** |
| output | `logic` | **done** |
