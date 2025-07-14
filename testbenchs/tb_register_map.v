`timescale 1ns / 1ps

module tb_reg_map_simple_assign();

    // Parâmetros
    parameter GAIN_WIDTH = 24;

    // Entradas
    reg clk;
    reg rst;
    reg we;
    reg [7:0] addr;
    reg [7:0] data_in;

    // Saídas
    wire [7:0] configuration;
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
        .configuration(configuration),
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

        // Reset
        #12 rst = 1;

        // Escrever valor de configuração (regbank[0] = 8'hAA)
        write(0, 8'hAA);

        // Banda 1 = 0x000000
        write(1, 8'h00); write(2, 8'h00); write(3, 8'h00);
        // Banda 2 = 0x1C71C7
        write(4, 8'hC7); write(5, 8'h71); write(6, 8'h1C);
        // Banda 3 = 0x38E38E
        write(7, 8'h8E); write(8, 8'hE3); write(9, 8'h38);
        // Banda 4 = 0x553F55
        write(10, 8'h55); write(11, 8'h3F); write(12, 8'h55);
        // Banda 5 = 0x71AB1E
        write(13, 8'h1E); write(14, 8'hAB); write(15, 8'h71);
        // Banda 6 = 0x8E16E6
        write(16, 8'hE6); write(17, 8'h16); write(18, 8'h8E);
        // Banda 7 = 0xAA82AF
        write(19, 8'hAF); write(20, 8'h82); write(21, 8'hAA);
        // Banda 8 = 0xC6EE78
        write(22, 8'h78); write(23, 8'hEE); write(24, 8'hC6);
        // Banda 9 = 0xE35A41
        write(25, 8'h41); write(26, 8'h5A); write(27, 8'hE3);
        // Banda 10 = 0xFFFFFF
        write(28, 8'hFF); write(29, 8'hFF); write(30, 8'hFF);

        // Esperar propagação
        #10;

        // Verificar no terminal
        $display("CONFIGURATION = 0x%h", configuration);
        $display("GAIN_1        = %0d", gain_1);
        $display("GAIN_2        = %0d", gain_2);
        $display("GAIN_3        = %0d", gain_3);
        $display("GAIN_4        = %0d", gain_4);
        $display("GAIN_5        = %0d", gain_5);
        $display("GAIN_6        = %0d", gain_6);
        $display("GAIN_7        = %0d", gain_7);
        $display("GAIN_8        = %0d", gain_8);
        $display("GAIN_9        = %0d", gain_9);
        $display("GAIN_10       = %0d", gain_10);

        // Esperar e encerrar
        #20;
        $stop;
    end

    // Tarefa para escrever no regbank
    task write(input [ADDR_WIDTH-1:0] a, input [7:0] d);
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
