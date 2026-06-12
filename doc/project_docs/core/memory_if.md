# Interface Architecture: memory_if
[⬅️ Back to Directory Index](../index.md)

## Overview Profiles
**Author:** MP  
**Description:** 
Interface for ram mux


---

## Declared Modport Sub-Interfaces

### Modport: `in`
| Direction | Signal Group |
| :--- | :--- |
| input | **addresses** |
| input | **request** |
| output | **value** |
| output | **granted** |

### Modport: `out`
| Direction | Signal Group |
| :--- | :--- |
| output | **addresses** |
| output | **request** |
| input | **value** |
| input | **granted** |
