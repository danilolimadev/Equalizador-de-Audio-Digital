module fir_parameterizable_filter #(
    parameter integer N = 255,                // Número de taps
    parameter COEF_FILE = "coef.hex"          // Arquivo com coeficientes
)(
    input  wire                clk,           // Clock do sistema
    input  wire                rst_n,         // Reset ativo em 0
    input  wire                enable,        // Habilita o filtro
    input  wire signed [23:0]  audio_in,      // Entrada de amostra
    output reg  signed [23:0]  audio_out      // Saída filtrada
);

    // Coeficientes (Q1.15, signed)
    reg signed [15:0] coefficients [0:N-1];

    // Linha de atraso
    reg signed [23:0] delay_line [0:N-1];

    // Acumulador
    reg signed [47:0] accumulator;

    integer i;

    // Carrega coeficientes do arquivo na inicialização (para simulação)
    initial begin
        $readmemh(COEF_FILE, coefficients);
        //coefficients[0] = 17'sd32767; // 1.0 em Q1.15
        //for (i = 1; i < N; i = i + 1)
        //    coefficients[i] = 17'sd0;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset
            for (i = 0; i < N; i = i + 1)
                delay_line[i] = 24'sd0;
            accumulator = 48'sd0;
            audio_out   = 24'sd0;
        end else if (enable) begin
            // Desloca linha de atraso
            for (i = N-1; i > 0; i = i - 1)
                delay_line[i] = delay_line[i-1];
            delay_line[0] = audio_in;

            // Calcula MAC completo
            accumulator = 48'sd0;
            for (i = 0; i < N; i = i + 1)
                accumulator = accumulator + delay_line[i] * coefficients[i];

            // Ajuste de ponto fixo: pega os bits mais significativos
            audio_out = accumulator[47:24];
        end
    end

endmodule
