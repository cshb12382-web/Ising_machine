`timescale 1ns / 1ps

module LFSR(clk,rst,seed,out,random);  //피보나치

input clk,rst;
input [19:0] seed;
output reg [19:0] out;
output reg [6:0] random;

reg [19:0] outt;
wire xxo;

assign xxo = outt[0]^outt[1]^outt[4]^outt[6];

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    outt <= seed; out <=0;
end
else begin
    outt <= {xxo,outt[19:1]};
    random <= outt[19:13];
    out <= outt;  //이전의 LSB를 받아옴.
end
end

endmodule
