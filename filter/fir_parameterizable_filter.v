module fir_parameterizable_filter #(
    parameter integer N = 31,                               // Número de taps
    parameter signed [11:0] COEFFS [0:N-1] = '{default:12'sd0} // Coeficientes Q1.11
)(
    input  wire                 clk,         // Clock do sistema
    input  wire                 rst_n,       // Reset ativo baixo
    input  wire                 enable,      // Habilita o filtro
    input  wire signed [23:0]   audio_in,    // Entrada de áudio (24 bits)
    output reg  signed [23:0]   audio_out    // Saída filtrada (24 bits)
);

    integer i;

    // Delay line para armazenar N amostras anteriores
    reg signed [23:0] delay_line [0:N-1];

    // Acumulador intermediário combinacional (MAC)
    reg signed [40:0] accumulator_next;

    // Lógica combinacional para calcular o resultado do filtro
    always @(*) begin
        accumulator_next = 41'sd0;
        for (i = 0; i < N; i = i + 1)
            accumulator_next = accumulator_next + delay_line[i] * COEFFS[i];
    end

    // Lógica sequencial para deslocamento das amostras e registro da saída
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < N; i = i + 1)
                delay_line[i] <= 24'sd0;

            audio_out <= 24'sd0;
        end else if (enable) begin
            // Desloca as amostras na linha de atraso
            for (i = N-1; i > 0; i = i - 1)
                delay_line[i] <= delay_line[i-1];

            delay_line[0] <= audio_in;

            // Saída ajustada do acumulador (descarta 17 bits fracionários)
            audio_out <= accumulator_next[40:17];
        end
    end

endmodule
