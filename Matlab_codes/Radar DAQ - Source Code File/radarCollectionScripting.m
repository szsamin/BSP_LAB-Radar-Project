% Function to collection non-real time data using the DAQ
% radarCollectionScripting(samplingRate,timeSeconds,steps);
% SAMPLINGRATE: the variable specifies the to specify the required sampling rate for the DAQ
% TIMESECONDS:    timeSeconds to specify the time in second for the scripting length to be
% STEPS:

function radarCollectionScripting(samplingRate,timeSeconds,steps)

clearvars -except samplingRate timeSeconds steps;


%%% Finds a DAQ, if its already running stop it.
if (~isempty(daqfind))
    stop(daqfind)
end
DataVal = []; TimeVal = []; Time = [];



numberOfSamples = samplingRate.*timeSeconds;
inputRange = [-5 5]; count = 0;
N = 1; % Number of channels+1

% The code below Samples data and takes of data acquisition

audioOut('Wait');
pause(10);
audioOut('Start Collection'); % The audio strings sends intructions
% [data,time,abstime,events] = getdata(ai);
tic
for i = 1:steps
    count = count + 1;
    for states = 1:3
        switch states
            case 1
                audioOut('Begin Recording');
            case 2
                audioOut('Put object infront of the sensor and Begin Recording');
            case 3
                audioOut('Continue Recording without any object infront');
        end
        [ai] = DAQInitialize(N,samplingRate,numberOfSamples,inputRange);
        start(ai); % Start the object - Begin Collection
        [data,time,~,~] = getdata(ai); % Pull in the data
        DAQclear(ai);
        [row, ~] = size(time);
        TOC = toc;
        [newState, timeVal] = tagging(states,row,TOC);
        [newTag, ~] = tagging(count,row,TOC);
        
        newdata = horzcat(data,newState',newTag');
        DataVal = vertcat(DataVal, newdata);
        Time = horzcat(time, timeVal');
        TimeVal = vertcat(TimeVal,Time);
        
        switch states
            case 2
                audioOut('Remove Object');
        end
        pause(2);
    end
    audioOut('Move to next location');
    pause(10);    
end

% Deactivate Data acquisition board
audioOut('End Collection'); % Intruct to stop doing collection


% generatePlot(time,data);
DataSavePrompt(TimeVal,DataVal,samplingRate,steps);

end


%     str = sprintf('Data%s',num2str(i));
%     varname = genvarname(str);
%     eval([varname ' = data']);
