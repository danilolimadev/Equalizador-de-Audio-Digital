`timescale 1ns/1ps

module tb_reg_map;

  reg clk, rst_n, we;
  reg [7:0] addr, data_in;

  wire [7:0] gain_1, gain_2, gain_3, gain_4, gain_5, gain_6, gain_7, gain_8, gain_9, gain_10;

  reg_map uut (
    .clk(clk),
    .rst_n(rst_n),
    .we(we),
    .addr(addr),
    .data_in(data_in),
    .gain_1(gain_1),
    .gain_2(gain_2),
    .gain_3(gain_3),
    .gain_4(gain_4),
    .gain_5(gain_5),
    .gain_6(gain_6),
    .gain_7(gain_7),
    .gain_8(gain_8),
    .gain_9(gain_9),
    .gain_10(gain_10)
  );

  // Clock 50 MHz
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  integer i;

  initial begin

    clk = 0;
    rst_n = 0;
    we = 0;
    addr = 0;
    data_in = 0;

    // Reset
    #20;
    rst_n = 1;

    // Escreve nos registradores 
    for (i = 0; i < 10; i = i + 1) begin
      @(posedge clk);
      we <= 1;
      addr <= i;
      data_in <= i * 2; 
    end

    // Desabilita escrita
    @(posedge clk);
    we <= 0;

    // Espera 1 ciclo e mostra os resultados
    @(posedge clk);
    $display("Ganhos:");
    $display("gain_1  = %h", gain_1);
    $display("gain_2  = %h", gain_2);
    $display("gain_3  = %h", gain_3);
    $display("gain_4  = %h", gain_4);
    $display("gain_5  = %h", gain_5);
    $display("gain_6  = %h", gain_6);
    $display("gain_7  = %h", gain_7);
    $display("gain_8  = %h", gain_8);
    $display("gain_9  = %h", gain_9);
    $display("gain_10 = %h", gain_10);

    #20 
    $stop;

  end

endmodule
