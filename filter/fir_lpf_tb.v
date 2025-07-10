`timescale 1ns / 100ps

module fir_lpf_tb;
    reg                clk;
    reg                rst_n;
    reg                en;
    reg signed  [23:0] in_data;
    wire signed [23:0] out_data;

    // filtro do lowpass
    fir_lpf uut (
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_en(en),
        .i_data(in_data),
        .o_data(out_data)
    );

    // clock
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz
    end

    initial begin
        $display("Carregando coeficientes FIR...");
    end


    // Estímulos
    initial begin
        rst_n = 0;
        en = 0;
        in_data = 0;
        #25;
        rst_n = 1;
        en = 1;

        // Impulso
        in_data = 24'sd32768; // valor qqr pra teste
        #20;
        in_data = 24'sd0;

        // Aguarda respostas do filtro
        repeat (300) @(posedge clk);

        $stop;
    end

endmodule
