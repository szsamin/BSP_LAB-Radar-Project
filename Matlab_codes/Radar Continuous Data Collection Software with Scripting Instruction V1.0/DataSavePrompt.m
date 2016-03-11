function DataSavePrompt(timeData,saveData,samplingRate,steps)

str3 = sprintf('datafile_%s.mat',datestr(now,'yyyymmddTHHMMSS'));
[file,path] = uiputfile(str3,'Save Workspace As');
saveData; timeData; samplingRate; steps;
save(fullfile(path, file),'timeData','saveData','samplingRate','steps');

end