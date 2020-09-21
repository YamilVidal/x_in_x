function [grandavg] = TimelockGrandAverage(cfg, data, time)

% FT_TIMELOCKGRANDAVERAGE computes ERF/ERP average and variance
% over multiple subjects or over blocks within one subject
%
% Use as
%   [grandavg] = ft_timelockgrandaverage(cfg, avg1, avg2, avg3, ...)
%
% where
%   avg1..N are the ERF/ERP averages as obtained from FT_TIMELOCKANALYSIS
%
% and cfg is a configuration structure with
%  cfg.channel        = Nx1 cell-array with selection of channels (default = 'all'),
%                       see FT_CHANNELSELECTION for details
%  cfg.latency        = [begin end] in seconds or 'all' (default = 'all')
%  cfg.keepindividual = 'yes' or 'no' (default = 'no')
%  cfg.normalizevar   = 'N' or 'N-1' (default = 'N-1')
%  cfg.method         = 'across' (default) or 'within', see below.
%  cfg.parameter      = string or cell-array indicating which
%                        parameter to average. default is set to
%                        'avg', if it is present in the data.
%
% If cfg.method = 'across', an plain average is performed, i.e. the
% requested parameter in each input argument is weighted equally in the
% average. This is useful when averaging across subjects. The
% variance-field will contain the variance across the parameter of
% interest, and the dof-field will contain the number of input arguments.
%
% If cfg.method = 'within', a weighted average is performed, i.e. the
% requested parameter in each input argument is weighted according to the
% dof-field. This is useful when averaging across blocks within subjects.
% The variance-field will contain the variance across all input
% observations, and the dof-field will contain the number of observations.
%
% To facilitate data-handling and distributed computing you can use
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure. For this particular function, the input should be
% structured as a cell array.
%
% See also FT_TIMELOCKANALYSIS, FT_TIMELOCKSTATISTICS, FT_TIMELOCKBASELINE

% Copyright (C) 2003-2006, Jens Schwarzbach
% Copyright (C) 2013, Burkhard Maess
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_timelockgrandaverage.m 9292 2014-03-13 09:25:00Z roboos $


Nsubj    = size(data,3);

% set the defaults

cfg.subjects       = [1:Nsubj]; 

% dimord   = varargin{1}.dimord;
% hastime  = ~isempty(strfind(varargin{1}.dimord, 'time'));
% hasrpt   = ~isempty(strfind(varargin{1}.dimord, 'rpt'));
% hasdof   = isfield(varargin{1}, 'dof');


if ischar(cfg.latency) && strcmp(cfg.latency, 'all')
  tbeg = min(time);
  tend = max(time);
else
  tbeg = cfg.latency(1);
  tend = cfg.latency(2);
end

% select the data in all inputs
% determine which channels, and latencies are available for all inputs
cfg.channel = cfg.channel; % channels over which is compute

% pick the selections

timesel = time>=tbeg & time<=tend;
time = time(logical(timesel));

avgmat = data(logical(timesel),cfg.channel,cfg.subjects); 
avgmat = permute(avgmat,[3 2 1]); % Nsubj x Nchan x Nsamples
if strcmp( cfg.keepindividual,'yes')
    grandavg.individual = avgmat;
end

% determine the size of the data to be averaged
dim{1} = size(avgmat);

% give some feedback on the screen

fprintf('computing average');

%avgvar = avgmat .^2;     % preparing the computation of the variance
n = reshape(sum(~isnan(avgmat),1), dim{1}(2:end));
% average across subject dimension
grandavg.avg   = reshape(nanmean(avgmat, 1), dim{1}(2:end));
%ResultVar      = reshape(nansum(avgvar,1), dim{1}(2:end)) - reshape(nansum(avgmat,1), dim{1}(2:end)).^2;

switch cfg.normalizevar
    case 'N-1'
        ResultVar = reshape(nanvar(avgmat,[],1),dim{1}(2:end));
        %ResultVar = ResultVar./(n-1);
    case 'N'
        ResultVar = reshape(nanvar(avgmat,1,1),dim{1}(2:end));
        %ResultVar = ResultVar./n;
end
grandavg.var = ResultVar;



% collect the output data
grandavg.time = time;
grandavg.label = cfg.label;
grandavg.dimord = cfg.dimord;
grandavg.fsample = 1/(time(2)-time(1));
grandavg.cfg.keepindividual = cfg.keepindividual;
grandavg.cfg.channel = cfg.channel;
grandavg.cfg.latency = cfg.latency;
grandavg.cfg.normalizevar = cfg.normalizevar;
