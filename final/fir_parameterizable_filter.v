module fir_parameterizable_filter #(
    parameter integer N = 255,                // number of filter taps
    parameter COEF_FILE = "coef.hex"  // coefficient file path
)(
    input  wire                clk,           // system clock
    input  wire                rst_n,         // active-low (0) reset
    input  wire                enable,        // filter enable
    input  wire signed  [23:0] audio_in,      // input data sample
    output reg  signed  [23:0] audio_out      // output data sample
);

    // Filter coefficients in Q1.15 format (signed 17 bits)
    reg signed [16:0] coefficients [0:N-1];

    // Delay line buffer (history of input samples)
    reg signed [23:0] delay_line   [0:N-1];

    // Multiply-accumulate accumulator
    reg signed [47:0] accumulator;

    integer i;

    // Load coefficients from external hex file
    initial begin
        $readmemh(COEF_FILE, coefficients);
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset delay line, output and accumulator
            for (i = 0; i < N; i = i + 1)
                delay_line[i] <= 24'sd0;
            audio_out <= 24'sd0;
            accumulator   <= 48'sd0;
        end begin
            // Shift delay line
            for (i = N-1; i > 0; i = i - 1)
                delay_line[i] <= delay_line[i-1];
            delay_line[0] <= audio_in;

            // Multiply and accumulate
            accumulator = 48'sd0;
            for (i = 0; i < N; i = i + 1)
                accumulator = accumulator + delay_line[i] * coefficients[i];

            // Fixed-point adjustment (Q1.15 to 24-bit)
            audio_out <= accumulator[38:15];
        end
    end

endmodule
