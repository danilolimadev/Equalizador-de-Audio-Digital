module i2c_slave #(
    parameter SLAVE_ADDR = 7'h50  // Valor padrão
)(
    input wire clk,
    input wire reset,
    input wire scl,
    inout wire sda,
    output reg [7:0] data_out,
    input wire [7:0] data_in,
    output reg data_ready,
    output reg ack_error,
    output reg start
);

    localparam ADDRESS = 7'b1101010;

    localparam IDLE      = 3'b000;
    localparam ADDR      = 3'b001;
    localparam ACK_ADDR  = 3'b010;
    localparam READ      = 3'b011;  // Mestre escreve no escravo (recebendo bytes)
    localparam WRITE     = 3'b100;  // Mestre lê do escravo (enviando bytes)
    localparam ACK_DATA  = 3'b101;

    reg [7:0] shift_reg;
    reg [2:0] bit_count;
    reg [2:0] state, next_state;
    reg sda_out;
    reg sda_drive;
    reg scl_sync;
    reg sda_sync;
    reg scl_last;
    reg sda_last;

    //MELHORAR AQUI TÁ SÓ PRA RASCUNHO
    reg opcao;
    reg [7:0] posicao;
    reg [7:0] valor;

    reg rw_flag; // 0 = write (mestre escreve), 1 = read (mestre lê)
    reg new_data = 0;

    assign sda = (sda_drive) ? sda_out : 1'bz;

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

    always @(posedge new_data) begin
        new_data = 0;
        //$display("Byte recebido: %b", shift_reg);
        if(opcao) begin
            valor = shift_reg;
            $display("Valor recebido: %d para posicao: ", valor, posicao);
            posicao = posicao + 1;
        end else begin
            opcao = 1;
            posicao = shift_reg;
            $display("Posicao recebida: %d", posicao);
        end
    end

    // Detect start/stop
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            start <= 0;
        end else begin
            if (!start && scl_sync && sda_last && !sda_sync) begin
                start <= 1;
                $display("%0t: START detectado", $time);
            end else if (start && scl_sync && !sda_last && sda_sync) begin
                start <= 0;
                $display("%0t: STOP detectado", $time);
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end

    always @(*) begin
        next_state = state;

        if (!start) next_state = IDLE;
        else begin
            case (state)
                IDLE: begin
                    if (start && scl_last && !scl_sync) next_state = ADDR;
                end

                ADDR: begin
                    if (scl_last && !scl_sync) begin
                        if (bit_count == 0) next_state = ACK_ADDR;
                    end
                end

                ACK_ADDR: begin
                    if (scl_last && !scl_sync) begin
                        if (shift_reg[7:1] == ADDRESS) begin
                            if (shift_reg[0] == 0) next_state = READ;
                            else next_state = WRITE;
                        end else begin
                            next_state = IDLE;
                        end
                    end
                end

                READ: begin
                    if (scl_last && !scl_sync && bit_count == 0) next_state = ACK_DATA;
                end

                WRITE: begin
                    if (scl_last && !scl_sync && bit_count == 0) next_state = ACK_DATA;
                end

                ACK_DATA: begin
                    if (scl_last && !scl_sync) begin
                        if (rw_flag == 0)
                            next_state = READ;  // Mestre vai enviar mais bytes para escravo
                        else
                            next_state = WRITE; // Escravo vai enviar mais bytes para mestre
                    end
                end

                default: next_state = IDLE;
            endcase
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_count <= 7;
            shift_reg <= 8'b0;
            data_ready <= 0;
            ack_error <= 0;
            data_out <= 0;
            sda_drive <= 0;
            sda_out <= 1;
            rw_flag <= 0;
        end else begin
            case(state)
                IDLE: begin
                    bit_count <= 7;
                    shift_reg <= 8'b0;
                    data_ready <= 0;
                    ack_error <= 0;
                    data_out <= 0;
                    sda_drive <= 0;
                    sda_out <= 1;
                    rw_flag <= 0;
                    opcao <= 0;
                end

                ADDR: begin
                    if (!scl_last && scl_sync) begin
                        shift_reg[bit_count] <= sda_sync;
                        //$display("%0t: Bit endereço recebido: %b, bit_count=%d", $time, sda_sync, bit_count);
                    end
                    if (scl_last && !scl_sync) bit_count <= bit_count - 1'd1;
                end

                ACK_ADDR: begin
                    sda_drive <= 1;
                    sda_out <= 0; // ACK = 0
                    if (scl_last && !scl_sync) begin
                        if (shift_reg[7:1] == ADDRESS) begin
                            bit_count <= 7;
                            rw_flag <= shift_reg[0];
                            $display("%0t: ACK endereço enviado, endereço válido %b, RW=%b", $time, shift_reg[7:1], shift_reg[0]);
                        end else begin
                            $display("%0t: Endereço inválido: %b", $time, shift_reg[7:1]);
                        end
                    end
                end

                READ: begin
                    sda_drive <= 0;
                    if (!scl_last && scl_sync) begin
                        shift_reg[bit_count] <= sda_sync;
                        //$display("%0t: Bit de dados recebido: %b, bit_count=%d", $time, sda_sync, bit_count);
                        if (bit_count == 0) begin
                            data_out <= shift_reg;
                            data_ready <= 1;
                            new_data <= 1;
                            //$display("Byte recebido: %b", shift_reg); //Creio que aqui tá atrasado de 1 por conta de que atualiza somente com o clock
                        end
                    end
                    if (scl_last && !scl_sync) bit_count <= bit_count - 1'd1;
                end

                WRITE: begin
                    sda_drive <= 1;
                    sda_out <= data_in[bit_count];
                    //$display("%0t: Bit de dados enviado: %b, bit_count=%d", $time, data_in[bit_count], bit_count);
                    if (scl_last && !scl_sync) bit_count <= bit_count - 1'd1;
                end

                ACK_DATA: begin
                    sda_drive <= 1;
                    sda_out <= 0; // ACK do escravo para o mestre

                    if (scl_last && !scl_sync) begin
                        data_ready <= 0; // Limpa flag para o próximo byte
                        //$display("%0t: ACK para byte %s enviado", $time, (rw_flag==0) ? "recebido" : "enviado");
                        bit_count <= 7;
                    end
                end
            endcase
        end
    end

endmodule
