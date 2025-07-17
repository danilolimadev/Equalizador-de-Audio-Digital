`timescale 1ns/1ps

module fir_all_filters_tb;

    // Testbench signals
    reg                 clk;                  // system clock
    reg                 reset_n;              // active-low reset
    reg                 enable;               // global filter enable
    reg signed [23:0]   input_sample;         // 24-bit input sample

    // Filter outputs
    wire signed [23:0]  output_lowpass;       // low-pass output
    wire signed [23:0]  output_band_64_125;   // 64–125 Hz band output
    wire signed [23:0]  output_band_125_250;  // 125–250 Hz band output
    wire signed [23:0]  output_band_250_500;  // 250–500 Hz band output
    wire signed [23:0]  output_band_500_1k;   // 500 Hz–1 kHz band output
    wire signed [23:0]  output_band_1k_2k;    // 1–2 kHz band output
    wire signed [23:0]  output_band_2k_4k;    // 2–4 kHz band output
    wire signed [23:0]  output_band_4k_8k;    // 4–8 kHz band output
    wire signed [23:0]  output_band_8k_16k;   // 8–16 kHz band output
    wire signed [23:0]  output_highpass;      // high-pass output

    // Instantiate the unit under test (UUT)
    fir_all_filters uut (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_lowpass(output_lowpass),
        .output_band_64_125(output_band_64_125),
        .output_band_125_250(output_band_125_250),
        .output_band_250_500(output_band_250_500),
        .output_band_500_1k(output_band_500_1k),
        .output_band_1k_2k(output_band_1k_2k),
        .output_band_2k_4k(output_band_2k_4k),
        .output_band_4k_8k(output_band_4k_8k),
        .output_band_8k_16k(output_band_8k_16k),
        .output_highpass(output_highpass)
    );

    // Clock generation: 50 MHz
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        // Initialize inputs
        reset_n      = 0;
        enable       = 0;
        input_sample = 24'sd0;

        // Apply reset
        #50;
        reset_n = 1;
        enable  = 1;

        // Ramp input sample over 6000 cycles
        repeat (6000) begin
            @(posedge clk);
            input_sample = input_sample + 24'sd100;
        end

        // Finish simulation
        #200;
        $stop;
    end

endmodule
