# Module: music_rom
[⬅️ Back to Directory Index](../index.md)

## Overview
**Author:** MP  
**Description:** 
It is ROM where music sits


---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **FILE_SIZE** | `int` | `16` |
| **FILE_PATH** | `int` | `"../../rtl/audio_driver/music_files/nokia_ringtone.hex"` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic [$clog2(FILE_SIZE):0]` | **address** |
| output | `logic [31:0]` | **value** |
