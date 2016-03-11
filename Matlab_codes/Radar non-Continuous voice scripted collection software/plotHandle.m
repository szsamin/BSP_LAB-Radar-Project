function [a, b, d] = plotHandle(newData,Duration, samplingRate, inputRange, x, y)

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


end