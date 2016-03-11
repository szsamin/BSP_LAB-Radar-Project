function [data] = meanNormalize(data)

[~, col] = size(data);

for i = 1:col
data(:,i) = data(:,i)-mean(data(:,i)); % Shifting the mean to center it around zero
data(:,i) = data(:,i)/max(abs(data(:,i))); % Normalizing the values
end

end