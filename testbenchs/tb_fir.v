`timescale 1ns/100ps

module all_filters_tb;

    reg  clk;
    reg  reset_n;
    reg  enable;
    reg signed [23:0] audio_in;

    wire signed [23:0] output_lowpass;
    wire signed [23:0] output_band_64_125;
    wire signed [23:0] output_band_125_250;
    wire signed [23:0] output_band_250_500;
    wire signed [23:0] output_band_500_1k;
    wire signed [23:0] output_band_1k_2k;
    wire signed [23:0] output_band_2k_4k;
    wire signed [23:0] output_band_4k_8k;
    wire signed [23:0] output_band_8k_16k;
    wire signed [23:0] output_highpass;
    

    
    fir_all_filters uut (
        .clk(clk), .reset_n(reset_n), .enable(enable), .audio_in(audio_in),
        .output_lowpass(output_lowpass), .output_band_64_125(output_band_64_125), .output_band_125_250(output_band_125_250),
        .output_band_250_500(output_band_250_500), .output_band_500_1k(output_band_500_1k),
        .output_band_1k_2k(output_band_1k_2k), .output_band_2k_4k(output_band_2k_4k),
        .output_band_4k_8k(output_band_4k_8k), .output_band_8k_16k(output_band_8k_16k),
        .output_highpass(output_highpass)
    );

    
    initial clk = 0;
    always #10 clk = ~clk;

    
    initial begin

        reset();
        enable();

        impulse_test();         arquivo_saida("impulse.csv");      
        step_test();            arquivo_saida("step.csv");
        ramp_test();            arquivo_saida("ramp.csv");
        hold_test();            arquivo_saida("hold.csv");
        noise_test();           arquivo_saida("noise.csv");

        $stop;
    end




    integer N;
    integer f;


      task arquivo_saida(input [1023:0] nome_arquivo);
        begin
            #100;
            f = $fopen(nome_arquivo, "w");
            $fwrite(f, "tempo,audio_in,output_lowpass,output_highpass,output_band_64_125,output_band_125_250,output_band_250_500,output_band_500_1k,output_band_1k_2k,output_band_2k_4k,output_band_4k_8k,output_band_8k_16k\n");

            repeat (300) begin
                @(posedge clk);
                $fwrite(f, "%0t,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n", $time, audio_in, output_lowpass, output_highpass, output_band_64_125, output_band_125_250, output_band_250_500, output_band_500_1k, output_band_1k_2k, output_band_2k_4k, output_band_4k_8k, output_band_8k_16k);
            end
            $fclose(f);

        end  
    endtask


  

    task reset;
        begin
            reset_n = 0;
            enable = 0;
            audio_in = 0;
            repeat (5) @(posedge clk);
            reset_n = 1;
        end
    endtask

    task enable;
        begin
            enable = 1;
        end
    endtask

    task impulse_test;
        begin
            audio_in = 24'sd1000000;
            @(posedge clk);
            audio_in = 0;
            repeat (N+10) @(posedge clk);
        end
    endtask

    task step_test;
        begin
            audio_in = 24'sd500000;
            repeat (300) @(posedge clk);
        end
    endtask

    task ramp_test;
        begin
            audio_in = 0;
            repeat (500) begin
                @(posedge clk);
                audio_in = audio_in + 24'sd1000;
            end
        end
    endtask


    task hold_test;
        begin
            audio_in = 24'sd123456;
            @(posedge clk);
            enable = 0;
            audio_in = 24'sd654321;
            @(posedge clk);
            enable = 1;
        end
    endtask

    task noise_test;
        begin
            repeat (300) begin
                @(posedge clk);
                audio_in = $random % (2**23); 
            end
        end
    endtask

endmodule
