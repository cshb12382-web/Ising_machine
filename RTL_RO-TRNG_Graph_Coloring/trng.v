`timescale 1ns / 1ps
(*ALLOW_COMBINATIONAL_LOOPS = "TRUE", KEEP = "TRUE" *)
module trng(clk,rst,ro_out);
input clk,rst;
output ro_out;

wire [6:0] node;

assign #1 node[0] = ~node[6];
assign #1 node[1] = ~node[0];
assign #1 node[2] = ~node[1];
assign #1 node[3] = ~node[2];
assign #1 node[4] = ~node[3];
assign #1 node[5] = ~node[4];
assign #1 node[6] = ~node[5];

assign ro_out = node[0];

initial begin
force node[0] = 1'b0;
#10
release node[0];
end

endmodule
