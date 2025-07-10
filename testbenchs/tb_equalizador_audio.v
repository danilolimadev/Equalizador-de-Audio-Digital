`timescale 1ns/100ps

module tb_audio_equalizer;

    // Clock e reset
    reg clk = 0;
    reg rst_n = 0;

    // Clock de 50 MHz
    always #10 clk = ~clk;

    // I2C sinais
    reg i2c_scl = 1;
    reg i2c_sda_out = 1;
    reg i2c_sda_dir = 0;
    wire i2c_sda;
    assign i2c_sda = i2c_sda_dir ? i2c_sda_out : 1'bz; //1'bz = Alta impedância

    // Áudio
    reg [23:0] audio_in = 0;
    wire [23:0] audio_out;
    reg audio_valid = 0;
    wire audio_ready;

    // DUT
    top_module dut (
        .clk(clk),
        .rst_n(rst_n),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .audio_in(audio_in),
        .audio_out(audio_out),
        .audio_valid(audio_valid),
        .audio_ready(audio_ready)
    );

    // WAV leitura
    integer wav_file;
    integer file_out;
    reg [7:0] b0, b1, b2;
    reg [23:0] sample;
    reg [7:0] buf [0:3];
    integer found_data = 0;
    integer data_size = 0;
    integer c;

    // I2C parâmetros
    parameter I2C_ADDR = 7'b10101010; //Valor aleatório

    // Tasks I2C master
    task i2c_start(); //Start: SDA faz a transição do estado ALTO para o estado BAIXO, enquanto o SCL é ALTO.
        begin
            i2c_sda_dir = 1;
            i2c_sda_out = 1; 
            i2c_scl = 1; 
            #5;
            i2c_sda_out = 0; 
            #5;
        end
    endtask

    task i2c_stop(); //Stop: SDA faz a transição do estado BAIXO para o estado ALTO, enquanto o SCL é ALTO.
        begin
            i2c_sda_out = 0; 
            i2c_scl = 1; 
            #5;
            i2c_sda_out = 1; 
            #5;
        end
    endtask

    task i2c_send_bit(input b); // Envia 1 bit no barramento I2C: coloca o valor em SDA e gera pulso de clock (SCL)
        begin
            i2c_sda_out = b; 
            #1;
            i2c_scl = 1; #5;
            i2c_scl = 0; #5;
        end
    endtask

    task i2c_read_ack();// Lê o bit de ACK do escravo após envio de um byte no protocolo I2C
        begin
            i2c_sda_dir = 0;
            i2c_scl = 1; #5;
            i2c_scl = 0; #5;
            i2c_sda_dir = 1;
        end
    endtask

    task i2c_send_byte(input [7:0] byte); //Faz o envio de 1 byte(8 bits)
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1)
                i2c_send_bit(byte[i]);
            i2c_read_ack();
        end
    endtask

    task i2c_write_reg(input [6:0] slave_addr, input [7:0] register_addr, input [7:0] data);
        begin
            i2c_start();
            i2c_send_byte({slave_addr, 1'b0});
            i2c_send_byte(register_addr);
            i2c_send_byte(data);
            i2c_stop();
        end
    endtask

    initial begin
        $display("=== Equalizador de Áudio Digital ===");
        rst_n = 0;
        #10;
        rst_n = 1;
        #20;

        // Configuração via I2C
        $display("Configurando ganhos via I2C..."); //Precisamos criar o padrão aqui, enviando valores aleatórios por exemplo 0 - 255 0 = -24db e 255 = 24db
        i2c_write_reg(I2C_ADDR, 8'h01, 8'd5);
        i2c_write_reg(I2C_ADDR, 8'h02, 8'd10);
        i2c_write_reg(I2C_ADDR, 8'h03, 8'd15);
        i2c_write_reg(I2C_ADDR, 8'h04, 8'd20);
        i2c_write_reg(I2C_ADDR, 8'h05, 8'd25);
        i2c_write_reg(I2C_ADDR, 8'h06, 8'd30);
        i2c_write_reg(I2C_ADDR, 8'h07, 8'd35);
        i2c_write_reg(I2C_ADDR, 8'h08, 8'd40);
        i2c_write_reg(I2C_ADDR, 8'h09, 8'd45);
        i2c_write_reg(I2C_ADDR, 8'h0A, 8'd50);
        $display("Ganhos configurados");

        // Abrir arquivo WAV
        wav_file = $fopen("entrada_de_audio.wav", "rb"); //"rb" significa abrir o arquivo para leitura em modo binário.
        if (wav_file == 0) begin
            $display("Erro ao abrir entrada_de_audio.wav");
            $stop;
        end

        // Abrir arquivo de saída
        file_out = $fopen("output_audio.wav", "wb"); //"wb" significa abrir o arquivo para escrita em modo binário, se não existir o arquivo cria um novo
        if (file_out == 0) begin
            $display("Erro ao abrir/criar output_audio.wav");
            $stop;
        end

        // Copiar cabeçalho WAV (44 bytes típicos)
        integer i;
        reg [7:0] header_byte;
        for (i = 0; i < 44; i = i + 1) begin
            if ($fread(header_byte, wav_file) != 1) begin
                $display("Erro ao ler cabeçalho");
                $stop;
            end
            $fwrite(file_out, "%c", header_byte);
        end

        // Procurar chunk "data" para verificar se é um arquivo válido, o áudio válido ocorre somente após "data": 0x64, 0x61, 0x74, 0x61
        found_data = 0;
        buf[0] = 0; buf[1] = 0; buf[2] = 0; buf[3] = 0;

        while (!$feof(wav_file)) begin ////$feof é utilizado para verificar final do arquivo 
            buf[0] = buf[1];
            buf[1] = buf[2];
            buf[2] = buf[3];
            c = $fgetc(wav_file);
            if (c == -1) break;
            buf[3] = c[7:0];

            if (buf[0] == 8'h64 && buf[1] == 8'h61 && buf[2] == 8'h74 && buf[3] == 8'h61) begin
                found_data = 1;
                $display("Chunk 'data' encontrado");

                buf[0] = $fgetc(wav_file);
                buf[1] = $fgetc(wav_file);
                buf[2] = $fgetc(wav_file);
                buf[3] = $fgetc(wav_file);
                data_size = buf[0] + (buf[1] << 8) + (buf[2] << 16) + (buf[3] << 24);
                $display("Tamanho do chunk 'data' = %0d bytes", data_size);
                break;
            end
        end

        if (!found_data) begin
            $display("Erro: chunk 'data' não encontrado");
            $stop;
        end

        // Leitura e envio dos samples
        while (!$feof(wav_file)) begin
            if (audio_ready) begin
                if ($fread(b0, wav_file) != 1) break;
                if ($fread(b1, wav_file) != 1) break;
                if ($fread(b2, wav_file) != 1) break;

                sample = {b2, b1, b0};
                audio_in <= sample;
                audio_valid <= 1;
                #20;
                audio_valid <= 0;

                // Espera processamento e escreve a saída no arquivo
                #20;
                $fwrite(file_out, "%c%c%c",
                    audio_out[23:16],
                    audio_out[15:8],
                    audio_out[7:0]
                );
            end
            #20;
        end

        $display("=== Fim da simulação ===");
        $fclose(wav_file);
        $fclose(file_out);
        #10;
        $stop;
    end

endmodule
