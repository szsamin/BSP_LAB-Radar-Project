% Real Time Visualization for the DAQ Radar System - BSP Lab Summer 2015
% Author - Shadman Zaman Samin
% The visualizer is compatible to MCC DAQ with a legacy based system. The
% function prompts the user to select a sampling rate. The GUI is then
% generated, where the user is asked to start the collection using the START
% button. The CLEAR button closes the figure and prompts the user to save
% the file in a designated location.
% --------------------- Hardware Set up ---------------------------------
% Below, is the detail layout of the hardware connections with the IR GAIT
% system
% Analog Pin Connections ------------------------------------------------
% Pin 1 (CH0 H)	----> Reference Wave
% Pin 2 (CH1 H) ----> Scattered Wave
%
% Once all the analog pins are connected. Connect all the corresponding (CHX L) to (AGND).
% Also connect the GND with the system with GND. Connect the (+5
% ext) with the power source output.
%
% ----------------------- GUI Layout -----------------------------------
% The GUI has few different components. The GUI has a sliding windows of 3
% seconds. The toolbar allows the user to make changes in the plot in real
% time. The buttons on the user interface is as follows.
% PLAY button starts the collection.
% CLEAR button ends collection and prompts the users to save the data.
% REFERENCE button clear/plots the signals from Reference wave
% SCATTERED button clear/plots the signal from Scattered wave

function main_radarContinuous

global saveData; global timeData; global clear1; global toggle; Duration = 3; 
[samplingRate] = samplingRatePrompt;

%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
Duration = 3; %% Duration in seconds
% numberOfSample0s = samplingRate; %% Total number of samples that needs to be collected
inputRange = [-1 1]; %% Define the input range for the input Voltage +- 5 V
newData = zeros(Duration*samplingRate,2); x = zeros(samplingRate/1000,1); y = zeros(samplingRate/1000,1);

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
d = plot(x,y); axis([-2 2 -2 2]);


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
                saveData = horzcat(saveData,data'); % save all the data in an array
                timeData = horzcat(timeData,time'); % save the time in an array
               
                [data] = meanNormalize(data);
                [x,y] = ellipticalXY(data);
                
                [newData] = GUIProcessing(data,newData, Duration, samplingRate);
                
                set(d,'XData',x,'YData',y);
                set(a,'YData',newData(:,1));
                set(b,'YData',newData(:,2));
                drawnow;
                
                set(time_elapsed,'String',max(time));
                
                
                if(clear1 == 1)
                    DAQclear(ai);
                    DataSavePrompt(timeData,saveData);
                    guiClear;
                    break;
                end
            end
            guiClear;
            break;
        end
    end

end
