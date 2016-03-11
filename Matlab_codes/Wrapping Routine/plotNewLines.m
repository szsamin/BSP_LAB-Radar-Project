function [xx, yy] = plotNewLines(new_point, length_phase)

index = 0;
% Plot Lines on the graph
for ii = 1:length_phase
    if new_point(ii)~= 0
        index = index + 1;
        xx(:,index) = [ii-10 ii+10];
        yy(:,index) = [new_point(ii) new_point(ii)];
    end
end

xx; yy;

end