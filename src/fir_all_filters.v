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
    '{12'sd163, 12'sd183, 12'sd240, 12'sd332, 12'sd457, 12'sd607, 12'sd779, 12'sd964, 12'sd1155, 12'sd1343, 12'sd1523, 12'sd1685, 12'sd1823, 12'sd1933, 12'sd2008, 12'sd2047, 12'sd2047, 12'sd2008, 12'sd1933, 12'sd1823, 12'sd1685, 12'sd1523, 12'sd1343, 12'sd1155, 12'sd964, 12'sd779, 12'sd607, 12'sd457, 12'sd332, 12'sd240, 12'sd183, 12'sd163}
) lowpass_filter (
    .clk      (clk),
    .rst_n    (rst_n),
    .audio_in (audio_in),
    .audio_out(output_lowpass)
);


// 64–125 Hz band-pass filter instance (31 taps, Q1.11 coefficients embutidos)
fir_filter #(
    '{12'sd161, 12'sd180, 12'sd237, 12'sd329, 12'sd452, 12'sd603, 12'sd774, 12'sd959, 12'sd1150, 12'sd1340, 12'sd1520, 12'sd1683, 12'sd1822, 12'sd1932, 12'sd2008, 12'sd2047, 12'sd2047, 12'sd2008, 12'sd1932, 12'sd1822, 12'sd1683, 12'sd1520, 12'sd1340, 12'sd1150, 12'sd959, 12'sd774, 12'sd603, 12'sd452, 12'sd329, 12'sd237, 12'sd180, 12'sd161}
) band_64_125_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_64_125)
);


    // 125–250 Hz band-pass filter instance
fir_filter #(
   '{12'sd152, 12'sd171, 12'sd227, 12'sd317, 12'sd438, 12'sd587, 12'sd758, 12'sd943, 12'sd1135, 12'sd1326, 12'sd1509, 12'sd1675, 12'sd1817, 12'sd1929, 12'sd2007, 12'sd2047, 12'sd2047, 12'sd2007, 12'sd1929, 12'sd1817, 12'sd1675, 12'sd1509, 12'sd1326, 12'sd1135, 12'sd943, 12'sd758, 12'sd587, 12'sd438, 12'sd317, 12'sd227, 12'sd171, 12'sd152}
) band_125_250_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_125_250)
);



    // 250–500 Hz band-pass filter instance
fir_filter #(
    '{12'sd117, 12'sd137, 12'sd188, 12'sd270, 12'sd384, 12'sd527, 12'sd694, 12'sd879, 12'sd1075, 12'sd1274, 12'sd1466, 12'sd1643, 12'sd1796, 12'sd1918, 12'sd2003, 12'sd2047, 12'sd2047, 12'sd2003, 12'sd1918, 12'sd1796, 12'sd1643, 12'sd1466, 12'sd1274, 12'sd1075, 12'sd879, 12'sd694, 12'sd527, 12'sd384, 12'sd270, 12'sd188, 12'sd137, 12'sd117}
) band_250_500_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_250_500)
);


    // 500 Hz–1 kHz band-pass filter instance
fir_filter #(
   '{12'sd7, 12'sd25, 12'sd56, 12'sd109, 12'sd191, 12'sd307, 12'sd457, 12'sd640, 12'sd848, 12'sd1073, 12'sd1301, 12'sd1520, 12'sd1715, 12'sd1875, 12'sd1988, 12'sd2047, 12'sd2047, 12'sd1988, 12'sd1875, 12'sd1715, 12'sd1520, 12'sd1301, 12'sd1073, 12'sd848, 12'sd640, 12'sd457, 12'sd307, 12'sd191, 12'sd109, 12'sd56, 12'sd25, 12'sd7}
) band_500_1k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_500_1k)
);


    // 1–2 kHz band-pass filter instance
fir_filter #(
    '{-12'sd138, -12'sd152, -12'sd187, -12'sd232, -12'sd266, -12'sd267, -12'sd214, -12'sd91, 12'sd109, 12'sd380, 12'sd706, 12'sd1059, 12'sd1404, 12'sd1705, 12'sd1928, 12'sd2047, 12'sd2047, 12'sd1928, 12'sd1705, 12'sd1404, 12'sd1059, 12'sd706, 12'sd380, 12'sd109, -12'sd91, -12'sd214, -12'sd267, -12'sd266, -12'sd232, -12'sd187, -12'sd152, -12'sd138}
) band_1k_2k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_1k_2k)
);


    // 2–4 kHz band-pass filter instance
fir_filter #(
    '{12'sd72, 12'sd77, 12'sd75, 12'sd40, -12'sd61, -12'sd247, -12'sd505, -12'sd779, -12'sd980, -12'sd1008, -12'sd791, -12'sd317, 12'sd350, 12'sd1076, 12'sd1693, 12'sd2047, 12'sd2047, 12'sd1693, 12'sd1076, 12'sd350, -12'sd317, -12'sd791, -12'sd1008, -12'sd980, -12'sd779, -12'sd505, -12'sd247, -12'sd61, 12'sd40, 12'sd75, 12'sd77, 12'sd72}
) band_2k_4k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_2k_4k)
);


    // 4–8 kHz band-pass filter instance
fir_filter #(
    '{-12'sd33, -12'sd13, 12'sd10, 12'sd13, -12'sd20, -12'sd36, 12'sd79, 12'sd345, 12'sd545, 12'sd325, -12'sd436, -12'sd1326, -12'sd1584, -12'sd747, 12'sd813, 12'sd2047, 12'sd2047, 12'sd813, -12'sd747, -12'sd1584, -12'sd1326, -12'sd436, 12'sd325, 12'sd545, 12'sd345, 12'sd79, -12'sd36, -12'sd20, 12'sd13, 12'sd10, -12'sd13, -12'sd33}
) band_4k_8k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_4k_8k)
);


    // 8–16 kHz band-pass filter instance
fir_filter #(
    '{12'sd19, -12'sd24, -12'sd25, 12'sd13, -12'sd20, 12'sd79, 12'sd153, -12'sd212, -12'sd211, 12'sd103, -12'sd139, 12'sd511, 12'sd972, -12'sd1443, -12'sd1830, 12'sd2047, 12'sd2047, -12'sd1830, -12'sd1443, 12'sd972, 12'sd511, -12'sd139, 12'sd103, -12'sd211, -12'sd212, 12'sd153, 12'sd79, -12'sd20, 12'sd13, -12'sd25, -12'sd24, 12'sd19}
) band_8k_16k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_band_8k_16k)
);


// High-pass filter instance (31 taps, Q1.11 coefficients embedded)
fir_filter #(
    '{12'sd0, 12'sd0, 12'sd10, -12'sd16, -12'sd1, 12'sd35, -12'sd53, 12'sd0, 12'sd104, -12'sd143, -12'sd1, 12'sd260, -12'sd359, 12'sd0, 12'sd812, -12'sd1676, 12'sd2047, -12'sd1676, 12'sd812, 12'sd0, -12'sd359, 12'sd260, -12'sd1, -12'sd143, 12'sd104, 12'sd0, -12'sd53, 12'sd35, -12'sd1, -12'sd16, 12'sd10, 12'sd0}
) highpass_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .audio_in   (audio_in),
    .audio_out  (output_highpass)
);


endmodule
