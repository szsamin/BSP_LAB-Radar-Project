function generatePlot(time,data)

%%%% Generate Plot Routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = sprintf('Data sampled at %f Hands moving infront in line of sight',samplingRate);
plot(time,data(:,1),'b'); hold on; plot(time,data(:,2),'r');
title(str); ylabel('Output(Volts)'); xlabel('Time(sec)');
str2 = sprintf('every5cm_fig_%s.fig',datestr(now,'yyyymmddTHHMMSS'));
saveas(gcf,str2);

end