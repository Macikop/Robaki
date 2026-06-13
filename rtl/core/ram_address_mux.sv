/*
 * Designed by MP
 * 
 * How it works:
 * Switches between modules that try to access RAM.
 * Uses Round-Robin, granted is immediate, data arrives after delay.
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

    memory_if.in clients [0:INPUTS_NUMBER-1],

    input  logic clear,
    input  logic [WORD_WIDTH-1:0] ram_value,
    
    output logic [ADDRESS_WIDTH-1:0] ram_address,
    output logic ram_clear
);

    typedef logic [$clog2(INPUTS_NUMBER)-1:0] index_t;

    logic [ADDRESS_WIDTH-1:0] ram_address_nxt;
    logic [WORD_WIDTH-1:0] value_nxt [0:INPUTS_NUMBER-1];
    logic granted_nxt [0:INPUTS_NUMBER-1];
    logic ram_clear_nxt;

    index_t last_access, last_access_nxt;
    index_t delay_pipeline [0:RAM_DELAY-1];
    logic   delay_valid [0:RAM_DELAY-1];

    logic any_request_granted;

    logic [ADDRESS_WIDTH-1:0] client_addresses [0:INPUTS_NUMBER-1];
    logic client_request [0:INPUTS_NUMBER-1];

    genvar g;
    generate
        for (g = 0; g < INPUTS_NUMBER; g++) begin : gen_unpack_interfaces
            assign client_addresses[g] = clients[g].addresses;
            assign client_request[g]   = clients[g].request;
            

            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    clients[g].granted <= 1'b0;
                    clients[g].value   <= '0;
                end else begin
                    clients[g].granted <= granted_nxt[g];
                    clients[g].value   <= value_nxt[g];
                end
            end
        end
    endgenerate

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ram_address <= '0;
            ram_clear   <= '0;
            last_access <= '0;

            for (int k = 0; k < RAM_DELAY; k++) begin
                delay_pipeline[k] <= '0;
                delay_valid[k]    <= 1'b0;
            end
            
        end else begin
            ram_address <= ram_address_nxt;
            ram_clear   <= ram_clear_nxt;
            last_access <= last_access_nxt;

            delay_pipeline[0] <= last_access_nxt;
            delay_valid[0]    <= any_request_granted;
            
            for (int k = 1; k < RAM_DELAY; k++) begin
                delay_pipeline[k] <= delay_pipeline[k-1];
                delay_valid[k]    <= delay_valid[k-1];
            end
        end
    end

    always_comb begin
        ram_address_nxt     = ram_address; 
        ram_clear_nxt       = 1'b0; 
        last_access_nxt     = last_access;
        any_request_granted = 1'b0;

        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            if (client_request[i] && (i > last_access)) begin
                ram_address_nxt     = client_addresses[i];
                last_access_nxt     = index_t'(i);
                ram_clear_nxt       = (i == WRITE_CHANNEL) ? clear : 1'b0;
                any_request_granted = 1'b1;
                break;
            end
        end

        if (!any_request_granted) begin
            for (int i = 0; i < INPUTS_NUMBER; i++) begin
                if (client_request[i] && (i <= last_access)) begin
                    ram_address_nxt     = client_addresses[i];
                    last_access_nxt     = index_t'(i);
                    ram_clear_nxt       = (i == WRITE_CHANNEL) ? clear : 1'b0;
                    any_request_granted = 1'b1;
                    break;
                end
            end
        end

        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            if (any_request_granted && (index_t'(i) == last_access_nxt)) begin
                granted_nxt[i] = 1'b1;
            end else begin
                granted_nxt[i] = 1'b0;
            end
        end

        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            if (delay_valid[RAM_DELAY-1] && (index_t'(i) == delay_pipeline[RAM_DELAY-1])) begin
                value_nxt[i] = ram_value;
            end else begin
                value_nxt[i] = '0;
            end
        end
    
    end

endmodule
