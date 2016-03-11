% Wrapping Analysis Routine - Shadman Samin 9/22/2015
% The function first
% normalizes the data and finds the phase lag. The routine finds the phase
% lag. This is done by using a 0.1 second sliding window. Then we take a
% fourier of the sliding window, and the maximum of the reference wave is
% found, and the corresponding index point of the scattered wave is used to
% find the phase difference. This gives us an approximate phase array of
% the scattered wave versus the reference wave. We use an unwrap routine to
% properly unwrap the phase to see a gradual change in phase which will in
% return help accurately measure distance. The phase array is segmented
% into 10 sample windows and we use a mean algorithm to identify and
% threshold points on the stairs case to identify each step. Based on the
% steps we use mean square regression to find the difference between actual
% 'ground' values versus calculation to give us an accurate represention of
% the data collection. The function prompts the user to find the location
% of the file and select it. The way the function works is as follows: Step
% 1: Load the Matlab file Step 2: User specify the sampling rate Step 3:
% Find the phase difference between the reference and scattered Step 4:
% Unwrap the phase Step 5: Create small buffer windwos Step 6: Mean
% thresholding Step 7: Regressuib Calcution Step 8; Plot Routine

function newScriptingAnalysis

[FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
load(fullfile(PathName, FileName));

%%%%% USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt = {'How big are the steps in Inches? ','Starting Distance in Feet? '};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'2','12'};
output = inputdlg(prompt,dlg_title,num_lines,defaultans);
DistanceMultiple = str2double(output{1});
feet = str2double(output{2});

startingDistance = 12*feet; %% Conversion of feet to Inches

%%%%% VARIABLE INITIALIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Duration = 4;
T_win = .1; % sec % Time Window
bufferLength = 2; height = 3*12;
data = saveData';
dataPot = saveData'; timeVal = []; pole = zeros(); newPole = zeros(); index = zeros(); index(1) = 1;
Fs = samplingRate;

[data] = meanNormalize(data(:,1:2));
[amplitude,phase_lag, time_total] = findingPhaseLag(data,Fs);

phase_unwrap = unwrap(phase_lag);
high = max(phase_unwrap); low = min(phase_unwrap);

phase_unwrap = vertcat(phase_unwrap,time_total); count = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Finding Time positions for different classes %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2); hold all; indexSave = []; newCount = 0; newTime = []; newTime1 = [];
for step = 1:steps-1
    pole = find(dataPot(:,4) == step-1);
    for states = 1:4
        %%%% The states define the time positions during the data
        %%%% collection: Pole finds the state and time positions them
        count = count + 1;
        newPole = find(dataPot(min(pole):max(pole),3) == states); %% Find the beginning and end of a particular class: stationery,occlusion, stationery, movement
        timeVal1(count) = min(pole) + max(newPole); %% time index for a certain class in a certain step
        timeVal(count) = roundn(timeData(timeVal1(count)),-1); %% timeValue 
        index(count) = find(abs(phase_unwrap(2,:)-timeVal(count)) < 0.001);
        
        switch states
            case 1
                plot([timeVal(count)-Duration timeVal(count)-Duration], [low high],'k','linewidth',2);
            case 2
                plot([timeVal(count)-Duration timeVal(count)-Duration], [low high],'g','linewidth',2);
            case 3
                plot([timeVal(count)-Duration timeVal(count)-Duration], [low high],'b','linewidth',2);
            case 4
                newTime = [newTime timeVal(count)-Duration];
                plot([timeVal(count)-Duration timeVal(count)-Duration], [low high],'y','linewidth',4);
        end
    end
end

legend('No movement','Occlusion','No movement','Transition to new position','Location','northwest');
plot(phase_unwrap(2,:),phase_unwrap(1,:),'r');
str1 = sprintf('Stair Case showing %d inch steps',DistanceMultiple);
title(str1); ylabel('Phase (radians'); xlabel('time (sec)');
hold off;

figure(1);
hold all;
length_time = numel(newTime);
for i = 1:length_time
    h1=rectangle('Position',[newTime(i) 0 Duration max(amplitude)], 'FaceColor',[0.5 0.5 0.5]); % [X Y W H]
    p1=plot(nan,nan,'s','markeredgecolor',get(h1,'edgecolor'),'markerfacecolor',get(h1,'facecolor'));
    
%     plot([newTime(i) newTime(i)],[0 max(amplitude)],'-b');  
%     plot([newTime1(i) newTime1(i)],[0 max(amplitude)],'-b');  
end
p2=plot(time_total,amplitude,'-r','LineWidth',2); legend([p1,p2],{'Transitions','Wave Amplitude Envelope'});
strnew = sprintf('Amplitude Envelope showing regions of Transition with %d inch steps',DistanceMultiple);
xlabel('Time(sec)'); ylabel('Amplitude'); title(strnew);
hold off;


for i = 2:numel(index)
    hold all;
    findMean(i-1) = mean(phase_unwrap(1,index(i-1):index(i))); 
    if(mod(i-1,4)== 0)
        findMean(i-1) = 0;
    end
end
hold off;


findMean(findMean == 0) = [];

newPoint = []; count1 = 0;

for i = 1:round(numel(findMean)/3)
    for ii = 1:3
        count1 = count1 + 1;
        newPoint(ii,i) = findMean(count1);
    end
end

newplen = length(newPoint(1,:))-1;
trueDis = 0:DistanceMultiple:DistanceMultiple*(newplen-1);
averagePoints = zeros(1,numel(newplen-1)); occlusionPoint = zeros(1,numel(newplen-1)); 

for i = 1:numel(trueDis)
    averagePoints(i) = 0.5*(newPoint(1,i)+newPoint(3,i));
    occlusionPoint(i) = newPoint(2,i);
end

%%%%% Delta(H) = (2*X/(2*(X^2+Y^2)))*Delta(X) %%%%%%%%%%%%%%%%%%%%%%%%%%%
delta_hypotenus = (startingDistance/sqrt(startingDistance^2+height^2)).*trueDis;


DistanceMoved_hyp = delta_hypotenus;
DistanceMoved_floor = trueDis;
[CalculatedDis_hyp,difference_dis_hyp,rms_error] = LinearRMS(DistanceMoved_hyp,averagePoints);
% [occlusion_CalculatedDis_hyp,occlusion_difference_dis_hyp,occlusion_rms_error] = LinearRMS(DistanceMoved_hyp,occlusionPoint);

occlusion_rms_error = sqrt(mean((difference_dis(1,:)).^2));



figure(3);
hold on;
% plot(DistanceMoved_floor,averagePoints(1,:),'r*-');
plot(DistanceMoved_hyp,averagePoints,'g*'); plot(DistanceMoved_hyp,occlusionPoint,'r*'); plot(CalculatedDis_hyp,averagePoints,'k--');
legend('Stationary Positions','Occlusions','Linear Fit Model');
ylabel('Phase (rad)'); xlabel('Distance (inch)');
strnew = sprintf('Plot showing Occlusion positions and non-occlusion positions with an average Linear Fit Model with %d inch steps',DistanceMultiple);
title(strnew);
hold off;

% 
% [CalculatedDis,difference_dis,rms_error] = LinearRMS(DistanceMoved_floor,averagePoints);
% 
% 
figure(4);
hold all;
str = sprintf('Scatter Plot: RMS Stationery = %f ; RMS Occlusion = %f',rms_error,occlusion_rms_error);
plot(CalculatedDis_hyp,difference_dis_hyp,'r*');
plot(occlusion_CalculatedDis_hyp,occlusion_difference_dis_hyp,'kO'); legend('Stationery RMS','Occlusion RMS');

%legend('No Occlusion','Occlusion','No Occlusion');
plot([-5 max(DistanceMultiple*newplen)], [0 0]);
title(str); xlabel('True Distance (inch)'); ylabel('Calculated - True (inch)'); 
hold off;

% str3 = sprintf('phaseData_%s.mat',datestr(now,'yyyymmddTHHMMSS'));
% [file,path] = uiputfile(str3,'Save Workspace As');
% saveData; timeData; samplingRate; steps;
% save(fullfile(path, file),'timeData','saveData','samplingRate','steps');

end

