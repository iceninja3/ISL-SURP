%%
close all;
clear;
clc;
%% Motor Setup
instrreset;

motor = 1; 
speed = 1000; 
com = 3; % Use COSMOS software to find this
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%l
%%%%  Close COSMOS before running this %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stage = VMX(com, speed, [], [], motor); % Linear stage is connected using cable 2, rotary with cable 1

stage.toggleUnits('theta'); % Toggle the rotation units to radians

step_size_deg = 1;
step_size_rad = 1*pi/180; % Choose the step size
total_angle = 60;
%% Create ActiveX Controller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Close Thorlabs APT before running %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpos = get(0, 'DefaultFigurePosition'); % figure default position
fpos(3) = 650; %  figure window size;Width
fpos(4) = 450; % Height
f = figure('Position', fpos, ...
           'Menu', 'None', ...
           'Name', 'APT GUI');

h = actxcontrol('MGMOTOR.MGMotorCtrl.1', [20 20 600 400 ], f);
% h1 = actxcontrol('MGMOTOR.MGMotorCtrl.1', [20 20 600 400 ], f);

% Initialize
% Start Control
h.StartCtrl;
% h1.StartCtrl;
% Set the Serial Number
SN = 45833158; % Put in the serial number of the hardware
set(h, 'HWSerialNum', SN);

% SN1 = 45866685; % Put in the serial number of the hardware
% set(h1, 'HWSerialNum', SN1);

% Indentify the device
h.Identify;
% h1.Identify;

f0 = 405e9;
lambda = 3e11 / f0; %mm

num_rail_points = 10;
x_step = lambda / 2 / num_rail_points; %mm
z_step = 1 / num_rail_points; %mm

h.SetJogStepSize(0, x_step);
% h1.SetJogStepSize(0, z_step);

% Jog velocity
h.SetJogVelParams(0, 0, 5, 10);
% h1.SetJogVelParams(0, 0, 5, 10);

direction = 0;
%% SA Initialization
MXAObj = visa('ni', 'GPIB0::20::INSTR');
set(MXAObj, 'InputBufferSize', 200);    %InputBufferSize as the total number of bytes that can be stored in the software input buffer during a read operation.
set(MXAObj, 'Timeout', 30);
pause(1);
fopen(MXAObj);
fprintf(MXAObj, 'SENSe:FREQuency:CENTer 1.5e9');
fprintf(MXAObj, 'SENSe:FREQuency:SPAN 2e9');
fprintf(MXAObj, 'SENSe:BANDwidth:RESolution 8e6');
%% Start Measurements
peak_amp = -100 .* ones(total_angle/step_size_deg, 2*num_rail_points);

figure;
for i=1:total_angle/step_size_deg
    stage.moveMotorRelative('theta', step_size_rad);
    pause(0.2);

    for j = 1:num_rail_points
        h.MoveJog(0,1+direction);
        pause(0.5);

        % temp = 0;
        temp = [];
        for k = 1:1:10
            fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
            % temp = temp + str2num(query(MXAObj,':CALCulate:MARKer1:Y?'));
            temp = [temp, str2num(query(MXAObj,':CALCulate:MARKer1:Y?'))];
        end
        % peak_amp(i,j) = temp ./ 20;
        peak_amp(i,j) = max(temp);
    end

    for j = num_rail_points+1:num_rail_points*2
        h.MoveJog(0,1+~direction);
        pause(0.5);

        % temp = 0;
        temp = [];
        for k = 1:1:10
            fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
            % temp = temp + str2num(query(MXAObj,':CALCulate:MARKer1:Y?'));
            temp = [temp, str2num(query(MXAObj,':CALCulate:MARKer1:Y?'))];
        end
        % peak_amp(i,j) = temp ./ 20;
        peak_amp(i,j) = max(temp);
    end


    % fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
    % fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
    % peak_amp(i) = str2num(query(MXAObj,':CALCulate:MARKer1:Y?'));
    plot(peak_amp);
    pause(0.1);
end

close all;

fclose(MXAObj);

timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
filename = sprintf('TX_400_GHZ_TEST_H_PLANE_15_CM_DATE_%s.csv', timestamp);
csvwrite(filename, peak_amp);
%% Plotting The Pattern
figure;
theta = -total_angle/2:step_size_deg:total_angle/2-step_size_deg;
plot(theta, max(peak_amp, [], 2), 'LineWidth', 2);
grid on;
hold on;
plot(theta, mean(peak_amp, 2), 'LineWidth', 2);
delete(stage);
clear stage;
clc;