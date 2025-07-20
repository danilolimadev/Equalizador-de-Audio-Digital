module reg_map #(
    parameter GAIN_WIDTH = 13  
)(
    input clk,
    input rst_n,
    input we,
    input [7:0] addr,
    input [7:0] data_in, 
    output [GAIN_WIDTH-1:0] gain_1,
    output [GAIN_WIDTH-1:0] gain_2,
    output [GAIN_WIDTH-1:0] gain_3,
    output [GAIN_WIDTH-1:0] gain_4,
    output [GAIN_WIDTH-1:0] gain_5,
    output [GAIN_WIDTH-1:0] gain_6,
    output [GAIN_WIDTH-1:0] gain_7,
    output [GAIN_WIDTH-1:0] gain_8,
    output [GAIN_WIDTH-1:0] gain_9,
    output [GAIN_WIDTH-1:0] gain_10
);
    // Banco de 10 registradores de 13 bits 
    reg [12:0] regbank [0:9];
    

    wire [12:0] data_converted;

    converter_Q5_8 converter_inst ( 
        .gain_in(data_in),
        .gain_out(data_converted)
    );

    // Escrita e reset
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 10; i = i + 1)
                regbank[i] <= 13'b00001_00000000;
        end else if (we) begin
            regbank[addr] <= data_converted;
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
