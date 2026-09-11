`timescale 1ns / 1ps
//미리 확률을 계산해 bram에 넣기, energy로 부터 확률 받아오고 lfsr과 비교

module compa(clk,rst,probability,random,space_en,res,change);

input clk,rst;
input [6:0] probability, random;
input space_en;
output reg res;
output reg change;

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    res <= 1'b0;
    change <=1'b0;
end
else begin
if(space_en==1'b1)begin //really_i가 유효해진 시점
    change <=1'b1;
    if(probability > random)
        res <= 1'b1;
    else if(probability < random)
        res <= 1'b0;
    else
        res <= res;
end
else begin
change <= 1'b0;
end
end
end
endmodule
