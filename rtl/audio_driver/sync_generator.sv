module sync_generator (
    input  logic clk,
    input  logic rst_n,

    output logic sync
);
    logic [7:0] timer;
    logic sync_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            timer <= '0;
            sync  <= '0;
        end else begin
            timer <= timer + 1;
            sync  <= sync_nxt;
        end
    end

    assign sync_nxt = (timer == 255);
    
endmodule
