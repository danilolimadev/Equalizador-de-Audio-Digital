`timescale 1ns/1ps

module fir_testbench;

    reg clk = 0;
    always #10 clk = ~clk; // Clock de 50MHz (20ns período)

    reg rst_n = 0;
    reg signed [23:0] audio_in = 0;

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

    fir_all_filters dut (
        .clk(clk),
        .rst_n(rst_n),
        .audio_in(audio_in),
        .output_lowpass(output_lowpass),
        .output_band_64_125(output_band_64_125),
        .output_band_125_250(output_band_125_250),
        .output_band_250_500(output_band_250_500),
        .output_band_500_1k(output_band_500_1k),
        .output_band_1k_2k(output_band_1k_2k),
        .output_band_2k_4k(output_band_2k_4k),
        .output_band_4k_8k(output_band_4k_8k),
        .output_band_8k_16k(output_band_8k_16k),
        .output_highpass(output_highpass)
    );

    integer f_out;

    task apply_stimulus_and_capture;
        input [8*32:1] filename;
        input integer stimulus_type;
        integer i;
        begin
            rst_n = 0;
            audio_in = 0;
            #100;
            rst_n = 1;
            #20;

            f_out = $fopen(filename, "w");
            $fdisplay(f_out, "sample,input,lowpass,64_125,125_250,250_500,500_1k,1k_2k,2k_4k,4k_8k,8k_16k,highpass");

            for (i = 0; i < 512; i = i + 1) begin
                case (stimulus_type)
                    1: audio_in = (i < 80) ? 24'sd0 : 24'sh400000; // Degrau
                    2: audio_in = i <<< 12;                       // Rampa
                    3: audio_in = 24'sh100000;                    // Valor constante
                    4: audio_in = $random;                        // Ruído
                    default: audio_in = 24'sd0;
                endcase

                @(posedge clk);
                $fdisplay(f_out, "%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                          i,
                          audio_in,
                          output_lowpass,
                          output_band_64_125,
                          output_band_125_250,
                          output_band_250_500,
                          output_band_500_1k,
                          output_band_1k_2k,
                          output_band_2k_4k,
                          output_band_4k_8k,
                          output_band_8k_16k,
                          output_highpass);
            end

            $fclose(f_out);
        end
    endtask

    initial begin
        apply_stimulus_and_capture("step.csv",    1);
        apply_stimulus_and_capture("ramp.csv",    2);
        apply_stimulus_and_capture("constant.csv",3);
        apply_stimulus_and_capture("noise.csv",   4);
        $stop;
    end

endmodule
