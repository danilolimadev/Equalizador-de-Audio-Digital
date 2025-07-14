// Recebe comandos via I2C e envia dados e endereço de registrador ao bloco de controle
module i2c_slave (
    input wire clk,                    // Clock
    input wire rst_n,                  // Reset em 0
    input wire scl,                    // Linha de clock I2C
    inout wire sda,                    // Linha de dados I2C
    input wire [7:0] data_in,          // Dado a ser enviado pelo escravo (quando em leitura)
    output reg [7:0] data_out,         // Dados recebidos
    output reg reg_write_enable,       // Sinal de escrita no registrador
    output reg data_ready,             // Flag indicando dado recebido
    output reg start,                  // Indica inicio/fim da transmissão
    output reg ack_error,              // Flag para indicar erro no ACK
    output reg [7:0] reg_addr          // Endereço do registrador mas so usaremos 0:29
);

    localparam ADDRESS = 7'b1101010;   // 6Ah o endereço é formado por um bit a mais LSB de leitura e escrita
    // Declaração de parâmetros locais para implementação da máquina de estados
    localparam I2C_IDLE         = 4'b0000; // Estado inativo
    localparam I2C_START        = 4'b0001; // Indica início da comunicação 
    localparam I2C_ADDR_SHIFT   = 4'b0010; // Recebe 7 bits de endereço + 1 bit R/W
    localparam I2C_ACK_ADDR     = 4'b0011; // Envia ACK para endereço
    localparam I2C_REG_ADDR     = 4'b0100; // Recebe endereço do registrador
    localparam I2C_READ         = 4'b0101; // Envia dados
    localparam I2C_WRITE        = 4'b0110; // Recebe dados
    localparam I2C_ACK_DATA     = 4'b0111; // Envia/recebe ACK para dados
    localparam I2C_STOP         = 4'b1000; // Encerramento da transação I2C

    // Declaração dos registradores internos
    reg [7:0] shift_reg;        // Registrador de deslocamento para leitura de dados
    reg [2:0] bit_count;        // Contador de bits (0-7)
    reg [3:0] state;            // Estado atual da maquina de estados
    reg [3:0] next_state;       // Proximo estado da maquina de estados
    reg [7:0] registers [0:29]; // Memória de registradores: 30 posições de 8 bits
    reg sda_out;                // Controle de saida para SDA
    reg sda_drive;              // Define se o escravo controla diretamente a linha SDA
    reg scl_sync;               // Valor sincronizado de SCL
    reg sda_sync;               // Valor sincronizado de SDA
    reg scl_last;               // Estado anterior de SCL
    reg sda_last;               // Estado anterior de SDA
    reg scl_falling_edge;       // Detector de borda de descida de SCL
    reg scl_rising_edge;        // Detector de borda de subida de SCL
    reg rw_bit;                 // Bit R/W recebido
    reg address_match;          // Flag de endereço correspondente no mapa de registro
    
    // Controle bidirecional da linha Serial Data
    assign sda = (sda_drive) ? sda_out : 1'bz;

    // Ligação da memória para leitura
    assign data_in = registers[reg_addr];
    integer i;
    // Sincronização de bordas de SCL e escrita nos registradores
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl_sync <= 1;
            sda_sync <= 1;
            scl_last <= 1;
            sda_last <= 1;
            scl_falling_edge <= 0;
            scl_rising_edge <= 0;
            start <= 0;
            state <= I2C_IDLE;
            bit_count <= 0;
            shift_reg <= 0;
            reg_write_enable <= 0;
            data_ready <= 0;
            ack_error <= 0;
            rw_bit <= 0;
            address_match <= 0;
            data_out <= 0;
            reg_addr <= 0;
            // Inicializar registradores
            for (i = 0; i < 30; i = i + 1) begin
                registers[i] <= 8'h00;
            end
        end 
        else begin
            // Estágios de sincronização
            scl_sync <= scl;
            sda_sync <= sda;
            scl_last <= scl_sync;
            sda_last <= sda_sync;
            
            // Detecção de bordas
            scl_falling_edge <= scl_last && !scl_sync;//borda de descida
            scl_rising_edge <= !scl_last && scl_sync; //borda de subida

            // Detecção de condições START/STOP
            if (!start && scl_sync && sda_last && !sda_sync) begin
                start <= 1;  // Condição START
            end 
            else if (start && scl_sync && !sda_last && sda_sync) begin
                start <= 0;  // Condição STOP
            end

            state <= next_state;
            
            // Lógica de estado
            case (state)
                I2C_IDLE: begin
                    bit_count <= 0;
                    shift_reg <= 0;
                    reg_write_enable <= 0;
                    data_ready <= 0;
                    ack_error <= 0;
                    rw_bit <= 0;
                    address_match <= 0;
                    data_out <= 0;
                    reg_addr <= 0;
                end
                I2C_ADDR_SHIFT: 
                    if (scl_rising_edge) begin
                        if (bit_count < 7) begin
                            shift_reg[7-bit_count] <= sda_sync; 
                            bit_count <= bit_count + 1;
                        end 
                        else if (bit_count == 7) begin
                            rw_bit <= sda_sync;
                            address_match <= (shift_reg[7:1] == ADDRESS); 
                            bit_count <= 0;
                        end
                    end
                    
                I2C_ACK_ADDR:
                    if (scl_rising_edge && !address_match) begin
                        ack_error <= 0;
                    end 
                    else if (scl_rising_edge && address_match) begin
                        ack_error <= 1;
                    end
                    
                I2C_REG_ADDR: 
                    if (scl_rising_edge) begin
                        if (bit_count < 8) begin
                            reg_addr[7-bit_count] <= sda_sync;
                            bit_count <= bit_count + 1;
                        end 
                        else begin
                            bit_count <= 0;
                        end
                    end
                    
                I2C_WRITE: 
                    if (scl_rising_edge) begin
                        if (bit_count < 8) begin
                            shift_reg[7-bit_count] <= sda_sync;
                            bit_count <= bit_count + 1;
                        end 
                        else begin
                            data_out <= shift_reg; // Corrigido para usar shift_reg diretamente
                            data_ready <= 1;
                            bit_count <= 0;
                        end
                    end
                    
                I2C_READ:
                    if (scl_falling_edge) begin
                        if (bit_count < 8) begin
                            bit_count <= bit_count + 1;
                        end 
                        else begin
                            bit_count <= 0;
                        end
                    end
                    
                I2C_ACK_DATA: 
                    if (scl_falling_edge) begin
                        if (rw_bit == 0) begin
                            reg_write_enable <= 1;
                        end 
                        else if (rw_bit == 1 && sda_sync) begin
                            // NACK recebido
                            ack_error <= 1;
                        end
                    end 
                    else if (bit_count == 0 && state != I2C_ACK_DATA) begin
                        reg_write_enable <= 0; // Desativa fora da borda
                    end
                    
                I2C_STOP: 
                    if (!start) begin
                        bit_count <= 0;
                        shift_reg <= 0;
                        data_ready <= 0;
                        reg_write_enable <= 0;
                        address_match <= 0;
                        rw_bit <= 0;
                        ack_error <= 0;
                    end
                    
                default: begin
                    data_ready <= 0;
                    reg_write_enable <= 0;
                end
            endcase

            // Escrita na memória de registradores
            if (reg_write_enable && reg_addr <= 8'd29) begin
                registers[reg_addr] <= data_out;
            end
        end
    end

    // Lógica combinacional para o próximo estado
    always @(*) begin
        // Valores padrão
        next_state <= state;
        sda_drive <= 0;
        sda_out <= 1;

        case (state)
            I2C_IDLE: begin
                if (start) begin
                    next_state <= I2C_START;
                end
                else begin
                    next_state <= I2C_IDLE;
                end
            end

            I2C_START: begin
                if (scl_falling_edge) begin
                    next_state <= I2C_ADDR_SHIFT;
                end
            end

            I2C_ADDR_SHIFT: begin
                if (scl_rising_edge && bit_count == 7) begin
                    next_state <= I2C_ACK_ADDR;
                end
            end

            I2C_ACK_ADDR: begin
                if (address_match) begin
                    sda_drive <= 1;
                    sda_out <= 0;  // Envia ACK
                end
                if (scl_falling_edge) begin
                    if (address_match) begin
                        next_state <= (rw_bit == 0) ? I2C_REG_ADDR : I2C_READ;
                    end 
                    else begin
                        next_state <= I2C_IDLE;
                    end
                end
            end

            I2C_REG_ADDR: begin
                if (scl_rising_edge && bit_count == 8) begin
                    next_state <= I2C_ACK_DATA;
                end
            end

            I2C_READ: begin
                sda_drive <= 1;
                sda_out <= data_in[7-bit_count];  // Envia bits do dado
                if (scl_falling_edge && bit_count == 7) begin
                    next_state <= I2C_ACK_DATA;
                end
            end

            I2C_WRITE: begin
                if (scl_rising_edge && bit_count == 8) begin
                    next_state <= I2C_ACK_DATA;
                end
            end

            I2C_ACK_DATA: begin
                if (rw_bit == 0) begin  // Modo escrita
                    sda_drive <= 1;
                    sda_out <= 0;  // Envia ACK
                end
                if (scl_falling_edge) begin
                    if (rw_bit == 0) begin
                        next_state <= I2C_WRITE;
                    end 
                    else if (rw_bit == 1) begin
                        if (sda_sync) begin  // NACK recebido
                            next_state <= I2C_STOP;
                        end 
                        else begin  // ACK recebido
                            next_state <= I2C_READ;
                        end
                    end
                end
            end
            
            I2C_STOP: begin
                if (!start) begin
                    next_state <= I2C_IDLE;
                end
            end
            
            default: next_state <= I2C_IDLE;
        endcase
    end

endmodule

module regmap_fir_coeffs #(
)(
    input clk,
    input rst,
    input we,
    input [4:0] addr,  // 5 bits (0-29)
    input [7:0] data_in,
    output [7:0] confi,
    output [23:0] coeffs_1,
    output [23:0] coeffs_2,
    output [23:0] coeffs_3,
    output [23:0] coeffs_4,
    output [23:0] coeffs_5,
    output [23:0] coeffs_6,
    output [23:0] coeffs_7,
    output [23:0] coeffs_8,
    output [23:0] coeffs_9,
    output [23:0] coeffs_10
);
    // Banco de 30 registradores de 8 bits (0-29)
    reg [7:0] regbank [0:29];

    // Escrita e reset
    integer i;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 30; i = i + 1)
                regbank[i] <= 8'd0;
        end 
        else if (we) begin
            regbank[addr] <= data_in;
        end
    end

    assign confi = regbank[0];  // Registrador de configuração
    // Mapeamento corrigido dos coeficientes
    assign coeffs_1 = {regbank[3], regbank[2], regbank[1]};
    assign coeffs_2 = {regbank[6], regbank[5], regbank[4]};  
    assign coeffs_3 = {regbank[9], regbank[8], regbank[7]};  
    assign coeffs_4 = {regbank[12], regbank[11], regbank[10]}; 
    assign coeffs_5 = {regbank[15], regbank[14], regbank[13]}; 
    assign coeffs_6 = {regbank[18], regbank[17], regbank[16]}; 
    assign coeffs_7 = {regbank[21], regbank[20], regbank[19]}; 
    assign coeffs_8 = {regbank[24], regbank[23], regbank[22]}; 
    assign coeffs_9 = {regbank[27], regbank[26], regbank[25]}; 
    assign coeffs_10 = {regbank[29], regbank[28], regbank[27]}; // Corrigido
endmodule