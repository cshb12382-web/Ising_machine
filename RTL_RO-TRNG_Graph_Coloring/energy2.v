`timescale 1ns / 1ps

module energy2(clk,rst,color_idx,space,start,flip_done,direction0,direction1,direction2,one_cycle_done,restart,done,h_value0,h_value1,h_value2,
addr,new_space,space_en,target0_ff, target1_ff, target2_ff,original_node0,original_node1,original_node2);
input clk,rst;
input [3:0] color_idx;
input [19:0] space;
input start;
input flip_done;
input [1:0] direction0;
input [1:0] direction1;
input [1:0] direction2;
input one_cycle_done;
input restart;
output reg done;
output signed [15:0] h_value0;
output signed [15:0] h_value1;
output signed [15:0] h_value2;
output reg [4:0] addr;
output reg [19:0] new_space;
input space_en;
reg [4:0] target0, target1, target2;
reg [2:0] valid_lane;

output reg [4:0] target0_ff, target1_ff, target2_ff;
output reg original_node0;
output reg original_node1;
output reg original_node2;
reg [2:0] valid_lane_ff;
reg [1:0] direction0_ff; // 필요시 사용
reg [1:0] direction1_ff;
reg [1:0] direction2_ff;

reg signed [15:0] h_reg [0:19];
wire signed [159:0] dout;
wire signed [159:0] dout0;
wire signed [159:0] dout1;
wire signed [159:0] dout2;

reg [3:0] state;
parameter init = 1, cal=2, flip=3, waiting =4, read =5, pre_req=6, pre_cal =7, waiting2=8, waiting3 = 9, waiting4= 10;
integer i,k;
/*
blk_mem_gen_3 weight2_mem(
    .clka(clk),
    .addra(addr),
    .douta(dout),
    .clkb(clk),
    .addrb(9'b0),
    .doutb()
  );
*/

reg [3:0] col_addr;
wire [19:0] col_dout;

blk_mem_gen_4 color_mem(
    .clka(clk),
    .addra(col_addr),
    .douta(col_dout),
    .clkb(clk),
    .addrb(9'b0),
    .doutb()
  );
  
reg signed [15:0] init_sum;
reg signed [15:0] p_sum [0:3];
reg signed [8:0] delta0;
reg signed [8:0] delta1;
reg signed [8:0] delta2;

/*always @(*) begin
    init_sum = 16'sd0;
    for(k=0; k<20; k=k+1)begin
        if(new_space[k] == 1'b1)
            init_sum = init_sum + $signed(dout[(19-k)*8+:8]);
        else
            init_sum = init_sum - $signed(dout[(19-k)*8+:8]);
    end
end
*/
// FSM과 독립적으로 매 클럭 도는 2-Stage 파이프라인 가산기

reg [4:0] addr_d1;
reg [4:0] addr_d2;
reg signed [159:0] dout0_ff;
reg signed [159:0] dout1_ff;
reg signed [159:0] dout2_ff;


reg [159:0] weight2 [0:19];
initial begin
    $readmemh("weight2.mem",weight2);
end

assign dout = weight2[addr];
assign dout0 = weight2[target0_ff];
assign dout1 = weight2[target1_ff];
assign dout2 = weight2[target2_ff];

assign        h_value0 = h_reg[target0_ff];
assign        h_value1 = h_reg[target1_ff];
assign        h_value2 = h_reg[target2_ff];

always @ (*) begin
    target0=5'b0; target1=5'b0; target2=5'b0;
    valid_lane = 3'b0;
        for(i=0; i<20; i= i+1)begin
            if(col_dout[i]==1'b1)begin
                if(valid_lane==3'b0)begin
                    target0 = i;
                    valid_lane = 3'b001;
                end
                else if(valid_lane==3'b001)begin
                    target1 = i;
                    valid_lane = 3'b010;
                end
                else if(valid_lane==3'b010)begin
                    target2 = i;
                    valid_lane = 3'b011;
                end
            end
        end 
end

always @ (posedge clk or negedge rst)begin
if(!rst)begin
  //  h_reg[0] <= 16'd58; h_reg[1] <= 16'd60; h_reg[2] <= 16'd69; h_reg[3] <= 16'd61; h_reg[4] <= 16'd49; h_reg[5] <= 16'd91; h_reg[6] <= 16'd70; h_reg[7] <= 16'd82;
   // h_reg[8] <= 16'd61; h_reg[9] <= 16'd70; h_reg[10] <= 16'd71; h_reg[11] <= 16'd61; h_reg[12] <= 16'd30; h_reg[13] <= 16'd55; h_reg[14] <= 16'd62; h_reg[15] <= 16'd88;
   // h_reg[16] <= 16'd94; h_reg[17] <= 16'd90; h_reg[18] <= 16'd74; h_reg[19] <= 16'd70;
    addr <= 5'b0;
    state <= init;
    done <= 1'b0;
    new_space <= space;
    addr_d1 <=5'd0;
    addr_d2 <= 5'd0;
    col_addr <= 4'b0;
end
else begin
    p_sum[0] <= (new_space[0] ? +$signed(dout[159:152]) : -$signed(dout[159:152])) +
                (new_space[1] ? +$signed(dout[151:144]) : -$signed(dout[151:144])) +
                (new_space[2] ? +$signed(dout[143:136]) : -$signed(dout[143:136])) +
                (new_space[3] ? +$signed(dout[135:128]) : -$signed(dout[135:128])) +
                (new_space[4] ? +$signed(dout[127:120]) : -$signed(dout[127:120]));

    p_sum[1] <= (new_space[5] ? +$signed(dout[119:112]) : -$signed(dout[119:112])) +
                (new_space[6] ? +$signed(dout[111:104]) : -$signed(dout[111:104])) +
                (new_space[7] ? +$signed(dout[103:96])  : -$signed(dout[103:96])) +
                (new_space[8] ? +$signed(dout[95:88])   : -$signed(dout[95:88])) +
                (new_space[9] ? +$signed(dout[87:80])   : -$signed(dout[87:80]));

    p_sum[2] <= (new_space[10]? +$signed(dout[79:72])   : -$signed(dout[79:72])) +
                (new_space[11]? +$signed(dout[71:64])   : -$signed(dout[71:64])) +
                (new_space[12]? +$signed(dout[63:56])   : -$signed(dout[63:56])) +
                (new_space[13]? +$signed(dout[55:48])   : -$signed(dout[55:48])) +
                (new_space[14]? +$signed(dout[47:40])   : -$signed(dout[47:40]));

    p_sum[3] <= (new_space[15]? +$signed(dout[39:32])   : -$signed(dout[39:32])) +
                (new_space[16]? +$signed(dout[31:24])   : -$signed(dout[31:24])) +
                (new_space[17]? +$signed(dout[23:16])   : -$signed(dout[23:16])) +
                (new_space[18]? +$signed(dout[15:8])    : -$signed(dout[15:8])) +
                (new_space[19]? +$signed(dout[7:0])     : -$signed(dout[7:0]));

    init_sum <= p_sum[0] + p_sum[1] + p_sum[2] + p_sum[3];
    done <= 1'b0;
    case(state)
    init : begin
        if(start==1)begin
            state <= pre_cal;
        end
        else
            state <= state;
    end
    pre_req : begin
        state <= waiting2;
    end
    waiting2 : begin
        state <= waiting3;
    end
    waiting3 : begin
        state <= pre_cal;
    end
    pre_cal : begin

        h_reg[addr] <= init_sum;
        if(addr == 5'd19)begin
            state <= cal;
        end
        else begin
            addr <= addr + 1'b1;
            state <= pre_req;
        end
    end
    
    
    cal : begin
    col_addr <= color_idx;
    state <= read;
    end
    
    
    read : begin
        done <= 1'b1;
        state <= waiting4;
        target0_ff <= target0;
        target1_ff <= target1;
        target2_ff <= target2;
        valid_lane_ff <= valid_lane;
    end
    
    waiting4 : begin
        dout0_ff <= dout0;
        dout1_ff <= dout1;
        dout2_ff <= dout2;
        original_node0 <= new_space[target0_ff];
        original_node1 <= new_space[target1_ff];
        original_node2 <= new_space[target2_ff];
        state <= flip;
    end
    flip : begin
       if(flip_done==1'b1)begin
            for(i=0;i<20;i=i+1)begin
                delta0 = 9'sd0; delta1 = 9'sd0; delta2 = 9'sd0; //중간계산용 변수라서 (=) 사용 가능 임시변수는 예외. 만약 이 임시값을 다른 모듈이나 블록에서 읽는다면 이렇게 쓰면X
                
                if(valid_lane_ff>=3'd1)begin
                    if(direction0==2'b01) //0에서 1로 뒤집힐 때
                        delta0 = + ($signed(dout0_ff[(19-i)*8+:8])<<<1); //해당 노드의 가중치를 모든 노드 계산에서 변화시킴.
                    else if(direction0 == 2'b10) //1에서 0으로 뒤집힐 때
                        delta0 = - ($signed(dout0_ff[(19-i)*8+:8])<<<1);
                end
                if(valid_lane_ff>=3'd2)begin 
                    if(direction1==2'b01) //0에서 1로 뒤집힐 때
                        delta1 = + ($signed(dout1_ff[(19-i)*8+:8])<<<1); // <<<1 = 16'sd2와 같아
                    else if(direction1 == 2'b10) //1에서 0으로 뒤집힐 때
                        delta1 = - ($signed(dout1_ff[(19-i)*8+:8])<<<1);
                end
                if(valid_lane_ff>=3'd3)begin
                    if(direction2==2'b01) //0에서 1로 뒤집힐 때1
                        delta2 = + ($signed(dout2_ff[(19-i)*8+:8])<<<1);
                    else if(direction2 == 2'b10) //1에서 0으로 뒤집힐 때
                        delta2 = - ($signed(dout2_ff[(19-i)*8+:8])<<<1);
                end
                h_reg[i] <= (h_reg[i] + delta0) + (delta1 + delta2);
            end
            
            if(valid_lane_ff>=3'd1)begin
                if(direction0==2'b01)
                    new_space[target0_ff] <= 1'b1;
                else if(direction0 == 2'b10)
                    new_space[target0_ff] <= 1'b0;
            end
            if(valid_lane_ff>=3'd2)begin   
                if(direction1==2'b01)
                    new_space[target1_ff] <= 1'b1;
                else if(direction1 == 2'b10)
                    new_space[target1_ff] <= 1'b0;
            end
            if(valid_lane_ff>=3'd3)begin
                if(direction2==2'b01)
                    new_space[target2_ff] <= 1'b1;
                else if(direction2 == 2'b10)
                    new_space[target2_ff] <= 1'b0;
            end     
                
                
            if(color_idx == 4'd9)
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
