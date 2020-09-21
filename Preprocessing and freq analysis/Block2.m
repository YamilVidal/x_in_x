clear; close all;

INPath         = fullfile(pwd, 'Data', '1 - Set filtered');
OUTPath        = fullfile(pwd, 'Data', '2 - Done ICA');

ff = dir(fullfile(INPath,'*.set'));

parfor s = 1:length(ff)
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    EEG = pop_loadset('filename',ff(s).name,'filepath',INPath);
    
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');

    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',fullfile(OUTPath, ff(s).name),'overwrite','on','gui','off'); 
end