

module key_decoder_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15.3846;    //65MHz
    localparam RST_START_TIME = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;
    
    /**
     *  Signals
     */
    
    
     logic clk, rst_n, ps2_clk, ps2_data;
     logic [7:0] scan_code;
    