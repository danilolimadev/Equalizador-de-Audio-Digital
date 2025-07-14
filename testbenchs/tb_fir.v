`timescale 1ns/100ps

module tb_fir_lpf;

   localparam N = 255;

   reg                 i_clk;
   reg                 i_rst_n;
   reg                 i_en;
   reg  signed [23:0]  i_data;
   wire signed [23:0]  o_data;

   fir_lpf #(.N(N)) dut (
      .i_clk   (i_clk),
      .i_rst_n (i_rst_n),
      .i_en    (i_en),
      .i_data  (i_data),
      .o_data  (o_data)
   );

   initial begin
      i_clk = 1'b0;
      forever #5 i_clk = ~i_clk; // clk 10ns
   end

   integer k;

   initial begin
      i_en    = 1'b0;
      i_data  = 24'sd0;
      i_rst_n = 1'b0;

      // Mantém reset por algumas bordas
      repeat (5) @(posedge i_clk);
      i_rst_n = 1'b1;

      // Aguarda duas bordas para estabilidade
      repeat (2) @(posedge i_clk);

      // Ativa o filtro
      i_en = 1'b1;

      // Impulso unitario
      i_data = 24'sd1 <<< 15;
      @(posedge i_clk);

      // Demais amostras = 0
      i_data = 24'sd0;

      // Captura resposta por alguns ciclos além de N
      for (k = 0; k < N + 10; k = k + 1)
         @(posedge i_clk);

      // Fim de simulação
      $stop;
   end

endmodule
