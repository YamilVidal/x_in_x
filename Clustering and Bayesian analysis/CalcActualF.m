INPath  = fullfile(pwd, ThePath, 'Behavioral');

ff = dir(fullfile(INPath,'*.mat'));

Fnt = nan(length(ff),1);
Ft  = nan(length(ff),1);

for file = 1:length(ff)
    load(fullfile(INPath,ff(file).name));
    
    df    = diff(E.Screen.vblBlocks,1,2);
    timeW = E.Screen.vblBlocks(:,1:(60/CarrierFreq):end);
    timeT = timeW(:,5:5:end);
    
    dfw = diff(timeW,1,2);
    dft = diff(timeT,1,2);
    
    delay = sum(df(2:end)>.018); % Test for frame delays. First frame is ignored as is usually delayed
    if any(delay); warning(['Participant ',ff(file).name,' has ',num2str(delay),' delayed frames.']); end
    
    Fnt(file) = 1/nanmean(dfw(:));
    Ft(file) = 1/nanmean(dft(:));
end

%%
Fnt = mean(Fnt);
Ft = mean(Ft);

display(['Fnt = ',num2str(Fnt),' Ft = ',num2str(Ft)]);