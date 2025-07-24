import numpy as np
import pandas as pd
import os

# === Parâmetros ===
N = 31
INT_WIDTH = 24
FRAC_BITS = 11  # Q1.11
SAMPLES = 512
OUTPUT_FOLDER = "fir_outputs_int"

# === Conversão de coeficiente hexadecimal para inteiro com sinal (12 bits) ===
def hex_to_signed12(h):
    val = int(h, 16)
    return val - 0x1000 if val & 0x800 else val

# === Coeficientes dos filtros ===
def get_coeffs(hex_list):
    return np.array([hex_to_signed12(h) for h in hex_list], dtype=np.int64)

filters = {
    "lowpass": get_coeffs([
        "0a3", "0b7", "0f4", "157", "1da", "279", "32d", "3ee", "4b3", "573", "627",
        "c67", "74a", "7ad", "7ea", "7ff", "7ea", "7ad", "74a", "c67", "627", "573",
        "4b3", "3ee", "32d", "279", "1da", "157", "0f4", "0b7", "0a3"
    ]),
    "band_64_125": get_coeffs([
        "0a0", "0b5", "0f1", "153", "1d6", "275", "329", "3e9", "4af", "570", "625",
        "6c5", "749", "7ac", "7ea", "7ff", "7ea", "7ac", "749", "6c5", "625", "570",
        "4af", "3e9", "329", "275", "1d6", "153", "0f1", "0b5", "0a0"
    ]),
    "band_125_250": get_coeffs([
        "098", "0ad", "0e8", "148", "1c9", "266", "319", "3da", "4a1", "564", "61b",
        "6be", "745", "7ab", "7e9", "7ff", "7e9", "7ab", "745", "6be", "61b", "564",
        "4a1", "3da", "319", "266", "1c9", "148", "0e8", "0ad", "098"
    ]),
    "band_250_500": get_coeffs([
        "078", "08d", "0c3", "11b", "195", "22d", "2dd", "39f", "46a", "536", "5f7",
        "6a4", "736", "7a3", "7e7", "7ff", "7e7", "7a3", "736", "6a4", "5f7", "536",
        "46a", "39f", "2dd", "22d", "195", "11b", "0c3", "08d", "078"
    ]),
    "band_500_1k": get_coeffs([
        "00f", "022", "045", "080", "0db", "15a", "1fd", "2bf", "39a", "481", "567",
        "63e", "6f7", "786", "7e0", "7ff", "7e0", "786", "6f7", "63e", "567", "481",
        "39a", "2bf", "1fd", "15a", "0db", "080", "045", "022", "00f"
    ]),
    "band_1k_2k": get_coeffs([
        "f77", "f6c", "f4b", "f25", "f0e", "f1e", "f6a", "000", "0e2", "208", "35c",
        "4bd", "606", "712", "7c2", "7ff", "7c2", "712", "606", "4bd", "35c", "208",
        "0e2", "000", "f6a", "f1e", "f0e", "f25", "f4b", "f6c", "f77"
    ]),
    "band_2k_4k": get_coeffs([
        "047", "044", "036", "fff", "f82", "eb4", "db1", "cbf", "c3d", "c87", "dce",
        "000", "2b8", "55e", "74a", "7ff", "74a", "55e", "2b8", "000", "dce", "c87",
        "c3d", "cbf", "db1", "eb4", "f82", "fff", "036", "044", "047"
    ]),
    "band_4k_8k": get_coeffs([
        "feb", "000", "00d", "fff", "fe1", "000", "0ac", "1a0", "1c0", "fff", "cc9",
        "a64", "b5b", "000", "588", "7ff", "588", "000", "b5b", "a64", "cc9", "fff",
        "1c0", "1a0", "0ac", "000", "fe1", "fff", "00d", "000", "feb"
    ]),
    "band_8k_16k": get_coeffs([
        "fff", "fea", "000", "fff", "000", "068", "fff", "f2f", "000", "fff", "000",
        "2cd", "fff", "9a6", "000", "7ff", "000", "9a6", "fff", "2cd", "000", "fff",
        "000", "f2f", "fff", "068", "000", "fff", "000", "fea", "fff"
    ]),
    "highpass": get_coeffs([
        "000", "00a", "ff0", "fff", "023", "fcb", "000", "068", "f71", "fff", "104",
        "e99", "000", "32c", "974", "7ff", "974", "32c", "000", "e99", "104", "fff",
        "f71", "068", "000", "fcb", "023", "fff", "ff0", "00a", "000"
    ])
}

# === Estímulos ===
def generate_input(stim_type):
    if stim_type == "step":
        data = np.zeros(SAMPLES, dtype=np.int64)
        data[80:] = 0x400000
    elif stim_type == "ramp":
        data = np.arange(SAMPLES, dtype=np.int64) << 12
    elif stim_type == "constant":
        data = np.ones(SAMPLES, dtype=np.int64) * 0x100000
    elif stim_type == "noise":
        data = np.random.randint(-2**23, 2**23, SAMPLES, dtype=np.int64)
    else:
        raise ValueError("Estímulo inválido.")
    return data

# === Simulação ===
os.makedirs(OUTPUT_FOLDER, exist_ok=True)
stimuli = ["step", "ramp", "constant", "noise"]

for stim in stimuli:
    x = generate_input(stim)
    df = pd.DataFrame({"sample": np.arange(SAMPLES), "input": x})

    for name, h in filters.items():
        y = np.zeros(SAMPLES, dtype=np.int64)
        for n in range(SAMPLES):
            acc = 0
            for k in range(N):
                if n - k >= 0:
                    acc += x[n - k] * h[k]
            y[n] = acc >> FRAC_BITS  # Ajusta Q1.11 -> saída inteira
        df[name] = y

    csv_path = os.path.join(OUTPUT_FOLDER, f"{stim}.csv")
    df.to_csv(csv_path, index=False)
    print(f"[OK] {stim}.csv salvo com inteiros.")


