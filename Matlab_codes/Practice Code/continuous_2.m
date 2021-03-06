% Script for DAQ data acquistion Practice Test two %%%%%%%%%%%%%%%%%%%%

function continuous_2

%%% Finds a DAQ, if its already running stop it.
if (~isempty(daqfind))
    stop(daqfind)
end

clear all; clc;

global saveData;
global timeData; global clear1;


%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
samplingRate = 20000; % Setting up the sampling rate
Duration = 3; %% Duration in seconds
% numberOfSample0s = samplingRate; %% Total number of samples that needs to be collected
inputRange = [0 5]; %% Define the input range for the input Voltage +- 5 V
newData = zeros(Duration*samplingRate,2);

data = zeros();


%%%%% Some arbitrary length --- NOT EXACT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = zeros(samplingRate/1000,1); y = zeros(samplingRate/1000,1); timer = 0;
% phase_lag = zeros(samplingRate/1000,1); count1 = 0;

%%%% Setting up the Graphical user Interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Visible','on','Position',[200,50,1024,600],'name','DAQ Visualizer');

%%%%%%%%%%%% Setting up the Device object for recording %%%%%%%%%%%%%%%%%
ai = analoginput('mcc',0); %% Initializing the Analog input device 0
dio = digitalio('mcc','0');
dout = addline(dio,0:3,1,'out');
addchannel(ai, [0,1]); %% Add the analog input channels into your object
set(ai,'InputType','Differential'); % Set the input type
set(ai, 'SampleRate',samplingRate); % Set the samplingRate
set(ai,'TriggerType','Immediate');
set(ai,'SamplesPerTrigger',1000*samplingRate);
ai.Channel.InputRange = inputRange; % Set the input range

%%% Time Elapsed GUI
time_elapsed = uicontrol('Style','text',...
    'Position',[20 80 50 20],...
    'String','Value');

% Clear button GUI to end the program and save the data
clearButton = uicontrol('Style','pushbutton','String','Close',...
    'Position',[20 50 50 20],...
    'Callback',@setClear);

    function setClear(source,~)
        clear1 = get(source,'Value');
    end

% Initialize the plot interface on the Figure
timespan = linspace(1,Duration,Duration*samplingRate);
positionVector1 = [0.1, 0.08, 0.8, 0.45];    % position of first subplot
subplot('Position',positionVector1);
a = plot(timespan,newData(:,1),'r');
hold on; b = plot(timespan,newData(:,2),'b'); ylim(inputRange);
xlabel('Time(sec)'); ylabel('Ouput(V)'); str = sprintf('Sampling at %s',num2str(samplingRate));
title(str); hold off;

positionVector2 = [0.1, 0.6, 0.3, 0.35];    % position of first subplot
subplot('Position',positionVector2); %[left bottom width height]
d = plot(x,y); axis([-1 1 -1 1]);

% positionVector3 = [0.45, 0.6, 0.3, 0.35];    % position of first subplot
% subplot('Position',positionVector3); %[left bottom width height];
% kk = linspace(1,1000,1000);
% e = plot(kk,unwrap(phase_lag));


% Toggle button to play/start recording
toggleButton = uicontrol('Style','togglebutton','String','Play',...
    'Position',[20 20 50 20],...
    'Callback',@toggle);

    function toggle(source,~)
        toggle = get(source,'Value');
        start(ai); % Start recording
        % When play button is hit
        while(toggle==1 && isempty(toggle) ~= 1)
            while(isrunning(ai))
                i = 0;
                for i = 0:15
                    putvalue(dio,i);
                    while(ai.SamplesAvailable <=0)
                    end
                    %                     [data,time,abstime] = getdata(ai,ai.SamplesAvailable);
                    %             count1 = count1 + 1;
                    
                    tic;
                    [data,time,~] = getdata(ai,ai.SamplesAvailable); %% Push the buffer data into the array
                    saveData = horzcat(saveData,data'); % save all the data in an array
                    timeData = horzcat(timeData,data'); % save the time in an array
                    
                    %             [data] = meanNormalize(data);
                    
                    m = numel(data(:,1)); % Length of the latest collection
                    length = numel(newData); % Length of the data that is suppposed to be on the screen
                    
                    [x,y] = ellipticalXY(data);
                    
                    
                    %%%% Zero padding the length before the data comes in, so that
                    %%%% the data appear to be moving from right to left
                    if(length < Duration*samplingRate)
                        difference = Duration*samplingRate - length;
                        
                        pad = zeros(difference,1);
                        newData = horzcat(pad', newData');
                        newData = newData';
                    end
                    
                    %%%% Adding the recorded data to new data on screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if(m < Duration*samplingRate)
                        newData = horzcat(newData', data');
                        newData = newData';
                    end
                    
                    %             NFFT = 2^nextpow2(L); % Next power of 2 from length of y
                    %             Y = fft(y,NFFT)/L;
                    
                    
                    set(d,'XData',x,'YData',y);
                    %             set(e,'YData',phase_lag);
                    drawnow;
                    
                    newData(1:m,:) = [];
                    
                    %             [newData] = meanNormalize(newData);
                    
                    set(a,'YData',newData(:,1));
                    set(b,'YData',newData(:,2));
                    drawnow;
                    
                    timer = timer + toc;
                    set(time_elapsed,'String',timer);
                    
                    if(clear1 == 1)
                        stop (ai);
                        delete(ai);
                        clear ai;
                        str2 = sprintf('%s_fig.fig',datestr(now,'yyyymmddTHHMMSS'));
                        saveas(gcf,str2);
                        str3 = sprintf('datafile_%s',datestr(now,'yyyymmddTHHMMSS'));
                        saveData; timeData;
                        save(str3,'timeData','saveData');
                        close all;
                        clear all; clc;
                        break;
                    end
                end
                
            end
        end
    end

end
