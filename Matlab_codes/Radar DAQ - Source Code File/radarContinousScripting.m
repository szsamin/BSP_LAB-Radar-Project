% Function to collection non-real time data using the DAQ
% radarCollection(samplingRate,minutes);
% Sampling Rate to specify the required sampling rate for the DAQ
% minutes to specify the time in minutes for the entire collection

function main_scriptingVisualization

clearvars; 
saveData = []; timeData = []; global clear1; global toggle; Duration = 3; TOC = 0;
[samplingRate] = samplingRatePrompt; newState = []; states = 0; newSteps = [];

%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
Duration = 3; %% Duration in seconds
% numberOfSample0s = samplingRate; %% Total number of samples that needs to be collected
inputRange = [-1 1]; %% Define the input range for the input Voltage +- 5 V
newData = zeros(Duration*samplingRate,2); x = zeros(samplingRate/1000,1); y = zeros(samplingRate/1000,1); count = 1;

%%% Finds a DAQ, if its already running stop it.
if (~isempty(daqfind))
    stop(daqfind)
end

%%%%%%%%%%%% GUI SET UP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setting up the Graphical user Interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Visible','on','Position',[200,50,1024,600],'name','DAQ Visualizer for Radar System with two Input');
set(f,'toolbar','figure');

%%% Time Elapsed GUI
time_elapsed = uicontrol('Style','text',...
    'Position',[20 100 50 20],...
    'String','Value');

positionTrack = uicontrol('Style','text',...
    'Position',[100 100 900 400],...
    'String','Value',...
    'FontSize',130);



% Clear button GUI to end the program and save the data
clearButton = uicontrol('Style','pushbutton','String','Close',...
    'Position',[20 50 50 20],...
    'Callback',@setClear);

    function setClear(source,~)
        clear1 = get(source,'Value');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = 1;

[ai] = DAQInitialize(N,samplingRate,1000*samplingRate,inputRange); % Function to initialize all the DAQ Hardware parameters and create the hardware object

% Toggle button to play/start recording
toggleButton = uicontrol('Style','togglebutton','String','Play',...
    'Position',[20 20 50 20],...
    'Callback',@toggle1);

    function toggle1(source,~)
        toggle = get(source,'Value');
        % When play button is hit
        while(toggle==1 && isempty(toggle) ~= 1)
            start(ai); % Start recording
            while(isrunning(ai))
                tic;
                while(ai.SamplesAvailable <=0)
                end
                
                
                [data,time,~] = getdata(ai,ai.SamplesAvailable); %% Push the buffer data into the array
                [row, ~] = size(data);
                [newSteps, newState] = tagging(count,row,states);
                bol = horzcat(data,newSteps', newState');
                saveData = horzcat(saveData,bol'); % save all the data in an array
                timeData = horzcat(timeData,time'); % save the time in an array
                                
                if(TOC < 5)
                    TOC = TOC+toc;
                else
                    count = count + 1;
                    TOC = 0;
                    TOC = TOC + toc;
                    sound(10);
                end
                
                if(mod(count,5)==0)
                    states = states + 1;
                    count = 1;
                end
                
                switch count 
                    case 1
                         set(positionTrack,'String','Dont move');
                    case 2
                         set(positionTrack,'String','Occlusion');
                    case 3
                         set(positionTrack,'String','Dont move');
                    case 4
                         set(positionTrack,'String','New Location');
                end
                
                
                set(time_elapsed,'String',TOC);
                drawnow;
                
                
                if(clear1 == 1)
                    DAQclear(ai);
                    DataSavePrompt(timeData,saveData,samplingRate,count);
                    guiClear;
                    break;
                end
            end
            guiClear;
            break;
        end
    end
end