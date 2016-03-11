%%%%%%%%%%%%%%%%%% Dr Wan code find Phase Difference between two waves %%%%
clear all; clc; close all;

%%%%% Initializing the signal parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
Fs = 80000; %Hz %Sampling rate
T_win = .1; % sec % Time Window

%%%%% Load the saved data file from location %%%%%
load('withOcclusion8feet_withBook700page1.4inch_every5cmdatafile_20150807T095607.mat');
% load('C:/Users/BSP_Wan/Desktop/Radar Project/Matlab_codes/every5mmdatafile_20150728T113947.mat')
%load('/Users/ericwan/Dropbox/Work/MyMotio/BSPL Projects/Radar Project/Data Files .mat/stationary_datafile_20150722T120227.mat')

N = length(data); % Length of Data File (number of rows)
t = 0:1/Fs:T_win*(Fs-1)/Fs; %
npts = length(t); % Finding the length of T

[data] = meanNormalize(data); % Mean Normalize the raw data

phase_lag = zeros(1,N/npts);
amplitude_ratio = zeros(1,N/npts);

for k=1:N/npts-1;
    
    kk = k*npts:(k+1)*npts-1;
    x = data(kk,1);
    y = data(kk,2);
    x = x - mean(x);
    y = y - mean(y);
    
    %     figure(2);
    %     plot(x,y);
    %     axis([-1 1 -1 1]);
    
    % take the FFT
    NFFT = 2^nextpow2(numel(x)); % Next power of 2 from length of y
    f = Fs/2*linspace(0,1,NFFT/2+1);
    
    fft_x = fft(x,NFFT)/numel(x);
    fft_y = fft(y,NFFT)/numel(y);
    
    %     plot(f,2*abs(fft_x(1:NFFT/2+1)),'r'); hold on; xlim([875 920]); plot(f,2*abs(fft_y(1:NFFT/2+1)),'b'); hold off; drawnow;
    
    % Determine the max value and max point.
    % This is where the sinusoidal
    % is located. See Figure 2.
    [mag_x, idx_x] = max(abs(fft_x));
    [mag_y, idx_y] = max(abs(fft_y));
    % determine the phase difference
    % at the maximum point.
    px = angle(fft_x(idx_x));
    py = angle(fft_y(idx_y));
    phase_lag(k) = py - px;
    % determine the amplitude scaling
    amplitude_ratio(k) = mag_y/mag_x;
    
end

% Create Variable
phase_unwrap = unwrap(phase_lag);
time_total = (1:N/npts)*T_win;
length_phase = length(phase_unwrap);

% Create a 10 sample data buffer to segment the data
bufferLength = 10;
phase_segment = buffer(phase_unwrap,bufferLength);
[row, col] = size(phase_segment); %% [10 x 200] - [row x col]

new_point = zeros(length_phase,1); pop = zeros(length_phase,1);
mean_points = mean(phase_segment(:,:)); % Find the mean of the segmented data

index = 1;
% Difference thresholding between adjacent means
for ii = 2:col
    index = index + row;
    difference = abs(mean_points(ii)-mean_points(ii-1));
    if difference < 0.1
        new_point(index) = mean_points(ii-1);
    end
end

index = 0;
% Plot Lines on the graph
for ii = 1:length_phase
    if new_point(ii)~= 0
        index = index + 1;
        xx(:,index) = [ii-10 ii+10];
        yy(:,index) = [new_point(ii) new_point(ii)];
    end
end

kk = (1:N/npts)*T_win;
figure(1); hold all; plot(time_total,phase_unwrap,'r');
plot(xx./bufferLength,yy,'b','LineWidth',2); 
hold off; title('Staircase Graph showing 5 mm Steps'); ylabel('Phase (radians'); xlabel('time (sec)');

new_point(new_point == 0) = [];
new_point(diff(new_point)<0.5) = [];

newplen = length(new_point);
trueDis = 0:5:5*newplen-1;% True Distance
phase_square = (new_point).^2;
phaseDis = new_point.*trueDis';
sum_phase = sum(new_point);
sum_phasesquare = sum(phase_square);
sum_trueDis = sum(trueDis);
sum_phaseDis = sum(phaseDis);

% Slope(b) = (N?XY - (?X)(?Y)) / (N?X2 - (?X)2)
Slope = (newplen*sum_phaseDis - ((sum_phase)*(sum_trueDis)))/(newplen*sum_phasesquare - (sum_phase).^2);

% Intercept(a) = (?Y - b(?X)) / N 
Intercept = (sum_trueDis - Slope*sum_phase)/newplen;

CalculatedDis = Slope*new_point + Intercept;

figure(2); hold all; scatter(new_point,trueDis'); plot(new_point,CalculatedDis,'r'); title('Scatter Plot vs Regression fit line'); xlabel('Phase (radians)'); ylabel('True Distance (mm)');
legend('True Distance','Least Square Regression'); hold off;

difference_dis = CalculatedDis - trueDis';

rms_error = sqrt(mean((difference_dis).^2));

figure(3);
hold all;
plot(trueDis',difference_dis,'o'); line([0 max(trueDis)],[0 0]);
str = sprintf('Scatter Plot showing the difference between calculated and true distance with an RMS of %s',num2str(rms_error));
title(str);
xlabel('True Distance (mm)'); ylabel('Calculated - True (mm)');
hold off;




% plot(time_total,phase_unwrap);

% figure(1);
% plot(time,data(:,1),time,data(:,2));


% figure(4);
% kk = (1:N/npts)*T_win;
% subplot(211);
% len = length(unwrap(phase_lag));
% plot(kk,unwrap(phase_lag));
% xlabel('sec');
% ylabel('Radians');
% title('Phase Lag (unwraped)');
%
% subplot(212);
% plot(kk,amplitude_ratio);
% xlabel('sec');
% ylabel('Amplitude Ratio');
% title('Amplitude Ratio');

