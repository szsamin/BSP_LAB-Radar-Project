% Script for DAQ data acquistion Practice Test two %%%%%%%%%%%%%%%%%%%%

function daq_test2

clear all; clc;

global saveData;
global timeData;
global val;

% Construct a questdlg with three options
choice = questdlg('How many channels do you want to display?', ...
	'Channel Selection Menu', ...
	'1','2','3','1');

% Handle response
switch choice
    case '1'
        val = 0;
        channelVal = 0;
    case '2'
        val = 1;
        channelVal = [0,1];
    case '3'
        val = 2;
        channelVal = [0,1,2];
end


%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
samplingRate = 80000; % Setting up the sampling rate
Duration = 2; %% Duration in seconds
% numberOfSample0s = samplingRate; %% Total number of samples that needs to be collected
inputRange = [-5 5]; %% Define the input range for the input Voltage +- 5 V
newData = zeros(Duration*samplingRate,2);
data = zeros();

%%%% Setting up the Graphical user Interface %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Visible','on','Position',[200,50,1024,600],'name','DAQ Visualizer');
        
        %%%%%%%%%%%% Setting up the Device object for recording %%%%%%%%%%%%%%%%%
        ai = analoginput('mcc',0);
        addchannel(ai, channelVal);
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
                saveData; timeData;
                save(str3,'timeData','saveData');
                stop (ai);
                delete(ai)
                clear ai
                close all; clear all; clc
            end
        end
        
        timespan = linspace(1,Duration,Duration*samplingRate);
        switch val
            case 0
                a = plot(timespan,newData(:,1));
            case 1
                a = plot(timespan,newData(:,1));
                hold on; b = plot(timespan,newData(:,1));
            case 2
                a = plot(timespan,newData(:,1));
                hold on; b = plot(timespan,newData(:,2)); hold on; c = plot(timespan,newData(:,3));
        end
        
        
        
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
                
                switch val
                    case 0
                        set(a,'YData',newData(:,1));
                    case 1
                        set(a,'YData',newData(:,1));
                        set(b,'YData',newData(:,2));
                    case 2
                        set(a,'YData',newData(:,1));
                        set(b,'YData',newData(:,2));
                        set(c,'YData',newData(:,3));
                end
                drawnow;
            end
        end
        
    end
