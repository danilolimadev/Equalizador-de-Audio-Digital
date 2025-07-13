module reg_map #(
    parameter GAIN_WIDTH = 24,    
    parameter ADDR_WIDTH = 31      
)(
    input clk,
    input rst,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [7:0] data_in, 
    output [7:0] configuration, 
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
    // Banco de 31 registradores de 8 bits (3 bytes por ganho)
    reg [7:0] regbank [0:ADDR_WIDTH-1];

    // Escrita e reset
    integer i;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 31; i = i + 1)
                regbank[i] <= 8'd0;
        end else if (we) begin
            regbank[addr] <= data_in;
        end
    end

    //Criação dos ganhos e seus respectivos mapas de registros
    assign configuration =    {regbank[0]}; // Para armazenar bits de configuração 
    assign gain_1 = {regbank[3],  regbank[2],  regbank[1]};
    assign gain_2 = {regbank[6],  regbank[5],  regbank[4]};
    assign gain_3 = {regbank[9],  regbank[8],  regbank[7]};
    assign gain_4 = {regbank[12], regbank[11], regbank[10]};
    assign gain_5 = {regbank[15], regbank[14], regbank[13]};
    assign gain_6 = {regbank[18], regbank[17], regbank[16]};
    assign gain_7 = {regbank[21], regbank[20], regbank[19]};
    assign gain_8 = {regbank[24], regbank[23], regbank[22]};
    assign gain_9 = {regbank[27], regbank[26], regbank[25]};
    assign gain_10 = {regbank[30], regbank[29], regbank[28]};

endmodule
