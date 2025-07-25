module fir_filter#(
    parameter signed [11:0] COEFFS [0:31]
  )(
    input rst_n,
    input clk,
    input [23:0] audio_in,
    output [23:0] audio_out
  );

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
  for (j = 0; j < 32; j = j + 1)
  begin
    assign products[j] = delay_line[j] * COEFFS[j];
  end

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
  assign audio_out = final_sum[38:14]; // Output the lower 24 bits

endmodule
