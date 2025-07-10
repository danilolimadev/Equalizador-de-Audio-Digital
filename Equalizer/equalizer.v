module equalizer(
    input clk,
    input reset,
    input [9:0] data_in,
    input [9:0] gains [9:0], 
    output [9:0] data_out,
    output [9:0] data_out_gain 
);

    reg [9:0] data_out_reg;

    genvar i;
    generate
        for (i = 0; i < 9; i = i + 1) begin
            // filtro filtro_inst (
            //     .clk(clk),
            //     .reset(reset),
            //     .data_in(data_in),
            //     .gain(gains[i]),
            //     .data_out(data_out[i])
            // );
            assign data_out_reg[i] = data_out[i]; //data_in * gains[i]; ?
        end
    endgenerate


   // Somatório das saídas dos filtros
    reg [9:0] sum;
    integer j;
    always @(*) begin
        sum = 1'b0;  //inicializa o somatório com 0
        for (j = 0; j < 9; j = j + 1) begin
            sum = sum + data_out_reg[j];
        end
    end

    assign data_out_gain = sum;

    // always @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         data_out_reg <= 16'd0;
    //     end else begin
    //         data_out_reg <= data_in;

    //     end
    // end

    // assign data_out = data_out_reg;
    //mux?

endmodule