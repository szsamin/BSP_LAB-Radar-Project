function [samplingRate] = samplingRatePrompt

choice = menu('Select a sampling Rate','5000','10000','80000','250000');

switch choice
    case 0
        samplingRate = 5000;
    case 1
        samplingRate = 10000;
    case 2
        samplingRate = 80000;
    case 3
        samplingRate = 250000;        
end

end
