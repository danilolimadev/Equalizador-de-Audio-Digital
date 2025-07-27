import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin, freqz

def salvar_array_verilog_signed12(nome_arquivo, vetor):
    """
    Salva um vetor de inteiros em um arquivo txt formatado como array Verilog
    com valores signed de 12 bits, todos em uma única linha.

    Args:
        nome_arquivo (str): Nome do arquivo de saída (ex: "meu_array.txt")
        vetor (list[int]): Lista de inteiros com sinal (range: -2048 a 2047)
    """
    with open(nome_arquivo, 'w') as f:
        f.write("// Signed 12-bit Verilog array\n")
        f.write(f"logic signed [11:0] my_array [{len(vetor)-1}:0] = '{{")

        valores = []
        for i, val in enumerate(vetor):
            if val < -2048 or val > 2047:
                raise ValueError(f"Valor fora do intervalo signed 12-bit: {val} (índice {i})")
            sinal = '-' if val < 0 else ''
            valor_abs = abs(val)
            valores.append(f"{sinal}12'sd{valor_abs}")

        f.write(", ".join(valores))
        f.write("};\n")

# %% Setup the parameters
Sample_Rate = 48e3
filter_type = 'bandpass'  # 'low', 'high', or 'bandpass'

cutoff_frequency = 16000   # for low/high
band_edges        = [64, 125]  # for bandpass: [low_cutoff, high_cutoff] in Hz

number_of_filter_taps = 1024  # 32 for lowpass; 31 for highpass
filter_taps_bitwidth = 12   # Q1.11
# output_hex_file       = "high.hex"

# %% Calculate the taps
Nyquist_frequency = Sample_Rate / 2

if filter_type == 'low':
    Wn = cutoff_frequency / Nyquist_frequency
    pass_zero = True
elif filter_type == 'high':
    Wn = cutoff_frequency / Nyquist_frequency
    pass_zero = False
elif filter_type == 'bandpass':
    Wn = [f / Nyquist_frequency for f in band_edges]
    pass_zero = False
else:
    raise ValueError("Invalid filter type. Use 'low', 'high', or 'bandpass'.")

# Generate the FIR filter taps
filter_taps = firwin(
    numtaps=number_of_filter_taps,
    cutoff=Wn,
    window="hamming",
    pass_zero=pass_zero
)

# %% Quantization (Q1.11)
max_val = np.max(np.abs(filter_taps))
quantized_taps = np.floor(
    filter_taps / max_val * (2**(filter_taps_bitwidth - 1) - 1)
).astype(int)

# Optional: zero-padded version for 31-tap highpass
filter_taps_zero_padded = np.concatenate(([0], quantized_taps))

salvar_array_verilog_signed12("filter_taps.txt", filter_taps_zero_padded)

# %% Frequency response
N = 1024
w, h = freqz(quantized_taps, worN=N, fs=Sample_Rate)
magnitude = np.abs(h)

# %% Plot magnitude response
plt.figure()
plt.plot(w, 20 * np.log10(magnitude + 1e-10), linewidth=1.3)  # add small offset to avoid log(0)
plt.grid(True)
plt.title(f'Magnitude Response ({filter_type.capitalize()} Filter)', fontsize=22)
plt.xlabel('Frequency (Hz)', fontsize=22)
plt.ylabel('Magnitude (dB)', fontsize=22)

# %% Plot using freqz interactive style
plt.figure()
w2, h2 = freqz(quantized_taps, fs=Sample_Rate)
plt.plot(w2, 20 * np.log10(np.abs(h2) + 1e-10), linewidth=1.3)
plt.grid(True)
plt.title(f'Interactive-style Frequency Response ({filter_type.capitalize()})')
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude (dB)')

# %% Stem plot of filter taps
plt.figure()
plt.stem(
    quantized_taps,
    basefmt=" ",
    linefmt='b-',
    markerfmt='bo'
)
plt.grid(True)
plt.title(f'Quantized Filter Taps ({filter_type.capitalize()})')
plt.xlabel('Tap Index')
plt.ylabel('Coefficient Value')
plt.show()
