`timescale 1ns / 1ps


module maxcut(clk,rst,finish,new_space,maxcut);

input clk,rst;
input finish;
input [19:0] new_space;
output reg signed [8:0] maxcut;

reg [8:0] addr;
wire signed [7:0] dout;
reg [4:0] i;
reg [4:0] j;
reg [2:0] max_state;
parameter idle = 0, max1 = 1, wait_mem = 2, max2 = 3, done =4;

blk_mem_gen_1 weight_mem(
    .clka(clk),
    .addra(9'b0),
    .douta(),
    .clkb(clk),
    .addrb(addr),
    .doutb(dout)
  );
  

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    maxcut <= 9'b0;
    max_state <= idle;
    i <= 5'b0;
    j <= 5'b0;
    addr <= 9'b0;
end
else begin
    case(max_state)
    idle : begin
        if(finish==1'b1)begin
            max_state <= max1;
        end
    end
    max1 : begin
        if(new_space[i] != new_space[j])begin
            addr <= 20*i+j;
            max_state <= wait_mem;
        end
        else begin
            if (j== 5'd19)begin
                if(i == 5'd18)begin
                    max_state <= done;
                end
                else begin
                    i <= i + 1'b1;
                    j <= i + 2;
                    max_state <= max1;
                end
            end
            else begin
                max_state <= max1;
                j<= j+1'b1;
            end
        end
    end
    wait_mem : begin
        max_state <= max2;
    end
    max2 : begin
        maxcut <= maxcut - dout;
        if (j== 5'd19)begin
                if(i == 5'd18)begin
                    max_state <= done;
                end
                else begin
                    i <= i + 1'b1;
                    j <= i + 2;
                    max_state <= max1;
                end
        end
        else begin
                max_state <= max1;
                j<= j+1'b1;
        end
    end
    done : begin
        i <= 5'b0;
        j <= 5'b0;
        addr <= 9'b0; 
    end
    default : max_state <= max_state;
    endcase
end
end
endmodule
