%% Piece One: Interferometer Step-by-Step Measurement
% This script moves a Thorlabs rail by a fixed step size and logs power
% from a Spectrum Analyzer at each step

close all;
clear;
clc;
instrreset; % Resets any lingering instrument connections

%% USER INPUT: Experimental Parameters
% -------------------------------------------------------------------------
rail_serial_number = 45833158;      % TODO: Enter the serial number for your Thorlabs rail
sa_gpib_address = 'GPIB0::20::INSTR'; % TODO: Enter the GPIB address of your Spectrum Analyzer
step_size_mm = 0.001;               % TODO: Enter the smallest step size for the rail in mm
total_steps = 500;                  % TODO: Enter the total number of steps for the scan
settle_time_s = 0.5;                % Time in seconds to wait for the rail to settle after moving
% -------------------------------------------------------------------------

%% Rail Controller Initialization
fprintf('Initializing Thorlabs Rail...\n');
fpos = get(0, 'DefaultFigurePosition');
fpos(3) = 650; % Width
fpos(4) = 450; % Height
f = figure('Position', fpos, 'Menu', 'None', 'Name', 'APT Motor Control');
h = actxcontrol('MGMOTOR.MGMotorCtrl.1', [20 20 600 400], f);
h.StartCtrl;
set(h, 'HWSerialNum', rail_serial_number); % Sets the serial number for the controller
h.Identify; % Causes the controller to flash its indicator light
pause(1); % Wait for initialization to complete

% Configure Rail Movement
h.SetJogStepSize(0, step_size_mm); % Sets the distance for a single jog command
h.SetJogVelParams(0, 0, 5, 10);    % Set velocity parameters (channel, min_vel, max_vel, accel)
fprintf('Rail Initialized.\n');

%% Spectrum Analyzer (SA) Initialization
fprintf('Initializing Spectrum Analyzer...\n');
MXAObj = visa('ni', sa_gpib_address);
set(MXAObj, 'InputBufferSize', 200);
set(MXAObj, 'Timeout', 30);
fopen(MXAObj);

% Configure SA Measurement Settings
fprintf(MXAObj, 'SENSe:FREQuency:CENTer 1.5e9'); %
fprintf(MXAObj, 'SENSe:FREQuency:SPAN 2e9');     %
fprintf(MXAObj, 'SENSe:BANDwidth:RESolution 8e6'); %
fprintf('SA Initialized.\n\n');

%% Measurement Loop
fprintf('Starting measurement scan...\n');
power_data = zeros(total_steps, 1);
figure; % Create a new figure for live plotting
h_plot = plot(NaN, NaN);
title('Live Power Measurement');
xlabel('Step Number');
ylabel('Power (dBm)');
grid on;

for i = 1:total_steps
    % Move the rail one step forward
    h.MoveJog(0, 1); % Arg2 = 1 for forward, 2 for reverse
    
    % Wait for the stage to settle
    pause(settle_time_s);
    
    % Take a power reading from the SA
    fprintf(MXAObj,':CALCulate:MARKer:MAXimum'); % Command SA to find the peak power
    power_reading_str = query(MXAObj,':CALCulate:MARKer1:Y?'); % Query the marker power value
    power_data(i) = str2double(power_reading_str);
    
    % Update the live plot
    set(h_plot, 'XData', 1:i, 'YData', power_data(1:i));
    drawnow;
    
    fprintf('Step %d/%d: Power = %.2f dBm\n', i, total_steps, power_data(i));
end

fprintf('Measurement scan complete.\n');

%% Save Data and Cleanup
% Save data to a CSV file with a timestamp
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
filename = sprintf('Interferometer_StepScan_%s.csv', timestamp);
writematrix(power_data, filename);
fprintf('Data saved to %s\n', filename);

% Close instrument connections
fclose(MXAObj);
delete(MXAObj);
h.StopCtrl; % Release the motor controller
close(f); % Close the APT figure window
fprintf('Instruments disconnected. Script finished.\n');
