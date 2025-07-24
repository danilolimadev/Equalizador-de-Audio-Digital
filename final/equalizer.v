module equalizer #(
    parameter GAIN_WIDTH = 13
  )(
    input  signed [23:0] audio_in,
    input clk, rst_n,
    output signed [23:0] audio_out,
    input signed [GAIN_WIDTH-1:0] gain_1,
    input signed [GAIN_WIDTH-1:0] gain_2,
    input signed [GAIN_WIDTH-1:0] gain_3,
    input signed [GAIN_WIDTH-1:0] gain_4,
    input signed [GAIN_WIDTH-1:0] gain_5,
    input signed [GAIN_WIDTH-1:0] gain_6,
    input signed [GAIN_WIDTH-1:0] gain_7,
    input signed [GAIN_WIDTH-1:0] gain_8,
    input signed [GAIN_WIDTH-1:0] gain_9,
    input signed [GAIN_WIDTH-1:0] gain_10
  );

  localparam AUDIO_WIDTH = 24; // Largura do áudio de entrada e saída

  // Instancia os filtros FIR para cada faixa, com apenas uma instância
  wire signed [23:0] output_lowpass, output_band_64_125, output_band_125_250, output_band_250_500, output_band_500_1k, output_band_1k_2k,
       output_band_2k_4k, output_band_4k_8k, output_band_8k_16k, output_highpass;

  fir_all_filters inst_filter (
                    .clk(clk),
                    .rst_n(rst_n),
                    .enable(1'b1),
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
  wire signed [AUDIO_WIDTH+GAIN_WIDTH-1:0] weighted_1, weighted_2, weighted_3, weighted_4, weighted_5,
       weighted_6, weighted_7, weighted_8, weighted_9, weighted_10;

  assign weighted_1 = $signed(output_lowpass) * gain_1*96;
  assign weighted_2 = $signed(output_band_64_125) * gain_2*96;
  assign weighted_3 = $signed(output_band_125_250) * gain_3*96;
  assign weighted_4 = $signed(output_band_250_500) * gain_4*96;
  assign weighted_5 = $signed(output_band_500_1k) * gain_5*96;
  assign weighted_6 = $signed(output_band_1k_2k) * gain_6*96;
  assign weighted_7 = $signed(output_band_2k_4k) * gain_7*96;
  assign weighted_8 = $signed(output_band_4k_8k) * gain_8*96;
  assign weighted_9 = $signed(output_band_8k_16k) * gain_9*96;
  assign weighted_10 = $signed(output_highpass) * gain_10*96;

  wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s1 = weighted_1 + weighted_2;
  wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s2 = weighted_3 + weighted_4;
  wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s3 = weighted_5 + weighted_6;
  wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s4 = weighted_7 + weighted_8;
  wire signed [AUDIO_WIDTH+GAIN_WIDTH:0] sum_out_1s5 = weighted_9 + weighted_10;

  wire signed [AUDIO_WIDTH+GAIN_WIDTH+1:0] sum_out_2s1 = sum_out_1s1 + sum_out_1s2;
  wire signed [AUDIO_WIDTH+GAIN_WIDTH+1:0] sum_out_2s2 = sum_out_1s3 + sum_out_1s4;

  wire signed [AUDIO_WIDTH+GAIN_WIDTH+2:0] sum_out_3s1 = sum_out_2s1 + sum_out_2s2;

  wire signed [AUDIO_WIDTH+GAIN_WIDTH+2:0] sum_out_4s = sum_out_3s1 + sum_out_1s5;

  assign audio_out = sum_out_4s[AUDIO_WIDTH+GAIN_WIDTH+2:GAIN_WIDTH+2];

endmodule
