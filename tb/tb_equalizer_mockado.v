`timescale 1ns / 1ps

module equalizer_mockado #(
    parameter GAIN_WIDTH = 8
)(
    input  wire signed [23:0] audio_in,
    input  wire clk,
    input  wire rst_n,
    output wire signed [23:0] audio_out,

    input  wire signed [23:0] filter_out_1,
    input  wire signed [23:0] filter_out_2,
    input  wire signed [23:0] filter_out_3,
    input  wire signed [23:0] filter_out_4,
    input  wire signed [23:0] filter_out_5,
    input  wire signed [23:0] filter_out_6,
    input  wire signed [23:0] filter_out_7,
    input  wire signed [23:0] filter_out_8,
    input  wire signed [23:0] filter_out_9,
    input  wire signed [23:0] filter_out_10,

    input  wire signed [GAIN_WIDTH-1:0] gain_1,
    input  wire signed [GAIN_WIDTH-1:0] gain_2,
    input  wire signed [GAIN_WIDTH-1:0] gain_3,
    input  wire signed [GAIN_WIDTH-1:0] gain_4,
    input  wire signed [GAIN_WIDTH-1:0] gain_5,
    input  wire signed [GAIN_WIDTH-1:0] gain_6,
    input  wire signed [GAIN_WIDTH-1:0] gain_7,
    input  wire signed [GAIN_WIDTH-1:0] gain_8,
    input  wire signed [GAIN_WIDTH-1:0] gain_9,
    input  wire signed [GAIN_WIDTH-1:0] gain_10
);

    localparam AUDIO_WIDTH = 24;

    // multiplicação filtro * ganho
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_1 = filter_out_1 * gain_1;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_2 = filter_out_2 * gain_2;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_3 = filter_out_3 * gain_3;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_4 = filter_out_4 * gain_4;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_5 = filter_out_5 * gain_5;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_6 = filter_out_6 * gain_6;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_7 = filter_out_7 * gain_7;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_8 = filter_out_8 * gain_8;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_9 = filter_out_9 * gain_9;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_10 = filter_out_10 * gain_10;

    // soma 
    wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s1 = weighted_1 + weighted_2;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s2 = weighted_3 + weighted_4;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s3 = weighted_5 + weighted_6;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s4 = weighted_7 + weighted_8;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s5 = weighted_9 + weighted_10;

    wire signed [AUDIO_WIDTH+GAIN_WIDTH+1:0] sum_out_2s1 = sum_out_1s1 + sum_out_1s2;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH+1:0] sum_out_2s2 = sum_out_1s3 + sum_out_1s4;

    wire signed [AUDIO_WIDTH+GAIN_WIDTH+2:0] sum_out_3s1 = sum_out_2s1 + sum_out_2s2;
    wire signed [AUDIO_WIDTH+GAIN_WIDTH+2:0] sum_out_4s  = sum_out_3s1 + sum_out_1s5;

    // truncamento 
    assign audio_out = sum_out_4s[AUDIO_WIDTH+GAIN_WIDTH+2:GAIN_WIDTH+2];

endmodule


`timescale 1ns / 1ps

module tb_equalizer_mockado();
    reg clk;
    reg rst_n;
    reg signed [23:0] audio_in;
    wire signed [23:0] audio_out;

    reg signed [23:0] filter_out_1, filter_out_2, filter_out_3, filter_out_4, filter_out_5;
    reg signed [23:0] filter_out_6, filter_out_7, filter_out_8, filter_out_9, filter_out_10;

    reg signed [7:0] gain_1, gain_2, gain_3, gain_4, gain_5;
    reg signed [7:0] gain_6, gain_7, gain_8, gain_9, gain_10;


    equalizer_mockado inst (
        .clk(clk),
        .rst_n(rst_n),
        .audio_in(audio_in),
        .filter_out_1(filter_out_1),
        .filter_out_2(filter_out_2),
        .filter_out_3(filter_out_3),
        .filter_out_4(filter_out_4),
        .filter_out_5(filter_out_5),
        .filter_out_6(filter_out_6),
        .filter_out_7(filter_out_7),
        .filter_out_8(filter_out_8),
        .filter_out_9(filter_out_9),
        .filter_out_10(filter_out_10),
        .gain_1(gain_1),
        .gain_2(gain_2),
        .gain_3(gain_3),
        .gain_4(gain_4),
        .gain_5(gain_5),
        .gain_6(gain_6),
        .gain_7(gain_7),
        .gain_8(gain_8),
        .gain_9(gain_9),
        .gain_10(gain_10),
        .audio_out(audio_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        audio_in = 0;

        filter_out_1 = 0; filter_out_2 = 0; filter_out_3 = 0; filter_out_4 = 0; filter_out_5 = 0;
        filter_out_6 = 0; filter_out_7 = 0; filter_out_8 = 0; filter_out_9 = 0; filter_out_10 = 0;

        gain_1 = 0; gain_2 = 0; gain_3 = 0; gain_4 = 0; gain_5 = 0;
        gain_6 = 0; gain_7 = 0; gain_8 = 0; gain_9 = 0; gain_10 = 0;

        #20;
        rst_n = 1;
        #20;

        filter_out_1 = 24'sd1000; gain_1 = 8'sd2;
        filter_out_2 = 24'sd2000; gain_2 = 8'sd3;
        filter_out_3 = 24'sd1500; gain_3 = 8'sd4;
        filter_out_4 = 24'sd1200; gain_4 = 8'sd5;
        filter_out_5 = 24'sd1100; gain_5 = 8'sd6;
        filter_out_6 = 24'sd1300; gain_6 = 8'sd7;
        filter_out_7 = 24'sd1400; gain_7 = 8'sd8;
        filter_out_8 = 24'sd1250; gain_8 = 8'sd9;
        filter_out_9 = 24'sd1350; gain_9 = 8'sd10;
        filter_out_10 = 24'sd1450; gain_10 = 8'sd11;

        repeat (10) begin
            @(posedge clk);
            audio_in = audio_in + 24'sd500;
        end

        #100;
        $stop;
    end

endmodule
