import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin, freqz

# %% Setup the parameters
Sample_Rate = 48e3
filter_type = 'bandpass'  # 'low', 'high', or 'bandpass'

cutoff_frequency = 16000   # for low/high
band_edges        = [4000, 8000]  # for bandpass: [low_cutoff, high_cutoff] in Hz

number_of_filter_taps = 31  # 32 for lowpass; 31 for highpass
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

# %% Save to .hex in two’s-complement 12-bit
#with open(output_hex_file, "w") as f:
#    for c in quantized_taps:
#        # &0xFFF ensures two’s-complement 12-bit representation
#        hexval = format(c & 0xFFF, '03x')
#        f.write(hexval + "\n")
#print(f"Gravados {len(quantized_taps)} coeficientes em '{output_hex_file}'")

# Optional: zero-padded version for 31-tap highpass
filter_taps_zero_padded = np.concatenate(([0], quantized_taps))

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
