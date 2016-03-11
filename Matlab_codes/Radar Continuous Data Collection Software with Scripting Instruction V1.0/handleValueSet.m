function handleValueSet(a,b,d,newData,x,y,Duration,samplingRate,button1,button2,button3)

if(button1 == 0)
    set(a,'YData',newData(:,1));
else
    set(a,'YData',zeros(Duration*samplingRate,1));
end
if(button2 == 0)
    set(b,'YData',newData(:,2));
else
    set(b,'YData',zeros(Duration*samplingRate,1));
end
if(button3 == 0)
    set(d,'XData',x,'YData',y);
else
    set(d,'XData',zeros(numel(x),1),'YData',zeros(numel(y),1));
end

drawnow;















end