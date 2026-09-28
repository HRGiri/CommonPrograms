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

function [allBadTrials,badTrials, badTrialsUnique, badElecs, allBadElecs] = findbadTrialsWithLFPv5(monkeyName,expDate,protocolName,folderSourceString, opts)

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
    opts.checkPeriod double = [-0.7 -0.2; 0.5 1.2];  % nx2 arrays where n=# check periods
    opts.timeThreshold double = 6;
    opts.maxLimit double = 350;
    opts.minLimit double = -350;
    opts.rmsThreshold double = [1.5 100];             % [lower upper]
    opts.checkPsdPeriod double = [-0.7 -0.2; 0.7 1.2];  % nx2 arrays where n=# check periods
    opts.psdThreshold double = 6;
    opts.checkPsdSlopePeriod double = [-0.7 -0.2];
    opts.badTrialPercentageThreshold = 40;
    opts.showElectrodes double = [];                 % electrodes to plot
    opts.marginalsFlag logical = 0;
    opts.saveDataFlag logical = 0;
    opts.badTrialNameStr char = '_v5';                  % string to be added to the bad trial file name
    opts.showPlot logical = 0;
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
badTrialNameStr = opts.badTrialNameStr;
showPlot = opts.showPlot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initializations %%%%%%%%%%%%%%%%%%%%%%%%%%%%
impedanceCutOff = 3000; % KOhm
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
    checkTheseElectrodes = lfpInfo.electrodesStored;    
end
numElectrodes = length(checkTheseElectrodes);

x = load(fullfile(folderSegment,'LFP',['elec' num2str(lfpInfo.electrodesStored(1)) '.mat']));
numTotalTrials = size(x.analogData, 1); numTotalSamples = size(x.analogData, 2); % get size of LFPdata for 1 electrode
lfpData = zeros(numElectrodes, numTotalTrials, numTotalSamples); % initializing array to store LFP data corr. to all the electrodes
nameElec = cell(1,numElectrodes);

hW1 = waitbar(0,'collecting data...');
for i=1:numElectrodes
    iElec = checkTheseElectrodes(i);
    
    waitbar((i-1)/numElectrodes,hW1,['collecting data from electrode: ' num2str(i) ' of ' num2str(numElectrodes)] );

    clear x; x = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat'])); % Load LFP Data
    lfpData(i,:,:) = x.analogData;
    nameElec{i} = ['elec' num2str(iElec)];    
end
close(hW1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Impedance data %%%%%%%%%%%%%%%%%%%%%%%%

%

%%%%%%%%%%%%%%%%%%%%%%%%%% Bad Trial Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%
originalTrialInds = 1:numTotalTrials;

% 1. Get electrode impedances for rejecting noisy electrodes (impedance > 3000k)



allBadTrials = cell(1,numElectrodes);
hW1 = waitbar(0,'Processing electrodes...');

for iElec=1:numElectrodes

    waitbar((iElec-1)/numElectrodes,hW1,['Processing electrode: ' num2str(iElec) ' of ' num2str(numElectrodes)]);
    % if ~GoodElec_Z(iElec); allBadTrials{iElec} = NaN; continue; end % Analyzing only those electrodes with impedance < 25k
    clear analogData; analogData = squeeze(lfpData(iElec,:,:));

    %%%%%%%%%%%%%%%%%%%%% Applying Filter (if instructed) %%%%%%%%%%%%%%%%%%%%%
    if ~isempty(highPassCutOff)    % high pass filter    % can do this after the impedance check as well
        [analogData, filterStr] = applyFilter(analogData,2000,'butter','high',4,highPassCutOff);
        % fprintf('Applied a 4th order Butterworth High pass filter with cutoff=%d Hz\n', highPassCutOff)
    end
    % subtract dc
    % analogData = analogData - repmat(mean(analogData,2),1,size(analogData,2));

    badTimeTrials = []; badRmsTrials = []; noisyTrials = []; badMinValTrials = []; badMaxValTrials = []; badTimeTraceTrials = [];

    numCheckPeriods = size(checkPeriod, 1);
    for j=1:numCheckPeriods
        % determine indices corresponding to the check period

        checkPeriodIndices = timeVals>=checkPeriod(j,1) & timeVals<=checkPeriod(j,2);
        analogDataSegment = analogData(:, checkPeriodIndices);

        % 2.1 Time Thresholding based on stats (across time points)

        % 2.1.1 check variation within a trial, check Max value, check Min value
        meanData = mean(analogDataSegment,2)';
        stdData  = std(analogDataSegment,[],2)';
        maxData  = max(analogDataSegment,[],2)';
        % maxData(badTimeTrials) = meanData(badTimeTrials); % exclude trial indices already in badTrials1
        minData  = min(analogDataSegment,[],2)';
        % minData(badTimeTrials) = meanData(badTimeTrials); % exclude trial indices already in badTrials1

        clear tmpNoisyTrials tmpBadMinValTrials tmpBadMaxValTrials
        tmpNoisyTrials = unique([find(maxData > meanData + timeThreshold * stdData) find(minData < meanData - timeThreshold * stdData)]);
        tmpBadMaxValTrials = unique(find(maxData > maxLimit));
        tmpBadMinValTrials = unique(find(minData < minLimit));


        % consolidate across checkPeriods
        noisyTrials = unique([noisyTrials(:); tmpNoisyTrials(:)]);   % save the consolidated arrays as column vectors
        badMaxValTrials = unique([badMaxValTrials(:); tmpBadMaxValTrials(:)]);
        badMinValTrials = unique([badMinValTrials(:); tmpBadMinValTrials(:)]);

        % 2.1.2 RMS Check
        % calculate RMS Values for each trial
        if ~isempty(analogDataSegment)
            allTrialsRMS = sqrt(mean(analogDataSegment.^2, 2));
            % allTrialsRMS(badTimeTrials) = mean(rmsThreshold);        % exclude trial indices already in badTrials
        else
            allTrialsRMS=[];
        end

        % finding indices which have threshold values higher or lower than this
        clear tmpBadRmsTrials
        tmpBadRmsTrials = find(allTrialsRMS>rmsThreshold(2) | allTrialsRMS<rmsThreshold(1));        

        % add list of bad RMS trials in this checkPeriod to list containing all bad RMS trials for all the checkPeriods
        badRmsTrials = unique([badRmsTrials(:); tmpBadRmsTrials(:)]);

        % consolidate all bad trials till now (noisy, badMinVal, badMaxVal, badRms)
        badTimeTrials = unique([badTimeTrials(:); noisyTrials(:); badMaxValTrials(:); badMinValTrials(:); badRmsTrials(:)]);  % badTimeTrials --> all bad trials that fail Trial Thresholding

        % removing all bad Trials till now
        % if ~isempty(analogDataSegment)
        %     analogDataSegment(badTimeTrials,:) = [];
        % end

        % 2.2 Time Thresholding based on mean trace (across trials)

        numTrials = size(analogDataSegment, 1);                          % excluding badTimeTrials
        remainingGoodTrials = setdiff(originalTrialInds, badTimeTrials);                    % excluding previous bad trials for mean trace calculations
        meanTrialData = mean(analogDataSegment(remainingGoodTrials,:),1);                    % mean trial trace
        stdTrialData = std(analogDataSegment(remainingGoodTrials,:),[],1);                   % std across trials

        tDplus = (meanTrialData + (timeThreshold)*stdTrialData);    % upper boundary/criterion
        tDminus = (meanTrialData - (timeThreshold)*stdTrialData);   % lower boundary/criterion

        tBoolTrials = sum((analogDataSegment > ones(numTrials,1)*tDplus) | (analogDataSegment < ones(numTrials,1)*tDminus),2);
        % didn't do exclusion of trials which failed timeThresholding check in previous checkPeriods here, hopefully no hit on performance

        clear tmpBadTimeTraceTrials
        tmpBadTimeTraceTrials = find(tBoolTrials>0);

        % consolidate across checkPeriods
        badTimeTraceTrials = unique([badTimeTraceTrials(:); tmpBadTimeTraceTrials(:)]);  % badTrialstimeThres --> all bad trials that further fail Time Thresholding

        % consolidate all bad trials till now
        badTimeTrials = unique([badTimeTrials(:); badTimeTraceTrials(:)]);

    end

    % 2.3 Frequency Thresholding
    %%%%%%%%%%%%%%%%%%%%%%%% Set up MT parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Fs = 1/(timeVals(2) - timeVals(1)); %Hz

    params.tapers   = [3 5];
    params.pad      = -1;
    params.Fs       = Fs;
    params.fpass    = [0 200];
    params.trialave = 0;

    badFreqTrials = [];
    numPsdPeriods = size(checkPsdPeriod,1);

    for j = 1:numPsdPeriods

        % Get indices for PSD period
        psdPeriodIndices = timeVals >= checkPsdPeriod(j,1) & ...
            timeVals <= checkPsdPeriod(j,2);

        analogDataPsd = squeeze(lfpData(iElec,:, psdPeriodIndices));        

        % Remove bad trials
        % analogDataPsd(badTimeTrials,:) = [];
        % analogDataPsd(badTimeTraceTrials,:) = [];

        % check PSD
        clear powerVsFreq;
        [powerVsFreq,~] = mtspectrumc(analogDataPsd',params);
        powerVsFreq = powerVsFreq';

        numTrialsPsd = size(powerVsFreq, 1);
        remainingGoodTrials = setdiff(originalTrialInds, badTimeTrials);    % excluding previous bad trials for mean PSD trace calculations
        clear meanTrialData stdTrialData tDplus
        meanTrialData = mean(powerVsFreq(remainingGoodTrials,:), 1);  % calculate mean for remaining trials
        stdTrialData = std(powerVsFreq(remainingGoodTrials,:), [], 1); % calculate std for remaining trials

        tDplus = (meanTrialData + (psdThreshold)*stdTrialData);    % upper boundary/criterion

        clear tBoolTrials; tBoolTrials = sum((powerVsFreq > ones(numTrialsPsd,1)*tDplus),2);
        clear tmpBadFreqTrials; tmpBadFreqTrials = find(tBoolTrials>0);

        badFreqTrials = unique([badFreqTrials(:); tmpBadFreqTrials(:)]);

    end
    
    % All bad trials for each electrode
    allBadTrials{iElec} = unique([badTimeTrials(:); badFreqTrials(:)]);
    % Save bad trials for each thresholding criterion
    badTrialsUnique.noisyTrials{iElec} = noisyTrials;
    badTrialsUnique.maxThresh{iElec} = badMaxValTrials;
    badTrialsUnique.minThresh{iElec} = badMinValTrials;
    badTrialsUnique.rmsThres{iElec} = badRmsTrials;
    badTrialsUnique.timeThres{iElec} = badTimeTraceTrials;
    badTrialsUnique.freqThres{iElec} = badFreqTrials;

end
close(hW1);

% Bad Trials Matrix for plotting
allBadTrialsMatrix = zeros(length(allBadTrials),numTrials);
for i=1:length(allBadTrials)
    allBadTrialsMatrix(i,allBadTrials{i}) = 1;    
end

% 3. Remove electrodes containing more than x% bad trials
badTrialUL = (badTrialPercentageThreshold/100)*numTotalTrials;
badTrialLength=cellfun(@length,allBadTrials);
noisyElecs = logical(badTrialLength>badTrialUL)';
allBadTrials(noisyElecs) = {NaN};

% 4. Find common bad trials across all electrodes subject to conditions
commonBadTrialsAllElecs = trimBadTrials(allBadTrials);
badTrialsUnique.commonBadTrialsAllElecs = commonBadTrialsAllElecs;
badTrials = commonBadTrialsAllElecs;

% 5. PSD Slope calculation across baseline period
checkPeriodIndicesPSD = timeVals>=checkPsdSlopePeriod(1) & timeVals<checkPsdSlopePeriod(2);
params.tapers   = [(tapersPSD+1)/2 tapersPSD];
slopeValsVsFreq = cell(1,numElectrodes);

lfpData = lfpData(:,setdiff(originalTrialInds,badTrials),checkPeriodIndicesPSD);
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

allBadElecs.noisyElecs = checkTheseElectrodes(noisyElecs);
allBadElecs.flatPSDElecs = setdiff(find(~goodSlopeFlag),nanElecs)';

badElecs = union(allBadElecs.noisyElecs, allBadElecs.flatPSDElecs);

if saveDataFlag
    disp(['Saving ' num2str(length(badTrials)) ' bad trials']);
    badTrialsFileName = fullfile(folderSegment,['badTrials' badTrialNameStr '.mat']);
    if exist(badTrialsFileName,'file'); delete(badTrialsFileName); end
    badTrialParameters.checkTheseElectrodes = checkTheseElectrodes;
    badTrialParameters.highPassCutOff = highPassCutOff;
    badTrialParameters.filterStr = filterStr;
    badTrialParameters.checkPeriod = checkPeriod;
    badTrialParameters.timeThreshold = timeThreshold;
    badTrialParameters.maxLimit = maxLimit;
    badTrialParameters.minLimit = minLimit;
    badTrialParameters.rmsThreshold = rmsThreshold;
    badTrialParameters.checkPsdPeriod = checkPsdPeriod;
    badTrialParameters.psdThreshold = psdThreshold;
    badTrialParameters.checkPsdSlopePeriod = checkPsdSlopePeriod;
    badTrialParameters.badTrialPercentageThreshold = badTrialPercentageThreshold;    

    save(badTrialsFileName,'badTrials','allBadTrials','badTrialsUnique',...
        'badElecs','allBadElecs','numTotalTrials','slopeValsVsFreq','nameElec','badTrialParameters');
else
    disp('Bad trials will not be saved..');
end


%**************************************************************************
% summary plot
%--------------------------------------------------------------------------
lengthShowElectrodes = length(showElectrodes);
if ~isempty(showElectrodes)
    for i=1:lengthShowElectrodes
        figure;
        subplot(2,1,1);
        channelNum = showElectrodes(i);

        clear signal analogData analogDataSegment
        analogData = load(fullfile(folderSegment,'LFP',['elec' num2str(channelNum) '.mat'])).analogData;
        analogDataSegment = analogData;
        if numTrials<4000
            plot(timeVals,analogDataSegment(setdiff(1:numTrials,badTrials),:),'color','k');
            hold on;
        else
            disp('More than 4000 trials...');
        end
        if ~isempty(badTrials)
            plot(timeVals,analogDataSegment(badTrials,:),'color','g');
        end
        title(['electrode ' num2str(channelNum)]);
        axis tight;

        subplot(2,1,2);
        plot(timeVals,analogDataSegment(setdiff(1:numTrials,badTrials),:),'color','k');
        hold on;
        j = find(checkTheseElectrodes == channelNum);
        if ~isempty(allBadTrials{j})
            plot(timeVals,analogDataSegment(allBadTrials{j},:),'color','r');
        end
        axis tight;
    end
end

if showPlot
    summaryFig = figure('name',[monkeyName expDate protocolName],'numbertitle','off');
    h0 = subplot('position',[0.8 0.8 0.18 0.18]); set(h0,'visible','off');
    text(0.05, 0.7, ['thresholds (uV): [' num2str(minLimit) ' ' num2str(maxLimit) ']'],'fontsize',12,'unit','normalized','parent',h0);
    checkPeriodString = '';
    for i=1:numCheckPeriods
        checkPeriodString = [checkPeriodString ' [' num2str(checkPeriod(i,1)) ' ' num2str(checkPeriod(i,2)) ']']; %#ok<AGROW>
    end
    text(0.05, 0.4, ['checkPeriod (s): ' checkPeriodString],'fontsize',12,'unit','normalized','parent',h0);
    % text(0.05, 0.1, ['rejectTolerance : ' num2str(rejectTolerance)],'fontsize',12,'unit','normalized','parent',h0);
    
    h1 = getPlotHandles(1,1,[0.07 0.07 0.7 0.7]);
    subplot(h1);
    imagesc(1:numTrials,flip(checkTheseElectrodes),flipud(allBadTrialsMatrix),'parent',h1);
    set(gca,'YDir','normal','ylim',[checkTheseElectrodes(1) checkTheseElectrodes(end)]); colormap(gray);
    xlabel('# trial num','fontsize',15,'fontweight','bold');
    ylabel('# electrode num','fontsize',15,'fontweight','bold');
    
    h2 = getPlotHandles(1,1,[0.07 0.8 0.7 0.17]);
    h3 = getPlotHandles(1,1,[0.8 0.07 0.18 0.7]);
    subplot(h2); cla; set(h2,'nextplot','add');
    stem(h2,1:numTrials,sum(allBadTrialsMatrix,1)); axis('tight');
    ylabel('#count');
    if ~isempty(badTrials)
        stem(h2,badTrials,sum(allBadTrialsMatrix(:,badTrials),1),'color','r');
    end
    subplot(h3); cla; set(h3,'nextplot','add');
    stem(h3,checkTheseElectrodes,sum(allBadTrialsMatrix,2)); axis('tight'); ylabel('#count');
    if ~isempty(badElecs)
        stem(h3,badElecs,sum(allBadTrialsMatrix(checkTheseElectrodes == badElecs,:),2),'color','r');
    end
    xlim(h3,[checkTheseElectrodes(1) checkTheseElectrodes(end)]);
    view([90 -90]);
    
    saveas(summaryFig,fullfile(folderSegment,[monkeyName expDate protocolName 'summmaryBadTrials' badTrialNameStr '.fig']),'fig');
end

end

function [newBadTrials] =  trimBadTrials(allBadTrials)
badElecThreshold = 30; % Percentage

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


