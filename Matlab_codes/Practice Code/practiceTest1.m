% Script for DAQ data acquistion Practice Test one %%%%%%%%%%%%%%%%%%%%

samplingRate = 60000;
numberOfSamples = samplingRate.*120;
inputRange = [-5 5];
excelFileName = 'sampleData';

% The code below Samples data and takes of data acquisition

ai = analoginput('mcc',0);
addchannel(ai, [0,1]);
set(ai,'InputType','Differential');
set(ai, 'SampleRate',samplingRate);
set(ai,'SamplesPerTrigger',numberOfSamples);
ai.Channel.InputRange = inputRange;

start(ai); 

[data,time,abstime,events] = getdata(ai);

chan0 = data(:,1); 
chan1 = data(:,2);

% Deactivate Data acquisition board
stop (ai); 
delete(ai)
clear ai

plot(time,chan0,'b'); hold all; plot(time,chan1,'r');

