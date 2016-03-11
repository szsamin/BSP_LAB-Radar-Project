function [x,y] = ellipticalXY(data)

[data] = meanNormalize(data);

X = data(:,1);
Y = data(:,2);
x = X - mean(X);
y = Y - mean(Y);

end