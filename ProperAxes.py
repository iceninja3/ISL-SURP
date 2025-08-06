import pandas as pd
import matplotlib.pyplot as plt

FILENAME = 'newTest.csv'
PLOT_TITLE = '5-Slide Oil in Water Absorption/Reflection Analysis'

try:
    df = pd.read_csv(FILENAME)
    print("--- 1. After loading CSV ---")
    print("Columns found:", df.columns.tolist())
    print("First 5 rows:")
    print(df.head())
    print("-" * 30)

    # Convert to numeric, turning errors into NaN (Not a Number)
    df['Concentration(%)'] = pd.to_numeric(df['Concentration(%)'], errors='coerce')
    df['Power (dBm)'] = pd.to_numeric(df['Power (dBm)'], errors='coerce')

    print("\n--- 2. After trying to convert to numbers ---")
    print("First 5 rows (notice any 'NaN' values?):")
    print(df.head())
    print("-" * 30)
    
    # Drop rows with NaN values
    df.dropna(inplace=True)

    print("\n--- 3. After dropping rows with errors ---")
    if df.empty:
        print("RESULT: The DataFrame is now EMPTY. This is why the graph is blank.")
    else:
        print("RESULT: Data is ready for plotting. First 5 rows:")
        print(df.head())
    print("-" * 30)


    # Plotting section
    plt.figure(figsize=(12, 7))

    for sample_name, group_data in df.groupby('Sample'):
        plt.plot(group_data['Concentration(%)'], group_data['Power (dBm)'], marker='o', linestyle='-', label=sample_name)

    plt.title(PLOT_TITLE)
    plt.xlabel('Concentration(%)')
    plt.ylabel('Reflected Power (dBm)')
    plt.legend()
    plt.grid(True)
    plt.show()

except FileNotFoundError:
    print(f"Error: The file '{FILENAME}' was not found.")
except KeyError as e:
    print(f"ERROR: A column name doesn't match! The script is looking for {e}.")
    print("Please check your CSV headers for typos or extra spaces.")
