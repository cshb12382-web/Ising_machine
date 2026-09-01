`timescale 1ns / 1ps

module check(clk,rst,change,res,new_space,space_en,flip_done,target,direction,one_cycle_done);

input clk,rst,change,res;
input [19:0] new_space;
input space_en;
output flip_done;
output reg [4:0] target;
output [1:0] direction;
output reg one_cycle_done;

reg change_done;

assign flip_done = change;

assign direction = (new_space[target] == res)?2'b00:
                    (new_space[target] > res)? 2'b10:
                    (new_space[target] < res)? 2'b01:2'b11;

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    target <= 5'b0;
    one_cycle_done <= 1'b0;
    change_done <= 1'b0;
end
else begin
    one_cycle_done <= 1'b0;
if(flip_done==1'b1)begin
    if(target == 5'd19)begin
        target <= 5'd0;
        one_cycle_done <= 1'b1;
    end
    else begin
        target <= target + 1'b1;
    end
end
end
end
endmodule
