`timescale 1ns/100ps

module tb_top_module;

parameter MAX_COUNT = 10; //NUMERO DE FAIXAS
reg clk;
reg rst_n;

//I2C
reg scl;
wire sda;
reg i2c_sda_out;
reg i2c_sda_dir;
wire i2c_sda_in;
parameter I2C_ADDR = 7'h6A;
reg [7:0] ganhos1 [0:9]; //Casos de teste, ganhos de 1-10

assign sda = i2c_sda_dir ? i2c_sda_out : 1'bz;
assign i2c_sda_in = sda;

// Áudio
reg [23:0] audio_in = 0;
wire [23:0] audio_out;
wire audio_ready;
//PARA TESTAR GERAR O ARQUIVO IGUAL, SOMENTE PARA COMPARAÇÃO
assign audio_ready = 1'b1;      // Sempre pronto para receber dados

// WAV leitura
integer wav_file;
integer file_out;
reg [7:0] b0, b1, b2; //São os 3 bytes de leitura do arquivo wav, como temos 24 bits, é necessário 3 bytes para compor
reg [23:0] sample; //Composição com b0, b1 e b2
reg [7:0] buffer [0:3]; //Utilizado para análise do cabeçalho
integer found_data = 0;
integer data_size = 0;
integer progress = 0;
integer progresso_inteiro = 0;
integer c; //Variável auxiliar para tratamento no cabeçalho

// Parametros do arquivo
reg [7:0] header_byte;
integer i;
reg doneFile; // Variável de controle
reg [1:0] endFile; // Variavel de controle que indica o final do arquivo

integer j = 0; //Utilizado para indicar progresso

top_module #(.SLAVE_ADDR(I2C_ADDR)) dut (
             .clk(clk),
             .rst_n(rst_n),
             .scl(scl),
             .sda(sda),
             .audio_in(audio_in),
             .audio_out(audio_out)
           );

initial
begin
  clk = 0;
  forever
    #10 clk = ~clk;  // 50 MHz clock
end

initial
begin
  rst_n = 0;
  scl = 1;
  i2c_sda_dir = 1;
  i2c_sda_out = 1;
  #50;
  rst_n = 1;

  ganhos1[0] = 8'd16;
  ganhos1[1] = 8'd16;
  ganhos1[2] = 8'd16;
  ganhos1[3] = 8'd0;
  ganhos1[4] = 8'd0;
  ganhos1[5] = 8'd0;
  ganhos1[6] = 8'd0;
  ganhos1[7] = 8'd0;
  ganhos1[8] = 8'd0;
  ganhos1[9] = 8'd0;

  $display("--- Envio sequencial 1: 1 ao 10 ---");
  i2c_write_sequential_fixed(I2C_ADDR, 8'h00, 10);
  $display("Ganhos configurados");

  // Abrir arquivo WAV
  wav_file = $fopen("24_48k_mono_PerfectTest.wav", "rb"); //"rb" significa abrir o arquivo para leitura em modo binário.
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
  while (!$feof(wav_file) && !doneFile) begin //$feof é utilizado para verificar final do arquivo 
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
              progress = progress + 3;
              
              j = j+1;
              if(j>100) begin
                progresso_inteiro = (progress * 1000) / data_size;  // Escala x10 para 1 casa decimal
                $display("Progresso = %0d.%0d%%", progresso_inteiro / 10,  // parte inteira
                  progresso_inteiro % 10   // parte decimal (1 casa)
                );
                j = 0;

              end

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


// I2C MASTER
task i2c_write_sequential_fixed(input [6:0] slave_addr, input [7:0] start_addr, input integer count);
  integer i;
  begin
    i2c_start();
    i2c_send_byte({slave_addr, 1'b0});
    i2c_send_byte(start_addr);

    for (i = 0; i < count; i = i + 1)
    begin
      i2c_send_byte(ganhos1[i]);
    end

    i2c_stop();
    #2000;  // pausa maior entre transmissões
  end
endtask

task i2c_start();
  begin
    i2c_sda_dir = 1;
    i2c_sda_out = 1;
    scl = 1;
    #50;
    i2c_sda_out = 0;  // SDA cai enquanto SCL alto: START
    #50;
    scl = 0;
    #100;
  end
endtask

task i2c_stop();
  begin
    i2c_sda_out = 0;
    scl = 1;
    #50;
    i2c_sda_out = 1;  // SDA sobe enquanto SCL alto: STOP
    #50;
  end
endtask

task i2c_send_bit(input b);
  begin
    i2c_sda_out = b;
    #20;         // setup time para SDA
    scl = 1;
    #100;        // tempo com SCL alto (amostragem slave)
    scl = 0;
    #100;        // tempo com SCL baixo antes próximo bit
  end
endtask

task i2c_read_ack();
  begin
    i2c_sda_dir = 0; // libera SDA para slave responder
    #20;             // setup
    scl = 1;
    #100;
    scl = 0;
    #100;
    i2c_sda_dir = 1; // mestre retoma controle
  end
endtask

task i2c_send_byte(input [7:0] byte);
  integer i;
  begin
    for (i = 7; i >= 0; i = i - 1)
      i2c_send_bit(byte[i]);
    i2c_read_ack();
  end
endtask

endmodule
