//Módulo principal que interliga todos os blocos — recebe áudio, recebe comandos via I2C e aplica os parâmetros no equalizador.
module top_module (
    input wire clk,              // Clock
    input wire rst_n,            // Reset em 0
    input wire i2c_scl,          // Clock I2C
    inout wire i2c_sda,          // Dados I2C
    input wire [23:0] audio_in,  // Entrada de áudio (24 bits)
    output wire [23:0] audio_out,// Saída de áudio (24 bits)
    input wire audio_valid,      // Indica dado de áudio válido
    output wire audio_ready     // Indica pronto para receber novo dado
);

//Recebe comandos via I2C e envia dados e endereço de registrador ao bloco de controle; gera sinal para escrita nos registradores.
module i2c_slave (
    input wire clk,                    // Clock
    input wire rst_n,                  // Reset em 0
    input wire scl,                    // Clock do mestre
    inout wire sda,                    // Dados
    output wire [7:0] register_addr,   // Endereço do registrador
    output wire [7:0] data,            // Dados recebidos
    output wire reg_write_enable       // Sinal indicando que deve ocorrer escrita no registrador
);

//Armazena os valores de configuração recebidos via I2C e os disponibiliza para o equalizador.
module reg_map #(
    parameter GAIN_WIDTH = 24,    
    parameter ADDR_WIDTH = 31      
)(
    input wire clk,                     // Clock
    input wire rst,                     // Reset em 0
    input wire we,                      // Sinal para habilitar escrita nos registradores
    input wire [ADDR_WIDTH-1:0] addr,   // Endereço do registrador para leitura/escrita 
    input wire [7:0] data_in,           // Dados de entrada para gravação no registrador (1 byte -> devido ao i2c)
    output [7:0] configuration,         // Para armazenar bits de configuração 
    output reg [GAIN_WIDTH-1:0] gain_1, // Parâmetro de ganho para banda 1 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_2, // Parâmetro de ganho para banda 2 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_3, // Parâmetro de ganho para banda 3 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_4, // Parâmetro de ganho para banda 4 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_5, // Parâmetro de ganho para banda 5 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_6, // Parâmetro de ganho para banda 6 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_7, // Parâmetro de ganho para banda 7 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_8, // Parâmetro de ganho para banda 8 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_9, // Parâmetro de ganho para banda 9 do equalizador
    output reg [GAIN_WIDTH-1:0] gain_10 // Parâmetro de ganho para banda 10 do equalizador

);

//Aplica os ganhos nas bandas de frequência do sinal de áudio
module equalizer (
    input wire clk,                // Clock
    input wire rst_n,              // Reset em 0
    input wire [23:0] audio_in,    // Entrada do áudio (24 bits)
    input wire audio_valid,        // Validação dos dados de entrada (indica dado válido)
    output wire audio_ready,       // Indica que o módulo está pronto para receber próximo dado
    output wire [23:0] audio_out,  // Saída do áudio processado (24 bits)
    input wire [15:0] band1_gain,  // Ganho configurável para banda 1
    input wire [15:0] band2_gain,  // Ganho configurável para banda 2
    input wire [15:0] band3_gain   // Ganho configurável para banda 3
);

//Referencia do de baixo: https://www.controlpaths.com/2021/04/19/implementing-a-digital-biquad-filter-in-verilog/
//Implementa um filtro digital de segunda ordem (biquad), usando coeficientes fornecidos para aplicar uma resposta de frequência desejada (ex: passa-baixa, passa-banda, etc.).
module biquad_filter (
    input wire clk,                // Clock
    input wire rst_n,              // Reset em 0
    input wire [23:0] x_in,        // Entrada de áudio para filtro (24 bits)
    output wire [23:0] y_out,      // Saída filtrada (24 bits)
    input wire [15:0] a1,          // Coeficiente a1 do filtro biquad
    input wire [15:0] a2,          // Coeficiente a2 do filtro biquad
    input wire [15:0] b0,          // Coeficiente b0 do filtro biquad
    input wire [15:0] b1,          // Coeficiente b1 do filtro biquad
    input wire [15:0] b2           // Coeficiente b2 do filtro biquad
);
