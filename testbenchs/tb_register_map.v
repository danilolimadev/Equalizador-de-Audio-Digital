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
        write(9, 8'd34);

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
