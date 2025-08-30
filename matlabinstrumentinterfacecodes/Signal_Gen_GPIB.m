%%
close all;
clear;
clc;
%% Signal Generator Initialization
SignalGen = visadev("GPIB2::19::INSTR");
set(SignalGen, 'Timeout', 30);
pause(1);

SA = visadev("GPIB0::10::INSTR");
set(SA, 'Timeout', 30);
pause(1);

writeline(SignalGen, "SOURce:FREQuency:CW 1e9");
writeline(SignalGen, "SOURce:POWer:LEVel:IMMediate:AMPLitude 0DBM");

writeline(SA, "SENSe:FREQuency:CENTer 1e9");
writeline(SA, "SENSe:FREQuency:SPAN 1e9");
writeline(SA, "SENSe:BANDwidth:RESolution 1e6");

writeline(SA, "DISPlay:WINDow:TRACe:Y:SCALe:RLEVel 10DBM");
writeline(SA, "DISPlay:WINDow:TRACe:Y:SCALe:PDIVision 7DB");

writeline(SignalGen, "OUTPut:STATe ON");
pause(5);
writeline(SignalGen, "OUTPut:STATe OFF");