function [amplitude,phase_lag, time_total] = findingPhaseLag(data,Fs)

T_win = .1; % sec % Time Window
N = length(data); % Length of Data File (number of rows)
t = 0:1/Fs:T_win*(Fs-1)/Fs; %
npts = length(t); % Finding the length of T

phase_lag = zeros(1,floor(N/npts));
amplitude = zeros(1,floor(N/npts));
% amplitude_ratio = zeros(1,N/npts);

K = numel(data(:,1)) - npts;   % Number of repetitions


for k=1:N/npts-1;

% for k = 1:K;

%     kk = k:k+npts-1;
    
    kk = k*npts:(k+1)*npts-1;
    
    x = data(kk,1);
    y = data(kk,2);
    x = x - mean(x);
    y = y - mean(y);
    
    % take the FFT
    NFFT = 2^nextpow2(numel(x)); % Next power of 2 from length of y
%     f = Fs/2*linspace(0,1,NFFT/2+1);
    
    fft_x = fft(x,NFFT)/numel(x);
    fft_y = fft(y,NFFT)/numel(y);
        
    % Determine the max value and max point.
    % This is where the sinusoidal
    % is located. See Figure 2.
    mfx = abs(fft_x);
    mfy = abs(fft_y);
    
    [~, idx_x] = max(mfx);
    mag_y = mfy(idx_x); 
    
    % determine the phase difference
    % at the maximum point.
    px = angle(fft_x(idx_x));
    py = angle(fft_y(idx_x));
    
    phase_lag(k) = py - px;
    
    % determine the amplitude scaling
    amplitude(k) = mag_y;
end

time_total = (1:N/npts)*T_win;

end