% Function to collection non-real time data using the DAQ
% radarCollection(samplingRate,minutes);
% Sampling Rate to specify the required sampling rate for the DAQ
% minutes to specify the time in minutes for the entire collection

function radarCollection(samplingRate,timeSeconds,steps)

clearvars -except samplingRate timeSeconds steps;


%%% Finds a DAQ, if its already running stop it.
if (~isempty(daqfind))
    stop(daqfind)
end
DataVal = []; TimeVal = []; Time = [];



numberOfSamples = samplingRate.*timeSeconds;
inputRange = [-5 5]; count = 0;
N = 6; % Number of channels+1

% The code below Samples data and takes of data acquisition

audioOut('Wait');
pause(10);
audioOut('Start Collection'); % The audio strings sends intructions
% [data,time,abstime,events] = getdata(ai);
for i = 1:steps
    tic;
    audioOut('Stay stationary'); % The audio strings sends intructions
    [ai] = DAQInitialize(N,samplingRate,numberOfSamples,inputRange);
    start(ai); % Start the object - Begin Collection
    [data,time,~,~] = getdata(ai); % Pull in the data
    DAQclear(ai);
    [row, ~] = size(time);
    count = count + 1;
    TOC = toc;
    [new, timeVal] = tagging(count,row,TOC);
    newdata = horzcat(data,new');
    DataVal = vertcat(DataVal, newdata);
    Time = horzcat(time, timeVal');
    TimeVal = vertcat(TimeVal,Time);
    if(count ~= steps)
        audioOut('Start Moving');
    end    
    pause(5);
end

% Deactivate Data acquisition board
audioOut('End Collection'); % Intruct to stop doing collection


% generatePlot(time,data);
DataSavePrompt(TimeVal,DataVal);

end