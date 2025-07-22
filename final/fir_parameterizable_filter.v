module fir_parameterizable_filter #(
    // Parâmetros ajustados: 31 taps e coeficientes Q1.11 (default zeros)
    parameter integer N                    = 31,                // Número de taps
    parameter signed [11:0] COEFFS [0:N-1] = '{default:12'sd0} // Sobrepor na instância
)(
    input  wire                clk,                       // Clock do sistema
    input  wire                rst_n,                    // Reset ativo baixo
    input  wire                enable,                  // Habilita o filtro
    input  wire signed [23:0]  audio_in,               // Entrada de amostra (24 bits)
    output reg  signed [23:0]  audio_out              // Saída filtrada (24 bits)
);

    // Delay line de N amostras
    reg signed [23:0] delay_line  [0:N-1];

    // Acumulador: produto = 24 + 12 = 36 bits, acumula N => 36 + 5 = 41 bits
    reg signed [40:0] accumulator;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset: zera delay line e acumulador
            for (i = 0; i < N; i = i + 1) begin
                delay_line[i] = 24'sd0;
            end
            accumulator = 41'sd0;
            audio_out   = 24'sd0;

        end else if (enable) begin
            // Desloca a linha de atraso
            for (i = N-1; i > 0; i = i - 1) begin
                delay_line[i] = delay_line[i-1];
            end
            delay_line[0] = audio_in;

            // Computa MAC em loop serial usando coeficientes parâmetros
            accumulator = 41'sd0;
            for (i = 0; i < N; i = i + 1) begin
                accumulator = accumulator + delay_line[i] * COEFFS[i];
            end

            /*for (i = 0; i < N; i = i + 1) begin
                if(i==0)begin
                    accumulator = accumulator + delay_line[i] * 12'sd4095;
                end else begin
                    accumulator = accumulator + delay_line[i] * 12'sd0;
                end
            end*/

            // Ajuste de ponto fixo: descarta 11 bits fracionários => mantém 24 bits de saída
            audio_out = accumulator[40:17];
        end
    end

endmodule