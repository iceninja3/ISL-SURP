import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# --- Configuration ---
OIL_WATER_FILENAME = 'UpdatedOilWaterConcentrations.csv'
GLUCOSE_WATER_FILENAME = 'UpdatedGlucoseWaterConcentrations.csv'
PLOT_TITLE = 'Oil & Glucose in Water Absorption/Reflection Analysis'
OUTPUT_FILENAME = 'combined_plot_fixed.png'

# --- Data Loading and Cleaning Function ---
def load_and_clean_data(filename, concentration_col_name):
    """Loads a CSV file, cleans it, and returns a DataFrame."""
    try:
        df = pd.read_csv(filename)
        df[concentration_col_name] = pd.to_numeric(df[concentration_col_name], errors='coerce')
        df['Power (dBm)'] = pd.to_numeric(df['Power (dBm)'], errors='coerce')
        df.dropna(inplace=True)
        return df
    except FileNotFoundError:
        print(f"Error: The file '{filename}' was not found.")
        return None
    except KeyError:
        print(f"Error: A required column was not found in '{filename}'.")
        return None

# --- Main Script ---
df_oil = load_and_clean_data(OIL_WATER_FILENAME, 'Concentration(%)')
df_glucose = load_and_clean_data(GLUCOSE_WATER_FILENAME, 'Concentration(M)')

# --- Plotting Section ---
if df_oil is not None and df_glucose is not None:
    fig, ax1 = plt.subplots(figsize=(14, 8))

    # Plot Oil-Water data on the primary axes (ax1)
    color_map1 = plt.colormaps.get('viridis')
    colors1 = color_map1(np.linspace(0, 1, df_oil['Sample'].nunique()))
    for i, (sample_name, group_data) in enumerate(df_oil.groupby('Sample')):
        ax1.plot(group_data['Concentration(%)'], group_data['Power (dBm)'], marker='o', linestyle='-', label=f"Oil: {sample_name}", color=colors1[i])

    ax1.set_xlabel('Oil Concentration (%)', fontsize=12)
    ax1.set_ylabel('Reflected Power (dBm)', fontsize=12)

    # Create the second axes that shares the y-axis
    ax2 = ax1.twiny()

    # Plot Glucose-Water data on the secondary axes (ax2)
    color_map2 = plt.colormaps.get('plasma')
    colors2 = color_map2(np.linspace(0, 1, df_glucose['Sample'].nunique()))
    for i, (sample_name, group_data) in enumerate(df_glucose.groupby('Sample')):
        ax2.plot(group_data['Concentration(M)'], group_data['Power (dBm)'], marker='s', linestyle='--', label=f"Glucose: {sample_name}", color=colors2[i])

    ax2.set_xlabel('Glucose Concentration (M)', fontsize=12)

    plt.title(PLOT_TITLE, fontsize=16, pad=20)

    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax2.legend(lines1 + lines2, labels1 + labels2, loc='best')

    fig.tight_layout()
    plt.savefig(OUTPUT_FILENAME)
    print(f"Plot saved as '{OUTPUT_FILENAME}'")