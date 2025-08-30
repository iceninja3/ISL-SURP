%%
clc;
clear; 
close all;

instrreset;
%%
MXAObj = visa('ni', 'GPIB0::20::INSTR');
set(MXAObj, 'InputBufferSize', 200);    %InputBufferSize as the total number of bytes that can be stored in the software input buffer during a read operation.
set(MXAObj, 'Timeout', 30);
pause(1);
fopen(MXAObj);
fprintf(MXAObj,'SENSe:FREQuency:CENTer 2e9');
fprintf(MXAObj,'SENSe:FREQuency:SPAN 1e9');
fprintf(MXAObj,'SENSe:BANDwidth:RESolution 8e6');
%%
figure;
for i=1:90
    % stage.moveMotorRelative('theta', step_size_rad);
    pause(1);
    % for j = 1:50
    %     h.MoveJog(0,1+direction);
    %     pause(0.1)
    %     fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
    %     peak_amp(i,j) = str2num(query(MXAObj,':CALCulate:MARKer1:Y?'));
    % end
    % for j = 51:100
    %     h.MoveJog(0,1+~direction);
    %     pause(0.1)
    %     fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
    %     peak_amp(i,j) = str2num(query(MXAObj,':CALCulate:MARKer1:Y?'));
    % end

    fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
    fprintf(MXAObj,':CALCulate:MARKer:MAXimum');
    peak_amp(i) = str2num(query(MXAObj,':CALCulate:MARKer1:Y?'));
    %peak_amp_avg(i,1) = mean(peak_amp(i,:));
    plot(peak_amp);
end

close all;

% timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
% filename = sprintf('RAD_DATA_%s.csv', timestamp);
% csvwrite(filename, peak_amp);
%%
fclose(MXAObj);
%%
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
filename_good = sprintf('RX_400_GHz_TEST_DATE_%s.csv', timestamp);
csvwrite(filename_good, peak_amp);
%%
figure;
theta = -total_angle/2:step_size_deg:total_angle/2-step_size_deg;
%plot(theta, smoothdata(peak_amp), 'LineWidth', 2);
plot(theta, smoothdata(peak_amp), 'LineWidth', 2);
grid on;