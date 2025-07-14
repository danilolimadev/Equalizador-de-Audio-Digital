`timescale 1ns/1ps

module fir_all_filters_tb;

    reg  i_clk;
    reg  i_rst_n;
    reg  i_en;
    reg signed [23:0] i_data;

    wire signed [23:0] o_lp;
    wire signed [23:0] o_band_64_125;
    wire signed [23:0] o_band_125_250;
    wire signed [23:0] o_band_250_500;
    wire signed [23:0] o_band_500_1k;
    wire signed [23:0] o_band_1k_2k;
    wire signed [23:0] o_band_2k_4k;
    wire signed [23:0] o_band_4k_8k;
    wire signed [23:0] o_band_8k_16k;
    wire signed [23:0] o_hp;
    wire signed [23:0] o_sum;

    fir_all_filters uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_en(i_en),
        .i_data(i_data),
        .o_lp(o_lp),
        .o_band_64_125(o_band_64_125),
        .o_band_125_250(o_band_125_250),
        .o_band_250_500(o_band_250_500),
        .o_band_500_1k(o_band_500_1k),
        .o_band_1k_2k(o_band_1k_2k),
        .o_band_2k_4k(o_band_2k_4k),
        .o_band_4k_8k(o_band_4k_8k),
        .o_band_8k_16k(o_band_8k_16k),
        .o_hp(o_hp),
        .o_sum(o_sum)
    );

    initial i_clk = 0;
    always #10 i_clk = ~i_clk;

    initial begin
        i_rst_n = 0;
        i_en = 0;
        i_data = 24'sd0;

        #50;
        i_rst_n = 1;
        i_en = 1;

        repeat (6000) begin
            @(posedge i_clk);
            i_data = i_data + 24'sd100; // ramp
        end

        #200;
        $stop;
    end

endmodule
