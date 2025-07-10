module fir_lpf (
    input  wire                i_clk,
    input  wire                i_rst_n,
    input  wire                i_en,           // enable
    input  wire signed  [23:0] i_data,         // input data
    output reg  signed  [23:0] o_data          // output data
);

    parameter N = 255; // Número de taps

    // Coeficientes do filtro em 1.15 (signed 17 bits)
    reg signed [16:0] h [0:N-1];
    // Buffer de atraso (histórico das entradas)
    reg signed [23:0] x [0:N-1];

    // Acumulador de 48 bits, ele é maior que a entrada para o resultado da multiplicação e soma
    reg signed [47:0] acc;

    integer i;

    // Leitura dos coeficientes a partir de arquivo externo
    initial begin
        $readmemh("C:\coef_faixa1.hex", h); // quem for rodar aqui, modifica o caminho só
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (i = 0; i < N; i = i + 1)
                x[i] <= 24'sd0;
                o_data <= 24'sd0;
                acc    <= 48'sd0;
        end else if (i_en) begin
            // deslocamento do buffer
            for (i = N-1; i > 0; i = i - 1)
                x[i] <= x[i-1];
                x[0] <= i_data;

            // multiplicação e acumulação
            acc = 48'sd0;
            for (i = 0; i < N; i = i + 1)
                acc = acc + x[i] * h[i]; // aqui é basicamente a soma das frequencias
                // ajuste de ponto fixo (1.15 para 24 bits)
                o_data <= acc[38:15]; // pega os 24 bits centrais
        end
    end

endmodule
