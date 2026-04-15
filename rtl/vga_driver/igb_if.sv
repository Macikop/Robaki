/* Internal Graphics Bus
 * Designed by MP
 */

interface igb_if ();
    logic [10:0] vcount;
    logic [10:0] hcount;
    logic [11:0] rgb;
    logic        frame_sending


    modport in (
        input vcount,
        input hcount,
        input rgb,
        input frame_sending
    );

    modport out (
        output vcount,
        output hcount,
        output rgb,
        output frame_sending
    );

endinterface