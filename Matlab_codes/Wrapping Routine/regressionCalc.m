function [CalculatedDis, trueDis, difference_dis, rms_error] = regressionCalc(new_point)

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

difference_dis = CalculatedDis - trueDis'; 
rms_error = sqrt(mean((difference_dis).^2));

end

