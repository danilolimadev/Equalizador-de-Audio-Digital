module equalizer #(
    parameter GAIN_WIDTH = 13
  )(
    input  signed [23:0] audio_in,
    input clk, rst_n,
    output [23:0] audio_out,
    input [GAIN_WIDTH-1:0] gain_1,
    input [GAIN_WIDTH-1:0] gain_2,
    input [GAIN_WIDTH-1:0] gain_3,
    input [GAIN_WIDTH-1:0] gain_4,
    input [GAIN_WIDTH-1:0] gain_5,
    input [GAIN_WIDTH-1:0] gain_6,
    input [GAIN_WIDTH-1:0] gain_7,
    input [GAIN_WIDTH-1:0] gain_8,
    input [GAIN_WIDTH-1:0] gain_9,
    input [GAIN_WIDTH-1:0] gain_10
  );

  // Instancia os filtros FIR para cada faixa, com apenas uma instância
  wire signed [23:0] output_lowpass, output_band_64_125, output_band_125_250, output_band_250_500, output_band_500_1k, output_band_1k_2k,
       output_band_2k_4k, output_band_4k_8k, output_band_8k_16k, output_highpass;

  fir_all_filters inst_filter (
                    .clk(clk),
                    .rst_n(rst_n),
                    .enable(1),
                    .audio_in(audio_in),
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

  // Multiplicação dos filtros pelos ganhos
  wire signed [36:0] weighted_1, weighted_2, weighted_3, weighted_4, weighted_5,
       weighted_6, weighted_7, weighted_8, weighted_9, weighted_10;

  assign weighted_1 = output_lowpass * gain_1;
  assign weighted_2 = output_band_64_125 * gain_2;
  assign weighted_3 = output_band_125_250 * gain_3;
  assign weighted_4 = output_band_250_500 * gain_4;
  assign weighted_5 = output_band_500_1k * gain_5;
  assign weighted_6 = output_band_1k_2k * gain_6;
  assign weighted_7 = output_band_2k_4k * gain_7;
  assign weighted_8 = output_band_4k_8k * gain_8;
  assign weighted_9 = output_band_8k_16k * gain_9;
  assign weighted_10 = output_highpass * gain_10;

  // Soma em árvore binária (cada nível soma 2 resultados do nível anterior)
  wire signed [24:0] sum_1 = weighted_1[36:13] + weighted_2[36:13];
  wire signed [24:0] sum_2 = weighted_3[36:13] + weighted_4[36:13];
  wire signed [24:0] sum_3 = weighted_5[36:13] + weighted_6[36:13];
  wire signed [24:0] sum_4 = weighted_7[36:13] + weighted_8[36:13];
  wire signed [24:0] sum_5 = weighted_9[36:13] + weighted_10[36:13];

  wire signed [24:0] sum_6 = sum_1[24:1] + sum_2[24:1];
  wire signed [24:0] sum_7 = sum_3[24:1] + sum_4[24:1];

  wire signed [24:0] sum_8 = sum_6[24:1] + sum_7[24:1];

  wire signed [24:0] sum_out = sum_8[24:1] + sum_5[24:1];

  // Truncamento para 24 bits
  assign audio_out = sum_out[24:1];

endmodule
