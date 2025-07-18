module i2c_system #(
    parameter SLAVE_ADDR = 7'h50  // Valor padrão
  )(
    input wire clk,
    input wire rst_n,
    input wire scl,
    input wire sda,
    output wire [12:0] gain_1,
    output wire [12:0] gain_2,
    output wire [12:0] gain_3,
    output wire [12:0] gain_4,
    output wire [12:0] gain_5,
    output wire [12:0] gain_6,
    output wire [12:0] gain_7,
    output wire [12:0] gain_8,
    output wire [12:0] gain_9,
    output wire [12:0] gain_10,
    output wire [7:0] reg_addr,
    output wire [7:0] reg_data,
    output wire reg_we
  );
  // Conexões entre i2c_slave e reg_map
  /*wire [7:0] reg_addr;
  wire [7:0] reg_data;
  wire reg_we;

  wire [12:0] gain1;
  wire [12:0] gain2;
  wire [12:0] gain3;
  wire [12:0] gain4;
  wire [12:0] gain5;
  wire [12:0] gain6;
  wire [12:0] gain7;
  wire [12:0] gain8;
  wire [12:0] gain9;
  wire [12:0] gain10;*/

  wire [7:0] data_out;
  reg [7:0] data_in;

  wire [2:0] i2c_state;

  // Instância do i2c_slave
  i2c_slave #(.SLAVE_ADDR(SLAVE_ADDR)) dut (
              .clk(clk),
              .rst_n(rst_n),
              .scl(scl),
              .sda(sda),
              .data_out(data_out),
              .data_in(data_in),
              .data_ready(data_ready),
              .ack_error(ack_error),
              .start(start),
              .reg_addr(reg_addr),
              .reg_data(reg_data),
              .reg_we(reg_we)
            );

  reg_map #(
            .GAIN_WIDTH(13)
          ) reg_map_inst (
            .clk(clk),
            .rst_n(rst_n),
            .we(reg_we),
            .addr(reg_addr),
            .data_in(reg_data),
            .gain_1(gain_1),
            .gain_2(gain_2),
            .gain_3(gain_3),
            .gain_4(gain_4),
            .gain_5(gain_5),
            .gain_6(gain_6),
            .gain_7(gain_7),
            .gain_8(gain_8),
            .gain_9(gain_9),
            .gain_10(gain_10)
          );
endmodule