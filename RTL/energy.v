`timescale 1ns / 1ps
//mac연산해야지
module energy(clk,rst,target,weight,space,start,change,res,done,h_value,addr,change_node,one_cycle_done,new_space);
input clk,rst;
input signed [7:0] weight;
input [19:0] space;
input start;
input change;
input res;
output reg done;
output reg signed [11:0] h_value;  //9,10비트로 줄일 수 있음
output reg [4:0] target;
output reg [8:0] addr;
output reg [4:0] change_node;
output reg one_cycle_done;
output reg [19:0] new_space;

parameter cal = 0, plus = 1, condi = 2, idle = 3, init = 4;
reg [2:0] state;
reg [4:0]cnt;
reg signed [11:0] store;


always @ (posedge clk or negedge rst)begin
if(!rst)begin
    h_value <= 12'b0;
    target <= 5'b0;
    store <= 12'b0;
    cnt <= 5'b0;
    done <= 1'b0;
    addr <= 9'b0;
    state <= init;
    change_node <= 5'b0;
    new_space <= 20'b0;
    one_cycle_done <= 1'b0;
end
else begin
if (!start) begin
        state <= init;
        cnt <= 0;
        target <= 0;
        store <= 0;
        done <= 0;
        addr <= 0;
        one_cycle_done <= 0;
end
else begin 
    case(state)
    init : begin
        if(start==1)begin
            state <= plus;
            new_space <= space;
        end
        else
            state <= state;
    end
    idle : begin
        done <= 1'b0;
            if(change==1'b1)begin
                state<=plus;
                new_space[change_node] <= res;
                change_node <= change_node+1'b1;
                if(change_node == 5'd19)begin
                    change_node <= 5'b0;
                    one_cycle_done <= 1'b1;
                end 
            end
    end
    plus : begin
        state <= cal;
        if(addr == 399)begin
            addr <= 9'b0;
        end
        else begin
            addr <= addr + 1'b1;
        end
    end
    cal : begin
        if(new_space[target] == 1'b1)begin
            store <= store + weight;
        end
        else begin
            store <= store - weight;   //0이 -1역할 수행
        end
        one_cycle_done <= 1'b0;
        if(cnt < 5'd19)begin
            if(addr == 399)begin
                addr <= 9'b0;
            end
            else begin
                addr <= addr + 1'b1;
            end
        end
        if(cnt == 5'd19)
            state <= condi;
        else begin
            state <= cal;
            cnt <= cnt +1'b1;
            target <= target + 1'b1;
        end
        end  

    condi : begin
        h_value <= store;   //새로운 h밸류가 들어올 때까지 처리가 가능한가? 고민 좀.
        cnt <= 5'b0;
        target <= 5'b0;
        store <= 12'b0;
        state <= idle;
        done <= 1'b1;
    end
    default : state <= state;
    endcase
end
end
end
endmodule
