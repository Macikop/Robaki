/*
 * Designed by MP
 * 
 * How it works:
 * Switches between modules that try to access RAM.
 * Uses Round-Robin, granted is imidiet, data arrives after delay.
 */


module ram_address_mux #(
    parameter ADDRESS_WIDTH = 20,
    parameter WORD_WIDTH    = 1,
    parameter INPUTS_NUMBER = 3,
    parameter WRITE_CHANNEL = 0,
    parameter RAM_DELAY     = 2
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [ADDRESS_WIDTH-1:0] addresses [0:INPUTS_NUMBER-1],
    input  logic request [0:INPUTS_NUMBER-1],
    input  logic clear,

    input  logic [WORD_WIDTH-1:0] ram_value,
    
    output logic [WORD_WIDTH-1:0] value [0:INPUTS_NUMBER-1],
    output logic granted [0:INPUTS_NUMBER-1],
    
    output logic [ADDRESS_WIDTH-1:0] ram_address,
    output logic ram_clear
);


    logic [ADDRESS_WIDTH-1:0] ram_address_nxt;
    logic [WORD_WIDTH-1:0] value_nxt [0:INPUTS_NUMBER-1];
    logic granted_nxt [0:INPUTS_NUMBER-1];
    logic ram_clear_nxt;

    logic [$clog2(INPUTS_NUMBER)-1:0] last_access, last_access_nxt;
    logic [$clog2(INPUTS_NUMBER)-1:0] delay_pipeline [0:RAM_DELAY-1];
    logic delay_valid [0:RAM_DELAY-1];

    logic any_request_granted;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ram_address <= '0;
            ram_clear <= '0;
            last_access <= '0;

            for (int i = 0; i < INPUTS_NUMBER; i++) begin
                value[i] <= '0;
                granted[i] <= '0;
            end

            for (int k = 0; k < RAM_DELAY; k++) begin
                delay_pipeline[k] <= '0;
                delay_valid[k] <= 1'b0;
            end
            
        end else begin
            ram_address <= ram_address_nxt;
            ram_clear <= ram_clear_nxt;
            last_access <= last_access_nxt;

            for (int i = 0; i < INPUTS_NUMBER; i++) begin
                value[i] <= value_nxt[i];
                granted[i] <= granted_nxt[i];
            end

            delay_pipeline[0] <= last_access_nxt;
            delay_valid[0]    <= any_request_granted;
            
            for (int k = 1; k < RAM_DELAY; k++) begin
                delay_pipeline[k] <= delay_pipeline[k-1];
                delay_valid[k] <= delay_valid[k-1];
            end
        end
    end

    always_comb begin
        ram_address_nxt = ram_address; 
        ram_clear_nxt = 1'b0; 
        last_access_nxt = last_access;
        any_request_granted = 1'b0;

        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            granted_nxt[i] = 1'b0;
            value_nxt[i]   = value[i];
        end

        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            if (request[i] && (i > last_access) && !any_request_granted) begin
                ram_address_nxt = addresses[i];
                last_access_nxt = ADDRESS_WIDTH'(i);
                granted_nxt[i] = 1'b1;
                ram_clear_nxt = (i == WRITE_CHANNEL) ? clear : 1'b0;
                any_request_granted = 1'b1;
            end
        end

        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            if (request[i] && (i <= last_access) && !any_request_granted) begin
                if (request[i]) begin
                    ram_address_nxt = addresses[i];
                    last_access_nxt = ADDRESS_WIDTH'(i);
                    granted_nxt[i] = 1'b1;
                    ram_clear_nxt = (i == WRITE_CHANNEL) ? clear : 1'b0;
                    any_request_granted = 1'b1;
                end
            end
        end

        if (delay_valid[RAM_DELAY-1]) begin
            value_nxt[delay_pipeline[RAM_DELAY-1]] = ram_value;
        end
    end

endmodule
