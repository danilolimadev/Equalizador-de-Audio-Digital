import numpy as np
from scipy.signal import firwin
import os
import zipfile

# Parâmetros
fs = 48000
num_taps = 255
scale = 2**15  # 1.15 formato

bands = [
    ("band_lp", 0, 64),
    ("band_64_125", 64, 125),
    ("band_125_250", 125, 250),
    ("band_250_500", 250, 500),
    ("band_500_1k", 500, 1000),
    ("band_1k_2k", 1000, 2000),
    ("band_2k_4k", 2000, 4000),
    ("band_4k_8k", 4000, 8000),
    ("band_8k_16k", 8000, 16000),
    ("band_hp", 16000, None)
]

output_dir = "fir_bands_equalizer"
os.makedirs(output_dir, exist_ok=True)

file_paths = []
for name, f1, f2 in bands:
    if f2 is None:
        coeffs = firwin(num_taps, f1, fs=fs, window="hamming", pass_zero=False)
    elif f1 == 0:
        coeffs = firwin(num_taps, f2, fs=fs, window="hamming", pass_zero=True)
    else:
        coeffs = firwin(num_taps, [f1, f2], fs=fs, window="hamming", pass_zero=False)
    
    quantized = np.round(coeffs * scale).astype(np.int16)
    filename = f"{name}.hex"
    filepath = os.path.join(output_dir, filename)
    with open(filepath, "w") as f:
        for q in quantized:
            f.write(f"{q & 0xFFFF:04X}\n")
    file_paths.append(filepath)

# Salvar todos em um zip
zip_path = "fir_bands_equalizer.zip"
with zipfile.ZipFile(zip_path, 'w') as zipf:
    for file in file_paths:
        zipf.write(file, arcname=os.path.basename(file))

print(f"Coeficientes gerados em: {output_dir}")
print(f"Arquivo ZIP gerado em: {zip_path}")
