module fir_parameterizable_filter #(
    parameter N = 255,                             // Taps
    parameter COEF_FILE = "coef.hex"               // Path (don't change here)
)(
    input  wire                i_clk,              // Clock
    input  wire                i_rst_n,            // Reset 0
    input  wire                i_en,               // Enable
    input  wire signed  [23:0] i_data,             // In
    output reg  signed  [23:0] o_data              // Out
);

    // Coefficients
    reg signed [16:0] h [0:N-1];

    // Sample history
    reg signed [23:0] x [0:N-1];

    // Accumulator
    reg signed [47:0] acc;

    integer i;

    initial begin
        $readmemh(COEF_FILE, h);
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (i = 0; i < N; i = i + 1)
                x[i] <= 24'sd0;
            o_data <= 24'sd0;
            acc    <= 48'sd0;
        end else if (i_en) begin
            // Buffer deslocation
            for (i = N-1; i > 0; i = i - 1)
                x[i] <= x[i-1];
            x[0] <= i_data;

            // Aaccumulate operation
            acc = 48'sd0;
            for (i = 0; i < N; i = i + 1)
                acc = acc + x[i] * h[i]; // Sum of all frequencies

            // Extract output
            o_data <= acc[38:15];
        end
    end

endmodule