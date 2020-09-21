%% Bayesian analysis for the paper 
% "Implicit Statistical Learning of Transient Categories in Fast Periodic
% Visual Stimulation"

% https://doi.org/xxxxxxxxxxxx

clear
close all

OutPath = 'Stats';

% Conditions
%       Pseudofonts = 1
%          Nonwords = 2
%      Pseudowords  = 3
%             Words = 4

Cond1        = 'Cnd_3';
Cond2        = 'Cnd_4';
CarrierFreq = 6;
yLimMin     = 0;
yLimMax     = 6;

Measure = 'BC';

ThePath = fullfile('Data');
CalcActualF

load Chanlocs

load(fullfile(pwd,ThePath,'Freq',Cond1));
SNR_all_1 = SNR_all;
BC_all_1  = BC_all;

load(fullfile(pwd,ThePath,'Freq',Cond2));
SNR_all_2 = SNR_all;
BC_all_2  = BC_all;

fi     = Ft; % Oddball frequency and first 3 harmonics
fI     = fi*(1:4)';

[~,fw] = min(abs(repmat(f,[length(fI),1]) - repmat(fI,[1,length(f)])),[],2);

IF = fw';

if strcmp(Measure,'SNR')
    M_1     = squeeze(mean(SNR_all_1(IF,:,:),1))'; % Mean of frequencies of interest
    M_2     = squeeze(mean(SNR_all_2(IF,:,:),1))'; % Mean of frequencies of interest
else
    M_1     = squeeze(sum(BC_all_1(IF,:,:),1))'; % Sum of frequencies of interest
    M_2     = squeeze(sum(BC_all_2(IF,:,:),1))'; % Sum of frequencies of interest
end

[~,~,~,stats] = ttest(M_1,M_2);

bf10 = nan(128,1);

for e = 1:128
    bf10(e) = t1smpbf(stats.tstat(e),size(M_1,1)); % Script originally writen by Sam Schwarzkopf (Twitter: @sampendu)
end

clc
elec = find(bf10>3);
fprintf('Electrodes with BF10 > 3: %2.f\n',numel(elec));

elec = find(bf10<1/3);
fprintf('Electrodes with BF10 < 1/3: %2.f\n',numel(elec));
