module reg_map (
    input clk,
    input rst_n,
    input we,
    input [7:0] addr,
    input [7:0] data_in,
    output [7:0] gain_1,
    output [7:0] gain_2,
    output [7:0] gain_3,
    output [7:0] gain_4,
    output [7:0] gain_5,
    output [7:0] gain_6,
    output [7:0] gain_7,
    output [7:0] gain_8,
    output [7:0] gain_9,
    output [7:0] gain_10
  );
  // Banco de 10 registradores de 13 bits
  reg [7:0] regbank [0:9];

  // Escrita e reset
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      regbank[0] <= 8'b0000_0000;
      regbank[1] <= 8'b0000_0000;
      regbank[2] <= 8'b0000_0000;
      regbank[3] <= 8'b0000_0000;
      regbank[4] <= 8'b0000_0000;
      regbank[5] <= 8'b0000_0000;
      regbank[6] <= 8'b0000_0000;
      regbank[7] <= 8'b0000_0000;
      regbank[8] <= 8'b0000_0000;
      regbank[9] <= 8'b0000_0000;
    end
    else if (we)
    begin
      regbank[addr] <= data_in;
    end
  end

  //Criação dos ganhos e seus respectivos mapas de registros
  assign gain_1  = regbank[0];
  assign gain_2  = regbank[1];
  assign gain_3  = regbank[2];
  assign gain_4  = regbank[3];
  assign gain_5  = regbank[4];
  assign gain_6  = regbank[5];
  assign gain_7  = regbank[6];
  assign gain_8  = regbank[7];
  assign gain_9  = regbank[8];
  assign gain_10 = regbank[9];

endmodule



