% Script for DAQ data acquistion Practice Test two %%%%%%%%%%%%%%%%%%%%
clear all;close all;clc;

samplingRate = 80000;
numberOfSamples = samplingRate.*0.01;
inputRange = [-5 5];
excelFileName = 'sampleData';

% The code below Samples data and takes of data acquisition

ai = analoginput('mcc',0);
dio = digitalio('mcc','0');
dout = addline(dio,0:3,1,'out');
putvalue(dio,5);
addchannel(ai, [0 1]);
set(ai,'InputType','Differential');
set(ai, 'SampleRate',samplingRate);
set(ai,'SamplesPerTrigger',numberOfSamples);
ai.Channel.InputRange = inputRange;

start(ai);

[data,time,abstime,events] = getdata(ai);

% Deactivate Data acquisition board
stop (ai); 
delete(ai)
clear ai
str = sprintf('Data sampled at %f moving away from the Receiver',samplingRate);
plot(time,data(:,1),'b'); hold on; plot(time,data(:,2),'r');
title(str); ylabel('Output(Volts)'); xlabel('Time(sec)');
% str2 = sprintf('%s_fig.fig',datestr(now,'yyyymmddTHHMMSS'));
% saveas(gcf,str2);
% str3 = sprintf('datafile_%s',datestr(now,'yyyymmddTHHMMSS'));
% save(str3,'time','data');


