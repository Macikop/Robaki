/*
 * Designed by MP
 * 
 * Description:
 * Interface for ram mux
 */

interface ram_mux_if #(
    parameter int WORD_WIDTH    = 1,
    parameter int ADDRESS_WIDTH = 20
) ();

    logic [WORD_WIDTH-1:0]    value;
    logic                     granted;
    logic [ADDRESS_WIDTH-1:0] addresses;
    logic                     request;

    modport in (
        input  addresses,
        input  request,
        output value,
        output granted
    );

    modport out (
        output addresses,
        output request,
        input  value,
        input  granted
    );

endinterface