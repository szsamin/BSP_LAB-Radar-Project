%%%%%%%%%%%%%%%%%% Dr Wan code find Phase Difference between two waves %%%%
clear all; clc; close all;

%%%%% Initializing the signal parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;
Fs = 80000; %Hz %Sampling rate
T_win = .1; % sec % Time Window


%%%%% Load the saved data file from location %%%%%
load('C:/Users/BSP_Wan/Desktop/Radar Project/Matlab_codes/every5cmdatafile_20150727T152635.mat')
%load('/Users/ericwan/Dropbox/Work/MyMotio/BSPL Projects/Radar Project/Data Files .mat/stationary_datafile_20150722T120227.mat')

N = length(data); % Length of Data File (number of rows) 
t = 0:1/Fs:T_win*(Fs-1)/Fs; % Dont know what this is doing??
npts = length(t); % Finding the length of T

[data] = meanNormalize(data); 

% figure(1);
% plot(time,data(:,1),time,data(:,2));

phase_lag = zeros(1,N/npts);
amplitude_ratio = zeros(1,N/npts);

for k=1:N/npts-1;
    
    kk = k*npts:(k+1)*npts-1;
    x = data(kk,1);
    y = data(kk,2);
    x = x - mean(x);
    y = y - mean(y);
    
    figure(2);
    plot(x,y);
    axis([-1 1 -1 1]);
    
    % take the FFT
    NFFT = 2^nextpow2(numel(x)); % Next power of 2 from length of y
    f = Fs/2*linspace(0,1,NFFT/2+1);

    fft_x = fft(x,NFFT)/numel(x);
    fft_y = fft(y,NFFT)/numel(y);
    
%     plot(f,2*abs(fft_x(1:NFFT/2+1)),'r'); hold on; xlim([875 920]); plot(f,2*abs(fft_y(1:NFFT/2+1)),'b'); hold off; drawnow; 
    
    % Determine the max value and max point.
    % This is where the sinusoidal
    % is located. See Figure 2.
    [mag_x idx_x] = max(abs(fft_x));
    [mag_y idx_y] = max(abs(fft_y));
    % determine the phase difference
    % at the maximum point.
    px = angle(fft_x(idx_x));
    py = angle(fft_y(idx_y));
    phase_lag(k) = py - px;
    % determine the amplitude scaling
    amplitude_ratio(k) = mag_y/mag_x;

end

figure(4);
kk = (1:N/npts)*T_win;
subplot(211);
len = length(unwrap(phase_lag));
plot(kk,unwrap(phase_lag));
xlabel('sec');
ylabel('Radians');
title('Phase Lag (unwraped)');

subplot(212);
plot(kk,amplitude_ratio);
xlabel('sec');
ylabel('Amplitude Ratio');
title('Amplitude Ratio');

