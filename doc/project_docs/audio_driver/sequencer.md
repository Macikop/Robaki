# Module: sequencer
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Outputs sequence of notes according to it's lenght


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **FILE_SIZE** | `int/logic` | `14` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **sync_in** |
| input | `logic [31:0]` | **word** |
| output | `logic` | **sync_out** |
| output | `logic [$clog2(FILE_SIZE):0]` | **address** |
| output | `note_t` | **note_out** |
