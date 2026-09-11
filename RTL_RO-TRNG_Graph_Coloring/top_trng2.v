`timescale 1ns / 1ps

module top_trng2(clk,rst,real_ro_out);

input clk,rst;
output reg real_ro_out;

wire a,b,c,d;
trng2 trng20(.clk(clk),.rst(rst),.ro_out(a));
trng3 trng30(.clk(clk),.rst(rst),.ro_out(b));
trng4 trng40(.clk(clk),.rst(rst),.ro_out(c));

assign d = a^b^c;

always @ (posedge clk or negedge rst)begin
if(!rst)
    real_ro_out <= 1'b0;
else begin
    real_ro_out <= d;
end
end
endmodule
