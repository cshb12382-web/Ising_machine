`timescale 1ns / 1ps

module fpga(clk,rst,rx,led,tx);
input clk,rst,rx;
output reg [3:0] led;
output tx;

parameter idle = 3'b000, send = 3'b001, send2 = 3'b010, send3 = 3'b011, last = 3'b100;

    wire [19:0] new_space;
    wire [8:0] maxcut;
    wire real_done;
top top0(.clk(clk),.rst(rst),.cycle(),.real_done(real_done),.new_space(new_space),.maxcut(maxcut));
    
    wire w_ready;
    reg w_valid;
    reg [7:0] w_dout;
    reg [2:0] state;
    reg [28:0] tx_buffer;


always @(posedge clk or negedge rst) begin
        if(!rst) begin
            state <= idle;
            led<=4'b1111;
            w_valid <= 1'b0;
        end 
        else begin
        case(state)
            idle : begin
                if(real_done == 1)begin
                    led <= 4'b0101;
                    tx_buffer <= {new_space, maxcut};
                    w_dout <= {3'b000, new_space[19:15]};
                    w_valid <= 1'b1;
                    state <= send;
                end
                else
                    w_valid <= 1'b0;
            end
            send : begin
                if(w_ready == 1'b1)begin
                    w_dout <= tx_buffer[23:16];
                    state <= send2;
                end
            end
            send2 : begin
                if(w_ready == 1'b1)begin
                    w_dout <= tx_buffer[15:8];
                    state <= send3;
                end
            end
            send3 : begin
                if(w_ready == 1'b1)begin
                    w_dout <= tx_buffer[7:0];
                    state <= last;
                end
            end
            last : begin
                if(w_ready==1'b1)begin
                    w_valid <= 0;
                    state <= last;
                end
            end
            default : state <= idle;
            endcase
        end
    end            



    uart_wrap wrap0(
    .clk(clk),
    .reset(!rst),
    .DataIn(w_dout),
    .DataIn_valid(w_valid),
    .DataIn_ready(w_ready),
    .DataOut(),
    .DataOut_valid(),
    .DataOut_ready(1'b1),
    .uart_rx(rx),
    .uart_tx(tx) 
);


endmodule
