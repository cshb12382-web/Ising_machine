`timescale 1ns / 1ps
(*ALLOW_COMBINATIONAL_LOOPS = "TRUE", KEEP = "TRUE" *)
module trng_11chain2(clk,rst,ro_out);
input clk,rst;
output reg ro_out;

wire [10:0] node;

assign #0.3 node[0] = ~node[10];
assign #0.3 node[1] = ~node[0];
assign #0.3 node[2] = ~node[1];
assign #0.3 node[3] = ~node[2];
assign #0.3 node[4] = ~node[3];
assign #0.3 node[5] = ~node[4];
assign #0.3 node[6] = ~node[5];
assign #0.3 node[7] = ~node[6];
assign #0.3 node[8] = ~node[7];
assign #0.3 node[9] = ~node[8];
assign #0.3 node[10] = ~node[9];

always @ (posedge clk or negedge rst)begin
if(!rst)
    ro_out <= 1'b0;
else begin
    ro_out = node[0];
end
end
initial begin
force node[0] = 1'b0;
#20
release node[0];
end

endmodule