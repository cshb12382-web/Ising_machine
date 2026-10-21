module uart_transmitter #(
    parameter CLOCK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);

    wire symbol_edge;
    wire start;
    wire tx_running;

    reg [9:0] tx_shift;
    reg [3:0] bit_counter;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;

    assign symbol_edge = clock_counter == (SYMBOL_EDGE_TIME - 1);
    assign start = data_in_valid & !tx_running;
    assign tx_running = bit_counter != 4'd0;
    assign data_in_ready = !tx_running;
    assign serial_out = tx_running ? tx_shift[0] : 1'b1;

    always @ (posedge clk) begin
        clock_counter <= (start || reset || symbol_edge) ? 0 : clock_counter + 1;
    end

    always @ (posedge clk) begin
        if (reset) begin
            bit_counter <= 0;
        end else if (start) begin
            bit_counter <= 10;
        end else if (symbol_edge && tx_running) begin
            bit_counter <= bit_counter - 1;
        end
    end

    always @ (posedge clk) begin
        if (reset) begin
            tx_shift <= 0;
        end else if (start) begin
            tx_shift <= {1'b1,data_in, 1'b0}; //??¨ö? lsb¨¬??? ¨ö???
        end else if (symbol_edge && tx_running) begin
            tx_shift <= {tx_shift[0],tx_shift[9:1]};
        end
    end

endmodule