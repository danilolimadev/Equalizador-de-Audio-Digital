import pandas as pd
import matplotlib.pyplot as plt
import os

# Mapeamento dos arquivos CSV e seus respectivos títulos
files = {
    "hold.csv": "Hold",
    "impulse.csv": "Impulse",
    "noise.csv": "Noise",
    "ramp.csv": "Ramp",
    "step.csv": "Step"
}

# Caminho onde os arquivos estão localizados
base_path = "./"  

# Colunas das bandas (nomes das colunas nos arquivos CSV)
bands = [
    "o_lp",
    "o_hp",
    "o_band_64_125",
    "o_band_125_250",
    "o_band_250_500",
    "o_band_500_1k",
    "o_band_1k_2k",
    "o_band_2k_4k",
    "o_band_4k_8k",
    "o_band_8k_16k"
]

# Rótulos legíveis para o eixo X
band_labels = [
    "LPF", "HPF", "64–125Hz", "125–250Hz", "250–500Hz", "500Hz–1k",
    "1k–2k", "2k–4k", "4k–8k", "8k–16k"
]

# Tamanho da figura
plt.figure(figsize=(18, 12))

# Loop para processar cada arquivo
for i, (filename, title) in enumerate(files.items(), start=1):
    filepath = os.path.join(base_path, filename)
    
    try:
        # Carrega o CSV
        df = pd.read_csv(filepath)
        df.columns = df.columns.str.strip()  # Remove espaços dos nomes das colunas

        # Calcula a média da amplitude por banda
        amplitudes = [df[band].mean() for band in bands]

        # Cria o gráfico de barras
        plt.subplot(3, 3, i)
        plt.bar(band_labels, amplitudes, color='skyblue')
        plt.title(title)
        plt.ylabel("Amplitude Média")
        plt.xticks(rotation=45)
        plt.grid(axis='y')
    except Exception as e:
        print(f"Erro ao processar '{filename}': {e}")

plt.tight_layout()
plt.show()
