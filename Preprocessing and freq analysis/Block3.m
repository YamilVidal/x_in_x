clear; close all;

INPath  = fullfile(pwd, 'DATA', '3 - Clean ICA');
OUTPath = fullfile(pwd, 'DATA', '4 - Conditions');

ff      = dir(fullfile(INPath,'*.set'));

for s = 1:length(ff)
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    % Dataset containing all channels
    EEG                       = pop_loadset('filename','ChanLocsInt.set','filepath',fullfile(pwd));
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Dataset with missing channels
    EEG                       = pop_loadset('filename', ff(s).name,'filepath',INPath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    % Interpolate missing channels
    EEG                     = pop_interp(EEG, ALLEEG(1).chanlocs, 'spherical');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'overwrite','on','gui','off');
    
    % Re-Ref to average reference
    EEG = pop_reref( EEG, []);
    
    % Convert all events to text
    for e = 1:length(EEG.event)
        EEG.event(e).type = num2str(EEG.event(e).type);
    end
    
    % Segment
    EEG                       = pop_epoch( EEG, {'11', '21', '31','41', '51', '61'}, [0, 60], 'newname', ff(s).name(1:end-4), 'epochinfo', 'yes');
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, CURRENTSET);
    
    %% Save conditions
    for cnd = 1:4
        EEG2                    = pop_selectevent( ALLEEG(2), 'type',{[num2str(cnd),'1']},'deleteevents','off','deleteepochs','on','invertepochs','off');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG2, CURRENTSET,'setname',[[num2str(cnd),'_'],ff(s).name(1:end-4)],'savenew',fullfile(OUTPath,[[num2str(cnd),'_'],ff(s).name]),'gui','off');
        ALLEEG                  = pop_delset( ALLEEG, [3]);
        
        eeglab redraw;
    end
end