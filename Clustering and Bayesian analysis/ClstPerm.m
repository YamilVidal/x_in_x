function stat = ClstPerm(data, Nelec, lb, Nei, conditions, nperm, isDep, varargin)


%% ========================================================================
%% Default parameters

if isDep
    design = 'within';      % design type within or between
else
    design = 'between';      % design type within or between
end

%% ========================================================================
%% Read the optional parameters
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        if ~ischar (varargin{i})
            error (['Unknown type of optional parameter name (parameter' ...
                ' names must be strings).']);
        end
        % change the value of parameter
        switch lower (varargin{i})
            case 'fs'
                fs = varargin{i+1};
            case 'design'
                design = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized parameter: ''' varargin{i} '''']);
        end
    end
end

%% ========================================================================
%% Other parameters

% General
cfg.keepindividual = 'yes';
cfg.latency        = [0 2];           % time where the cluster permutation is run: interval or 'all'
cfg.channel        = 1:size(data, 2);
cfg.subjects       = 'all';
cfg.normalizevar   = 'N-1';

cfg.label  = lb;
cfg.dimord = 'chan_time';

% Permutation
%cfg.parameter = 'individual';
cfg.method    = 'montecarlo';       % use the Monte Carlo Method to calculate the significance probability

if strcmp(design,'between')
    cfg.statistic = 'indepsamplesT'; % use the independent samples T-statistic as a measure to evaluate the effect at the sample level
elseif strcmp(design,'within')
    cfg.statistic = 'depsamplesT';
end

cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;         % alpha level of the sample-specific test statistic that will be used for thresholding
cfg.alpha            = 0.005;        % alpha level of the permutation test

cfg.clusterstatistic = 'maxsum';     % test statistic that will be evaluated under the permutation distribution.

if size(data,2)>1
    cfg.minnbchan = Nelec;               % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0).
else
    cfg.minnbchan = 0;
end

cfg.tail             = 0;            % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail      = cfg.tail;

cfg.numrandomization = nperm;     % number of draws from the permutation distribution

% Neightbours
cfg.neighbours = Nei;

%% ========================================================================
%% Time Lock

n_cnd = size(data,4);
GrandAvg = [];

for cnd = 1:n_cnd
    datai = data(:,:,:,cnd);
    [GrandAvg.(conditions{cnd})] = TimelockGrandAverage(cfg, datai, 1:2);
end

%% ========================================================================
%% Permutation

design1 = [ones(1,size(GrandAvg.(conditions{1}).individual,1))...
    2*ones(1,size(GrandAvg.(conditions{2}).individual,1))];

if strcmp(design,'within')
    design2 = [1:size(GrandAvg.(conditions{1}).individual,1)...
        1:size(GrandAvg.(conditions{2}).individual,1)];
    
    design_ = [design1; design2];
    
    cfg.ivar = 1;
    cfg.uvar = 2;
else
    design_ = design1;
end

cfg.design = design_;             % design matrix

data1 = GrandAvg.(conditions{1});
data2 = GrandAvg.(conditions{2});
stat.conditions = conditions;
stat.d1 = data1;
stat.d2 = data2;
[stat.c] = ft_timelockstatistics(cfg, data1, data2); % And this is the function that actually does the job...

