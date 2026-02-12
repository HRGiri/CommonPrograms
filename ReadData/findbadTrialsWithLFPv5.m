% This function integrates some of the features of findBadTrialsWithEEG
% into the findBadTrialsWithLFPv3.

% TRIALWISE CHECKS
% 1. Time thresholding based on (i) mean and std, (ii) max/min, (iii) rms
% 2. Time thresholding based on mean and std trace
% 3. PSD thresholding based on mean and std

% ELECTRODEWISE CHECKS
% 1. Impedance
% 2. Bad trial percentage on that electrode
% 3. Average PSD slope in a certain range 

function [allBadTrials,badTrials] = findbadTrialsWithLFPv5(monkeyName,expDate,protocolName,folderSourceString,gridType,processAllElectrodes,...
    checkTheseElectrodes,highPassCutOff,checkPeriod,timeThreshold,maxLimit,minLimit,rmsThreshold,checkPsdPeriod,psdThreshold,checkPsdSlopePeriod,...
    badTrialPercentageThreshold,showElectrodes,marginalsFlag,saveDataFlag,badTrialName)

% Defining named arguments here so that optional arguments can be provided
% using the name of the argument
arguments
    monkeyName                                  % Required
    expDate                                     % Required
    protocolName                                % Required
    folderSourceString                          % Required
    gridType char = 'Microelectrode';       
    processAllElectrodes logical = 0;
    checkTheseElectrodes double = 49:96;        % V1 for Jojo
    highPassCutOff double = [];                 % No high pass filtering done when empty
    checkPeriod double = [-0.7 -0.1; 0.4 1.2];  % nx2 arrays where n=# check periods
    timeThreshold double = 6;
    maxLimit double = 1000; 
    minLimit double = -1000;
    rmsThreshold double = [1.5 35];             % [lower upper]
    checkPsdPeriod double = [-0.7 -0.2; 0.7 1.2];  % nx2 arrays where n=# check periods
    psdThreshold double = 6;
    checkPsdSlopePeriod double = [-0.7 -0.2];
    badTrialPercentageThreshold = 40;
    showElectrodes double = [];                 % electrodes to plot
    marginalsFlag logical = 0;
    saveDataFlag logical = 0;    
    badTrialName char = '_v5';                  % string to be added to the bad trial file name
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initializations %%%%%%%%%%%%%%%%%%%%%%%%%%%%
impedanceCutOff = 25; % KOhm
% Parameters for PSD slope calculations
tapersPSD = 1; % No. of tapers used for computation of slopes
slopeRange = {[56 86]}; % Hz, slope range used to compute slopes
freqsToAvoid = {[0 0] [8 12] [46 54] [96 104]}; % Hz

end

