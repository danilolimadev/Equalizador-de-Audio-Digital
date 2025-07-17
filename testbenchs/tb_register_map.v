`timescale 1ns / 1ps

module tb_reg_map_simple_assign();

    // Parâmetros
    parameter GAIN_WIDTH = 13; //Q5.8

    // Entradas
    reg clk;
    reg rst;
    reg we;
    reg [7:0] addr;
    reg [7:0] data_in;

    // Saídas
    wire [GAIN_WIDTH-1:0] gain_1;
    wire [GAIN_WIDTH-1:0] gain_2;
    wire [GAIN_WIDTH-1:0] gain_3;
    wire [GAIN_WIDTH-1:0] gain_4;
    wire [GAIN_WIDTH-1:0] gain_5;
    wire [GAIN_WIDTH-1:0] gain_6;
    wire [GAIN_WIDTH-1:0] gain_7;
    wire [GAIN_WIDTH-1:0] gain_8;
    wire [GAIN_WIDTH-1:0] gain_9;
    wire [GAIN_WIDTH-1:0] gain_10;

    // Instanciação do módulo
    reg_map dut (
        .clk(clk),
        .rst(rst),
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

    // Clock: 
    // Período = 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Inicialização
        rst = 0;
        we = 0;
        addr = 0;
        data_in = 0;
        #12 rst = 1;

        //Banda 1 
        write(0, 8'd1);
        //Banda 2 
        write(1, 8'd5);
        //Banda 3 
        write(2, 8'd9);
        //Banda 4 
        write(3, 8'd13);
        //Banda 5 
        write(4, 8'd17);
        //Banda 6
        write(5, 8'd21);
        //Banda 7
        write(6, 8'd25);
        //Banda 8
        write(7, 8'd29);
        //Banda 9
        write(8, 8'd32);
        //Banda 10 
        write(9, 8'd33);

        // Esperar propagação
        #10;

       // Exibir ganhos Q5.8 com separação de parte inteira e fracionária
      $display("GAIN_1   = %05b_%08b", gain_1[12:8], gain_1[7:0]);
      $display("GAIN_2   = %05b_%08b", gain_2[12:8], gain_2[7:0]);
      $display("GAIN_3   = %05b_%08b", gain_3[12:8], gain_3[7:0]);
      $display("GAIN_4   = %05b_%08b", gain_4[12:8], gain_4[7:0]);
      $display("GAIN_5   = %05b_%08b", gain_5[12:8], gain_5[7:0]);
      $display("GAIN_6   = %05b_%08b", gain_6[12:8], gain_6[7:0]);
      $display("GAIN_7   = %05b_%08b", gain_7[12:8], gain_7[7:0]);
      $display("GAIN_8   = %05b_%08b", gain_8[12:8], gain_8[7:0]);
      $display("GAIN_9   = %05b_%08b", gain_9[12:8], gain_9[7:0]);
      $display("GAIN_10  = %05b_%08b", gain_10[12:8], gain_10[7:0]);

        #20;
        $stop;
    end

    // Tarefa para escrever no regbank
    task write(input [7:0] a, input [7:0] d);
        begin
            @(posedge clk);
            addr = a;
            data_in = d;
            we = 1;
            @(posedge clk);
            we = 0;
        end
    endtask

endmodule
