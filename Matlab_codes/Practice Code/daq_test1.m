% Script for DAQ data acquistion Practice Test two %%%%%%%%%%%%%%%%%%%%

function daq_test1

clear all; clc;

global saveData; 
global timeData;


%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
samplingRate = 80000; % Setting up the sampling rate
Duration = 2; %% Duration in seconds
% numberOfSample0s = samplingRate; %% Total number of samples that needs to be collected
inputRange = [-5 5]; %% Define the input range for the input Voltage +- 5 V
newData = zeros(Duration*samplingRate,1);
data = zeros();

%%%%%%%%%%%% Setting up the Device object for recording %%%%%%%%%%%%%%%%%
ai = analoginput('mcc',0);
addchannel(ai, [0 1]);
set(ai,'InputType','Differential');
set(ai, 'SampleRate',samplingRate);
% set(ai,'SamplesPerTrigger',50000);
ai.Channel.InputRange = inputRange;

%%%% Setting up the Graphical user Interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Visible','on','Position',[200,50,1024,600],'name','DAQ Visualizer');

clearButton = uicontrol('Style','pushbutton','String','Close',...
    'Position',[20 50 50 20],...
    'Callback',@setClear);

    function setClear(source,~)
        clear1 = get(source,'Value');
        if(clear1 == 1)
            str2 = sprintf('%s_fig.fig',datestr(now,'yyyymmddTHHMMSS'));
            saveas(gcf,str2);
            str3 = sprintf('datafile_%s',datestr(now,'yyyymmddTHHMMSS'));
            saveData; timeData;
            save(str3,'timeData','saveData');
            stop (ai);
            delete(ai)
            clear ai
            close all; clear all; clc 
        end
    end


h = plot(newData);
xlabel('Samples'); ylabel('Ouput (V)'); str = sprintf('Sampling at %s',num2str(samplingRate));
title(str);

toggleButton = uicontrol('Style','togglebutton','String','Play',...
    'Position',[20 20 50 20],...
    'Callback',@toggle);

    function toggle(source,~)
        toggle = get(source,'Value');
        
        while(toggle==1)
            start(ai);
            [data,time] = getdata(ai);
            saveData = horzcat(saveData,data(:,1)');
            timeData = horzcat(timeData,time');
            m = numel(data(:,1));
            length = numel(newData);
            
            if(length < Duration*samplingRate)
                difference = Duration*samplingRate - length;
                pad = zeros(difference,1);
                newData = horzcat(pad', newData');
                newData = newData';
            end
            
            %%%% Padding Zeros %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(m < Duration*samplingRate)
                newData = horzcat(newData', data(:,1)');
                newData = newData';
            end
            
            newData(1:m,:) = [];
            
            set(h,'YData',newData);
            drawnow;
        end
    end

end
