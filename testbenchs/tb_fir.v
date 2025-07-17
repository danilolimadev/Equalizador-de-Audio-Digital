`timescale 1ns/100ps

module all_filters_tb;

    reg  i_clk;
    reg  i_rst_n;
    reg  i_en;
    reg signed [23:0] i_data;

    wire signed [23:0] o_lp;
    wire signed [23:0] o_band_64_125;
    wire signed [23:0] o_band_125_250;
    wire signed [23:0] o_band_250_500;
    wire signed [23:0] o_band_500_1k;
    wire signed [23:0] o_band_1k_2k;
    wire signed [23:0] o_band_2k_4k;
    wire signed [23:0] o_band_4k_8k;
    wire signed [23:0] o_band_8k_16k;
    wire signed [23:0] o_hp;
    wire signed [23:0] o_sum;

    
    fir_all_filters uut (
        .i_clk(i_clk), .i_rst_n(i_rst_n), .i_en(i_en), .i_data(i_data),
        .o_lp(o_lp), .o_band_64_125(o_band_64_125), .o_band_125_250(o_band_125_250),
        .o_band_250_500(o_band_250_500), .o_band_500_1k(o_band_500_1k),
        .o_band_1k_2k(o_band_1k_2k), .o_band_2k_4k(o_band_2k_4k),
        .o_band_4k_8k(o_band_4k_8k), .o_band_8k_16k(o_band_8k_16k),
        .o_hp(o_hp), .o_sum(o_sum)
    );

    
    initial i_clk = 0;
    always #10 i_clk = ~i_clk;

    
    initial begin

        reset();
        enable();

        impulse_test();         arquivo_saida("impulse.csv");
        step_test();            arquivo_saida("step.csv");
        ramp_test();            arquivo_saida("ramp.csv");
        burst_test();           arquivo_saida("burst.csv");
        hold_test();            arquivo_saida("hold.csv");
        noise_test();           arquivo_saida("noise.csv");
        extreme_value_test();   arquivo_saida("extreme.csv");


        $stop;
    end




    integer N;
    integer f;

        task arquivo_saida;
        begin
            f = $fopen("saida_filtros.csv", "w");
            $fwrite(f, "tempo,i_data,o_lp,o_hp,o_band_64_125,o_band_125_250,o_band_250_500,o_band_500_1k,o_band_1k_2k,o_band_2k_4k,o_band_4k_8k,o_band_8k_16k\n");

            repeat (300) begin
                @(posedge i_clk);
                $fwrite(f, "%0t,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n", $time, i_data, o_lp, o_hp, o_band_64_125, o_band_125_250, o_band_250_500, o_band_500_1k, o_band_1k_2k, o_band_2k_4k, o_band_4k_8k, o_band_8k_16k);
            end
            $fclose(f);
        end  
    endtask

  

    task reset;
        begin
            i_rst_n = 0;
            i_en = 0;
            i_data = 0;
            repeat (5) @(posedge i_clk);
            i_rst_n = 1;
        end
    endtask

    task enable;
        begin
            i_en = 1;
        end
    endtask

    task impulse_test;
        begin
            i_data = 24'sd1000000;
            @(posedge i_clk);
            i_data = 0;
            repeat (N+10) @(posedge i_clk);
        end
    endtask

    task step_test;
        begin
            i_data = 24'sd500000;
            repeat (300) @(posedge i_clk);
        end
    endtask

    task ramp_test;
        begin
            i_data = 0;
            repeat (500) begin
                @(posedge i_clk);
                i_data = i_data + 24'sd1000;
            end
        end
    endtask

    task burst_test;
        begin
            i_data = 24'sd400000;
            repeat (3) @(posedge i_clk);
            i_data = 0;
            repeat (300) @(posedge i_clk);
        end
    endtask

    task hold_test;
        begin
            i_data = 24'sd123456;
            @(posedge i_clk);
            i_en = 0;
            i_data = 24'sd654321;
            @(posedge i_clk);
            i_en = 1;
        end
    endtask

    task noise_test;
        begin
            repeat (300) begin
                @(posedge i_clk);
                i_data = $random % (2**23); 
            end
        end
    endtask

    task extreme_value_test;
        begin
            i_data = 24'sd8388607;
            repeat (10) @(posedge i_clk);
            i_data = -24'sd8388608;
            repeat (10) @(posedge i_clk);
            i_data = 0;
            repeat (50) @(posedge i_clk);
        end
    endtask

endmodule
