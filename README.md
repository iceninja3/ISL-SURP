# ISL-SURP

Code I wrote in the Integrated Sensors Laboratory for a NSF REU opportunity in the Summer of 2025. 

Some is to operate machinery (like programming Thor Labs rails and collecting data from measurement instruments) while others are to analyze data (making simple plots and graphs). Other code is to simulate experimental setups.

## Concentration/Material Determination Experiments Plots
Made a few different plots. Fiddled a lot with the formatting/colors so that it would be presentable for the final research poster. 
Two main plots:
* Material determination experiment plots (can we identify any differences between the wave absorption of different materials?)
* Concentration Determination (Oil/water mixture and glucose/water solution). (Can we identify any differences in the concentrations of different materials?)

## Poster
Has draft posters meant for presentation at the SURP symposium. THe folder "final submission" has the posters themselves. File J is the one used in the SURP research journal while File S is the one used for the SURP research symposium. Both are the same, just sized accordingly.

## MatlabInstrumentationCodes
Some code is simply to set up the commands for interfacing with the Thorlabs rails (like a library to interface with the rails). SweepONE, VishalOscilloscope, and oscilloscope were the actual code that was used to collect data.

Roughly what they do is:
1. Initialize the rail and spectrum analyzer objects
2. Initialize a matlab graph that updates live so you can tell if the data is junk or not
3. Use input parameters (step_size mostly) to determine program flow
4. Moves rail step by step and records power at each step, adding onto the graph the entire time
5. Generates csv at the end so actual data can be used in other data analyses or simulations

