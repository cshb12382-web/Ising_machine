module uart_wrap (
    input clk,
    input reset,

    // for UART TX
    input [7:0] DataIn,
    input DataIn_valid,
    output DataIn_ready,

    // for UART RX
    output [7:0] DataOut,
    output DataOut_valid,
    input  DataOut_ready,

    input uart_rx,
    output uart_tx 
);

    parameter CLOCK_FREQ = 100_000_000;
    parameter BAUD_RATE = 115_200;

    wire [7:0] data_in;
    wire data_in_valid;
    wire  data_in_ready;

    wire  [7:0] data_out;
    wire  data_out_valid;
    wire  data_out_ready;

    uart #(
        .CLOCK_FREQ (CLOCK_FREQ),
        .BAUD_RATE  (BAUD_RATE)
    ) u_uart (
        .clk              (clk) ,
        .reset            (reset) ,
    
        .data_in          (data_in),
        .data_in_valid    (data_in_valid),
        .data_in_ready    (data_in_ready),
    
        .data_out         (data_out),
        .data_out_valid   (data_out_valid),
        .data_out_ready   (data_out_ready),
    
        .serial_in        (uart_rx),
        .serial_out       (uart_tx)
    );

    assign DataOut = data_out;
    assign DataOut_valid = data_out_valid;
    assign data_out_ready = DataOut_ready;

    assign DataIn_ready  = data_in_ready;
    assign data_in = DataIn[7:0];
    assign data_in_valid = DataIn_valid;

endmodule