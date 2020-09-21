%% EEG PreProcessing pipeline and frequency analysis for the paper
% "Implicit Statistical Learning of Transient Categories in Fast Periodic
% Visual Stimulation"

% https://doi.org/xxxxxxxxxxxx

% As some steps need to be done manually, code is divided in blocks.
% Each block uses one folder as input and another as output.
% To use it, download the data from one of the experiments and place the
% files into:

% ...\Data\0 - Raw\

% Feel free to adapt this code for your own experiments
% Yamil Vidal
% hvidaldossantos@gmail.com

%% First block of code
% Imports to EEGLAB and filters data

% IN  Path = '0 - Raw'
% OUT Path = '1 - Set filtered'

Block1

%% Visually inspect continuous data and spectra of each dataset to perform manual channel rejection

% Spectra can be plotted with this line of code
figure; SPEC = pop_spectopo(EEG, 1, [], 'EEG' , 'percent', 100, 'freqrange',[1 70],'electrodes','off');

% Continuous data can be plotted with:
% eegplot(EEG.data,'spacing',100,'winlength',60);

%% Run Independent Component Analysis (ICA)
% ICA is a computationally intensive process. To speed up things, a parfor
% is used.

Block2

%% Remove ICA components manually
% Save in a different directory (4 - Clean ICA) to keep a copy of the datasets with all the
% components, just in case a mistake is made.

% First 24 component maps can be plotted with:
pop_selectcomps(EEG, 1:24);

%% Third block of code
% ReRef to Average Reference. Segment and divide in conditions

% IN  Path = '4 - Clean ICA'
% OUT Path = '5 - Clean Conditions'

Block3

%% Fourth block of code
% Frequency analysis

% IN  Path = '4 - Clean Conditions'
% OUT Path = '5 - Freqs'

Block4
