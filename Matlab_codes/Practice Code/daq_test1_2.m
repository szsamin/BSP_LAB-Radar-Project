% Script for DAQ data acquistion Practice Test two %%%%%%%%%%%%%%%%%%%%

function daq_test1_2

clear all; clc;

global saveData;
global timeData; global clear1;


%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
samplingRate = 5000; % Setting up the sampling rate
Duration = 3; %% Duration in seconds
% numberOfSample0s = samplingRate; %% Total number of samples that needs to be collected
inputRange = [-5 5]; %% Define the input range for the input Voltage +- 5 V
newData = zeros(Duration*samplingRate,2);
data = zeros();

%%%% Setting up the Graphical user Interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Visible','on','Position',[200,50,1024,600],'name','DAQ Visualizer');

%%%%%%%%%%%% Setting up the Device object for recording %%%%%%%%%%%%%%%%%
ai = analoginput('mcc',0);
addchannel(ai, [0,1]);
dio = digitalio('mcc','0');
dout = addline(dio,0:3,1,'out');
set(ai,'InputType','Differential');
set(ai, 'SampleRate',samplingRate);
% set(ai,'SamplesPerTrigger',50000);
ai.Channel.InputRange = inputRange;

clearButton = uicontrol('Style','pushbutton','String','Close',...
    'Position',[20 50 50 20],...
    'Callback',@setClear);

    function setClear(source,~)
        clear1 = get(source,'Value');
        if(clear1 == 1)
            str2 = sprintf('%s_fig.fig',datestr(now,'yyyymmddTHHMMSS'));
            saveas(gcf,str2);
            str3 = sprintf('datafile_%s',datestr(now,'yyyymmddTHHMMSS'));
            saveData; timeData; Data1;
            save(str3,'timeData','saveData','Data1');
            close all; 
            clear all;
            clc;
        end
    end

timespan = linspace(1,Duration,Duration*samplingRate);
a = plot(timespan,newData(:,1),'r');
hold on; b = plot(timespan,newData(:,2),'b');




xlabel('Time(sec)'); ylabel('Ouput(V)'); str = sprintf('Sampling at %s',num2str(samplingRate));
title(str);

toggleButton = uicontrol('Style','togglebutton','String','Play',...
    'Position',[20 20 50 20],...
    'Callback',@toggle);

    function toggle(source,~)
        toggle = get(source,'Value');
        
        while(toggle==1)
            i = 0;
            for i = 0:15
            putvalue(dio,i);
            start(ai);
            [data,time] = getdata(ai);
            
            str3 = sprintf('datafile_%s',num2str(i));
            data; timeData;
            save(str3,'timeData','data');

            
            saveData = horzcat(saveData,data');
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
                newData = horzcat(newData', data');
                newData = newData';
            end
            
            
            newData(1:m,:) = [];
            
            set(a,'YData',newData(:,1));
            set(b,'YData',newData(:,2));
            drawnow;
            
            
            if(clear1 == 1 | i == 15)
                stop (ai);
                delete(ai);
                clear ai;
                break;
            end
            end
        end
    end

end
