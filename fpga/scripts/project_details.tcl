# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name robaki

# Top module name                               -- EDIT
set top_module top_robaki

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_robaki.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/audio_driver/address_counter.sv \
    ../rtl/audio_driver/midi_decoder.sv \
    ../rtl/audio_driver/music_rom.sv \
    ../rtl/audio_driver/note_pkg.sv \
    ../rtl/audio_driver/phase_increment_lut.sv \
    ../rtl/audio_driver/pwm_generator.sv \
    ../rtl/audio_driver/sequencer.sv \
    ../rtl/audio_driver/sine_lut.sv \
    ../rtl/audio_driver/sync_generator.sv \
    ../rtl/audio_driver/top_audio_driver.sv \

    ../rtl/core/aim.sv \
    ../rtl/core/bullet.sv \
    ../rtl/core/collision_detector.sv \
    ../rtl/core/explosion_consequences.sv \
    ../rtl/core/explosion_effect.sv \
    ../rtl/core/explosion.sv \
    ../rtl/core/master_fsm.sv \
    ../rtl/core/memory_if.sv \
    ../rtl/core/physics_engine.sv \
    ../rtl/core/polar_to_cartesian.sv \
    ../rtl/core/ram_address_mux.sv \
    ../rtl/core/rng.sv \
    ../rtl/core/simple_collision_detector.sv \
    ../rtl/core/tdc.sv \
    ../rtl/core/terrain_destruction.sv \
    ../rtl/core/top_core.sv \
    ../rtl/core/walk.sv \
    ../rtl/core/walking_collision.sv \
    ../rtl/core/worm.sv \

    ../rtl/keyboard_driver/key_decoder.sv \
    ../rtl/keyboard_driver/top_keyboard_driver.sv \

    ../rtl/shared_modules/synchroniser.sv \
    ../rtl/shared_modules/cdc.sv \
    ../rtl/shared_modules/delay.sv \
    ../rtl/shared_modules/edge_detector.sv \
    ../rtl/shared_modules/sr_flip_flop.sv \

    ../rtl/vga_driver/draw_bg.sv \
    ../rtl/vga_driver/draw_circle.sv \
    ../rtl/vga_driver/draw_sprite.sv \
    ../rtl/vga_driver/draw_terrain.sv \
    ../rtl/vga_driver/sprite_rom.sv \
    ../rtl/vga_driver/terrain_ram.sv \
    ../rtl/vga_driver/top_vga.sv \
    ../rtl/vga_driver/vga_if.sv \
    ../rtl/vga_driver/vga_pkg.sv \
    ../rtl/vga_driver/vga_timing.sv \

    ../rtl/top_game.sv \

    rtl/top_robaki.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    rtl/clk/clk_wiz_0.v \
    rtl/clk/clk_wiz_0_clk_wiz.v 
}

# Specify VHDL design files location            -- EDIT
set vhdl_files {
    ../rtl/keyboard_driver/Ps2Interface.vhd
}

# Specify files for a memory initialization     -- EDIT
set mem_files {
    ../rtl/audio_driver/luts/phase.dat \
    ../rtl/audio_driver/luts/sine.dat \

    ../rtl/audio_driver/music_files/nokia_ringtone.hex \
    ../rtl/audio_driver/music_files/the_a_team.hex \

    ../rtl/vga_driver/sprite_bank/agh_logo.dat \
    ../rtl/vga_driver/sprite_bank/aim.dat \
    ../rtl/vga_driver/sprite_bank/arrow.dat \
    ../rtl/vga_driver/sprite_bank/logo.dat \
    ../rtl/vga_driver/sprite_bank/worm.dat \

    ../rtl/vga_driver/maps/map1.dat 
}
