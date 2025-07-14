module equalizer (
    input  wire [23:0] audio_in,
    input clk, rst_n, 
    output wire [23:0] audio_out
);
    // Sinais de controle para o banco de registradores
    wire we = 1'b0; // Por enquanto, sem escrita (apenas leitura)
    wire [30:0] addr = 31'd0; // Endereço 0
    wire [7:0] data_in = 8'd0; // Dados de entrada (não usado na leitura)
    wire [7:0] configuration;
    
    // Sinais de ganho das 10 faixas
    wire [23:0] gain_1, gain_2, gain_3, gain_4, gain_5,
                gain_6, gain_7, gain_8, gain_9, gain_10;
    
    // Instancia o banco de registradores
    reg_map regs_inst (
        .clk(clk),
        .rst(rst_n),
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

    // Instancia os filtros FIR para cada faixa
    wire signed [23:0] filter_out_1, filter_out_2, filter_out_3, filter_out_4, filter_out_5,
                        filter_out_6, filter_out_7, filter_out_8, filter_out_9, filter_out_10;
    
    // Filtro 1
    fir_lpf filer1_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_1));
    
    // Filtro 2
    fir_lpf filter2_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_2));
    
    // Filtro 3
    fir_lpf filter3_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_3));
    
    // Filtro 4
    fir_lpf filter4_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_4));
    
    // Filtro 5
    fir_lpf filter5_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_5));
    
    // Filtro 6
    fir_lpf filter6_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_6));
    
    // Filtro 7
    fir_lpf filter7_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_7));
    
    // Filtro 8
    fir_lpf filter8_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_8));
    
    // Filtro 9
    fir_lpf filter9_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_9));
    
    // Filtro 10
    fir_lpf filter10_inst (.i_clk(clk), .i_rst_n(rst_n), .i_en(1'b1), .i_data(audio_in), .o_data(filter_out_10));

    // Multiplicação dos filtros pelos ganhos
    //Utilizei a palavra weighted por ser mais profissional e clara para ponderado ~pesquisei~
    wire signed [47:0] weighted_1, weighted_2, weighted_3, weighted_4, weighted_5,
                        weighted_6, weighted_7, weighted_8, weighted_9, weighted_10;
    
    assign weighted_1 = filter_out_1 * gain_1;
    assign weighted_2 = filter_out_2 * gain_2;
    assign weighted_3 = filter_out_3 * gain_3;
    assign weighted_4 = filter_out_4 * gain_4;
    assign weighted_5 = filter_out_5 * gain_5;
    assign weighted_6 = filter_out_6 * gain_6;
    assign weighted_7 = filter_out_7 * gain_7;
    assign weighted_8 = filter_out_8 * gain_8;
    assign weighted_9 = filter_out_9 * gain_9;
    assign weighted_10 = filter_out_10 * gain_10;

    // Soma das saídas dos filtros
    wire signed [47:0] sum_out;
    assign sum_out = weighted_1 + weighted_2 + weighted_3 + weighted_4 + weighted_5 +
                     weighted_6 + weighted_7 + weighted_8 + weighted_9 + weighted_10;

    // Truncamento para 24 bits
    assign audio_out = sum_out[47:24]; // Ajuste o truncamento conforme necessário. 
    //Precisa-se verificar os valores mais importantes a serem truncados. 
    //Verificar bit [47] < por geralmente indicar sinal

endmodule