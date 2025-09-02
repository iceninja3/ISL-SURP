# ISL-SURP

Code I wrote in the Integrated Sensors Laboratory for a NSF REU opportunity in the Summer of 2025. 

Some is to operate machinery (like programming Thor Labs rails and collecting data from measurement instruments) while others are to analyze data (making simple plots and graphs). Other code is to simulate experimental setups.

## Interferometric Sensor Response Simulation
In this script, I model and simulate the response of an interferometric sensor to a periodic, physiological signal. The primary goal is to demonstrate a full workflow: from processing raw calibration data to verifying that a known input frequency can be accurately recovered from the simulated sensor output. This is a foundational process for vibrometry applications, such as remote heartbeat detection.

The entire process is broken down into four main stages:

### 1. Calibration and Sensitivity Analysis
First, I take raw power data obtained from a calibration sweep of the interferometer. This data represents the measured optical power as a function of mirror displacement, which forms the characteristic sinusoidal fringe pattern of the interferometer.

I load this data using pandas and io.StringIO, which allows me to treat the multi-line string data as if it were a file.

The core of this section is finding the optimal operating point (also known as the quadrature point). This is the region where the sensor's response to small displacements is most linear and has the highest sensitivity.

To find this point, I calculate the derivative (the slope) of the power curve with respect to displacement using np.gradient. The displacement corresponding to the maximum absolute value of this derivative is my optimal DC offset.

Output: This stage generates calibration_curve.svg and a more detailed sensitivity_analysis.svg, which is a dual-axis plot showing the power curve and its derivative on the same graph to visually pinpoint the optimal offset.

### 2. Input Signal Generation
Next, I generate a synthetic input signal that mimics a physiological vibration, like a heartbeat.

I created a function get_heartbeat_signal that produces a periodic pulse train resembling a typical PQRST waveform.

The signal is defined by parameters like BPM (beats per minute), amplitude, and sampling rate.

Crucially, I superimpose this small, time-varying heartbeat displacement onto the optimal DC offset calculated in the previous step. This simulates a target vibrating around the most sensitive point of the interferometer.

Output: This stage generates input_signal.svg, which shows the displacement of the target over time.

### 3. Output Power Simulation
With the input displacement signal defined, I simulate the corresponding output power from the sensor.

This is the core of the simulation. I use np.interp to perform a linear interpolation. This function effectively "looks up" each value from my input displacement signal on the original calibration curve and finds the corresponding output power value. This accurately models how the sensor's non-linear transfer function converts the input displacement into an output power signal.

Output: This stage generates output_power.svg (the simulated power reading over time) and comparison.svg (a dual-axis plot comparing the input displacement and output power).

### 4. Frequency Verification with FFT
Finally, to close the loop and verify the simulation, I analyze the frequency content of the simulated output power signal to ensure I can recover the original heartbeat frequency.

I use the Fast Fourier Transform (FFT) algorithm from the scipy.fft library to transform the output power signal from the time domain to the frequency domain.

I process the FFT result by removing the DC component and focusing on the positive frequencies.

The script then identifies the peak frequency in the spectrum, which corresponds to the fundamental frequency of the signal.

The result is printed to the console, comparing the input frequency (from the BPM) with the detected peak frequency from the output.

Output: This stage generates fft_analysis.svg, which shows the frequency spectrum of the output signal with the detected peak clearly marked.

### Key Features and Libraries Used
Pandas: For easy data handling.

NumPy: For numerical operations, especially np.linspace, np.gradient, and np.interp.

Matplotlib: For generating high-quality plots, including sophisticated dual-axis plots using twinx(). All plots are saved as SVG (Scalable Vector Graphics) for lossless quality.

SciPy: Specifically, the fft and fftfreq functions for robust frequency analysis.

io.StringIO: A clever feature used to read my hardcoded string data directly into a pandas DataFrame without needing to create a temporary file.

## MatlabInstrumentationCodes
Some code is simply to set up the commands for interfacing with the Thorlabs rails (like a library to interface with the rails). SweepONE, VishalOscilloscope, and oscilloscope were the actual code that was used to collect data.

Roughly what they do is:
1. Initialize the rail and spectrum analyzer objects
2. Initialize a matlab graph that updates live so you can tell if the data is junk or not
3. Use input parameters (step_size mostly) to determine program flow
4. Moves rail step by step and records power at each step, adding onto the graph the entire time
5. Generates csv at the end so actual data can be used in other data analyses or simulations

## Concentration/Material Determination Experiments Plots
Made a few different plots. Fiddled a lot with the formatting/colors so that it would be presentable for the final research poster. 
Two main plots:
* Material determination experiment plots (can we identify any differences between the wave absorption of different materials?)
* Concentration Determination (Oil/water mixture and glucose/water solution). (Can we identify any differences in the concentrations of different materials?)

## Poster
Has draft posters meant for presentation at the SURP symposium. THe folder "final submission" has the posters themselves. File J is the one used in the SURP research journal while File S is the one used for the SURP research symposium. Both are the same, just scaled accordingly.


