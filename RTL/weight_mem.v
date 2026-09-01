`timescale 1ns / 1ps

module weight_mem(clk,rst,addr,dout);
input clk, rst;
input [8:0] addr;
output reg [4:0] dout;


reg signed [4:0] weight_memory [0:399];
initial begin
    $readmemh("weight_memory",weight_memory);
end

always @ (posedge clk or negedge rst)begin
if(!rst)
    dout <= 5'b00000;
else
    dout <= weight_memory[addr];
end
endmodule
