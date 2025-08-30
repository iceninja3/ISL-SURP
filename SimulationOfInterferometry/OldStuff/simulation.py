import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d

# Load the data
file_path = 'calibration.csv'
try:
    # Assuming a single column with no header, let's name it 'power'
    data = pd.read_csv(file_path, header=None, names=['power'])
    print("Data loaded successfully. Here's the first few rows:")
    print(data.head())
    print("\nData information:")
    data.info()

    # Create the 'x' position array
    step_size_micrometers = 10
    num_steps = len(data)
    # Create an array from 0 to (num_steps - 1) * step_size_micrometers
    x_position_micrometers = np.arange(0, num_steps * step_size_micrometers, step_size_micrometers)

    # Create the interpolation function y(x)
    # We now have x (position) and y (power)
    y_power = data['power'].values
    y_of_x = interp1d(x_position_micrometers, y_power, kind='linear', bounds_error=False, fill_value="extrapolate")

    # --- Simulation ---
    # Create the time array for the simulation
    # Let's simulate for a few cycles of the 500 Hz vibration
    frequency_hz = 500
    period = 1 / frequency_hz
    # Simulate for 5 periods to see a few oscillations
    simulation_time_seconds = 5 * period
    # Use a time step that is at least 10x smaller than the period for a smooth plot
    time_step = period / 20
    t = np.arange(0, simulation_time_seconds, time_step)

    # Create the position disturbance x(t)
    amplitude_micrometers = 15 # Choosing 15um as it is in the middle of 10-20um range
    # To observe the effect of the vibration, we need to add it to a central position on the rail.
    # Let's choose the center of our recorded data as the operating point.
    operating_point_x = x_position_micrometers.mean()
    x_of_t = operating_point_x + amplitude_micrometers * np.sin(2 * np.pi * frequency_hz * t)

    # Calculate the power over time y(t)
    y_of_t = y_of_x(x_of_t)

    # --- Plotting ---
    # Plot 1: The calibration curve (Power vs. Position)
    plt.figure(figsize=(10, 6))
    plt.plot(x_position_micrometers, y_power, label='Calibration Curve')
    plt.title('Interferometer Power vs. Position')
    plt.xlabel('Position (micrometers)')
    plt.ylabel('Power (arbitrary units)')
    plt.grid(True)
    plt.legend()
    plt.savefig('calibration_curve.png')

    # Plot 2: The simulated power over time (Power vs. Time)
    plt.figure(figsize=(10, 6))
    plt.plot(t * 1000, y_of_t) # Plot time in milliseconds
    plt.title('Simulated Power vs. Time with 500 Hz Vibration')
    plt.xlabel('Time (ms)')
    plt.ylabel('Power (arbitrary units)')
    plt.grid(True)
    plt.savefig('power_vs_time_simulation.png')

    print("\nSimulation and plotting complete. Two plots have been generated: 'calibration_curve.png' and 'power_vs_time_simulation.png'")

except FileNotFoundError:
    print(f"Error: The file '{file_path}' was not found. Please make sure the file is in the correct directory.")
except Exception as e:
    print(f"An error occurred: {e}")