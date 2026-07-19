/*
 * Designed by MP
 * 
 * How it works:
 * Synchroniser is simple 1 bit n STAGE ff cdc
 */

module synchroniser #(
    parameter STAGES = 2
)(
    input  logic clk,

    input  logic rst_n,

    input  logic data_in,
    output logic data_out
);

    (* ASYNC_REG = "TRUE" *)
    logic [STAGES-1: 0] sync_ff ;

    /* Synchronization */
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff <= '0;
        end else begin
            sync_ff <= {sync_ff [STAGES-2 : 0], data_in} ;     
        end  
    end

    assign data_out = sync_ff [STAGES-1];

endmodule