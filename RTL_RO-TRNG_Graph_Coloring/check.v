`timescale 1ns / 1ps

module check(clk,rst,change,res,original_node,space_en,flip_done,color_idx,direction,one_cycle_done);

input clk,rst,change,res;
input original_node;
input space_en;
output flip_done;
output reg [3:0] color_idx;
output [1:0] direction;
output reg one_cycle_done;

reg change_done;

assign flip_done = change;

assign direction = (original_node == res)?2'b00:
                    (original_node > res)? 2'b10:
                    (original_node < res)? 2'b01:2'b11;

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    color_idx <= 4'b0;
    one_cycle_done <= 1'b0;
    change_done <= 1'b0;
end
else begin
    one_cycle_done <= 1'b0;
if(flip_done==1'b1)begin
    if(color_idx == 4'd9)begin
        color_idx <= 4'd0;
        one_cycle_done <= 1'b1;
    end
    else begin
        color_idx <= color_idx + 1'b1;
    end
end
end
end
endmodule
