`timescale 1ns/100ps

module tb_i2c;

  reg clk;
  reg rst_n;
  reg scl;
  wire sda;

  reg i2c_sda_out;
  reg i2c_sda_dir;
  wire i2c_sda_in;

  assign sda = i2c_sda_dir ? i2c_sda_out : 1'bz;
  assign i2c_sda_in = sda;

  wire reg_write_enable;
  wire data_ready;
  wire start_detect;
  wire ack_error;
  wire [4:0] reg_addr;
  wire [7:0] data_out;

  parameter I2C_ADDR = 7'h6A;

  reg [7:0] data_in = 8'hAA;

  i2c_slave dut (
              .clk(clk),
              .rst_n(rst_n),
              .scl(scl),
              .sda(sda),
              .data_in(data_in),
              .data_out(data_out),
              .reg_write_enable(reg_write_enable),
              .data_ready(data_ready),
              .start(start_detect),
              .ack_error(ack_error),
              .reg_addr(reg_addr)
            );

  initial
  begin
    clk = 0;
    forever
      #10 clk = ~clk;
  end

  initial
  begin
    rst_n = 0;
    scl = 1;
    i2c_sda_dir = 1;
    i2c_sda_out = 1;
    #20;
    rst_n = 1;

    $display("--- Teste 1: Escrita simples ---");
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
    #100;

    $display("--- Teste 2: Escrita no registrador máximo (29) ---");
    i2c_write_reg(I2C_ADDR, 8'h1D, 8'h5A);
    #100;

    $display("--- Teste 3: Endereço inválido ---");
    i2c_write_reg(7'h55, 8'h01, 8'hFF);
    #100;

    $display("--- Teste 4: START seguido de STOP ---");
    i2c_start();
    i2c_stop();
    #20;

    $stop;
  end

  task i2c_start();
    begin
      i2c_sda_dir = 1;
      i2c_sda_out = 1;
      scl = 1;
      #5;
      i2c_sda_out = 0;
      #5;
    end
  endtask

  task i2c_stop();
    begin
      i2c_sda_out = 0;
      scl = 1;
      #5;
      i2c_sda_out = 1;
      #5;
    end
  endtask

  task i2c_send_bit(input b);
    begin
      i2c_sda_out = b;
      #1;
      scl = 1;
      #5;
      scl = 0;
      #5;
    end
  endtask

  task i2c_read_ack();
    begin
      i2c_sda_dir = 0;
      scl = 1;
      #5;
      $display("ACK recebido: %b", i2c_sda_in);
      scl = 0;
      #5;
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

  task i2c_write_reg(input [6:0] slave_addr, input [7:0] register_addr, input [7:0] data);
    begin
      i2c_start();
      i2c_send_byte({slave_addr, 1'b0});
      i2c_send_byte(register_addr);
      i2c_send_byte(data);
      i2c_stop();
      #200;
    end
  endtask

endmodule
