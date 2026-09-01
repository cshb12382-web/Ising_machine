`timescale 1ns / 1ps

module LFSR2(clk,rst,en,seed,out);  //갈루아

input clk,rst,en;
input [19:0] seed;
output reg out;

reg [19:0] outt;
wire xxo2,xxo3,xxo4;

assign xxo2 = outt[0]^outt[19];
assign xxo3 = outt[0]^outt[16];
assign xxo4 = outt[0]^outt[14];

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    outt <= seed; out <=0;
end
else begin
    outt <= {outt[0],xxo2,outt[18:17],xxo3,outt[15],xxo4,outt[13:1]};
    if(en)
        out <= outt[0];  //이전의 LSB를 받아옴.
    else
        out <= out;
end
end

endmodule