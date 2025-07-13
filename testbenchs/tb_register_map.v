`timescale 1ns / 1ps

module tb_reg_map_simple_assign();

    // Parâmetros
    parameter GAIN_WIDTH = 24;
    parameter ADDR_WIDTH = 31;

    // Entradas
    reg clk;
    reg rst;
    reg we;
    reg [ADDR_WIDTH-1:0] addr;
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

        // Banda 1 = -24 dB → 0xFFFEA0
        write(1, 8'hA0);  // LSB
        write(2, 8'hFE);  // MID
        write(3, 8'hFF);  // MSB

        // Banda 2 = -19 dB → 0xFFFECF
        write(4, 8'hD3);
        write(5, 8'hEC);
        write(6, 8'hFF);

        // Banda 3 = -14 dB → 0xFFFF1E
        write(7, 8'hE2);
        write(8, 8'hF1);
        write(9, 8'hFF);

        // Banda 4 = -9 dB → 0xFFFFA7
        write(10, 8'h97);
        write(11, 8'hFA);
        write(12, 8'hFF);

        // Banda 5 = -4 dB → 0xFFFFFC
        write(13, 8'hFC);
        write(14, 8'hFF);
        write(15, 8'hFF);

        // Banda 6 = +1 dB → 0x000001
        write(16, 8'h01);
        write(17, 8'h00);
        write(18, 8'h00);

        // Banda 7 = +6 dB → 0x000006
        write(19, 8'h06);
        write(20, 8'h00);
        write(21, 8'h00);

        // Banda 8 = +11 dB → 0x00000B
        write(22, 8'h0B);
        write(23, 8'h00);
        write(24, 8'h00);

        // Banda 9 = +16 dB → 0x000010
        write(25, 8'h10);
        write(26, 8'h00);
        write(27, 8'h00);

        // Banda 10 = +21 dB → 0x000015
        write(28, 8'h15);
        write(29, 8'h00);
        write(30, 8'h00);


        // Esperar propagação
        #10;

        // Verificar no terminal
        $display("CONFIGURATION = 0x%h", configuration);
        $display("GAIN_1        = %0d", $signed(gain_1));
        $display("GAIN_2        = %0d", $signed(gain_2));
        $display("GAIN_3        = %0d", $signed(gain_3));
        $display("GAIN_4        = %0d", $signed(gain_4));
        $display("GAIN_5        = %0d", $signed(gain_5));
        $display("GAIN_6        = %0d", $signed(gain_6));
        $display("GAIN_7        = %0d", $signed(gain_7));
        $display("GAIN_8        = %0d", $signed(gain_8));
        $display("GAIN_9        = %0d", $signed(gain_9));
        $display("GAIN_10       = %0d", $signed(gain_10));

        // Esperar e encerrar
        #20;
        $finish;
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
