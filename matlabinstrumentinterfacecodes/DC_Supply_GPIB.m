%%
close all;
clear;
clc;
%% DC Supply Initialization
DCSource = visadev("GPIB2::1::INSTR");
set(DCSource, 'Timeout', 30);
pause(1);

writeline(DCSource, "OUTPut ON");
pause(1);
writeline(DCSource, "INSTrument:SELect OUTPut1");
pause(1);
writeline(DCSource, "VOLTage 2");
pause(1);
writeline(DCSource, "INSTrument:SELect OUTPut2");
pause(1);
writeline(DCSource, "VOLTage 1.29");
pause(10);

writeline(DCSource, "OUTPut OFF");
pause(1);