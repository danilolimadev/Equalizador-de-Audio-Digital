`timescale 1ns / 1ps

module i2c_slave (
    input wire clk,         // Clock do sistema
    input wire reset,       // Reset do sistema
    input wire scl,         // Linha de clock I2C
    inout wire sda,         // Linha de dados I2C
    output reg [7:0] data_out, // Dado recebido
    input wire [7:0] data_in,  // Dado a ser enviado pelo escravo
    output reg data_ready,     // Flag indicando dado recebido
    output reg ack_error,      // Flag para indicar erro no ACK do mestre
    output reg start           // Indica inicio e fim da transmissao
);

    // Constantes
    localparam ADDRESS = 7'b1101010; // 6Ah
	 
    localparam IDLE = 3'b000;
    localparam ADDR = 3'b001;
    localparam ACK = 3'b010;
    localparam READ = 3'b011;
    localparam WRITE = 3'b100;
    localparam READ_ACK = 3'b101;

    // Registradores internos
    reg [7:0] shift_reg;  // Registrador de deslocamento para leitura de dados
    reg [2:0] bit_count;  // Contador de bits
    reg [2:0] state;      // Estado atual da maquina de estados
    reg [2:0] next_state; // Proximo estado da maquina de estados
    reg sda_out;          // Controle de saida para SDA
    reg sda_drive;        // Define se o escravo controla diretamente a linha SDA
    reg scl_sync;         // Valor sincronizado de SCL
    reg sda_sync;         // Valor sincronizado de SDA
    reg scl_last;         // Estado anterior de SCL
    reg sda_last;         // Estado anterior de SDA

    // Controle bidirecional da linha SDA
    assign sda = (sda_drive) ? sda_out : 1'bz;

    // Sincronizacao de SCL e SDA no clock do sistema
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            scl_sync <= 1;
            sda_sync <= 1;
            scl_last <= 1;
            sda_last <= 1;
        end else begin
            scl_sync <= scl;
            sda_sync <= sda;
            scl_last <= scl_sync;
            sda_last <= sda_sync;
        end
    end

    // Deteccao de borda de start/stop
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            start <= 0;
        end else begin
            if (!start && scl_sync && sda_last && !sda_sync) begin
                // Condicao de start
                start <= 1;
            end else if (start && scl_sync && !sda_last && sda_sync) begin
                // Condicao de stop
                start <= 0;
            end
        end
    end

    // Logica sequencial para o estado atual
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Logica combinacional para o proximo estado
    always @(*) begin
        // Estados padrao
        next_state = state;
		  
		  if (!start) begin
		      next_state = IDLE;
		  end else begin
            case (state)
                IDLE: begin
                    if (start && scl_last && !scl_sync) next_state = ADDR;
                end

                ADDR: begin
                    if (scl_last && !scl_sync) begin
                        if (bit_count == 0) begin
                            next_state = ACK;
                        end
                    end
                end

                ACK: begin
	                 if (scl_last && !scl_sync) begin
                        if (shift_reg[7:1] == ADDRESS) begin
                            next_state = (shift_reg[0] == 0) ? READ : WRITE;
                        end else begin
                            next_state = IDLE; // Endereco invalido
                        end
					     end
                end

                READ: begin
                    if (scl_last && !scl_sync) begin
                        if (bit_count == 0) begin
                            next_state = ACK;
                        end
                    end
                end

                WRITE: begin
                    if (scl_last && !scl_sync) begin
                        if (bit_count == 0) begin
                            next_state = READ_ACK;
                        end
                    end
                end

                READ_ACK: begin
                    if (scl_last && !scl_sync) begin
                        next_state = IDLE;
                    end
                end

                default: next_state = IDLE;
            endcase
	     end
    end

    // Logica combinacional e de saida
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_count <= 7;
            shift_reg <= 8'b0;
            data_ready <= 0;
            ack_error <= 0;
            data_out <= 0;
            sda_drive <= 0;
            sda_out <= 1;
        end else begin
            case (state)
                IDLE: begin
                    bit_count <= 7;
                    shift_reg <= 8'b0;
                    data_ready <= 0;
                    ack_error <= 0;
                    data_out <= 0;
                    sda_drive <= 0;
                    sda_out <= 1;
                end

                ADDR: begin
                    if (!scl_last && scl_sync) shift_reg[bit_count] <= sda_sync;
                    if (scl_last && !scl_sync) bit_count <= bit_count - 1'd1;
                end

                ACK: begin
					     sda_drive <= 1;
                    sda_out <= 0;
					     if (scl_last && !scl_sync) begin
                        if (shift_reg[7:1] == ADDRESS) begin
									 bit_count <= 7;
							   end
                    end
                end

                READ: begin
					     sda_drive <= 0;
                    if (!scl_last && scl_sync) begin
                        shift_reg[bit_count] <= sda_sync;
                        if (bit_count == 0) begin
                            data_out <= shift_reg;
                            data_ready <= 1;
                        end
                    end
						  if (scl_last && !scl_sync) bit_count <= bit_count - 1'd1;
                end

                WRITE: begin
					     sda_drive <= 1;
						  sda_out <= data_in[bit_count];
                    if (scl_last && !scl_sync) begin
						      bit_count <= bit_count - 1'd1;
						  end
                end

                READ_ACK: begin
					     sda_drive <= 0;
                    if (!scl_last && scl_sync) begin
                        ack_error <= (sda_sync != 0);
                    end
                end
            endcase
        end
    end
endmodule
