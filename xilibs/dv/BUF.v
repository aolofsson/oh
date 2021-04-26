
module BUF (O, I);


`ifdef XIL_TIMING

    parameter LOC = "UNPLACED";

`endif

    output O;
    input I;
    
    buf B1 (O, I);

endmodule

