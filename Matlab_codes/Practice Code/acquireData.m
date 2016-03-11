function acquireData
ai = analoginput('mcc',0); %% Initializing the Analog input device 0
addchannel(ai, [0,1]); %% Add the analog input channels into your object
set(ai,'InputType','Differential'); % Set the input type
set(ai, 'SampleRate',8000); % Set the samplingRate
set(ai,'SamplesPerTrigger',80000);
ai.Channel.InputRange = [-5 5]; % Set the input range
lh = ai.addlistener('DataAvailable',@plotData);
start(ai); % Start recording
% Do something
while(~ai.IsDone)
end
plot(data); %  plot global data
function plotData(src,event)
    persistent tempData;
    persistent tempTimeStamps;
    if(isempty(tempData))
         tempData = [];
         tempTimeStamps = [];
     end
     tempData = [tempData;event.Data];
     tempTimeStamps = [tempTimeStamps; event.TimeStamps];
     plot(tempTimeStamps,tempData);
end

end