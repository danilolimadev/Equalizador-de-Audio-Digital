module fir_all_filters (
    input  wire                i_clk,
    input  wire                i_rst_n,
    input  wire                i_en,
    input  wire signed [23:0]  i_data,
    output wire signed [23:0]  o_lp, // lowpass
    output wire signed [23:0]  o_band_64_125,
    output wire signed [23:0]  o_band_125_250,
    output wire signed [23:0]  o_band_250_500,
    output wire signed [23:0]  o_band_500_1k,
    output wire signed [23:0]  o_band_1k_2k,
    output wire signed [23:0]  o_band_2k_4k,
    output wire signed [23:0]  o_band_4k_8k,
    output wire signed [23:0]  o_band_8k_16k,
    output wire signed [23:0]  o_hp // highpass
);

    // lembrete sobre caminhos .hex, como você já comentou

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_LP.hex")
    ) fir_lp (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_lp)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_64-125.hex")
    ) fir_band_64_125 (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_64_125)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_125-250.hex")
    ) fir_band_125_250 (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_125_250)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_250-500.hex")
    ) fir_band_250_500 (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_250_500)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_500-1k.hex")
    ) fir_band_500_1k (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_500_1k)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_1k-2k.hex")
    ) fir_band_1k_2k (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_1k_2k)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_2k-4k.hex")
    ) fir_band_2k_4k (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_2k_4k)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_4k-8k.hex")
    ) fir_band_4k_8k (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_4k_8k)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_8k-16k.hex")
    ) fir_band_8k_16k (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_band_8k_16k)
    );

    fir_parameterizable_filter #(
        .N(255), .COEF_FILE("C:/coefficients/coef_HP.hex")
    ) fir_hp (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en),
        .i_data(i_data), .o_data(o_hp)
    );

endmodule
