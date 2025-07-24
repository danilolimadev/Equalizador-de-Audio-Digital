module fir_parameterizable_filter #(
    parameter integer N = 31,
    parameter signed [11:0] COEFFS [0:N-1] = '{default:12'sd0}
)(
    input  wire                clk,
    input  wire                rst_n,
    input  wire                enable,
    input  wire signed [23:0]  audio_in,
    output reg  signed [23:0]  audio_out
);

    reg signed [23:0] delay_line [0:N-1];
    reg signed [40:0] accumulator_stage [0:N];
    integer i;

    // Controle de latência: contador para saber quando saída está válida
    reg [5:0] cycle_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < N; i = i + 1) delay_line[i] <= 24'sd0;
            for (i = 0; i <= N; i = i + 1) accumulator_stage[i] <= 41'sd0;
            audio_out <= 24'sd0;
            cycle_count <= 0;
        end else if (enable) begin
            // Atualiza linha de atraso
            for (i = N-1; i > 0; i = i - 1)
                delay_line[i] <= delay_line[i-1];
            delay_line[0] <= audio_in;

            // Pipeline de acumulação
            accumulator_stage[0] <= 41'sd0;
            for (i = 0; i < N; i = i + 1) begin
                accumulator_stage[i+1] <= accumulator_stage[i] + delay_line[i] * COEFFS[i];
            end

            // Contador para latência do filtro (N clocks)
            if (cycle_count < N)
                cycle_count <= cycle_count + 1;

            // Atualiza saída apenas quando o pipeline estiver cheio
            if (cycle_count == N)
                audio_out <= accumulator_stage[N][40:17];
        end
    end

endmodule
