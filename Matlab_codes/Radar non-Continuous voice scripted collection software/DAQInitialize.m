function [ai] = DAQInitialize(N,samplingRate,numberOfSamples,inputRange)

ai = analoginput('mcc',0);
addchannel(ai, (0:N));
set(ai,'InputType','Differential');
set(ai, 'SampleRate',samplingRate);
set(ai,'TriggerType','Immediate');
set(ai,'SamplesPerTrigger',numberOfSamples);
ai.Channel.InputRange = inputRange;


end