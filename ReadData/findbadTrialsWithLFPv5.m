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

function [allBadTrials,badTrials] = findbadTrialsWithLFPv5(monkeyName,expDate,protocolName,folderSourceString, opts)

% Defining named arguments here so that optional arguments can be provided
% using the name of the argument
arguments
    monkeyName                                  % Required
    expDate                                     % Required
    protocolName                                % Required
    folderSourceString                          % Required
    opts.gridType char = 'Microelectrode';       
    opts.processAllElectrodes logical = 0;
    opts.checkTheseElectrodes double = 49:96;        % V1 for Jojo
    opts.highPassCutOff double = [];                 % No high pass filtering done when empty
    opts.checkPeriod double = [-0.7 -0.1; 0.4 1.2];  % nx2 arrays where n=# check periods
    opts.timeThreshold double = 6;
    opts.maxLimit double = 1000; 
    opts.minLimit double = -1000;
    opts.rmsThreshold double = [1.5 35];             % [lower upper]
    opts.checkPsdPeriod double = [-0.7 -0.2; 0.7 1.2];  % nx2 arrays where n=# check periods
    opts.psdThreshold double = 6;
    opts.checkPsdSlopePeriod double = [-0.7 -0.2];
    opts.badTrialPercentageThreshold = 40;
    opts.showElectrodes double = [];                 % electrodes to plot
    opts.marginalsFlag logical = 0;
    opts.saveDataFlag logical = 0;    
    opts.badTrialName char = '_v5';                  % string to be added to the bad trial file name
end

gridType = opts.gridType;
processAllElectrodes = opts.processAllElectrodes;
checkTheseElectrodes = opts.checkTheseElectrodes;
highPassCutOff = opts.highPassCutOff;
checkPeriod = opts.checkPeriod;
timeThreshold = opts.timeThreshold;
maxLimit = opts.maxLimit;
minLimit = opts.minLimit;
rmsThreshold = opts.rmsThreshold;
checkPsdPeriod = opts.checkPsdPeriod;
psdThreshold = opts.psdThreshold;
checkPsdSlopePeriod = opts.checkPsdSlopePeriod;
badTrialPercentageThreshold = opts.badTrialPercentageThreshold;
showElectrodes = opts.showElectrodes;
marginalsFlag = opts.marginalsFlag;
saveDataFlag = opts.saveDataFlag;
badTrialName = opts.badTrialName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initializations %%%%%%%%%%%%%%%%%%%%%%%%%%%%
impedanceCutOff = 25; % KOhm
% Parameters for PSD slope calculations
tapersPSD = 1; % No. of tapers used for computation of slopes
slopeRange = {[56 86]}; % Hz, slope range used to compute slopes
freqsToAvoid = {[0 0] [8 12] [46 54] [96 104]}; % Hz


% % Aniket % %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderName = fullfile(folderSourceString,'data',monkeyName,gridType,expDate,protocolName);
folderSegment = fullfile(folderName,'segmentedData');
lfpInfo = load(fullfile(folderSegment,'LFP','lfpInfo.mat'));

timeVals = lfpInfo.timeVals;

% for EEG, numElectrodes and loading data corr. to all the electrodes would
% be different
if processAllElectrodes % compute bad trials for all the saved electrodes
    numElectrodes = length(lfpInfo.electrodesStored);
else % compute bad trials for only the electrodes mentioned
    numElectrodes = length(checkTheseElectrodes);
end

x = load(fullfile(folderSegment,'LFP',['elec' num2str(lfpInfo.electrodesStored(1)) '.mat'])); 
numTotalTrials = size(x.analogData, 1); numTotalSamples = size(x.analogData, 2); % get size of LFPdata for 1 electrode
lfpData = zeros(numElectrodes, numTotalTrials, numTotalSamples); % initializing array to store LFP data corr. to all the electrodes
nameElec = cell(1,numElectrodes);

hW1 = waitbar(0,'collecting data...');
for i=1:numElectrodes
    if processAllElectrodes
        iElec = lfpInfo.electrodesStored(i);
        waitbar((i-1)/numElectrodes,hW1,['collecting data from electrode: ' num2str(i) ' of ' num2str(numElectrodes)] );
        
        clear x; x = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat'])); % Load LFP Data
        lfpData(i,:,:) = x.analogData; %#ok<AGROW>
        nameElec{i} = ['elec' num2str(iElec)]; 
        % disp(nameElec{i});
    else
        iElec = checkTheseElectrodes(i);
        waitbar((i-1)/numElectrodes,hW1,['collecting data from electrode: ' num2str(i) ' of ' num2str(numElectrodes)]);
        
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

%%%%%%%%%%%%%%%%%%%%% Applying Filter (if instructed) %%%%%%%%%%%%%%%%%%%%%
if ~isempty(highPassCutOff)    % high pass filter    % can do this after the impedance check as well
    for i=1:numElectrodes
        [lfpData(i, :, :), filterStr] = applyFilter(squeeze(lfpData(i, :, :)),2000,'butter','high',4,highPassCutOff);
    end
    fprintf('Applied a 4th order Butterworth High pass filter with cutoff=%d Hz\n', highPassCutOff)
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Bad Trial Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%
originalTrialInds = 1:numTotalTrials;

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

    badTimeTrials = []; badRmsTrials = []; noisyTrials = []; badMinValTrials = []; badMaxValTrials = []; badTrialsTimeThres = [];
    
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
        maxData(badTimeTrials) = meanData(badTimeTrials); % exclude trial indices already in badTrials1
        minData  = min(analogDataSegment,[],2)';
        minData(badTimeTrials) = meanData(badTimeTrials); % exclude trial indices already in badTrials1
   
        clear tmpNoisyTrials tmpBadMinValTrials tmpBadMaxValTrials
        tmpNoisyTrials = unique([find(maxData > meanData + timeThreshold * stdData) find(minData < meanData - timeThreshold * stdData)]);
        tmpBadMinValTrials = unique(find(maxData > maxLimit));
        tmpBadMaxValTrials = unique(find(minData < minLimit));
        

        % consolidate across checkPeriods
        noisyTrials = unique([noisyTrials(:); tmpNoisyTrials(:)]);   % save the consolidated arrays as column vectors
        badMaxValTrials = unique([badMaxValTrials(:); tmpBadMaxValTrials(:)]);
        badMinValTrials = unique([badMinValTrials(:); tmpBadMinValTrials(:)]);

        % 2.1.2 RMS Check
        % calculate RMS Values for each trial
        if ~isempty(analogDataSegment)
            allTrialsRMS = sqrt(mean(analogDataSegment.^2, 2));
            allTrialsRMS(badTimeTrials) = mean(rmsThreshold);        % exclude trial indices already in badTrials
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
        badTimeTrials = unique([noisyTrials(:); badMaxValTrials(:); badMinValTrials(:); badRmsTrials(:)]);  % badTrials1 --> all bad trials that fail Trial Thresholding

        % removing all bad Trials till now
        if ~isempty(analogDataSegment)
            analogDataSegment(badTimeTrials,:) = [];
        end

     % 2.2 Time Thresholding

        numTrials = size(analogDataSegment, 1);                          % excluding badTrials1
        meanTrialData = mean(analogDataSegment,1);                    % mean trial trace
        stdTrialData = std(analogDataSegment,[],1);                   % std across trials
        
        tDplus = (meanTrialData + (timeThreshold)*stdTrialData);    % upper boundary/criterion   
        tDminus = (meanTrialData - (timeThreshold)*stdTrialData);   % lower boundary/criterion
        
        tBoolTrials = sum((analogDataSegment > ones(numTrials,1)*tDplus) | (analogDataSegment < ones(numTrials,1)*tDminus),2);
        % didn't do exclusion of trials which failed timeThresholding check in previous checkPeriods here, hopefully no hit on performance
        
        clear tmpBadTrialsTimeThres
        tmpBadTrialsTimeThres = find(tBoolTrials>0);   
    
        % consolidate across checkPeriods
        badTrialsTimeThres = unique([badTrialsTimeThres(:); tmpBadTrialsTimeThres(:)]);  % badTrialstimeThres --> all bad trials that further fail Time Thresholding
       
    end

    % 2.3 Frequency Thresholding
        %%%%%%%%%%%%%%%%%%%%%%%% Set up MT parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Fs = 1/(timeVals(2) - timeVals(1)); %Hz
        
        params.tapers   = [3 5];
        params.pad      = -1;
        params.Fs       = Fs;
        params.fpass    = [0 200];
        params.trialave = 0;
        
     badTrialsFreqThres = []; 
         numPsdPeriods = size(checkPsdPeriod,1);
    
    for j = 1:numPsdPeriods
        
        % Get indices for PSD period
        psdPeriodIndices = timeVals >= checkPsdPeriod(j,1) & ...
                           timeVals <= checkPsdPeriod(j,2);
                       
        analogDataPsd = analogData(:, psdPeriodIndices);
    
      % Remove bad trials
        analogDataPsd(badTrials1,:) = [];
        analogDataPsd(badTrialsTimeThres,:) = [];
    
        % check PSD
        clear powerVsFreq;
        [powerVsFreq,~] = mtspectrumc(analogDataPsd',params);
        powerVsFreq = powerVsFreq';
        
        numTrialsPsd = size(powerVsFreq, 1);  
        clear meanTrialData stdTrialData tDplus
        meanTrialData = nanmean(powerVsFreq, 1);  % calculate mean for remaining trials
        stdTrialData = nanstd(powerVsFreq, [], 1); % calculate std for remaining trials
        
        tDplus = (meanTrialData + (psdThreshold)*stdTrialData);    % upper boundary/criterion
    
        clear tBoolTrials; tBoolTrials = sum((powerVsFreq > ones(numTrialsPsd,1)*tDplus),2);
        clear tmpBadTrialsFreqThres; tmpBadTrialsFreqThres = find(tBoolTrials>0);
    
        badTrialsFreqThres = unique([badTrialsFreqThres(:); tmpBadTrialsFreqThres(:)]);
    
    end
  
        % consolidate all bad trials
    tmpBadTrialsAll = unique([badTrials1(:); badTrialsTimeThres(:); badTrialsFreqThres(:)]); 
    % Remap bad trial indices to original indices
        allBadTrials{iElec} = originalTrialInds(tmpBadTrialsAll);
        % Calculate number of unique bad trials for each thresholding criterion
        badTrialsUnique.rmsThres{iElec} = originalTrialInds(badTrials1);
        badTrialsUnique.timeThres{iElec} = originalTrialInds(setdiff(badTrialsTimeThres,badTrials1));
        badTrialsUnique.freqThres{iElec} = originalTrialInds(setdiff(badTrialsFreqThres,[badTrialsTimeThres; badTrials1]));

end
close(hW1);

% decide what badTrials does
badTrials = 0;    % placeholder value, might show some error if not declared

% 3. Remove electrodes containing more than x% bad trials
badTrialUL = (badTrialPercentageThreshold/100)*totalTrials;
badTrialLength=cellfun(@length,allBadTrials);
nBadElecs = logical(badTrialLength>badTrialUL)';
allBadTrials(nBadElecs{2}) = {NaN};

% 4. Find common bad trials across all electrodes subject to conditions
commonBadTrialsAllElecs = trimBadTrials(allBadTrials);
badTrialsUnique.commonBadTrialsAllElecs = commonBadTrialsAllElecs;

% 5. PSD Slope calculation across baseline period
checkPeriodIndicesPSD = timeVals>=checkPsdSlopePeriod(1) & timeVals<checkPsdSlopePeriod(2);
params.tapers   = [(tapersPSD+1)/2 tapersPSD];
slopeValsVsFreq = cell(1,numElectrodes);

lfpData = lfpData(:,setdiff(originalTrialInds,tmpBadTrialsAll),checkPeriodIndicesPSD);
for iElec=1:numElectrodes
    if isnan(allBadTrials{1,iElec}); slopeValsVsFreq{iElec} = {NaN,NaN}; goodSlopeFlag(iElec) = false; continue; end %#ok<AGROW>
    
    % Computing slopes
    analogDataPSD = squeeze(lfpData(iElec,:,:));
    % analogDataPSD = analogDataPSD - repmat(mean(analogDataPSD,2),1,size(analogDataPSD,2));
    
    clear powerVsFreq freqVals
    [powerVsFreq,freqVals] = mtspectrumc(analogDataPSD',params);
    slopeValsVsFreq{iElec} = getSlopesPSDBaseline_v2((log10(mean(powerVsFreq,2)))',freqVals,slopeRange,[],freqsToAvoid);
    goodSlopeFlag(iElec) = slopeValsVsFreq{iElec}{2}>0; %#ok<AGROW>
end

nanElecs = find(cell2mat(cellfun(@(x)any(isnan(x)),allBadTrials,'UniformOutput',false)));

badElecs.flatPSDElecs = setdiff(find(~goodSlopeFlag),nanElecs)';
badElecs.declaredBadElectrodes = badElectrodes;


if saveDataFlag
    disp(['Saving ' num2str(length(allBadTrials)) ' bad trials']);
    badTrialsFileName = fullfile(folderSegment,['badTrials' badTrialNameStr '.mat']);
    if exist(badTrialsFileName,'file'); delete(badTrialsFileName); end
    save(badTrialsFileName,'badTrials','allBadTrials','badTrialsUnique','badElecs','totalTrials','slopeValsVsFreq','eegElectrodeLabels','highPriorityElectrodeList');
else
    disp('Bad trials will not be saved..');
end

if displayResultsFlag
    displayBadElectrodes(subjectName,expDate,protocolName,folderSourceString,gridType,capType,badTrialNameStr);
end
end

function [newBadTrials] =  trimBadTrials(allBadTrials)
badElecThreshold = 10; % Percentage

% 6. Removing common bad trials
% 6.1. Taking union across bad electrodes for conditions 1 and 2
newBadTrials=[];
numElectrodes = length(allBadTrials);
for iElec=1:numElectrodes
    if ~isnan(allBadTrials{1,iElec}); newBadTrials=union(newBadTrials,allBadTrials{iElec}); end
end

% 6.2. Co-occurence condition - Counting the trials which occurs in more than x% of the electrodes
badTrialElecs = zeros(1,length(newBadTrials));
for iTrial = 1:length(newBadTrials)
    for iElec = 1:numElectrodes
        if isnan(allBadTrials{1,iElec}); continue; end % Discarding the electrodes where the bad trials are NaN because of this NaN entries in badTrials have zero in 'badTrialElecs'
        if find(newBadTrials(iTrial)==allBadTrials{1,iElec})
            badTrialElecs(iTrial) = badTrialElecs(iTrial)+1;
        end
    end
end
newBadTrials(badTrialElecs<(badElecThreshold/100.*numElectrodes))=[];
end


