%%%%%%%%%%%% Author: Shadman Samin - January 2016 %%%%%%%%%%%%%%%%%%%%%%%%
%%% This function produces a linear fit model between the phase and
%%% distance. This gives a phase corelation between phase and distance. 

%%%%% Finding RMS error
%%%%% (1) Find the slope of the phase vs true distance
%%%%% (2) Find the Y intercept for the Linear fit between Phase n True dis
%%%%% (3) Find the RMS between true distance and linear fit distance

%%%% Inputs are Distance and Phase Information, outputs calculated linear
%%%% distance model and RMS value

function [CalculatedDis,difference_dis,rms_error] = LinearRMS(trueDis,newPoint)

newplen = numel(newPoint); %% Length of the Phase Array

CalculatedDis = [];
difference_dis = [];

%%% Linear Fit components
phase_square = (newPoint(1,1:newplen)).^2;
phaseDis = newPoint(1,1:newplen).*trueDis;
sum_phase = sum(newPoint(1,1:newplen));
sum_phasesquare = sum(phase_square);
sum_trueDis = sum(trueDis);
sum_phaseDis = sum(phaseDis);

% Slope(b) = (N?XY - (?X)(?Y)) / (N?X2 - (?X)2)
Slope = (newplen*sum_phaseDis - ((sum_phase)*(sum_trueDis)))/(newplen*sum_phasesquare - (sum_phase).^2);

% Intercept(a) = (?Y - b(?X)) / N
Intercept = (sum_trueDis - Slope*sum_phase)/newplen;

CalculatedDis(1,:) = Slope*(newPoint(1,1:newplen)) + Intercept;

difference_dis(1,:) = CalculatedDis(1,:) - trueDis;
rms_error = sqrt(mean((difference_dis(1,:)).^2));

end