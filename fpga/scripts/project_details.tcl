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
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
}

# Specify SystemVerilog design files location   -- EDIT
#    ../rtl/shared_modules/delay.sv \#
#    ../rtl/vga_driver/draw_circle.sv \#
#    ../rtl/vga_driver/draw_terrain.sv \#
#    ../rtl/vga_driver/terrain_ram.sv \#
#    ../rtl/vga_driver/draw_sprite.sv \#
#    ../rtl/vga_driver/sprite_rom.sv \#
#    ../rtl/vga_driver/vga_pkg.sv \#
#    ../rtl/vga_driver/vga_timing.sv \#
#    ../rtl/vga_driver/draw_bg.sv \#
#    ../rtl/vga_driver/vga_if.sv \#
#
#
#    ../rtl/vga_driver/top_vga.sv \#

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

    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    rtl/clk/clk_wiz_0.v \
    rtl/clk/clk_wiz_0_clk_wiz.v
}

# Specify VHDL design files location            -- EDIT
# set vhdl_files {
#    path/to/file.vhd
# }

# Specify files for a memory initialization     -- EDIT
set mem_files {
   ../rtl/audio_driver/luts/phase.dat \
   ../rtl/audio_driver/luts/sine.dat \
   ../rtl/audio_driver/music_files/nokia_ringtone.hex \
   ../rtl/audio_driver/music_files/nokia_ringtone.midi \
   ../rtl/audio_driver/music_files/test_music.hex \
   
   ../rtl/vga_driver/sprite_bank/arrow.dat \
   ../rtl/vga_driver/sprite_bank/weapons_archive.dat \
   ../rtl/vga_driver/sprite_bank/weapons.dat \
   ../rtl/vga_driver/sprite_bank/worms.dat \

   ../rtl/vga_driver/maps/map_test.dat \
   ../rtl/vga_driver/maps/map1.dat 



}
