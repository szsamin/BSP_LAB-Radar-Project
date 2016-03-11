% Script for DAQ data acquistion Practice Test two %%%%%%%%%%%%%%%%%%%%
clear all;close all;clc;

samplingRate = 80000;
numberOfSamples = samplingRate.*120;
inputRange = [-1 1];
excelFileName = 'sampleData';

% The code below Samples data and takes of data acquisition

ai = analoginput('mcc',0);
addchannel(ai, [0 1]);
set(ai,'InputType','Differential');
set(ai, 'SampleRate',samplingRate);
set(ai,'SamplesPerTrigger',numberOfSamples);
ai.Channel.InputRange = inputRange;

start(ai);
audioOut('Start Collection');
[data,time,abstime,events] = getdata(ai);

% Deactivate Data acquisition board
audioOut('End Collection');
stop (ai); 
delete(ai);
clear ai;
% str = sprintf('Data sampled at %f Hands moving infront in line of sight',samplingRate);
% plot(time,data(:,1),'b'); hold on; plot(time,data(:,2),'r');
% title(str); ylabel('Output(Volts)'); xlabel('Time(sec)');
% str2 = sprintf('every5cm_fig_%s.fig',datestr(now,'yyyymmddTHHMMSS'));
% saveas(gcf,str2);
str3 = sprintf('every5cmdatafile_%s',datestr(now,'yyyymmddTHHMMSS'));
save(str3,'time','data');


