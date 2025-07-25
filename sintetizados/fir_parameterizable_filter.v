
module fir_parameterizable_filter #(
    parameter integer N = 31,
parameter signed /*[11:0]*/ COEFFS /*[0:30]*/ = ({
        12'sd0, 12'sd0, 12'sd0, 12'sd0, 12'sd0,
        12'sd0, 12'sd0, 12'sd0, 12'sd0, 12'sd0,
        12'sd0, 12'sd0, 12'sd0, 12'sd0, 12'sd0,
        12'sd0, 12'sd0, 12'sd0, 12'sd0, 12'sd0,
        12'sd0, 12'sd0, 12'sd0, 12'sd0, 12'sd0,
        12'sd0, 12'sd0, 12'sd0, 12'sd0, 12'sd0
    })
)(
    input  wire                clk,
    input  wire                rst_n,
    input  wire                enable,
    input  wire signed [23:0]  audio_in,
    output reg  signed [23:0]  audio_out
);

    reg signed [23:0] delay_line [0:N-1];
    integer i;

    // Pipeline registers para somatório parcial
    reg signed [40:0] accumulator_stage [0:N]; // N+1 estágios: de 0 a N

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < N; i = i + 1)
                delay_line[i] <= 24'sd0;
            for (i = 0; i <= N; i = i + 1)
                accumulator_stage[i] <= 41'sd0;
            audio_out <= 24'sd0;
        end else if (enable) begin
            // Shift delay line
            for (i = N-1; i > 0; i = i - 1)
                delay_line[i] <= delay_line[i-1];
            delay_line[0] <= audio_in;

            // Pipeline soma MAC:
            // Inicializa estágio 0 com zero
            accumulator_stage[0] <= 41'sd0;

            // Para cada estágio, soma delay_line[i]*coeff[i] + resultado do estágio anterior
            // Esse processo leva N clocks para completar o resultado final.
            for (i = 0; i < N; i = i + 1) begin
                accumulator_stage[i+1] <= accumulator_stage[i] + delay_line[i] * COEFFS[i];
            end

            // Atualiza saída com valor do último estágio (pipeline completo)
            audio_out <= accumulator_stage[N][40:17]; // Ajusta ponto fixo, descarta 11 bits fracionários
        end
    end

endmodule



