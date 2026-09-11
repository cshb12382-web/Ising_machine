`timescale 1ns / 1ps
(*ALLOW_COMBINATIONAL_LOOPS = "TRUE", KEEP = "TRUE" *)
module trng_3chain3(clk,rst,ro_out);
input clk,rst;
output reg ro_out;

wire [6:0] node;

assign #0.7 node[0] = ~node[2];
assign #0.7 node[1] = ~node[0];
assign #0.7 node[2] = ~node[1];


always @ (posedge clk or negedge rst)begin
if(!rst)
    ro_out <= 1'b0;
else begin
    ro_out = node[0];
end
end
initial begin
force node[0] = 1'b0;
#10
release node[0];
end

endmodule