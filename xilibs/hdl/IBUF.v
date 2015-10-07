
module IBUF (O, I);

    parameter CAPACITANCE = "DONT_CARE";
    parameter IBUF_DELAY_VALUE = "0";
    parameter IBUF_LOW_PWR = "TRUE";
    parameter IFD_DELAY_VALUE = "AUTO";
    parameter IOSTANDARD = "DEFAULT";

`ifdef XIL_TIMING

    parameter LOC = " UNPLACED";

`endif

    
    output O;
    input  I;

    buf B1 (O, I);
    
endmodule

