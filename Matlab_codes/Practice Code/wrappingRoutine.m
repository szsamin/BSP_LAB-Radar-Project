clear all; clc; close all;
load('unwrap_phase.mat');
k = 0; u = 0;
phase_unwrap = buffer(unwrap_phase,10);

newp = zeros(2000,1);
pp = mean(phase_unwrap(:,:)); 

lol = 1;
for ii = 2:200
       lol = lol + 10;
       dff = abs(pp(ii)-pp(ii-1));
       if dff < 0.09
          pp(ii-1) = 0; 
          newp(lol) = pp(ii);
       end          
end


pol = 0;
for ii = 1:2000
    if newp(ii)~= 0 
       pol = pol + 1;
       xl(:,pol) = [ii-10 ii+10];
       yy(:,pol) = [newp(ii) newp(ii)];       
    end
end

% figure(1);
% hold all; plot(unwrap_phase,'r');
% plot(xl,yy,'b','LineWidth',2); hold off;

newp(newp == 0) = [];
newp(diff(newp)<0.5) = [];
newplen = length(newp);
trueDis = 0:5:5*newplen-1;% True Distance

phase_square = (newp).^2;
phaseDis = newp.*trueDis';
sum_phase = sum(newp);
sum_phasesquare = sum(phase_square);
sum_trueDis = sum(trueDis);
sum_phaseDis = sum(phaseDis);

% Slope(b) = (N?XY - (?X)(?Y)) / (N?X2 - (?X)2)
Slope = (newplen*sum_phaseDis - ((sum_phase)*(sum_trueDis)))/(newplen*sum_phasesquare - (sum_phase).^2);

% Intercept(a) = (?Y - b(?X)) / N 
Intercept = (sum_trueDis - Slope*sum_phase)/newplen;


CalculatedDis = Slope*newp + Intercept;

difference_dis = CalculatedDis - trueDis';
hold all;
plot(trueDis',difference_dis,'o'); line([0 250],[0 0]); hold off;





% figure(2); 
% scatter(newp,trueDis(1:newplen)'); h = lsline;
% 
% p2 = polyfit(get(h,'xdata'),get(h,'ydata'),1);
% slope = p2(1); intercept = p2(2);

% num = 0:1:newplen;
% CalculatedDis = slope*num+intercept;
% 
% difference_dis = trueDis;
% figure(3);
% plot(trueDis,CalculatedDis,'o');
% 




% plot(trueDis(1:newplen)',newp,'-*');

% figure(2); plot(newp,'r*');

