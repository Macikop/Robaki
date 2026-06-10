/*
 * Designed by MP
 * 
 * Description:
 * Interface for ram mux
 */

interface memory_if;

    logic [19:0] addresses;
    logic        request;
    logic        granted;
    logic        value;

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