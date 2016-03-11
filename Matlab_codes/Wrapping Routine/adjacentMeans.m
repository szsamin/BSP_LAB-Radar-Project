function [new_point, length_phase] = adjacentMeans(phase_unwrap)

% Create a 10 sample data buffer to segment the data
bufferLength = 10;
phase_segment = buffer(phase_unwrap,bufferLength);
[row, col] = size(phase_segment); %% [10 x 200] - [row x col]


length_phase = length(phase_unwrap);
new_point = zeros(length_phase,1); 
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


end