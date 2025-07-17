`timescale 1ns/100ps

module tb_i2c;

  parameter MAX_COUNT = 10;
  reg clk;
  reg reset;
  reg scl;
  wire sda;

  reg i2c_sda_out;
  reg i2c_sda_dir;
  wire i2c_sda_in;

  assign sda = i2c_sda_dir ? i2c_sda_out : 1'bz;
  assign i2c_sda_in = sda;

  wire [7:0] data_out;
  reg [7:0] data_in;
  wire data_ready;
  wire start;
  wire ack_error;

  parameter I2C_ADDR = 7'h6A;

  reg [7:0] ganhos1 [0:9];
  reg [7:0] ganhos2 [0:2];
  reg [7:0] ganhos3 [0:2];
  reg [7:0] ganhos4 [0:0];

  i2c_slave #(.SLAVE_ADDR(I2C_ADDR)) dut (
    .clk(clk),
    .reset(reset),
    .scl(scl),
    .sda(sda),
    .data_out(data_out),
    .data_in(data_in),
    .data_ready(data_ready),
    .ack_error(ack_error),
    .start(start)
  );

  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // 50 MHz clock
  end

  initial begin
    reset = 1;
    scl = 1;
    i2c_sda_dir = 1;
    i2c_sda_out = 1;
    #50;
    reset = 0;

    ganhos1[0] = 8'd1;
    ganhos1[1] = 8'd2;
    ganhos1[2] = 8'd3;
    ganhos1[3] = 8'd4;
    ganhos1[4] = 8'd5;
    ganhos1[5] = 8'd6;
    ganhos1[6] = 8'd7;
    ganhos1[7] = 8'd8;
    ganhos1[8] = 8'd9;
    ganhos1[9] = 8'd10;

    ganhos2[0] = 8'd11;
    ganhos2[1] = 8'd12;
    ganhos2[2] = 8'd13;

    ganhos3[0] = 8'd14;
    ganhos3[1] = 8'd15;
    ganhos3[2] = 8'd16;

    ganhos4[0] = 8'd17;

    $display("--- Envio sequencial 4: só o 7 ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h07, 1, 4);
    
    $display("--- Envio sequencial 3: 8 ao 10 ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h08, 3, 3);

    $display("--- Envio sequencial 1: 1 ao 10 ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h01, 10, 1);

    $display("--- Envio sequencial 2: 3 ao 5 ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h03, 3, 2);

    

    $stop;
  end

  // TASKS atualizados com delays maiores para SCL estável e amostragem segura

  task i2c_write_sequential_fixed(input [6:0] slave_addr, input [7:0] start_addr, input integer count, input integer select_array);
    integer i;
    begin
      i2c_start();
      i2c_send_byte({slave_addr, 1'b0});
      i2c_send_byte(start_addr);

      for (i = 0; i < count; i = i + 1) begin
        case (select_array)
          1: i2c_send_byte(ganhos1[i]);
          2: i2c_send_byte(ganhos2[i]);
          3: i2c_send_byte(ganhos3[i]);
          4: i2c_send_byte(ganhos4[i]);
        endcase
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
      //$display("ACK recebido: %b", i2c_sda_in);
      scl = 0;
      #100;
      i2c_sda_dir = 1; // mestre retoma controle
    end
  endtask

  task i2c_send_byte(input [7:0] byte);
    integer i;
    begin
      $display("Byte a enviar: %b", byte);
      for (i = 7; i >= 0; i = i - 1)
        i2c_send_bit(byte[i]);
      i2c_read_ack();
    end
  endtask

endmodule
