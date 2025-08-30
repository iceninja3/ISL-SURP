import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# --- Configuration ---
OIL_WATER_FILENAME = 'UpdatedOilWaterConcentrations.csv'
GLUCOSE_WATER_FILENAME = 'UpdatedGlucoseWaterConcentrations.csv'
PLOT_TITLE = 'Oil & Glucose in Water Absorption/Reflection Analysis'
OUTPUT_FILENAME = 'combined_plot_final_legend.svg'

# --- Styling Parameters ---
plt.rcParams['font.family'] = 'Arial'
plt.rcParams['font.weight'] = 'bold'
plt.rcParams['axes.labelweight'] = 'bold'
plt.rcParams['axes.titleweight'] = 'bold'

# --- FONT SIZES (LARGE VERSION) ---
LABEL_FONTSIZE = 48
TICK_FONTSIZE = 40
LINE_WIDTH = 3.5
AXIS_LINE_WIDTH = 1.6
LEGEND_FONTSIZE = 16

# --- Manual Color Mapping ---
color_map = {
    '365': '#1f77b4',  # Muted Blue
    '408': '#d62728',  # Brick Red
    '432': '#2ca02c'   # Kelly Green
}

def get_color_for_sample(sample_name):
    sample_str = str(sample_name)
    if sample_str.startswith('365'):
        return color_map['365']
    elif sample_str.startswith('408'):
        return color_map['408']
    elif sample_str.startswith('432'):
        return color_map['432']
    return 'black'

# --- Data Loading and Cleaning Function ---
def load_and_clean_data(filename, concentration_col_name):
    try:
        df = pd.read_csv(filename)
        df['Sample'] = df['Sample'].astype(str)
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
    fig, ax1 = plt.subplots(figsize=(14, 8), constrained_layout=True)

    # Plot Oil-Water data
    for sample_name, group_data in df_oil.groupby('Sample'):
        color = get_color_for_sample(sample_name)
        ax1.plot(group_data['Concentration(%)'], group_data['Power (dBm)'],
                 marker='o', linestyle='-', label=f"Oil: {sample_name}",
                 color=color, linewidth=LINE_WIDTH)

    # Style Primary Axis
    ax1.set_xlabel('Oil Concentration (%)', fontsize=LABEL_FONTSIZE)
    ax1.set_ylabel('Reflected Power (dBm)', fontsize=LABEL_FONTSIZE)
    ax1.tick_params(axis='both', which='major', labelsize=TICK_FONTSIZE, pad=15)

    # Create and Plot Glucose-Water data
    ax2 = ax1.twiny()
    for sample_name, group_data in df_glucose.groupby('Sample'):
        color = get_color_for_sample(sample_name)
        ax2.plot(group_data['Concentration(M)'], group_data['Power (dBm)'],
                 marker='s', linestyle='--', label=f"Glucose: {sample_name}",
                 color=color, linewidth=LINE_WIDTH)

    # Style Secondary Axis
    ax2.set_xlabel('Glucose Concentration (M)', fontsize=LABEL_FONTSIZE)
    ax2.tick_params(axis='x', which='major', labelsize=TICK_FONTSIZE, pad=15)

    # --- General Figure Styling ---
    for spine in ax1.spines.values():
        spine.set_linewidth(AXIS_LINE_WIDTH)
    ax1.grid(True, linestyle='-', linewidth=0.5, color='gray')

    # --- LEGEND FIX ---
    handles1, labels1 = ax1.get_legend_handles_labels()
    handles2, labels2 = ax2.get_legend_handles_labels()
    
    # Place legend at the bottom and increase handlelength to show line styles
    ax1.legend(handles1 + handles2, labels1 + labels2,
               loc='upper center', 
               bbox_to_anchor=(0.4, 0.2), # Position legend below plot
               handlelength=4, # <-- THIS IS THE FIX
               ncol=3, 
               fontsize=LEGEND_FONTSIZE)

    # --- Final Touches & Save ---
    plt.savefig(OUTPUT_FILENAME)
    print(f"Plot saved as '{OUTPUT_FILENAME}'")