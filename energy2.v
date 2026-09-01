`timescale 1ns / 1ps

module energy2(clk,rst,target,space,start,flip_done,direction,one_cycle_done,restart,done,h_value,addr,new_space,space_en);
input clk,rst;
input [4:0] target;
input [19:0] space;
input start;
input flip_done;
input [1:0] direction;
input one_cycle_done;
input restart;
output reg done;
output reg signed [15:0] h_value;
output reg [4:0] addr;
output reg [19:0] new_space;
input space_en;

reg signed [15:0] h_reg [0:19];
wire [159:0] dout;

reg [2:0] state;
parameter init = 1, cal=2, flip=3, waiting =4, read =5;
integer i;

blk_mem_gen_3 weight2_mem(
    .clka(clk),
    .addra(addr),
    .douta(dout),
    .clkb(clk),
    .addrb(9'b0),
    .doutb()
  );

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    h_reg[0] <= 16'd58; h_reg[1] <= 16'd60; h_reg[2] <= 16'd69; h_reg[3] <= 16'd61; h_reg[4] <= 16'd49; h_reg[5] <= 16'd91; h_reg[6] <= 16'd70; h_reg[7] <= 16'd82;
    h_reg[8] <= 16'd61; h_reg[9] <= 16'd70; h_reg[10] <= 16'd71; h_reg[11] <= 16'd61; h_reg[12] <= 16'd30; h_reg[13] <= 16'd55; h_reg[14] <= 16'd62; h_reg[15] <= 16'd88;
    h_reg[16] <= 16'd94; h_reg[17] <= 16'd90; h_reg[18] <= 16'd74; h_reg[19] <= 16'd70;
    addr <= 5'b0;
    state <= init;
    done <= 1'b0;
end
else begin
    done <= 1'b0;
    case(state)
    init : begin
        if(start==1)begin
            state <= cal;
            new_space <= space;
        end
        else
            state <= state;
    end
    cal : begin
    
    addr <= target;
    state <= read;

    end
    read : begin
        h_value <= h_reg[target];  //top에서 change신호 오면  if new space[target] == res 검사 후 flip done조정, target+1
        done <= 1'b1;
        state <= flip;
    end
    flip : begin
       if(flip_done==1'b1)begin
            for(i=0;i<20;i=i+1)begin
                if(direction==2'b01) //0에서 1로 뒤집힐 때
                    h_reg[i] <= h_reg[i] + ($signed(dout[(19-i)*8+:8])*2); //해당 노드의 가중치를 모든 노드 계산에서 변화시킴.
                else if(direction == 2'b10) //1에서 0으로 뒤집힐 때
                    h_reg[i] <= h_reg[i] - ($signed(dout[(19-i)*8+:8])*2);
            end
            if(direction==2'b01)
                new_space[target] <= 1'b1;
            else if(direction == 2'b10)
                new_space[target] <= 1'b0;
            if(target == 5'd19)
                state <= waiting;
            else begin
                state <= cal;
            end
       end
       else begin
            state<=flip;
       end
    end
    waiting : begin
        if(restart == 1'b1)begin
            state <= cal;
        end
    end
    default : begin end
    endcase
end
end
endmodule
