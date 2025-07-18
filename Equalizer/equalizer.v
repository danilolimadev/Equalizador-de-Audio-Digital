module equalizer (
    input  signed [23:0] audio_in, 
    input clk, rst_n, 
    output [23:0] audio_out
);
    
    // Sinais de ganho das 10 faixas 
    // Banco de 10 registradores de 13 bits 
    wire [12:0] gain_1, gain_2, gain_3, gain_4, gain_5,
                gain_6, gain_7, gain_8, gain_9, gain_10;
    
    // Instancia o banco de registradores de 13 bits 
    reg_map regs_inst (
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

    // Instancia os filtros FIR para cada faixa, com apenas uma instância
    wire signed [23:0] o_lp, o_band_64_125, o_band_125_250, o_band_250_500, o_band_500_1k, o_band_1k_2k,
                        o_band_2k_4k, o_band_4k_8k, o_band_8k_16k, o_hp;

                        fir_all_filters inst_filter (
                        //     .i_clk(i_clk),
                        //     .i_rst_n(i_rst_n),
                        //     .i_en(i_en),
                            .i_data(audio_in),
                            .o_lp(o_lp),
                            .o_band_64_125(o_band_64_125),
                            .o_band_125_250(o_band_125_250),
                            .o_band_250_500(o_band_250_500),
                            .o_band_500_1k(o_band_500_1k),
                            .o_band_1k_2k(o_band_1k_2k),
                            .o_band_2k_4k(o_band_2k_4k),
                            .o_band_4k_8k(o_band_4k_8k),
                            .o_band_8k_16k(o_band_8k_16k),
                            .o_hp(o_hp)
                        );

    // Multiplicação dos filtros pelos ganhos
    wire signed [36:0] weighted_1, weighted_2, weighted_3, weighted_4, weighted_5,
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
    wire signed [40:0] sum_out;
    assign sum_out = weighted_1 + weighted_2 + weighted_3 + weighted_4 + weighted_5 +
                     weighted_6 + weighted_7 + weighted_8 + weighted_9 + weighted_10;

    // Truncamento para 24 bits
    assign audio_out = sum_out[39:16]; // Ajuste o truncamento conforme necessário  24bits
    // Depois é realizado o truncamento para voltar a ter 24 bits. audio_out[39:16]. 
    // 39 porque é desconsiderado o bit de sinal que é o bit 40. 
    // E 16 porque são desconsiderados os bits menos significativos (é um arredondamento do valor).

endmodule