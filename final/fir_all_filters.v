module fir_all_filters (
    input  wire                clk,                  // system clock
    input  wire                rst_n,              // active-low reset
    input  wire                enable,               // global filter enable
    input  wire signed [23:0]  audio_in,         // 24-bit input sample

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
fir_parameterizable_filter #(
  .N(31),
  .COEFFS('{
    12'sh0a3, 12'sh0b7, 12'shf4, 12'sh157, 12'sh1da, 
    12'sh279, 12'sh32d, 12'sh3ee, 12'sh4b3, 12'sh573, 
    12'sh627, 12'shc67, 12'sh74a, 12'sh7ad, 12'sh7ea, 
    12'sh7ff, 12'sh7ea, 12'sh7ad, 12'sh74a, 12'shc67, 
    12'sh627, 12'sh573, 12'sh4b3, 12'sh3ee, 12'sh32d, 
    12'sh279, 12'sh1da, 12'sh157, 12'shf4, 12'sh0b7, 
    12'sh0a3
  })
) lowpass_filter (
  .clk      (clk),
  .rst_n    (rst_n),
  .enable   (enable),
  .audio_in (audio_in),
  .audio_out(output_lowpass)
);


// 64–125 Hz band-pass filter instance (31 taps, Q1.11 coefficients embutidos)
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'sh0a0, 12'sh0b5, 12'shf1, 12'sh153,
        12'sh1d6, 12'sh275, 12'sh329, 12'sh3e9,
        12'sh4af, 12'sh570, 12'sh625, 12'sh6c5,
        12'sh749, 12'sh7ac, 12'sh7ea, 12'sh7ff,
        12'sh7ea, 12'sh7ac, 12'sh749, 12'sh6c5,
        12'sh625, 12'sh570, 12'sh4af, 12'sh3e9,
        12'sh329, 12'sh275, 12'sh1d6, 12'sh153,
        12'shf1, 12'sh0b5, 12'sh0a0
    })
) band_64_125_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_64_125)
);


    // 125–250 Hz band-pass filter instance
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'sh098, 12'sh0ad, 12'sh0e8, 12'sh148,
        12'sh1c9, 12'sh266, 12'sh319, 12'sh3da,
        12'sh4a1, 12'sh564, 12'sh61b, 12'sh6be,
        12'sh745, 12'sh7ab, 12'sh7e9, 12'sh7ff,
        12'sh7e9, 12'sh7ab, 12'sh745, 12'sh6be,
        12'sh61b, 12'sh564, 12'sh4a1, 12'sh3da,
        12'sh319, 12'sh266, 12'sh1c9, 12'sh148,
        12'sh0e8, 12'sh0ad, 12'sh098
    })
) band_125_250_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_125_250)
);



    // 250–500 Hz band-pass filter instance
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'sh078, 12'sh08d, 12'sh0c3, 12'sh11b,
        12'sh195, 12'sh22d, 12'sh2dd, 12'sh39f,
        12'sh46a, 12'sh536, 12'sh5f7, 12'sh6a4,
        12'sh736, 12'sh7a3, 12'sh7e7, 12'sh7ff,
        12'sh7e7, 12'sh7a3, 12'sh736, 12'sh6a4,
        12'sh5f7, 12'sh536, 12'sh46a, 12'sh39f,
        12'sh2dd, 12'sh22d, 12'sh195, 12'sh11b,
        12'sh0c3, 12'sh08d, 12'sh078
    })
) band_250_500_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_250_500)
);


    // 500 Hz–1 kHz band-pass filter instance
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'sh00f, 12'sh022, 12'sh045, 12'sh080,
        12'sh0db, 12'sh15a, 12'sh1fd, 12'sh2bf,
        12'sh39a, 12'sh481, 12'sh567, 12'sh63e,
        12'sh6f7, 12'sh786, 12'sh7e0, 12'sh7ff,
        12'sh7e0, 12'sh786, 12'sh6f7, 12'sh63e,
        12'sh567, 12'sh481, 12'sh39a, 12'sh2bf,
        12'sh1fd, 12'sh15a, 12'sh0db, 12'sh080,
        12'sh045, 12'sh022, 12'sh00f
    })
) band_500_1k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_500_1k)
);


    // 1–2 kHz band-pass filter instance
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'shf77,  12'shf6c,  12'shf4b,  12'shf25,
        12'shf0e,  12'shf1e,  12'shf6a,  12'sh000,
        12'sh0e2,  12'sh208,  12'sh35c,  12'sh4bd,
        12'sh606,  12'sh712,  12'sh7c2,  12'sh7ff,
        12'sh7c2,  12'sh712,  12'sh606,  12'sh4bd,
        12'sh35c,  12'sh208,  12'sh0e2,  12'sh000,
        12'shf6a,  12'shf1e,  12'shf0e,  12'shf25,
        12'shf4b,  12'shf6c,  12'shf77
    })
) band_1k_2k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_1k_2k)
);


    // 2–4 kHz band-pass filter instance
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'sh047, 12'sh044, 12'sh036, 12'shfff,
        12'shf82, 12'sheb4, 12'shdb1, 12'shcbf,
        12'shc3d, 12'shc87, 12'shdce, 12'sh000,
        12'sh2b8, 12'sh55e, 12'sh74a, 12'sh7ff,
        12'sh74a, 12'sh55e, 12'sh2b8, 12'sh000,
        12'shdce, 12'shc87, 12'shc3d, 12'shcbf,
        12'shdb1, 12'sheb4, 12'shf82, 12'shfff,
        12'sh036, 12'sh044, 12'sh047
    })
) band_2k_4k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_2k_4k)
);


    // 4–8 kHz band-pass filter instance
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'shfeb, 12'sh000, 12'sh00d, 12'shfff,
        12'shfe1, 12'sh000, 12'sh0ac, 12'sh1a0,
        12'sh1c0, 12'shfff, 12'shcc9, 12'sha64,
        12'shb5b, 12'sh000, 12'sh588, 12'sh7ff,
        12'sh588, 12'sh000, 12'shb5b, 12'sha64,
        12'shcc9, 12'shfff, 12'sh1c0, 12'sh1a0,
        12'sh0ac, 12'sh000, 12'shfe1, 12'shfff,
        12'sh00d, 12'sh000, 12'shfeb
    })
) band_4k_8k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_4k_8k)
);


    // 8–16 kHz band-pass filter instance
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'shfff, 12'shfea, 12'sh000, 12'shfff,
        12'sh000, 12'sh068, 12'shfff, 12'shf2f,
        12'sh000, 12'shfff, 12'sh000, 12'sh2cd,
        12'shfff, 12'sh9a6, 12'sh000, 12'sh7ff,
        12'sh000, 12'sh9a6, 12'shfff, 12'sh2cd,
        12'sh000, 12'shfff, 12'sh000, 12'shf2f,
        12'shfff, 12'sh068, 12'sh000, 12'shfff,
        12'sh000, 12'shfea, 12'shfff
    })
) band_8k_16k_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_band_8k_16k)
);


// High-pass filter instance (31 taps, Q1.11 coefficients embedded)
fir_parameterizable_filter #(
    .N      (31),
    .COEFFS ('{
        12'sh000, 12'sh00a, 12'shff0, 12'shfff,
        12'sh023, 12'shfcb, 12'sh000, 12'sh068,
        12'shf71, 12'shfff, 12'sh104, 12'she99,
        12'sh000, 12'sh32c, 12'sh974, 12'sh7ff,
        12'sh974, 12'sh32c, 12'sh000, 12'she99,
        12'sh104, 12'shfff, 12'shf71, 12'sh068,
        12'sh000, 12'shfcb, 12'sh023, 12'shfff,
        12'shff0, 12'sh00a, 12'sh000
    })
) highpass_filter (
    .clk        (clk),
    .rst_n      (rst_n),
    .enable     (enable),
    .audio_in   (audio_in),
    .audio_out  (output_highpass)
);


endmodule
