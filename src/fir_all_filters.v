module fir_all_filters (
    input  wire                clk,                  // system clock
    input  wire                rst_n,                // active-low reset
    input  wire signed [23:0]  audio_in,             // 24-bit input sample
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


  // Low-pass filter instance
  fir_filter #(
               .COEFF_00(12'sd163), .COEFF_01(12'sd183), .COEFF_02(12'sd240), .COEFF_03(12'sd332),
               .COEFF_04(12'sd457), .COEFF_05(12'sd607), .COEFF_06(12'sd779), .COEFF_07(12'sd964),
               .COEFF_08(12'sd1155), .COEFF_09(12'sd1343), .COEFF_10(12'sd1523), .COEFF_11(12'sd1685),
               .COEFF_12(12'sd1823), .COEFF_13(12'sd1933), .COEFF_14(12'sd2008), .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd2008), .COEFF_18(12'sd1933), .COEFF_19(12'sd1823),
               .COEFF_20(12'sd1685), .COEFF_21(12'sd1523), .COEFF_22(12'sd1343), .COEFF_23(12'sd1155),
               .COEFF_24(12'sd964), .COEFF_25(12'sd779), .COEFF_26(12'sd607), .COEFF_27(12'sd457),
               .COEFF_28(12'sd332), .COEFF_29(12'sd240), .COEFF_30(12'sd183), .COEFF_31(12'sd163)

             ) lowpass_filter (
               .clk      (clk),
               .rst_n    (rst_n),
               .audio_in (audio_in),
               .audio_out(output_lowpass)
             );


  // 64–125 Hz band-pass filter instance (31 taps, Q1.11 coefficients embutidos)
  fir_filter #(
               .COEFF_00(12'sd161), .COEFF_01(12'sd180), .COEFF_02(12'sd237), .COEFF_03(12'sd329),
               .COEFF_04(12'sd452), .COEFF_05(12'sd603), .COEFF_06(12'sd774), .COEFF_07(12'sd959),
               .COEFF_08(12'sd1150), .COEFF_09(12'sd1340), .COEFF_10(12'sd1520), .COEFF_11(12'sd1683),
               .COEFF_12(12'sd1822), .COEFF_13(12'sd1932), .COEFF_14(12'sd2008), .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd2008), .COEFF_18(12'sd1932), .COEFF_19(12'sd1822),
               .COEFF_20(12'sd1683), .COEFF_21(12'sd1520), .COEFF_22(12'sd1340), .COEFF_23(12'sd1150),
               .COEFF_24(12'sd959), .COEFF_25(12'sd774), .COEFF_26(12'sd603), .COEFF_27(12'sd452),
               .COEFF_28(12'sd329), .COEFF_29(12'sd237), .COEFF_30(12'sd180), .COEFF_31(12'sd161)

             ) band_64_125_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_64_125)
             );


  // 125–250 Hz band-pass filter instance
  fir_filter #(
               .COEFF_00(12'sd152), .COEFF_01(12'sd171), .COEFF_02(12'sd227), .COEFF_03(12'sd317),
               .COEFF_04(12'sd438), .COEFF_05(12'sd587), .COEFF_06(12'sd758), .COEFF_07(12'sd943),
               .COEFF_08(12'sd1135), .COEFF_09(12'sd1326), .COEFF_10(12'sd1509), .COEFF_11(12'sd1675),
               .COEFF_12(12'sd1817), .COEFF_13(12'sd1929), .COEFF_14(12'sd2007), .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd2007), .COEFF_18(12'sd1929), .COEFF_19(12'sd1817),
               .COEFF_20(12'sd1675), .COEFF_21(12'sd1509), .COEFF_22(12'sd1326), .COEFF_23(12'sd1135),
               .COEFF_24(12'sd943), .COEFF_25(12'sd758), .COEFF_26(12'sd587), .COEFF_27(12'sd438),
               .COEFF_28(12'sd317), .COEFF_29(12'sd227), .COEFF_30(12'sd171), .COEFF_31(12'sd152)

             ) band_125_250_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_125_250)
             );



  // 250–500 Hz band-pass filter instance
  fir_filter #(

               .COEFF_00(12'sd117), .COEFF_01(12'sd137), .COEFF_02(12'sd188), .COEFF_03(12'sd270),
               .COEFF_04(12'sd384), .COEFF_05(12'sd527), .COEFF_06(12'sd694), .COEFF_07(12'sd879),
               .COEFF_08(12'sd1075), .COEFF_09(12'sd1274), .COEFF_10(12'sd1466), .COEFF_11(12'sd1643),
               .COEFF_12(12'sd1796), .COEFF_13(12'sd1918), .COEFF_14(12'sd2003), .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd2003), .COEFF_18(12'sd1918), .COEFF_19(12'sd1796),
               .COEFF_20(12'sd1643), .COEFF_21(12'sd1466), .COEFF_22(12'sd1274), .COEFF_23(12'sd1075),
               .COEFF_24(12'sd879), .COEFF_25(12'sd694), .COEFF_26(12'sd527), .COEFF_27(12'sd384),
               .COEFF_28(12'sd270), .COEFF_29(12'sd188), .COEFF_30(12'sd137), .COEFF_31(12'sd117)

             ) band_250_500_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_250_500)
             );


  // 500 Hz–1 kHz band-pass filter instance
  fir_filter #(

               .COEFF_00(12'sd7),   .COEFF_01(12'sd25),  .COEFF_02(12'sd56),  .COEFF_03(12'sd109),
               .COEFF_04(12'sd191), .COEFF_05(12'sd307), .COEFF_06(12'sd457), .COEFF_07(12'sd640),
               .COEFF_08(12'sd848), .COEFF_09(12'sd1073), .COEFF_10(12'sd1301), .COEFF_11(12'sd1520),
               .COEFF_12(12'sd1715), .COEFF_13(12'sd1875), .COEFF_14(12'sd1988), .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd1988), .COEFF_18(12'sd1875), .COEFF_19(12'sd1715),
               .COEFF_20(12'sd1520), .COEFF_21(12'sd1301), .COEFF_22(12'sd1073), .COEFF_23(12'sd848),
               .COEFF_24(12'sd640), .COEFF_25(12'sd457), .COEFF_26(12'sd307), .COEFF_27(12'sd191),
               .COEFF_28(12'sd109), .COEFF_29(12'sd56), .COEFF_30(12'sd25), .COEFF_31(12'sd7)

             ) band_500_1k_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_500_1k)
             );


  // 1–2 kHz band-pass filter instance
  fir_filter #(

               .COEFF_00(-12'sd138), .COEFF_01(-12'sd152), .COEFF_02(-12'sd187), .COEFF_03(-12'sd232),
               .COEFF_04(-12'sd266), .COEFF_05(-12'sd267), .COEFF_06(-12'sd214), .COEFF_07(-12'sd91),
               .COEFF_08(12'sd109),  .COEFF_09(12'sd380),  .COEFF_10(12'sd706),  .COEFF_11(12'sd1059),
               .COEFF_12(12'sd1404), .COEFF_13(12'sd1705), .COEFF_14(12'sd1928), .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd1928), .COEFF_18(12'sd1705), .COEFF_19(12'sd1404),
               .COEFF_20(12'sd1059), .COEFF_21(12'sd706),  .COEFF_22(12'sd380),  .COEFF_23(12'sd109),
               .COEFF_24(-12'sd91),  .COEFF_25(-12'sd214), .COEFF_26(-12'sd267), .COEFF_27(-12'sd266),
               .COEFF_28(-12'sd232), .COEFF_29(-12'sd187), .COEFF_30(-12'sd152), .COEFF_31(-12'sd138)

             ) band_1k_2k_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_1k_2k)
             );


  // 2–4 kHz band-pass filter instance
  fir_filter #(

               .COEFF_00(12'sd72),   .COEFF_01(12'sd77),   .COEFF_02(12'sd75),   .COEFF_03(12'sd40),
               .COEFF_04(-12'sd61),  .COEFF_05(-12'sd247), .COEFF_06(-12'sd505), .COEFF_07(-12'sd779),
               .COEFF_08(-12'sd980), .COEFF_09(-12'sd1008),.COEFF_10(-12'sd791), .COEFF_11(-12'sd317),
               .COEFF_12(12'sd350),  .COEFF_13(12'sd1076), .COEFF_14(12'sd1693), .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd1693), .COEFF_18(12'sd1076), .COEFF_19(12'sd350),
               .COEFF_20(-12'sd317), .COEFF_21(-12'sd791), .COEFF_22(-12'sd1008),.COEFF_23(-12'sd980),
               .COEFF_24(-12'sd779), .COEFF_25(-12'sd505), .COEFF_26(-12'sd247), .COEFF_27(-12'sd61),
               .COEFF_28(12'sd40),   .COEFF_29(12'sd75),   .COEFF_30(12'sd77),   .COEFF_31(12'sd72)

             ) band_2k_4k_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_2k_4k)
             );


  // 4–8 kHz band-pass filter instance
  fir_filter #(

               .COEFF_00(-12'sd33),  .COEFF_01(-12'sd13),  .COEFF_02(12'sd10),   .COEFF_03(12'sd13),
               .COEFF_04(-12'sd20),  .COEFF_05(-12'sd36),  .COEFF_06(12'sd79),   .COEFF_07(12'sd345),
               .COEFF_08(12'sd545),  .COEFF_09(12'sd325),  .COEFF_10(-12'sd436), .COEFF_11(-12'sd1326),
               .COEFF_12(-12'sd1584),.COEFF_13(-12'sd747), .COEFF_14(12'sd813),  .COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(12'sd813),  .COEFF_18(-12'sd747), .COEFF_19(-12'sd1584),
               .COEFF_20(-12'sd1326),.COEFF_21(-12'sd436), .COEFF_22(12'sd325),  .COEFF_23(12'sd545),
               .COEFF_24(12'sd345),  .COEFF_25(12'sd79),   .COEFF_26(-12'sd36),  .COEFF_27(-12'sd20),
               .COEFF_28(12'sd13),   .COEFF_29(12'sd10),   .COEFF_30(-12'sd13),  .COEFF_31(-12'sd33)

             ) band_4k_8k_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_4k_8k)
             );


  // 8–16 kHz band-pass filter instance
  fir_filter #(

               .COEFF_00(12'sd19),   .COEFF_01(-12'sd24),  .COEFF_02(-12'sd25),  .COEFF_03(12'sd13),
               .COEFF_04(-12'sd20),  .COEFF_05(12'sd79),   .COEFF_06(12'sd153),  .COEFF_07(-12'sd212),
               .COEFF_08(-12'sd211), .COEFF_09(12'sd103),  .COEFF_10(-12'sd139), .COEFF_11(12'sd511),
               .COEFF_12(12'sd972),  .COEFF_13(-12'sd1443),.COEFF_14(-12'sd1830),.COEFF_15(12'sd2047),
               .COEFF_16(12'sd2047), .COEFF_17(-12'sd1830),.COEFF_18(-12'sd1443),.COEFF_19(12'sd972),
               .COEFF_20(12'sd511),  .COEFF_21(-12'sd139), .COEFF_22(12'sd103),  .COEFF_23(-12'sd211),
               .COEFF_24(-12'sd212), .COEFF_25(12'sd153),  .COEFF_26(12'sd79),   .COEFF_27(-12'sd20),
               .COEFF_28(12'sd13),   .COEFF_29(-12'sd25),  .COEFF_30(-12'sd24),  .COEFF_31(12'sd19)

             ) band_8k_16k_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_band_8k_16k)
             );


  // High-pass filter instance (31 taps, Q1.11 coefficients embedded)
  fir_filter #(

               .COEFF_00(12'sd0),    .COEFF_01(12'sd0),    .COEFF_02(12'sd10),   .COEFF_03(-12'sd16),
               .COEFF_04(-12'sd1),   .COEFF_05(12'sd35),   .COEFF_06(-12'sd53),  .COEFF_07(12'sd0),
               .COEFF_08(12'sd104),  .COEFF_09(-12'sd143), .COEFF_10(-12'sd1),   .COEFF_11(12'sd260),
               .COEFF_12(-12'sd359), .COEFF_13(12'sd0),    .COEFF_14(12'sd812),  .COEFF_15(-12'sd1676),
               .COEFF_16(12'sd2047), .COEFF_17(-12'sd1676),.COEFF_18(12'sd812),  .COEFF_19(12'sd0),
               .COEFF_20(-12'sd359), .COEFF_21(12'sd260),  .COEFF_22(-12'sd1),   .COEFF_23(-12'sd143),
               .COEFF_24(12'sd104),  .COEFF_25(12'sd0),    .COEFF_26(-12'sd53),  .COEFF_27(12'sd35),
               .COEFF_28(-12'sd1),   .COEFF_29(-12'sd16),  .COEFF_30(12'sd10),   .COEFF_31(12'sd0)

             ) highpass_filter (
               .clk        (clk),
               .rst_n      (rst_n),
               .audio_in   (audio_in),
               .audio_out  (output_highpass)
             );


endmodule
