clear
close all

% Definition of folders
ThePath = 'DATA';
pathraw = fullfile(pwd, ThePath, '0 - Raw');
pathset = fullfile(pwd, ThePath, '1 - Set filtered');

% Looks for all files in folder
ff = dir(fullfile(pathraw,'*.bdf'));

%% Do this file by file
for s = 1:length(ff)
    
    % Import to EEGLAB
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    EEG                     = pop_biosig(fullfile(pathraw, ff(s).name), 'importannot','off', 'refoptions', {'keepref' 'off' });
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname', ff(s).name(1:end-4),'gui','off');
    
    % Import channel locations
    EEG = pop_select( EEG,'nochannel',{'EXG3' 'EXG4' 'EXG5' 'EXG6' 'EXG7' 'EXG8' 'GSR1' 'GSR2' 'Erg1' 'Erg2' 'Resp' 'Plet' 'Temp'});
    EEG = pop_chanedit(EEG, 'load',{fullfile(pwd,'biosemy_ch_locations - 128.ced'), 'filetype', 'autodetect'});
    
    % Band pass filter 0.1Hz to 100Hz
    EEG = pop_eegfiltnew(EEG, [], 0.1, [], true, [], 0); % Highpass filter 0.1 Hz
    EEG = pop_eegfiltnew(EEG, [], 100, [], 0, [], 0);    % Lowpass filter 100 Hz
    
    % Save
    EEG = pop_saveset( EEG, 'filename',[ff(s).name(1:end-4),'.set'],'filepath',pathset);
end