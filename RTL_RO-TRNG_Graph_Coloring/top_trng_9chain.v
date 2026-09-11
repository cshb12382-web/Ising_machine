`timescale 1ns / 1ps

module top_trng_9chain(clk,rst,real_ro_out);

input clk,rst;
output reg real_ro_out;

wire a,b,c,d;
trng_9chain trng_9chain0(.clk(clk),.rst(rst),.ro_out(a));
trng_9chain2 trng_9chain1(.clk(clk),.rst(rst),.ro_out(b));
trng_9chain3 trng_9chain2(.clk(clk),.rst(rst),.ro_out(c));

assign d = a^b^c;

always @ (posedge clk or negedge rst)begin
if(!rst)
    real_ro_out <= 1'b0;
else begin
    real_ro_out <= d;
end
end
endmodule
