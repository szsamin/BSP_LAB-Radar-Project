% Wrapping Analysis Routine - Shadman Samin 8/29/2015
% The function prompts the user to find the location of the file and select
% it. The way the function works is as follows:
% Step 1: Load the Matlab file
% Step 2: User specify the sampling rate
% Step 3: Find the phase difference between the reference and scattered
% Step 4: Unwrap the phase 
% Step 5: Create small buffer windwos
% Step 6: Mean thresholding
% Step 7: Regressuib Calcution
% Step 8; Plot Routine

function wrappingRoutine_analysis_v3

T_win = .1; % sec % Time Window
bufferLength = 10; Fs = 80000; 

[FileName,PathName] = uigetfile('*.mat','Select the MATLAB Data file');
load(fullfile(PathName, FileName));


[data] = meanNormalize(data);
[phase_lag, ~, time_total] = findingPhaseLag(data,Fs); 
phase_unwrap = unwrap(phase_lag);
[new_point, length_phase] = adjacentMeans(phase_unwrap);
[xx, yy] = plotNewLines(new_point, length_phase); 
new_point(new_point == 0) = [];
new_point(diff(new_point)<0.5) = [];
[CalculatedDis, trueDis, difference_dis, rms_error] = regressionCalc(new_point);

figure(1); hold all; plot(time_total,phase_unwrap,'r');
plot(xx./bufferLength,yy,'b','LineWidth',2); 
hold off; title('Staircase Graph showing 5 mm Steps'); ylabel('Phase (radians'); xlabel('time (sec)');

figure(2); hold all; scatter(new_point,trueDis'); plot(new_point,CalculatedDis,'r'); title('Scatter Plot vs Regression fit line'); xlabel('Phase (radians)'); ylabel('True Distance (mm)');
legend('True Distance','Least Square Regression'); hold off;

figure(3);
hold all;
plot(trueDis',difference_dis,'o'); line([0 max(trueDis)],[0 0]);
str = sprintf('Scatter Plot showing the difference between calculated and true distance with an RMS of %s',num2str(rms_error));
title(str);
xlabel('True Distance (mm)'); ylabel('Calculated - True (mm)');
hold off;

end
