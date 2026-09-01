`timescale 1ns / 1ps

module annealing(clk,rst,one_cycle_done,cycle,beta_addr,finish,restart);

input clk,rst,one_cycle_done;
input [5:0] cycle;
output reg [5:0] beta_addr;
output reg finish;
output reg restart;
reg [5:0] dwell_cnt;

always @ (posedge clk or negedge rst) begin
if(!rst)begin
    finish <= 1'b0;
    dwell_cnt <= 6'b0;
    beta_addr <= 6'b0;
    restart <= 1'b0;
end    
else begin
    finish <= 1'b0;
    restart <= 1'b0;
    if(one_cycle_done)begin
        restart <= 1'b1;
        dwell_cnt <= dwell_cnt+1'b1;
        if(dwell_cnt == 6'd39)begin
            dwell_cnt <= 6'b0;
            beta_addr <= beta_addr + 1'b1;
        end    
    end
    if(beta_addr == cycle)begin
        finish <= 1'b1;
        beta_addr <= 6'b0;
   end        
end
end
endmodule
