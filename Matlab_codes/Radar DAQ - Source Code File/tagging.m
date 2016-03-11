function [new, timeVal] = tagging(count,length,TOC)

for i = 1:length
    new(i) = count;
    timeVal(i) = TOC;
end

end