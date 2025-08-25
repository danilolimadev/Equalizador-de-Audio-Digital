module fir_filter#(
    //parameter signed [11:0] COEFFS [0:31]
    parameter signed [11:0] COEFF_00 = 0, parameter signed [11:0] COEFF_01 = 0,
    parameter signed [11:0] COEFF_02 = 0, parameter signed [11:0] COEFF_03 = 0,
    parameter signed [11:0] COEFF_04 = 0, parameter signed [11:0] COEFF_05 = 0,
    parameter signed [11:0] COEFF_06 = 0, parameter signed [11:0] COEFF_07 = 0,
    parameter signed [11:0] COEFF_08 = 0, parameter signed [11:0] COEFF_09 = 0,
    parameter signed [11:0] COEFF_10 = 0, parameter signed [11:0] COEFF_11 = 0,
    parameter signed [11:0] COEFF_12 = 0, parameter signed [11:0] COEFF_13 = 0,
    parameter signed [11:0] COEFF_14 = 0, parameter signed [11:0] COEFF_15 = 0,
    parameter signed [11:0] COEFF_16 = 0, parameter signed [11:0] COEFF_17 = 0,
    parameter signed [11:0] COEFF_18 = 0, parameter signed [11:0] COEFF_19 = 0,
    parameter signed [11:0] COEFF_20 = 0, parameter signed [11:0] COEFF_21 = 0,
    parameter signed [11:0] COEFF_22 = 0, parameter signed [11:0] COEFF_23 = 0,
    parameter signed [11:0] COEFF_24 = 0, parameter signed [11:0] COEFF_25 = 0,
    parameter signed [11:0] COEFF_26 = 0, parameter signed [11:0] COEFF_27 = 0,
    parameter signed [11:0] COEFF_28 = 0, parameter signed [11:0] COEFF_29 = 0,
    parameter signed [11:0] COEFF_30 = 0, parameter signed [11:0] COEFF_31 = 0
  )(

    input rst_n,
    input clk,
    input [23:0] audio_in,
    output [23:0] audio_out
  );


  wire signed [11:0] COEFFS [0:31];
  assign COEFFS[0] = COEFF_00;
  assign COEFFS[1] = COEFF_01;
  assign COEFFS[2] = COEFF_02;
  assign COEFFS[3] = COEFF_03;
  assign COEFFS[4] = COEFF_04;
  assign COEFFS[5] = COEFF_05;
  assign COEFFS[6] = COEFF_06;
  assign COEFFS[7] = COEFF_07;
  assign COEFFS[8] = COEFF_08;
  assign COEFFS[9] = COEFF_09;
  assign COEFFS[10] = COEFF_10;
  assign COEFFS[11] = COEFF_11;
  assign COEFFS[12] = COEFF_12;
  assign COEFFS[13] = COEFF_13;
  assign COEFFS[14] = COEFF_14;
  assign COEFFS[15] = COEFF_15;
  assign COEFFS[16] = COEFF_16;
  assign COEFFS[17] = COEFF_17;
  assign COEFFS[18] = COEFF_18;
  assign COEFFS[19] = COEFF_19;
  assign COEFFS[20] = COEFF_20;
  assign COEFFS[21] = COEFF_21;
  assign COEFFS[22] = COEFF_22;
  assign COEFFS[23] = COEFF_23;
  assign COEFFS[24] = COEFF_24;
  assign COEFFS[25] = COEFF_25;
  assign COEFFS[26] = COEFF_26;
  assign COEFFS[27] = COEFF_27;
  assign COEFFS[28] = COEFF_28;
  assign COEFFS[29] = COEFF_29;
  assign COEFFS[30] = COEFF_30;
  assign COEFFS[31] = COEFF_31;


  reg signed [23:0] delay_line [0:31];
  wire signed [35:0] products [0:31];

  // Initialize the delay line
  integer i;
  always @(posedge clk)
  begin
    for (i = 31; i > 0; i = i - 1)
    begin
      delay_line[i] <= delay_line[i-1];
    end
    delay_line[0] <= audio_in;
  end

  // Calculate products of coefficients and delay line values
  genvar j;
  generate
    for (j = 0; j < 32; j = j + 1)
    begin : product_block
      assign products[j] = delay_line[j] * COEFFS[j];
    end
  endgenerate

  // First stage of summation
  wire signed [36:0] sum_stage1_0, sum_stage1_1, sum_stage1_2, sum_stage1_3, sum_stage1_4, sum_stage1_5, sum_stage1_6, sum_stage1_7, sum_stage1_8, sum_stage1_9, sum_stage1_10, sum_stage1_11, sum_stage1_12, sum_stage1_13, sum_stage1_14, sum_stage1_15;
  assign sum_stage1_0 = products[0] + products[1];
  assign sum_stage1_1 = products[2] + products[3];
  assign sum_stage1_2 = products[4] + products[5];
  assign sum_stage1_3 = products[6] + products[7];
  assign sum_stage1_4 = products[8] + products[9];
  assign sum_stage1_5 = products[10] + products[11];
  assign sum_stage1_6 = products[12] + products[13];
  assign sum_stage1_7 = products[14] + products[15];
  assign sum_stage1_8 = products[16] + products[17];
  assign sum_stage1_9 = products[18] + products[19];
  assign sum_stage1_10 = products[20] + products[21];
  assign sum_stage1_11 = products[22] + products[23];
  assign sum_stage1_12 = products[24] + products[25];
  assign sum_stage1_13 = products[26] + products[27];
  assign sum_stage1_14 = products[28] + products[29];
  assign sum_stage1_15 = products[30] + products[31];

  // Second stage of summation
  wire signed [37:0] sum_stage2_0, sum_stage2_1, sum_stage2_2, sum_stage2_3, sum_stage2_4, sum_stage2_5, sum_stage2_6, sum_stage2_7;
  assign sum_stage2_0 = sum_stage1_0 + sum_stage1_1;
  assign sum_stage2_1 = sum_stage1_2 + sum_stage1_3;
  assign sum_stage2_2 = sum_stage1_4 + sum_stage1_5;
  assign sum_stage2_3 = sum_stage1_6 + sum_stage1_7;
  assign sum_stage2_4 = sum_stage1_8 + sum_stage1_9;
  assign sum_stage2_5 = sum_stage1_10 + sum_stage1_11;
  assign sum_stage2_6 = sum_stage1_12 + sum_stage1_13;
  assign sum_stage2_7 = sum_stage1_14 + sum_stage1_15;

  // Third stage of summation
  wire signed [38:0] sum_stage3_0, sum_stage3_1, sum_stage3_2, sum_stage3_3;
  assign sum_stage3_0 = sum_stage2_0 + sum_stage2_1;
  assign sum_stage3_1 = sum_stage2_2 + sum_stage2_3;
  assign sum_stage3_2 = sum_stage2_4 + sum_stage2_5;
  assign sum_stage3_3 = sum_stage2_6 + sum_stage2_7;

  // Fourth stage of summation
  wire signed [39:0] sum_stage4_0, sum_stage4_1;
  assign sum_stage4_0 = sum_stage3_0 + sum_stage3_1;
  assign sum_stage4_1 = sum_stage3_2 + sum_stage3_3;

  // Final summation
  reg signed [40:0] final_sum;
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      final_sum <= 0;
    end
    else
    begin
      final_sum <= sum_stage4_0 + sum_stage4_1;
    end
  end

  // Output the final result, truncating to 24 bits
  assign audio_out = final_sum[38:15]; // Output the lower 24 bits

endmodule
