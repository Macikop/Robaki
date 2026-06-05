# Project Architecture & IP Directory Index
[🏠 Go to Project README](../../README.md)

Generated tracking tree of available functional system hardware modules.

## Component Directories

### 📂 Area Workspace: `rtl/audio_driver`
* 🛠️ Logic Module: [address_counter](audio_driver/address_counter.md)
* 🛠️ Logic Module: [midi_decoder](audio_driver/midi_decoder.md)
* 🛠️ Logic Module: [music_rom](audio_driver/music_rom.md)
* 📦 Package Reference: [note_pkg](audio_driver/note_pkg.md)
* 🛠️ Logic Module: [phase_increment_lut](audio_driver/phase_increment_lut.md)
* 🛠️ Logic Module: [pwm_generator](audio_driver/pwm_generator.md)
* 🛠️ Logic Module: [sequencer](audio_driver/sequencer.md)
* 🛠️ Logic Module: [sine_lut](audio_driver/sine_lut.md)
* 🛠️ Logic Module: [sync_generator](audio_driver/sync_generator.md)
* 🛠️ Logic Module: [top_audio_driver](audio_driver/top_audio_driver.md)

### 📂 Area Workspace: `rtl/core`
* 🛠️ Logic Module: [aim](core/aim.md)
* 🛠️ Logic Module: [bullet](core/bullet.md)
* 🛠️ Logic Module: [collision_dectector](core/collision_dectector.md)
* 🛠️ Logic Module: [explosion](core/explosion.md)
* 🛠️ Logic Module: [explosion_consequences](core/explosion_consequences.md)
* 🛠️ Logic Module: [master_fsm](core/master_fsm.md)
* 🛠️ Logic Module: [physics_engine](core/physics_engine.md)
* 🛠️ Logic Module: [polar_to_cartesian](core/polar_to_cartesian.md)
* 🛠️ Logic Module: [ram_address_mux](core/ram_address_mux.md)
* 🛠️ Logic Module: [rng](core/rng.md)
* 🛠️ Logic Module: [simple_collision_detector](core/simple_collision_detector.md)
* 🛠️ Logic Module: [tdc](core/tdc.md)
* 🛠️ Logic Module: [terrain_destruction](core/terrain_destruction.md)
* 🛠️ Logic Module: [worm](core/worm.md)

### 📂 Area Workspace: `rtl/shared_modules`
* 🛠️ Logic Module: [delay](shared_modules/delay.md)
* 🛠️ Logic Module: [edge_detector](shared_modules/edge_detector.md)

### 📂 Area Workspace: `rtl/vga_driver`
* 🛠️ Logic Module: [draw_bg](vga_driver/draw_bg.md)
* 🛠️ Logic Module: [draw_circle](vga_driver/draw_circle.md)
* 🛠️ Logic Module: [draw_sprite](vga_driver/draw_sprite.md)
* 🛠️ Logic Module: [draw_terrain](vga_driver/draw_terrain.md)
* 🛠️ Logic Module: [sprite_rom](vga_driver/sprite_rom.md)
* 🛠️ Logic Module: [terrain_ram](vga_driver/terrain_ram.md)
* 🛠️ Logic Module: [top_vga](vga_driver/top_vga.md)
* 🔀 Interface Mapping: [vga_if](vga_driver/vga_if.md)
* 📦 Package Reference: [vga_pkg](vga_driver/vga_pkg.md)
* 🛠️ Logic Module: [vga_timing](vga_driver/vga_timing.md)
