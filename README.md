# Robaki
Worms-like game written in System Verilog, developed for the Basys3 board.

This is a project for the UEC2 class at the Microelectronics course at AGH University.

## Project Structure

```text
.
├── env.sh                         - environment configuration
├── doc                            - files with documentation and needed for the class
│   ├── checklist.docx             - file needed for the class
│   └── report.docx                - file needed for the class
├── fpga                           - files related to FPGA
│   ├── constraints                - xdc files
│   │   └── top_vga_basys3.xdc
│   ├── rtl                        - synthesizable files related to FPGA
│   │   └── top_vga_basys3.sv      - module instantiating the top module of the rtl/top* project and blocks
│   │                                    specific to FPGA (e.g., buffers or clock frequency synthesizer)
│   └── scripts                    - tcl scripts (run by appropriate tools from tools)
│       ├── generate_bitstream.tcl
│       ├── program_fpga.tcl
│       └── project_details.tcl    - information about the project name, top module and files for synthesis
├── README.md                      - this file
├── results                        - output files from bitstream generation
│   ├── top_vga_basys3.bit         - bitstream
│   └── warning_summary.log        - summary of warnings and errors
├── rtl                            - synthesizable project files (independent of FPGA)
│   ├── draw_bg.sv
│   ├── top_vga.sv                 - top module
│   ├── vga_pkg.sv                 - package containing constants used in the project
│   └── vga_timing.sv
├── sim                            - folder with tests
│   ├── common                     - files common for many tests
│   │   └── glbl.v                 - file needed for simulation with IP cores; created when calling env.sh
│   │   └── tiff_writer.sv
│   ├── top_fpga                   - folder of a single test
│   │   ├── top_fpga.prj           - list of files with modules used in the test
│   │   └── top_fpga_tb.sv         - testbench code
│   ├── top_vga
│   │   ├── top_vga.prj
│   │   └── top_vga_tb.sv
│   └── vga_timing
│       ├── vga_timing.prj
│       └── vga_timing_tb.sv
└── tools                          - tools for working with the project
    ├── clean.sh                   - cleaning temporary files
    ├── generate_bitstream.sh      - bitstream generation (also runs warning_summary.sh)
    ├── program_fpga.sh            - uploading bitstream to FPGA
    ├── run_simulation.sh          - running simulation
    ├── sim_cmd.tcl                - tcl commands used by run_simulation.sh (should not be called independently)
    └── warning_summary.sh         - filtering warnings and errors from bitstream generation (result in results)
```