/*
 *  Designed by MP
 * 
 * How it works
 */

module sequencer #(
    localparam FILE_SIZE = 2
)(
    input  logic clk,
    input  logic rst_n,

    input  logic sync_in,
    input  logic [31:0] word,

    output logic sync_out,
    output logic [FILE_SIZE-1:0] addres,
    output logic [5:0] width
);

    logic [25:0] counter;
    logic width_nxt;

    logic [FILE_SIZE-1:0] addres_nxt;


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sync_out <= '0;
            width <= '0;
            counter <= '0;
            addres <= '0;
        end else begin
            sync_out <= sync_in;
            width <= width_nxt
            counter <= counter_nxt;
            addres <= addres_nxt;
        end
    end

    always_comb begin
        if (sync_in) begin
            if (counter == 0) begin
                counter_nxt = (word >> 6);      //note lenght
                width_nxt = (width && 31b'0000_0000_0000_0000_0000_0000_0001_1111);
                addres_nxt = addres + 1;
            end else begin
                counter_nxt = counter - 1;
            end
        end else begin
            width_nxt = width;
            counter_nxt = counter;
            addres_nxt = addres;
        end
    end

endmodule
