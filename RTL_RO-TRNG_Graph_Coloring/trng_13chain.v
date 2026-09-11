`timescale 1ns / 1ps
(*ALLOW_COMBINATIONAL_LOOPS = "TRUE", KEEP = "TRUE" *)
module trng_13chain(clk,rst,ro_out);
input clk,rst;
output reg ro_out;

wire [12:0] node;

assign #1 node[0] = ~node[12];
assign #1 node[1] = ~node[0];
assign #1 node[2] = ~node[1];
assign #1 node[3] = ~node[2];
assign #1 node[4] = ~node[3];
assign #1 node[5] = ~node[4];
assign #1 node[6] = ~node[5];
assign #1 node[7] = ~node[6];
assign #1 node[8] = ~node[7];
assign #1 node[9] = ~node[8];
assign #1 node[10] = ~node[9];
assign #1 node[11] = ~node[10];
assign #1 node[12] = ~node[11];

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