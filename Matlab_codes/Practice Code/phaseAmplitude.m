function [phase,amplitude_ratio] = phaseAmplitude(x,y)


newx=fft(x);
newy=fft(y);
[mag_x idx_x] = max(abs(newx));
[mag_y idx_y] = max(abs(newy));

% determine the phase difference
% at the maximum point.
px = angle(newx(idx_x));
py = angle(newy(idx_y));
phase_lag = py - px;

% determine the amplitude scaling
amplitude_ratio  = mag_y/mag_x;

end