import pandas as pd
import matplotlib.pyplot as plt

# Lê o CSV exportado pelo testbench
df = pd.read_csv("saida_filtros.csv")

# Remove espaços em branco dos nomes das colunas
df.columns = df.columns.str.strip()

# Cria o gráfico com múltiplas curvas
plt.figure(figsize=(14, 8))
plt.plot(df["tempo"], df["i_data"], label="Entrada", linewidth=2, color="black")
plt.plot(df["tempo"], df["o_lp"], label="LPF (Baixa)")
plt.plot(df["tempo"], df["o_hp"], label="HPF (Alta)")
plt.plot(df["tempo"], df["o_band_64_125"], label="64–125 Hz")
plt.plot(df["tempo"], df["o_band_125_250"], label="125–250 Hz")
plt.plot(df["tempo"], df["o_band_250_500"], label="250–500 Hz")
plt.plot(df["tempo"], df["o_band_500_1k"], label="500–1k Hz")
plt.plot(df["tempo"], df["o_band_1k_2k"], label="1k–2k Hz")
plt.plot(df["tempo"], df["o_band_2k_4k"], label="2k–4k Hz")
plt.plot(df["tempo"], df["o_band_4k_8k"], label="4k–8k Hz")
plt.plot(df["tempo"], df["o_band_8k_16k"], label="8k–16k Hz")

# Configurações do gráfico
plt.title("Respostas dos Filtros FIR por Banda")
plt.xlabel("Tempo (ns)")
plt.ylabel("Amplitude")
plt.grid(True)
plt.legend(loc="upper right", fontsize="small")
plt.tight_layout()
plt.show()
