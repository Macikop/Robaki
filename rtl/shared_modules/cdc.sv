/*
 * Designed by MP
 * 
 * How it works:
 * Clock Crossing Domain - multibit, multistage
 */

module cdc #(
    parameter STAGES = 2,
    parameter WIDTH = 8
)(
    input  logic clk_a,
    input  logic clk_b,

    input  logic rst_n,
    

    input  logic [WIDTH-1:0] data_in,
    input  logic send_data,

    output logic [WIDTH-1:0] data_out
);

    logic toggle_a;
    logic toggle_sync_b;
    logic toggle_sync_b_reg;

    logic [WIDTH-1:0] data_holding_a;

    (* ASYNC_REG = "TRUE" *)
    logic [STAGES-1: 0] sync_ff ;

    /* domain A */
    always_ff @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            toggle_a <= 1'b0;
            data_holding_a <= '0;
        end else if (send_data) begin
            toggle_a <= ~toggle_a;
            data_holding_a <= data_in;
        end
    end

    /* Synchronization */
    always_ff @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff <= '0;
        end else begin
            sync_ff <= {sync_ff [STAGES-2 : 0], toggle_a} ;     
        end  
    end

    assign toggle_sync_b = sync_ff [STAGES-1] ;

    /* domain B */
    always_ff @(posedge clk_b or negedge rst_n) begin
        if (!rst_n) begin
            toggle_sync_b_reg <= 1'b0;
            data_out <= '0;
        end else begin
            toggle_sync_b_reg <= toggle_sync_b;
            if (toggle_sync_b ^ toggle_sync_b_reg) begin
                data_out <= data_holding_a; 
            end
        end
    end    

endmodule