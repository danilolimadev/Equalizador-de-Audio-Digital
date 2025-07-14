`timescale 1ns / 1ps

module tb_equalizer();
    reg clk;
    reg rst_n;
    reg signed [23:0] audio_in;
    wire signed [23:0] audio_out;

    equalizer inst (
        .clk(clk),
        .rst_n(rst_n),
        .audio_in(audio_in),
        .audio_out(audio_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        audio_in = 24'h000000;
        
        #20;
        rst_n = 1;
        
        // espera para os filtros estabilizarem
        #50;

        // teste 1: 0
        audio_in = 24'h000000; #50;
        
        // teste 2: +0.125
        audio_in = 24'sh100000; #50;

        // teste 3: +0.5
        audio_in = 24'sh400000; #50;

        // teste 4: +1.0
        audio_in = 24'sh800000; #50;

        // teste 5: -0.125
        audio_in = 24'shF00000; #50;

        // teste 6: -0.5
        audio_in = 24'shC00000; #50;
        
        // teste 7: -1.0
        audio_in = 24'sh800000; #50;

end
    
endmodule