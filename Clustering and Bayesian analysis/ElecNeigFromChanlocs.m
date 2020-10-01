function [ Nei ] = ElecNeigFromChanlocs( Chanlocs, N )
%ELECNEIG Creates fieldtrip friendly neighbor electrodes structure to use
%with statcondfieldtrip(). Uses Euclidean distance.
%   Usage:
%        [ Nei ] = ElecNeig( EEG, N );
%   Where:
%         EEG = EEGLAB EEG Structure.
%           N = Number of neighbor electrodes. An electrode is not neighbor
%           of itself.

Nei(length(Chanlocs)).label       = [];
Nei(length(Chanlocs)).neighblabel = [];

for e=1:length(Chanlocs)
    elec = ElecClustFromChanlocs(Chanlocs,e,N+1);
    
    Nei(e).label = Chanlocs(e).labels;
    
    n = cell(1,N);
    
    for l=1:N
        n{l} = Chanlocs(elec(l+1)).labels;
    end
    
    Nei(e).neighblabel = n;
end


end

