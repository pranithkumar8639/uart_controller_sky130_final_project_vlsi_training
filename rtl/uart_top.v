module uart_top #(
    parameter CLKS_PER_BIT = 5208
)(
    input        clk,
    input        reset,

    // Transmitter interface
    input        tx_start,
    input  [7:0] tx_data,

    output       tx,
    output       tx_busy,
    output       tx_done,

    // Receiver interface
    input        rx,

    output [7:0] rx_data,
    output       rx_valid
);

    // ------------------------------------------------
    // UART TRANSMITTER
    // ------------------------------------------------

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (
        .clk      (clk),
        .reset    (reset),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done)
    );


    // ------------------------------------------------
    // UART RECEIVER
    // ------------------------------------------------

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk      (clk),
        .reset    (reset),
        .rx       (rx),
        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

endmodule
