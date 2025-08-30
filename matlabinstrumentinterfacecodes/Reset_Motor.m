%%
close all;
clear;
clc;
%% Motor Setup
instrreset;

motor = 1; 
speed = 500; 
com = 3; % Use COSMOS software to find this
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Close COSMOS before running this %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stage = VMX(com, speed, [], [], motor); % Linear stage is connected using cable 2, rotary with cable 1

stage.toggleUnits('theta'); % Toggle the rotation units to radians

step_size_deg = 1;
step_size_rad = 1*pi/180; % Choose the step size
total_angle = 60;

stage.moveMotorRelative('theta', -total_angle/2*pi/180);

delete(stage);
clear stage;
clc;