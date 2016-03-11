% Script for DAQ data acquistion Practice Test two %%%%%%%%%%%%%%%%%%%%
clear all;close all;clc;

function daq_test
%%%%%%%%%%%% Setting up the input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
samplingRate = 250000; % Setting up the sampling rate
Duration = 20; %% Duration in seconds
numberOfSamples = samplingRate; %% Total number of samples that needs to be collected
inputRange = [-5 5]; %% Define the input range for the input Voltage +- 5 V

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

function setClear(hObject,eventdata)
		display([data.val data.diffMax]);
end

% function setClear(source,~)
% 
% 
% 
% 
%      clear = get(source,'Value');
% %     if(clear == 1)
% %         close all;
% %         clc;
% %         break;
% %     end 
% %     end
% %     
clearButton = uicontrol('Style','pushbutton','String','Close',...
    'Position',[20 20 50 20],...
    'Callback',@setClear);

% function toggle(source,~)
%     toggle = get(source,'Value');
        while(true)
        start(ai);
        [data,time,abstime,events] = getdata(ai);
        chan0 = data(:,1); 
        chan1 = data(:,2);
        plot(chan0); ylim([-1 5]);
        drawnow;
        end
% end

end

