/*
 * Designed by MP
 * * Description:
 * Testbench for ram_address_mux module.
 */

module ram_address_mux_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam WIDTH = 4;
    localparam HEIGHT = 4;
    localparam ADDR_WIDTH = $clog2(WIDTH * HEIGHT); 
    localparam WORD_WIDTH = 1;
    localparam INPUTS_NUMBER = 3;
    localparam WRITE_CHANNEL = 0;
    localparam RAM_DELAY = 2;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    
    logic [ADDR_WIDTH-1:0] address_core;
    logic [WORD_WIDTH-1:0] data_out_core;
    logic clear_sig;
    logic tb_clear;

    // Instantiate the physical interface array
    memory_if client_ifs[0:INPUTS_NUMBER-1]();

    // Declare a virtual interface array to allow dynamic variable indexing inside tasks
    virtual memory_if v_client_ifs[0:INPUTS_NUMBER-1];

    // Explicitly unrolled to satisfy Vivado's static indexing requirements
    initial begin
        v_client_ifs[0] = client_ifs[0];
        v_client_ifs[1] = client_ifs[1];
        v_client_ifs[2] = client_ifs[2];
    end

    /**
     * Clock generation
     */
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */
    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end


    /**
     * Supporting modules
     */
    terrain_ram # (
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map_test.dat")
    ) u_terrain_ram (
        .clk_vga(1'b0),
        .clk_core(clk),
        .rst_n(rst_n),
        .address_vga('0),
        .address_core(address_core),
        .clear(clear_sig),
        .data_out_vga(),
        .data_out_core(data_out_core)
    );

    /**
     * DUT placement
     */
    ram_address_mux #(
        .ADDRESS_WIDTH(ADDR_WIDTH),
        .WORD_WIDTH(WORD_WIDTH),
        .INPUTS_NUMBER(INPUTS_NUMBER),
        .WRITE_CHANNEL(WRITE_CHANNEL),
        .RAM_DELAY(RAM_DELAY)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .clients(client_ifs), // Pass the physical interface array directly
        .clear(tb_clear),
        .ram_value(data_out_core),
        .ram_address(address_core),
        .ram_clear(clear_sig)
    );


    /**
     * Tasks and Functions
     */

    task automatic clear_channels();
        tb_clear <= 1'b0;
        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            v_client_ifs[i].addresses <= '0;
            v_client_ifs[i].request   <= 1'b0;
        end
    endtask

    task automatic run_single_channel_test(
        input int channel,
        input logic [ADDR_WIDTH-1:0] test_addr,
        input logic [WORD_WIDTH-1:0] expected_data
    );
        @(posedge clk);
        $display("[TB_TASK] Running Single Channel Test on Ch %0d (Addr: %0d)...", channel, test_addr);
        
        v_client_ifs[channel].addresses <= test_addr;
        v_client_ifs[channel].request   <= 1'b1;
        
        @(posedge clk); 
        
        @(negedge clk); 
        assert(v_client_ifs[channel].granted === 1'b1) begin
            $display("PASSED Channel %0d successfully granted RAM access.", channel);
        end else begin
            $error("FAILED Arbitration Channel %0d was denied explicit slot access.", channel);
        end
        
        v_client_ifs[channel].request <= 1'b0; 
        
        repeat(RAM_DELAY) @(posedge clk);

        @(negedge clk); 
        assert(v_client_ifs[channel].value === expected_data) begin
            $display("PASSED Got: %b", v_client_ifs[channel].value);
        end else begin
            $error("FAILED Channel %0d! Got: %b, Expected: %b", channel, v_client_ifs[channel].value, expected_data);
        end
        
        clear_channels();
        repeat(2) @(posedge clk);
    endtask

    task automatic run_contention_test(
        input logic [ADDR_WIDTH-1:0] addr_ch0,
        input logic [ADDR_WIDTH-1:0] addr_ch1,
        input logic [ADDR_WIDTH-1:0] addr_ch2
    );
        int expected_grant;
        logic found_next;
        logic active_requests[INPUTS_NUMBER];

        @(posedge clk);
        
        v_client_ifs[0].addresses <= addr_ch0; 
        v_client_ifs[0].request <= 1'b1;
        v_client_ifs[1].addresses <= addr_ch1; 
        v_client_ifs[1].request <= 1'b1;
        v_client_ifs[2].addresses <= addr_ch2; 
        v_client_ifs[2].request <= 1'b1;
        
        active_requests[0] = 1'b1;
        active_requests[1] = 1'b1;
        active_requests[2] = 1'b1;

        for (int step = 0; step < INPUTS_NUMBER; step++) begin
            found_next = 1'b0;
            
            for (int i = 0; i < INPUTS_NUMBER; i++) begin
                if (i > dut.last_access && active_requests[i] && !found_next) begin
                    expected_grant = i;
                    found_next = 1'b1;
                end
            end

            for (int i = 0; i < INPUTS_NUMBER; i++) begin
                if (i <= dut.last_access && active_requests[i] && !found_next) begin
                    expected_grant = i;
                    found_next = 1'b1;
                end
            end

            @(posedge clk);
            @(negedge clk);
            
            assert(v_client_ifs[expected_grant].granted === 1'b1) begin 
                $display("Cycle %0d Checkpoint | Granted: Ch0=%b, Ch1=%b, Ch2=%b (Expected Ch%0d)", step, v_client_ifs[0].granted, v_client_ifs[1].granted, v_client_ifs[2].granted, expected_grant);
            end else begin
                $error("FAILED: Round-Robin Violation! Expected Channel %0d to win, but it was not granted.", expected_grant);
            end

            for (int i = 0; i < INPUTS_NUMBER; i++) begin
                if (i != expected_grant) begin
                    assert(v_client_ifs[i].granted === 1'b0) else begin
                        $error("Channel %0d was granted access simultaneously with Channel %0d.", i, expected_grant);
                    end
                end
            end

            v_client_ifs[expected_grant].request <= 1'b0;
            active_requests[expected_grant] = 1'b0;
        end
        
        clear_channels();
        repeat(RAM_DELAY + 1) @(posedge clk);
    endtask

    /**
     * Main Test Execution Sequence
     */
    initial begin
        @(negedge rst_n)
        @(posedge rst_n);
        
        clear_channels();
        @(posedge clk);

        $display("Single channel test");
        run_single_channel_test(1, ADDR_WIDTH'(4'd5), 1'b0);
        run_single_channel_test(0, ADDR_WIDTH'(4'd1), 1'b1);
        run_single_channel_test(2, ADDR_WIDTH'(4'd2), 1'b1);

        $display("Multi channel test");
        run_contention_test(ADDR_WIDTH'(4'd0), ADDR_WIDTH'(4'd6), ADDR_WIDTH'(4'd11));

        repeat (3) @(posedge clk);
        $finish;
    end

endmodule