function demoai_continuous_timer_callback(obj,event,plotHandle,titleHandle)
% This callback function executes each time the time specified by 
% TimerPeriod passes. The input parameters obj and event are passed implicitly in the callback
% function.
% * obj is the analog input object ai
% * event is a variable that stores the data contained in the EventLog
%   property
% This function calls the demoai_continuous_fft function to check whether the frequency is detected.
% If the frequency is detected then the callback issues a stop command to
% the analog input object.

persistent count;
persistent totalData;
if isempty(count)
     count =0;
end
count = count + 1;
% Get only the number of samples that are available
[data,time] =getdata(obj,obj.SamplesAvailable);
% First time through assign the data to totalData, else append it.
if isempty(totalData)
    totalData.time = time;
    totalData.data =data;
else
    totalData.time = [totalData.time;time];
    totalData.data = [totalData.data;data];
end
% Call demoai_continuous_fft to check whether the frequency is detected. If detected,
% transfer the data to UserData property of the object and stop the object
if(demoai_continuous_fft(data,plotHandle))
    set(obj,'UserData',totalData);
    stop(obj); 
end
% Update the title of the graph
set(titleHandle,'String',['Discrete Fourier Transform Plot (fft),Number of callback function calls: ', num2str(count)]);