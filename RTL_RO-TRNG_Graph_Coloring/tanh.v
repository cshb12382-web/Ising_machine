`timescale 1ns / 1ps

module tanh(clk,rst,really_i,probability); //더 정밀히 하고 싶다면 범위를 더 늘리기(c에서 tanh안의 /128 더 크게 나누기 => really_i범위도 늘어남)
// *128은 lfsr과 맞춰주기 위해서 그냥 스케일링 시킨 것.

input clk,rst;
input signed [14:0] really_i; // 128이 곱해진 값임.소수점 취급.
output reg [6:0] probability;  //tanh가 바뀌고 난 1clk 후에 probability바뀜. 향후 타이밍 조정 필요할수도

wire [15:0] addr_i;
wire [6:0] tanh;
reg signed [14:0] really_id;
assign addr_i = really_i+16'sd354; //주소로 매핑해주기 위해서.. 중간값은 0번째 64

blk_mem_gen_2 tanh_mem(
    .clka(clk),
    .addra(addr_i),
    .douta(tanh),
    .clkb(clk),
    .addrb(),
    .doutb()
);

always @ (posedge clk or negedge rst)begin
if(!rst)begin
    probability <= 7'b0;
    really_id <= 15'b0;
end
else begin
    really_id <= really_i;
    if(really_id < -15'sd354)
        probability <= 7'b0;       
    else if(really_id > 15'sd354)
        probability <= 7'd127;
    else
        probability <= tanh;
end
end
endmodule
