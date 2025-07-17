`timescale 1ns / 1ps

module tb_equalizer();
    reg clk;
    reg rst_n;
    reg we;
    reg [7:0] addr;
    reg [7:0] data_in;
    reg signed [23:0] audio_in;
    wire [23:0] audio_out;

    equalizer inst (
        .clk(clk),
        .rst_n(rst_n),
        .audio_in(audio_in),
        .audio_out(audio_out),
        .data_in(data_in),
        .we(we),
        .addr(addr)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        we = 0;
        addr = 0;
        audio_in = 0;
        data_in = 0;
        
        #20;
        rst_n = 1;
        #20;
        
        we = 1;
        // ganho máximo +16
        @(posedge clk);
        addr = 1;  data_in = 8'h10; // byte menos signficativo
        @(posedge clk);
        addr = 2;  data_in = 8'h00; 
        @(posedge clk);
        addr = 3;  data_in = 8'h00; // byte mais signficativo 

        // ganho minimo -16
        @(posedge clk);
        addr = 4;  data_in = 8'hF0; // byte menos signficativo
        @(posedge clk);
        addr = 5;  data_in = 8'hFF; 
        @(posedge clk);
        addr = 6;  data_in = 8'hFF; // byte mais signficativo 

        @(posedge clk);
        we = 0;
        @(posedge clk);

        // entrada de audio 
        repeat (100) begin
            @(posedge clk);
            audio_in = audio_in + 24'sd500;
        end
    end

endmodule

