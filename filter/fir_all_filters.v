module fir_all_filters (
    input  wire                clk,                  // system clock
    input  wire                reset_n,              // active-low reset
    input  wire                enable,               // global filter enable
    input  wire signed [23:0]  input_sample,         // 24-bit input sample

    output wire signed [23:0]  output_lowpass,       // low-pass output
    output wire signed [23:0]  output_band_64_125,   // 64–125 Hz band output
    output wire signed [23:0]  output_band_125_250,  // 125–250 Hz band output
    output wire signed [23:0]  output_band_250_500,  // 250–500 Hz band output
    output wire signed [23:0]  output_band_500_1k,   // 500–1 kHz band output
    output wire signed [23:0]  output_band_1k_2k,    // 1–2 kHz band output
    output wire signed [23:0]  output_band_2k_4k,    // 2–4 kHz band output
    output wire signed [23:0]  output_band_4k_8k,    // 4–8 kHz band output
    output wire signed [23:0]  output_band_8k_16k,   // 8–16 kHz band output
    output wire signed [23:0]  output_highpass       // high-pass output
);

    /*
       só um lembrete, todos os arquivos .hex estão configurados pro caminho no meu pc
       se for precisar alterar o caminho, vai ter que mudar em todos os ".COEF_FILE"
       por algum motivo, não conseguir testar deixando eles na raiz do projeto...
    */

    // Low-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_LP.hex")
    ) lowpass_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_lowpass)
    );

    // 64–125 Hz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_64-125.hex")
    ) band_64_125_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_64_125)
    );

    // 125–250 Hz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_125-250.hex")
    ) band_125_250_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_125_250)
    );

    // 250–500 Hz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_250-500.hex")
    ) band_250_500_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_250_500)
    );

    // 500 Hz–1 kHz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_500-1k.hex")
    ) band_500_1k_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_500_1k)
    );

    // 1–2 kHz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_1k-2k.hex")
    ) band_1k_2k_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_1k_2k)
    );

    // 2–4 kHz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_2k-4k.hex")
    ) band_2k_4k_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_2k_4k)
    );

    // 4–8 kHz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_4k-8k.hex")
    ) band_4k_8k_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_4k_8k)
    );

    // 8–16 kHz band-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_8k-16k.hex")
    ) band_8k_16k_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_band_8k_16k)
    );

    // High-pass filter instance
    fir_parameterizable_filter #(
        .N(255),
        .COEF_FILE("C:/coefficients/coef_HP.hex")
    ) highpass_filter (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .input_sample(input_sample),
        .output_sample(output_highpass)
    );

endmodule
