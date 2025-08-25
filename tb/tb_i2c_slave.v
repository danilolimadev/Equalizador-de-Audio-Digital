`timescale 1ns / 100ps

module tb_i2c_slave;

  reg clk;
  reg rst_n;

  // I2C
  reg scl;
  wire sda;
  reg i2c_sda_out;
  reg i2c_sda_dir;
  wire i2c_sda_in;

  parameter I2C_ADDR = 7'h6A;  // 0x6A
  reg [7:0] ganhos1 [0:15]; // Testes de 0 a 15 bytes

  assign sda = i2c_sda_dir ? i2c_sda_out : 1'bz;
  assign i2c_sda_in = sda;

  wire [7:0] data_out;
  wire data_ready;
  wire ack_error;
  wire start;
  wire [7:0] reg_addr;
  wire [7:0] reg_data;
  wire reg_we;

  i2c_slave #(.SLAVE_ADDR(I2C_ADDR)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .scl(scl),
    .sda(sda),
    .data_out(data_out),
    .data_in(8'hAA),
    .data_ready(data_ready),
    .ack_error(ack_error),
    .start(start),
    .reg_addr(reg_addr),
    .reg_data(reg_data),
    .reg_we(reg_we)
  );

  // Clock 50 MHz
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  initial begin
    // Inicialização
    rst_n = 0;
    scl = 1;
    i2c_sda_out = 1;
    i2c_sda_dir = 1;

    ganhos1[0] = 8'd10;
    ganhos1[1] = 8'd20;
    ganhos1[2] = 8'd30;
    ganhos1[3] = 8'd40;
    ganhos1[4] = 8'd50;
    ganhos1[5] = 8'd60;
    ganhos1[6] = 8'd70;
    ganhos1[7] = 8'd80;
    ganhos1[8] = 8'd90;
    ganhos1[9] = 8'd100;
    ganhos1[10] = 8'd110;
    ganhos1[11] = 8'd120;
    ganhos1[12] = 8'd130;
    ganhos1[13] = 8'd140;
    ganhos1[14] = 8'd150;
    ganhos1[15] = 8'd160;

    #100;
    rst_n = 1;
    #200;

    $display("\n--- Teste 1: Escrita válida de 10 bytes a partir do endereço 0x00 ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h00, 10);
    #1000;

    $display("\n--- Teste 2: Escrita de 5 bytes a partir do endereço 0x80 ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h80, 5);
    #1000;

    $display("\n--- Teste 3: Endereço I2C incorreto ---");
    i2c_write_sequential_fixed(7'h55, 8'h00, 3);
    #1000;

    $display("\n--- Teste 4: Escrita com parada abrupta após enviar 1 byte ---");
    i2c_start();
    i2c_send_byte({I2C_ADDR, 1'b0});
    i2c_send_byte(8'h22);  // start_addr
    i2c_stop();
    #1000;

    $display("\n--- Teste 5: Escrita de 0 bytes ---");
    i2c_start();
    i2c_send_byte({I2C_ADDR, 1'b0});
    i2c_stop();
    #1000;

    $display("\n--- Teste 6: Escrita de 16 bytes ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h10, 16);
    #1000;

    $display("\n--- Teste 7: START durante transmissão ---");
    i2c_start();
    i2c_send_byte({I2C_ADDR, 1'b0});
    i2c_send_byte(8'h33);
    #100;
    i2c_start(); // outro START no meio da comunicação!
    i2c_stop();
    #1000;

    $display("\n--- Testes finalizados ---");
    $stop;
  end


  task i2c_write_sequential_fixed(input [6:0] slave_addr, input [7:0] start_addr, input integer count);
    integer i;
    begin
      i2c_start();
      i2c_send_byte({slave_addr, 1'b0});
      i2c_send_byte(start_addr);

      for (i = 0; i < count; i = i + 1)
        i2c_send_byte(ganhos1[i]);

      i2c_stop();
      #1000;
    end
  endtask

  task i2c_start();
    begin
      i2c_sda_dir = 1;
      i2c_sda_out = 1;
      scl = 1;
      #50;
      i2c_sda_out = 0;
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
      i2c_sda_out = 1;
      #50;
    end
  endtask

  task i2c_send_bit(input b);
    begin
      i2c_sda_out = b;
      #20;
      scl = 1;
      #100;
      scl = 0;
      #100;
    end
  endtask

  task i2c_read_ack();
    begin
      i2c_sda_dir = 0;
      #20;
      scl = 1;
      #100;
      scl = 0;
      #100;
      i2c_sda_dir = 1;
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
