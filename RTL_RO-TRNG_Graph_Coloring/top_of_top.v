`timescale 1ns / 1ps

module top_of_top(clk,rst,out);

input clk,rst;
output [6:0] out;
top_trng_9chain top_trng_9chain0(.clk(clk),.rst(rst),.real_ro_out(out[6]));
top_trng_13chain top_trng_13chain0(.clk(clk),.rst(rst),.real_ro_out(out[5]));
top_trng_11chain top_trng_11chain0(.clk(clk),.rst(rst),.real_ro_out(out[4]));
top_trng_15chain top_trng_15chain0(.clk(clk),.rst(rst),.real_ro_out(out[3]));
top_trng2 top_trng60(.clk(clk),.rst(rst),.real_ro_out(out[2])); //7chain
top_trng_5chain top_trng_5chain0(.clk(clk),.rst(rst),.real_ro_out(out[1]));
top_trng_3chain top_trng_3chain0(.clk(clk),.rst(rst),.real_ro_out(out[0]));

endmodule
