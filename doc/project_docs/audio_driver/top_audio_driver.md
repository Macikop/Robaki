# Module: top_audio_driver
[⬅️ Back to Directory Index](../index.md)

## Overview
**Description:** No active functional description found.

---

## Parameter Configurations
| Parameter Name | Data Type | Default Assignment / Value |
| :--- | :--- | :--- |
| **FILE_SIZE** | `int` | `14` |
| **FILE_PATH** | `int` | `"../../rtl/audio_driver/music_files/nokia_ringtone.hex"` |

## Port Interface
| Direction | Data Type | Port Name |
| :--- | :--- | :--- |
| input | `logic` | **clk** |
| input | `logic` | **rst_n** |
| input | `logic` | **mute** |
| input | `logic` | **volume** |
| output | `logic` | **wave_out** |
| output | `logic` | **gain** |
| output | `logic` | **shoutdown** |
