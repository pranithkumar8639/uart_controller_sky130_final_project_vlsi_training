module uart_rx #(
    parameter CLKS_PER_BIT = 5208
)(
    input        clk,
    input        reset,

    input        rx,

    output reg [7:0] rx_data,
    output reg       rx_valid
);

    // UART receiver states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;

    // Two-flip-flop synchronizer
    reg rx_sync1;
    reg rx_sync2;

    // Baud-rate counter
    reg [12:0] clk_count;
    reg full_bit_done;
    reg half_bit_done; reg full_lo, full_hi, half_lo, half_hi;

    // Data bit counter
    reg [2:0] bit_index;

    // Data register
    reg [7:0] data_reg;

    // Half-bit count for start-bit verification
    localparam HALF_BIT = CLKS_PER_BIT / 2;

    // LFSR baud counter: no carry chain
    localparam [12:0] SEED = 13'd1;
    function [12:0] lfsr_at;
        input integer n;
        integer i;
        reg [12:0] v;
        begin
            v = 13'd1;
            for (i = 0; i < n; i = i + 1)
                v = {v[11:0], v[12] ^ v[3] ^ v[2] ^ v[0]};
            lfsr_at = v;
        end
    endfunction
    localparam [12:0] FULL_TC = lfsr_at(CLKS_PER_BIT - 3);
    localparam [12:0] HALF_TC = lfsr_at(HALF_BIT - 3);

    always @(posedge clk) begin

        if (reset) begin

            state     <= IDLE;

            rx_sync1  <= 1'b1;
            rx_sync2  <= 1'b1;

            clk_count <= SEED;
            full_bit_done <= 1'b0;
            half_bit_done <= 1'b0;
            bit_index <= 3'd0;

            data_reg  <= 8'd0;
            rx_data   <= 8'd0;
            rx_valid  <= 1'b0;

        end
        else begin

            // --------------------------------
            // RX input synchronizer
            // --------------------------------
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;

            // rx_valid is a one-clock pulse
            rx_valid <= 1'b0;
            full_lo <= (clk_count[6:0] == FULL_TC[6:0]); full_hi <= (clk_count[12:7] == FULL_TC[12:7]); full_bit_done <= full_lo & full_hi;
            half_lo <= (clk_count[6:0] == HALF_TC[6:0]); half_hi <= (clk_count[12:7] == HALF_TC[12:7]); half_bit_done <= half_lo & half_hi;

            case (state)

                // --------------------------------
                // IDLE STATE
                // --------------------------------
                IDLE: begin

                    clk_count <= SEED;
                    bit_index <= 3'd0;

                    // UART line is normally HIGH.
                    // LOW indicates the start bit.
                    if (rx_sync2 == 1'b0) begin

                        state <= START;

                    end

                end


                // --------------------------------
                // START BIT
                // --------------------------------
                START: begin

                    // Wait until the middle of
                    // the start bit.
                    if (half_bit_done) begin

                        clk_count <= SEED;

                        // Verify that the start bit
                        // is still LOW.
                        if (rx_sync2 == 1'b0) begin

                            state <= DATA;

                        end
                        else begin

                            // False start
                            state <= IDLE;

                        end

                    end
                    else begin

                        clk_count <= {clk_count[11:0], clk_count[12] ^ clk_count[3] ^ clk_count[2] ^ clk_count[0]};

                    end

                end


                // --------------------------------
                // DATA BITS
                // --------------------------------
                DATA: begin

                    // Wait one complete bit period
                    // before sampling the next data bit.
                    if (full_bit_done) begin

                        clk_count <= SEED;

                        // UART transmits LSB first
                        data_reg[bit_index] <= rx_sync2;

                        if (bit_index < 3'd7) begin

                            bit_index <= bit_index + 1'b1;

                        end
                        else begin

                            bit_index <= 3'd0;
                            state <= STOP;

                        end

                    end
                    else begin

                        clk_count <= {clk_count[11:0], clk_count[12] ^ clk_count[3] ^ clk_count[2] ^ clk_count[0]};

                    end

                end


                // --------------------------------
                // STOP BIT
                // --------------------------------
                STOP: begin

                    if (full_bit_done) begin

                        clk_count <= SEED;

                        // Transfer received data
                        // to output register.
                        rx_data <= data_reg;

                        // Indicate that a complete
                        // byte has been received.
                        rx_valid <= 1'b1;

                        state <= IDLE;

                    end
                    else begin

                        clk_count <= {clk_count[11:0], clk_count[12] ^ clk_count[3] ^ clk_count[2] ^ clk_count[0]};

                    end

                end


                // --------------------------------
                // DEFAULT
                // --------------------------------
                default: begin

                    state     <= IDLE;
                    clk_count <= SEED;
                    bit_index <= 3'd0;
                    rx_data   <= 8'd0;
                    rx_valid  <= 1'b0;

                end

            endcase
        end
    end

endmodule
