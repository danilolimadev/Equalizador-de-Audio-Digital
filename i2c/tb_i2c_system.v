`timescale 1ns/100ps

module tb_i2c_system;

  parameter MAX_COUNT = 10;
  reg clk;
  reg rst_n;
  reg scl;
  wire sda;

  wire [7:0] reg_addr;
  wire [7:0] reg_data;
  wire reg_we;
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

  wire [12:0] gain1;
  wire [12:0] gain2;
  wire [12:0] gain3;
  wire [12:0] gain4;
  wire [12:0] gain5;
  wire [12:0] gain6;
  wire [12:0] gain7;
  wire [12:0] gain8;
  wire [12:0] gain9;
  wire [12:0] gain10;

  i2c_system #(.SLAVE_ADDR(I2C_ADDR)) dut (
               .clk(clk),
               .rst_n(rst_n),
               .scl(scl),
               .sda(sda),
               .gain_1(gain1),
               .gain_2(gain2),
               .gain_3(gain3),
               .gain_4(gain4),
               .gain_5(gain5),
               .gain_6(gain6),
               .gain_7(gain7),
               .gain_8(gain8),
               .gain_9(gain9),
               .gain_10(gain10),
               .reg_addr(reg_addr),
               .reg_data(reg_data),
               .reg_we(reg_we)
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

    ganhos1[0] = 8'd17;
    ganhos1[1] = 8'd18;
    ganhos1[2] = 8'd19;
    ganhos1[3] = 8'd20;
    ganhos1[4] = 8'd21;
    ganhos1[5] = 8'd22;
    ganhos1[6] = 8'd23;
    ganhos1[7] = 8'd24;
    ganhos1[8] = 8'd25;
    ganhos1[9] = 8'd26;

    ganhos2[0] = 8'd11;
    ganhos2[1] = 8'd12;
    ganhos2[2] = 8'd13;

    ganhos3[0] = 8'd14;
    ganhos3[1] = 8'd15;
    ganhos3[2] = 8'd16;

    ganhos4[0] = 8'd17;

    $display("--- Envio sequencial 4: só o 7 ---");
    //i2c_write_sequential_fixed(I2C_ADDR, 8'h07, 1, 4);

    $display("--- Envio sequencial 3: 8 ao 10 ---");
    //i2c_write_sequential_fixed(I2C_ADDR, 8'h08, 3, 3);

    $display("--- Envio sequencial 1: 1 ao 10 ---");
    i2c_write_sequential_fixed(I2C_ADDR, 8'h01, 10, 1);

    $display("--- Envio sequencial 2: 3 ao 5 ---");
    //i2c_write_sequential_fixed(I2C_ADDR, 8'h03, 3, 2);



    $stop;
  end

  // TASKS atualizados com delays maiores para SCL estável e amostragem segura

  task i2c_write_sequential_fixed(input [6:0] slave_addr, input [7:0] start_addr, input integer count, input integer select_array);
    integer i;
    begin
      i2c_start();
      i2c_send_byte({slave_addr, 1'b0});
      i2c_send_byte(start_addr);

      for (i = 0; i < count; i = i + 1)
      begin
        case (select_array)
          1:
            i2c_send_byte(ganhos1[i]);
          2:
            i2c_send_byte(ganhos2[i]);
          3:
            i2c_send_byte(ganhos3[i]);
          4:
            i2c_send_byte(ganhos4[i]);
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
