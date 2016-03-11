%%% Finds a DAQ, if its already running stop it.
if (~isempty(daqfind))
    stop(daqfind)
end

%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
samplingRate = 80000; % Setting up the sampling rate
Duration = 3; %% Duration in seconds
timePeriod = 0.1;
% numberOfSample0s = samplingRate; %% Total number of samples that needs to be collected
inputRange = [-1 5]; %% Define the input range for the input Voltage +- 5 V

%%%%%%%%%%%% Setting up the Device object for recording %%%%%%%%%%%%%%%%%
ai = analoginput('mcc',0); %% Initializing the Analog input device 0
addchannel(ai, [0,1]); %% Add the analog input channels into your object
set(ai,'InputType','Differential'); % Set the input type
set(ai, 'SampleRate',samplingRate); % Set the samplingRate
set(ai, 'SamplesPerTrigger', timePeriod*ai.sampleRate);
set(ai, 'TriggerRepeat', 1);
set(ai, 'TriggerType', 'manual');

set(ai, 'TimerPeriod', timePeriod);  
set(ai, 'BufferingConfig',[2048,20]);

start(ai);
trigger(ai);

while(1)

% [data,time] =getdata(ai,ai.SamplesPerTrigger);
data = peekdata(ai,10000);

xlim([0 5]);
plot(data); drawnow; 

end
% drawnow;