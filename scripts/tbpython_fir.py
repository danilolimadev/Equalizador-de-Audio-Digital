import numpy as np
import pandas as pd
import os

# === Parâmetros ===
N = 32
INT_WIDTH = 24
FRAC_BITS = 11  # Q1.11
SAMPLES = 512
OUTPUT_FOLDER = "fir_outputs_from_verilog"

# === Coeficientes diretamente copiados do Verilog (Q1.11 inteiros signed) ===
def get_coeffs(coef_list):
    return np.array(coef_list, dtype=np.int64)

filters = {
    "lowpass": get_coeffs([163, 183, 240, 332, 457, 607, 779, 964, 1155, 1343, 1523, 1685, 1823, 1933, 2008, 2047,
                           2047, 2008, 1933, 1823, 1685, 1523, 1343, 1155, 964, 779, 607, 457, 332, 240, 183, 163]),
    "band_64_125": get_coeffs([161, 180, 237, 329, 452, 603, 774, 959, 1150, 1340, 1520, 1683, 1822, 1932, 2008, 2047,
                               2047, 2008, 1932, 1822, 1683, 1520, 1340, 1150, 959, 774, 603, 452, 329, 237, 180, 161]),
    "band_125_250": get_coeffs([152, 171, 227, 317, 438, 587, 758, 943, 1135, 1326, 1509, 1675, 1817, 1929, 2007, 2047,
                                2047, 2007, 1929, 1817, 1675, 1509, 1326, 1135, 943, 758, 587, 438, 317, 227, 171, 152]),
    "band_250_500": get_coeffs([117, 137, 188, 270, 384, 527, 694, 879, 1075, 1274, 1466, 1643, 1796, 1918, 2003, 2047,
                                2047, 2003, 1918, 1796, 1643, 1466, 1274, 1075, 879, 694, 527, 384, 270, 188, 137, 117]),
    "band_500_1k": get_coeffs([7, 25, 56, 109, 191, 307, 457, 640, 848, 1073, 1301, 1520, 1715, 1875, 1988, 2047,
                               2047, 1988, 1875, 1715, 1520, 1301, 1073, 848, 640, 457, 307, 191, 109, 56, 25, 7]),
    "band_1k_2k": get_coeffs([-138, -152, -187, -232, -266, -267, -214, -91, 109, 380, 706, 1059, 1404, 1705, 1928, 2047,
                              2047, 1928, 1705, 1404, 1059, 706, 380, 109, -91, -214, -267, -266, -232, -187, -152, -138]),
    "band_2k_4k": get_coeffs([72, 77, 75, 40, -61, -247, -505, -779, -980, -1008, -791, -317, 350, 1076, 1693, 2047,
                              2047, 1693, 1076, 350, -317, -791, -1008, -980, -779, -505, -247, -61, 40, 75, 77, 72]),
    "band_4k_8k": get_coeffs([-33, -13, 10, 13, -20, -36, 79, 345, 545, 325, -436, -1326, -1584, -747, 813, 2047,
                              2047, 813, -747, -1584, -1326, -436, 325, 545, 345, 79, -36, -20, 13, 10, -13, -33]),
    "band_8k_16k": get_coeffs([19, -24, -25, 13, -20, 79, 153, -212, -211, 103, -139, 511, 972, -1443, -1830, 2047,
                               2047, -1830, -1443, 972, 511, -139, 103, -211, -212, 153, 79, -20, 13, -25, -24, 19]),
    "highpass": get_coeffs([0, 0, 10, -16, -1, 35, -53, 0, 104, -143, -1, 260, -359, 0, 812, -1676, 2047, -1676, 812, 0,
                            -359, 260, -1, -143, 104, 0, -53, 35, -1, -16, 10, 0])
}

# === Estímulos ===
def generate_input(stim_type):
    if stim_type == "step":
        x = np.zeros(SAMPLES, dtype=np.int64)
        x[80:] = 0x400000
    elif stim_type == "ramp":
        x = np.arange(SAMPLES, dtype=np.int64) << 12
    elif stim_type == "constant":
        x = np.ones(SAMPLES, dtype=np.int64) * 0x100000
    elif stim_type == "noise":
        x = np.random.randint(-2**23, 2**23, SAMPLES, dtype=np.int64)
    else:
        raise ValueError("Tipo inválido")
    return x

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
            y[n] = acc >> FRAC_BITS  # Ajusta Q1.11 para inteiro 24 bits
        df[name] = y

    path = os.path.join(OUTPUT_FOLDER, f"{stim}.csv")
    df.to_csv(path, index=False)
    print(f"[OK] {stim}.csv salvo em {OUTPUT_FOLDER}")
