# Module: midi_decoder
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
Generates pulse width according to the note



---

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `note_t` | **note_in** |
| input | `logic` | **sync_in** |
| output | `logic [7:0]` | **width** |
| output | `logic` | **sync_out** |
