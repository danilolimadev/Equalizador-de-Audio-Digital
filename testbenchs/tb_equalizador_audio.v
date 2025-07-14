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
    /*top_module dut (
        .clk(clk),
        .rst_n(rst_n),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda),
        .audio_in(audio_in),
        .audio_out(audio_out),
        .audio_valid(audio_valid),
        .audio_ready(audio_ready)
    );*/

    //PARA TESTAR GERAR O ARQUIVO IGUAL, SOMENTE PARA COMPARAÇÃO
    assign audio_out = audio_in;    // Pass-through sem alteração
    assign audio_ready = 1'b1;      // Sempre pronto para receber dados

    // WAV leitura
    integer wav_file;
    integer file_out;
    reg [7:0] b0, b1, b2;
    reg [23:0] sample;
    reg [7:0] buffer [0:3];
    integer found_data = 0;
    integer data_size = 0;
    integer c;

    // I2C parâmetros
    parameter I2C_ADDR = 7'b10101010; //Valor aleatório

    // File parameters
    reg [7:0] header_byte;
    integer i;
    reg doneFile; // Variável de controle
    reg [1:0] endFile; // Variavel de controle que indica o final do arquivo

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

        // Procurar chunk "data" para verificar se é um arquivo válido, o áudio válido ocorre somente após "data": 0x64, 0x61, 0x74, 0x61
        found_data = 0;
        buffer[0] = 0; buffer[1] = 0; buffer[2] = 0; buffer[3] = 0;

        doneFile = 0;
        endFile = 0;
        while (!$feof(wav_file) && !doneFile) begin ////$feof é utilizado para verificar final do arquivo 
            buffer[0] = buffer[1];
            buffer[1] = buffer[2];
            buffer[2] = buffer[3];
            c = $fgetc(wav_file);
            if (c == -1) doneFile = 1;
            else begin
                $fwrite(file_out, "%c", c);
                buffer[3] = c[7:0];

                if (buffer[0] == 8'h64 && buffer[1] == 8'h61 && buffer[2] == 8'h74 && buffer[3] == 8'h61) begin
                    found_data = 1;
                    $display("Chunk 'data' encontrado");

                    buffer[0] = $fgetc(wav_file);
                    buffer[1] = $fgetc(wav_file);
                    buffer[2] = $fgetc(wav_file);
                    buffer[3] = $fgetc(wav_file);
                    $fwrite(file_out, "%c%c%c%c",
                        buffer[0],
                        buffer[1],
                        buffer[2],
                        buffer[3]
                    );
                    data_size = buffer[0] + (buffer[1] << 8) + (buffer[2] << 16) + (buffer[3] << 24);
                    $display("Tamanho do chunk 'data' = %0d bytes", data_size);
                    doneFile = 1;
                end
            end
        end

        if (!found_data) begin
            $display("Erro: chunk 'data' não encontrado");
            $stop;
        end

        doneFile = 0;
        // Leitura e envio dos samples
        while (!$feof(wav_file) && !doneFile) begin
            if (audio_ready) begin
                if ($fread(b0, wav_file) != 1) doneFile = 1;
                if ($fread(b1, wav_file) != 1) begin
                    endFile = 1;
                    b1 = 0;
                    b2 = 0;
                end
                if ($fread(b2, wav_file) != 1) begin
                    endFile = 2;
                    b2 = 0;
                end
                if (!doneFile) begin
                    sample = {b2, b1, b0};
                    audio_in <= sample;
                    audio_valid <= 1;
                    #20;
                    audio_valid <= 0;

                    // Espera processamento e escreve a saída no arquivo
                    #20;
                    if(endFile == 1) begin
                        doneFile = 1;
                        $fwrite(file_out, "%c",
                            audio_out[7:0]
                        );
                    end
                    else if(endFile == 2) begin
                        doneFile = 1;
                        $fwrite(file_out, "%c%c",
                            audio_out[7:0],
                            audio_out[15:8]
                        );
                    end
                    else begin
                        $fwrite(file_out, "%c%c%c",
                            audio_out[7:0],
                            audio_out[15:8],
                            audio_out[23:16]
                        );
                    end
                end
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
