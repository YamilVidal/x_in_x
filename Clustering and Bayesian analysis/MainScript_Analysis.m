%% Clustering analysis for the paper 
% "Implicit Statistical Learning of Transient Categories in Fast Periodic
% Visual Stimulation"

% https://doi.org/xxxxxxxxxxxx

%% Clustering analysis
%   Requires the EEGLAB toolbox with the Fieldtrip extension

% Conditions
%       Pseudofonts = 1
%          Nonwords = 2
%      Pseudowords  = 3
%             Words = 4

clear
close all
Cond        = 'Cnd_1';
CarrierFreq = 6;
yLimMin     = 0;
yLimMax     = 6;

Measure = 'BC';

ThePath = fullfile('Data');

CalcActualF % Uses Screen information to determine which was the average empirical presentation rate

load(fullfile(pwd,ThePath,'Freq',Cond));

fI     = Ft*(1:4)'; % Oddball frequency and first 3 harmonics
[~,fw] = min(abs(repmat(f,[length(fI),1]) - repmat(fI,[1,length(f)])),[],2);

IF = fw';

if strcmp(Measure,'SNR')
    M_all = SNR_all; % Measure to be used
    M     = mean(M_all(IF,:,:),1); % Mean of frequencies of interest
    data  = cat(4, M, ones(size(M))); % Null condition = 1
else
    M_all = BC_all; % Measure to be used
    M     = sum(M_all(IF,:,:),1); % Sum of frequencies of interest
    data  = cat(4, M, zeros(size(M))); % Null condition = 0
end

data = cat(1, data, data); % We only want to use clustering over space, but
                           % as the functions are designed to cluster over 
                           % time and space, we simply duplicate the data 
                           % on the first dimension to simulate two
                           % consecutive timepoints.

load Chanlocs.mat
lb = cell(length(Chanlocs),1);          % Electrode labels
for n = 1:length(Chanlocs)
    lb{n} = Chanlocs(n).labels;
end

[ Nei ] = ElecNeigFromChanlocs( Chanlocs, 3 ); % Create Electrode Neigbours structure
Nelec   = 1; % Number of neighboring electrodes that an electrode should have to be included in a cluster

conditions = {Cond, 'Null'};

% THE ACTUAL CLUSTERING
%%
nperm     = 5000;
stat      = ClstPerm(data, Nelec, lb, Nei, conditions, nperm, 1);

%% Check cluster stats

c = 1; % Cluster to check
P = stat.c.posclusters(c).prob;
clusterlabels = stat.c.posclusterslabelmat;

clust = clusterlabels == c;
elec  = find(sum(clust,2));

D = squeeze(mean(mean(data(:,:,:,1),3),1)); % Data for the topoplot

if strcmp(Measure,'SNR')
    figure; topoplot(D,Chanlocs, 'style', 'map',  'electrodes', 'off','emarker2',{elec,'o','k',8,1},'maplimits',[1 max(D)+.005]);
    MinCmap = (max(D)-1)/10*4+1;
    r = [ones(ceil((MinCmap-1)/((max(D)-(MinCmap))/64)),3);rmap];
    b = [r(:,2:3),r(:,1)];
    colormap(b);
    % caxis([1,max(D)]) % Force colormap limits
    caxis([1,max(D)+.005]) % Force colormap limits with an extra in case
    % tick is rounded above the max of the data
    
    % colorbar with defined number of ticks
    cbh = colorbar;
    set(cbh,'YTick',round(1:(max(D)-1)/4:max(D),2))
    ytickformat('%.2f')
else
    figure; topoplot(D,Chanlocs, 'style', 'map',  'electrodes', 'off','emarker2',{elec,'o','k',8,1});
    colormap(jetw);
    caxis([-(max(abs(D))+.005),max(abs(D))+.005]) % Force colormap limits with an extra in case
    % colorbar with defined number of ticks
    cbh = colorbar;
    set(cbh,'YTick',round(-max(abs(D)):(max(abs(D))*2)/4:max(abs(D)),2))
    ytickformat('%.2f')
end

set(gca,'LineWidth',1.5)% set axis font size
set(gca,'FontSize',16);

%title(['Condition ',Cond(end),' clust ',num2str(c),' ',Measure])
%savefig(fullfile(pwd,Exp,'Figures',[Cond,'_clust',num2str(c),'_',Measure,'_Topo']))

% Output at the command window, formated for LaTeX
% Requires the Measures of Effect Size Toolbox (Hentschke, 2011)
ExtractEffectSize_Freq
