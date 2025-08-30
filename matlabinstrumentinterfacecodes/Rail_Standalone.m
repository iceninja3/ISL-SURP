%%
clc;
clear; 
close all;
%%
% The first valid position is 0 mm
% The last valid position is 300 mm
%% Create ActiveX Controller
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Close Thorlabs APT before running %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fpos    = get(0, 'DefaultFigurePosition'); % figure default position
fpos(3) = 650; %  figure window size;Width
fpos(4) = 450; % Height
f = figure('Position', fpos, ...
           'Menu', 'None', ...
           'Name', 'APT GUI');

h = actxcontrol('MGMOTOR.MGMotorCtrl.1', [20 20 600 400 ], f);

% Initialize
% Start Control
h.StartCtrl;
% Set the Serial Number
SN = 45833158; % Put in the serial number of the hardware
set(h, 'HWSerialNum', SN);

% % Indentify the device
h.Identify;  %x axis

% x_step = 10e-3; %mm 
x_step = 10;

h.SetJogStepSize(0, x_step);

% %Jog velocity
h.SetJogVelParams(0, 0, 5, 10);

direction = 0;

h.MoveJog(0, 1+direction);