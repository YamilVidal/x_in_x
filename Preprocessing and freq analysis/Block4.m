clear; close all;

ThePath = 'DATA';
InPath  = fullfile(pwd, ThePath, '4 - Conditions');
OutPath = fullfile(pwd, ThePath, '5 - Freqs');

%%
for cnd = 1:4 % For each condition
    ff = dir(fullfile(InPath,[[num2str(cnd),'_'],'*.set']));
    
    Y_all      = cell(1,1,length(ff)); % Output of Fourier transform
    SNR_all    = cell(1,1,length(ff)); % Signal to noise ratio
    BC_all     = cell(1,1,length(ff)); % Baseline corrected
    
    for s = 1:length(ff)
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        
        EEG                       = pop_loadset('filename',ff(s).name,'filepath',InPath);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
        Fs = EEG.srate;         % Get Sampling rate
        L  = size(EEG.data,2);  % Length of the signal (one trial)
        %D  = mean(EEG.data,3)'; % Take the mean of trials
        D  = EEG.data(:,:,5)'; % Take the mean of trials
        
        Y  = fft(D); % Fast Fourier Transform
        
        % square root of the sum of squares of the real and imaginary parts
        % divided by the number of data points
        Y  = sqrt(real(Y).^2+imag(Y).^2)/L;
        
        Y  = Y(1:L/2+1,:); % Take half
        f  = Fs*(0:(L/2))/L; % Vector of values for the freq bins
        
        SNR    = zeros(size(Y));
        BC     = zeros(size(Y));
        
        for e = 1:size(EEG.data,1) % For each electrode
            for n = 12:length(Y)-12
                Ys = Y([n-11:n-2,n+2:n+11],e); % surrounding bins
                                               % excluding adjacent and two
                                               % extremes (min and max)
                [~, idmin] = min(Ys);
                [~, idmax] = max(Ys);
                Ys([idmin,idmax]) = [];
                
                SNR(n,e)    = Y(n,e) / mean(Ys); % SNR
                BC(n,e)     = Y(n,e) - mean(Ys); % Baseline corrected
            end
        end
        
        Y_all{s}      = Y;
        SNR_all{s}    = SNR;
        BC_all{s}     = BC;
        
        disp(['Done dataset ',num2str(s),' of cond ',num2str(cnd)]);
    end
    
    Y_all      = cell2mat(Y_all);
    SNR_all    = cell2mat(SNR_all);
    BC_all     = cell2mat(BC_all);
    
    save(fullfile(OutPath,['Cnd_',num2str(cnd),'.mat']),'Fs','L','f','Y_all','SNR_all','BC_all')
end
