module i2c_slave #(
    parameter SLAVE_ADDR = 7'h50  // reg_data padrão
  )(
    input wire clk,
    input wire rst_n,
    input wire scl,
    inout wire sda,
    output reg [7:0] data_out,
    input wire [7:0] data_in,
    output reg data_ready,
    output reg ack_error,
    output reg start,
    output reg [7:0] reg_addr,
    output reg [7:0] reg_data,
    output reg reg_we
  );

  localparam IDLE      = 3'b000;
  localparam ADDR      = 3'b001;
  localparam ACK_ADDR  = 3'b010;
  localparam READ      = 3'b011;  // Mestre escreve no escravo (recebendo bytes)
  localparam WRITE     = 3'b100;  // Mestre lê do escravo (enviando bytes)
  localparam ACK_DATA  = 3'b101;

  reg [7:0] shift_reg;
  reg [2:0] bit_count;
  reg [2:0] state, next_state;
  reg sda_out;
  reg sda_drive;
  reg scl_sync;
  reg sda_sync;
  reg scl_last;
  reg sda_last;



  reg option; // single driver

  reg rw_flag; // 0 = write (mestre escreve), 1 = read (mestre lê)
  reg new_data;

  assign sda = (sda_drive) ? sda_out : 1'bz;

  always @(posedge clk or negedge rst_n)
begin
  if (!rst_n)
  begin
    scl_sync  <= 1;
    sda_sync  <= 1;
    scl_last  <= 1;
    sda_last  <= 1;
    reg_we    <= 0;
    new_data  <= 0;
    option    <= 0;
    reg_data  <= 0;
    reg_addr  <= 0;
  end
  else
  begin
    scl_sync  <= scl;
    sda_sync  <= sda;
    scl_last  <= scl_sync;
    sda_last  <= sda_sync;
    reg_we    <= 0;


      if (state == READ && bit_count == 0 && scl_last && !scl_sync) begin
        new_data <= 1'b1;
      end
      
      if (new_data) begin
        new_data <= 1'b0;
        if (option) begin
          reg_data <= shift_reg;
          reg_addr <= reg_addr + 1;
          reg_we <= 1'b1;
        end
        else begin
          option <= 1'b1;
          reg_addr <= shift_reg - 1;
        end
      end
      else begin
        reg_we <= 1'b0;
      end
    end
  end
    
  // Detect start/stop
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      start <= 0;
    end
    else
    begin
      if (!start && scl_sync && sda_last && !sda_sync)
      begin
        start <= 1;
      end
      else if (start && scl_sync && !sda_last && sda_sync)
      begin
        start <= 0;
      end
    end
  end

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      state <= IDLE;
    else
      state <= next_state;
  end

  always @(*)
  begin
    next_state = state;

    if (!start)
      next_state = IDLE;
    else
    begin
      case (state)
        IDLE:
        begin
          if (start && scl_last && !scl_sync)
            next_state = ADDR;
        end

        ADDR:
        begin
          if (scl_last && !scl_sync)
          begin
            if (bit_count == 0)
              next_state = ACK_ADDR;
          end
        end

        ACK_ADDR:
        begin
          if (scl_last && !scl_sync)
          begin
            if (shift_reg[7:1] == SLAVE_ADDR)
            begin
              if (shift_reg[0] == 0)
                next_state = READ;
              else
                next_state = WRITE;
            end
            else
            begin
              next_state = IDLE;
            end
          end
        end

        READ:
        begin
          if (scl_last && !scl_sync && bit_count == 0)
            next_state = ACK_DATA;
        end

        WRITE:
        begin
          if (scl_last && !scl_sync && bit_count == 0)
            next_state = ACK_DATA;
        end

        ACK_DATA:
        begin
          if (scl_last && !scl_sync)
          begin
            if (rw_flag == 0)
              next_state = READ;  // Mestre vai enviar mais bytes para escravo
            else
              next_state = WRITE; // Escravo vai enviar mais bytes para mestre
          end
        end

        default:
          next_state = IDLE;
      endcase
    end
  end

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      bit_count <= 7;
      shift_reg <= 8'b0;
      data_ready <= 0;
      ack_error <= 0;
      data_out <= 0;
      sda_drive <= 0;
      sda_out <= 1;
      rw_flag <= 0;
    end
    else
    begin
      case(state)
        IDLE:
        begin
          bit_count <= 7;
          shift_reg <= 8'b0;
          data_ready <= 0;
          ack_error <= 0;
          data_out <= 0;
          sda_drive <= 0;
          sda_out <= 1;
          rw_flag <= 0;
          option <= 1'b0;
        end

        ADDR:
        begin
          if (!scl_last && scl_sync)
          begin
            shift_reg[bit_count] <= sda_sync;
          end
          if (scl_last && !scl_sync)
            bit_count <= bit_count - 1'd1;
        end

        ACK_ADDR:
        begin
          sda_drive <= 1;
          sda_out <= 0; // ACK = 0
          if (scl_last && !scl_sync)
          begin
            if (shift_reg[7:1] == SLAVE_ADDR)
            begin
              bit_count <= 7;
              rw_flag <= shift_reg[0];
            end
            else
            begin
              sda_out <= 1; // NACK para endereço inválido
            end
          end
        end

        READ:
        begin
          sda_drive <= 0;
          if (!scl_last && scl_sync)
          begin
            shift_reg[bit_count] <= sda_sync;
            if (bit_count == 0)
            begin
              data_out <= shift_reg;
              data_ready <= 1;
            end
          end
          if (scl_last && !scl_sync)
            bit_count <= bit_count - 1'd1;
        end

        WRITE:
        begin
          sda_drive <= 1;
          sda_out <= data_in[bit_count];
          if (scl_last && !scl_sync)
            bit_count <= bit_count - 1'd1;
        end

        ACK_DATA:
        begin
          sda_drive <= 1;
          sda_out <= 0; // ACK do escravo para o mestre

          if (scl_last && !scl_sync)
          begin
            data_ready <= 0; // Limpa flag para o próximo byte
            bit_count <= 7;
          end
        end
      endcase
    end
  end

endmodule


