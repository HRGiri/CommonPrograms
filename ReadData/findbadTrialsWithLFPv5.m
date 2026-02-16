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

% % Aniket % %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
folderSegment = fullfile(folderName,'segmentedData');
lfpInfo = load(fullfile(folderSegment,'LFP','lfpInfo.mat'));

timeVals = lfpInfo.timeVals;

% for EEG, numElectrodes and loading data corr. to all the electrodes would
% be different
if processAllElectrodes % compute bad trials for all the saved electrodes
    numElectrodes = length(electrodesStored);
else % compute bad trials for only the electrodes mentioned
    numElectrodes = length(checkTheseElectrodes);
end

x = load(fullfile(folderSegment,'LFP',['elec' num2str(electrodesStored(1)) '.mat'])); r = size(x.analogData, 1); c = size(x.analogData, 2); % get size of LFPdata for 1 electrode
lfpData = zeros(numElectrodes, r, c); % initializing array to store LFP data corr. to all the electrodes
nameElec = cell(1,numElectrodes);

hW1 = waitbar(0,'collecting data...');
for i=1:numElectrodes
    if processAllElectrodes
        iElec = electrodesStored(i);
        waitbar((i-1)/numElectrodes,hW1,['collecting data from electrode: ' num2str(iElec) ' of ' num2str(numElectrodes)]);
        
        clear x; x = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat'])); % Load LFP Data
        lfpData(i,:,:) = x.analogData; %#ok<AGROW>
        nameElec{i} = ['elec' num2str(iElec)];
        % disp(nameElec{i});
    else
        iElec = checkTheseElectrodes(i);
        waitbar((i-1)/numElectrodes,hW1,['collecting data from electrode: ' num2str(iElec) ' of ' num2str(numElectrodes)]);
        
        clear x; x = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat'])); % Load LFP Data
        lfpData(i,:,:) = x.analogData; %#ok<AGROW>
        nameElec{i} = ['elec' num2str(iElec)];
        % disp(nameElec{i});
    end
end
close(hW1);

% didn't do 'compare with montages', 'get Impedance data' from findBadTrialsWithEEG.m, 'filtering'

%%%%%%%%%%%%%%%%%%%%%% Compare with Montage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Impedance data %%%%%%%%%%%%%%%%%%%%%%%%

%

%%%%%%%%%%%%%%%%%%%%%%%% Set up MT parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 1/(timeVals(2) - timeVals(1)); %Hz

params.tapers   = [3 5];
params.pad      = -1;
params.Fs       = Fs;
params.fpass    = [0 200];
params.trialave = 0;

%%%%%%%%%%%%%%%%%%%%% Applying Filter (if instructed) %%%%%%%%%%%%%%%%%%%%%
if exist('highPassCutOff','var') || ~isempty(highPassCutOff)    % high pass filter    % can do this after the impedance check as well
    for i=1:numElectrodes
        fprintf('Applying a 4th order Butterworth High pass filter with cutoff=%d Hz', highPassCutOff)
        [lfpData(i, :, :), filterStr] = applyFilter(lfpData(iElec, :, :),2000,'butter','high',4,highPassCutOff);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Bad Trial Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%
totalTrials = size(lfpData,2);
originalTrialInds = 1:totalTrials;

% 1. Get electrode impedances for rejecting noisy electrodes (impedance > ?k)



% 2. Analysis for each trial and each electrode
                                                    % if exist('highPassCutOff','var') || ~isempty(highPassCutOff) % Defining filter
                                                    %     d1 = designfilt('highpassiir','FilterOrder',8, ...
   % findBadTrialsWithEEG.m designs own filter-->   %         'PassbandFrequency',highPassCutOff,'PassbandRipple',0.2, ...
                                                    %         'SampleRate',Fs);
                                                    % end

allBadTrials = cell(1,numElectrodes);
hW1 = waitbar(0,'Processing electrodes...');

for iElec=1:numElectrodes
    waitbar((iElec-1)/numElectrodes,hW1,['Processing electrode: ' num2str(iElec) ' of ' num2str(numElectrodes)]);
    % if ~GoodElec_Z(iElec); allBadTrials{iElec} = NaN; continue; end % Analyzing only those electrodes with impedance < 25k
    clear analogData; analogData = squeeze(lfpData(iElec,:,:));

    % subtract dc
    % analogData = analogData - repmat(mean(analogData,2),1,size(analogData,2));

    badTrials1 = []; badRmsTrials = []; noisyTrials = []; badMinValTrials = []; badMaxValTrials = []; badTrialsTimeThres = [];
    
    numCheckPeriods = size(checkPeriod, 1);    
    for j=1:numCheckPeriods
    % determine indices corresponding to the check period
        checkPeriodIndices = timeVals>=checkPeriod(j,1) & timeVals<=checkPeriod(j,2);
        analogDataSegment = analogData(:, checkPeriodIndices);
        
     % 2.1 Trial Thresholding

        % 2.1.1 check variation within a trial, check Max value, check Min value
        meanData = mean(analogDataSegment,2)';
        stdData  = std(analogDataSegment,[],2)';
        maxData  = max(analogDataSegment,[],2)'; 
        maxData(badTrials1) = meanData(badTrials1); % exclude trial indices already in badTrials1
        minData  = min(analogDataSegment,[],2)';
        minData(badTrials1) = meanData(badTrials1); % exclude trial indices already in badTrials1

        clear tmpNoisyTrials tmpBadMinValTrials tmpBadMaxValTrials
        tmpNoisyTrials = unique([find(maxData > meanData + timeThreshold * stdData) find(minData < meanData - timeThreshold * stdData)]);
        tmpBadMinValTrials = unique(find(maxData > maxLimit));
        tmpBadMaxValTrials = unique(find(minData < minLimit));

        % consolidate across checkPeriods
        noisyTrials = unique([noisyTrials tmpNoisyTrials]);
        badMaxValTrials = unique([badMaxValTrials, tmpBadMaxValTrials]);
        badMinValTrials = unique([badMinValTrials tmpBadMinValTrials]);


        % 2.1.2 RMS Check
        % calculate RMS Values for each trial
        if ~isempty(analogDataSegment)
            allTrialsRMS = rms(analogDataSegment, 2);
            allTrialsRMS(badTrials1) = mean(rmsThreshold);        % exclude trial indices already in badTrials
        else
            allTrialsRMS=[];
        end

        % finding indices which have threshold values higher or lower than this
        clear tmpBadRmsTrials
        tmpBadRmsTrials = find(allTrialsRMS>rmsThreshold(2) | allTrialsRMS<rmsThreshold(1));
        if ~exist('tmpBadRmsTrials','var')
            tmpBadRmsTrials = [];
        end 

        % add list of bad RMS trials in this checkPeriod to list containing all bad RMS trials for all the checkPeriods
        badRmsTrials = unique([badRmsTrials tmpBadRmsTrials]);

        % consolidate all bad trials till now (noisy, badMinVal, badMaxVal, badRms) 
        badTrials1 = unique([noisyTrials badMaxValTrials badMinValTrials badRmsTrials]);  % badTrials1 --> all bad trials that fail Trial Thresholding

        % removing all bad Trials till now
        if ~isempty(analogDataSegment)
            analogDataSegment(badTrials1,:) = [];
        end

     % 2.2 Time Thresholding

        numTrials = size(analogDataSegment, 1);                          % excluding badTrials1
        meanTrialData = nanmean(analogDataSegment,1);                    % mean trial trace
        stdTrialData = nanstd(analogDataSegment,[],1);                   % std across trials
        
        tDplus = (meanTrialData + (timeThreshold)*stdTrialData);    % upper boundary/criterion   
        tDminus = (meanTrialData - (timeThreshold)*stdTrialData);   % lower boundary/criterion
        
        tBoolTrials = sum((analogDataSegment > ones(numTrials,1)*tDplus) | (analogDataSegment < ones(numTrials,1)*tDminus),2);
        % didn't do exclusion of trials which failed timeThresholding check in previous checkPeriods here, hopefully no hit on performance
        
        clear badTrialsTimeThres
        tmpBadTrialsTimeThres = find(tBoolTrials>0);   

        % consolidate across checkPeriods
        badTrialsTimeThres = unique([badTrialsTimeThres tmpBadTrialsTimeThres]);  % badTrialstimeThres --> all bad trials that further fail Time Thresholding

     % 2.3 Frequency Thresholding


    end
end