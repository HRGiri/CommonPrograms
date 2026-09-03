% This function is used to extract the digital data for ML Protocols.

function [goodStimNums,goodStimTimes] = extractDigitalDataML(folderExtract,MLCodeList)

if ~exist('MLCodeList','var')
    MLCodeList.trialStart = 9;
    MLCodeList.trialEnd = 18;
    MLCodeList.stimStart = 20;
end

stimResults = readDigitalCodes(folderExtract,MLCodeList); % writes stimResults and trialResults
goodStimTimes = stimResults.time;
goodStimNums = 1:length(goodStimTimes); % dummy variable in this case
save(fullfile(folderExtract,'goodStimNums.mat'),'goodStimNums','goodStimTimes');
end

function [stimResults,trialResults,trialEvents] = readDigitalCodes(folderExtract,MLCodeList)

% Get the values of the following trial events for comparison with ML
trialEvents{1} = MLCodeList.trialStart; % Trial start
trialEvents{2} = MLCodeList.trialEnd; % Trial End

x=load(fullfile(folderExtract,'digitalEvents.mat'));
allDigitalCodesInDec = x.digitalEvents;
timeStamps = x.digitalTimeStamps;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find the times and values of the events in trialEvents

for i=1:length(trialEvents)
    pos = find(trialEvents{i}==allDigitalCodesInDec);
    if isempty(pos)
        warning(['Code ' trialEvents{i} ' not found!!']);
    else
        trialResults(i).times = timeStamps(pos); %#ok<*AGROW>
        trialResults(i).value = allDigitalCodesInDec(pos);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get timing from digital codes
trialStartTimes    = trialResults(1).times;
numTrials = length(trialStartTimes);

% Check for contiguous stimOn indices
stimOnIndices = find(allDigitalCodesInDec==MLCodeList.stimStart);
contiguousStimOnIndices = 1 + find(diff(stimOnIndices)==1);
stimOnIndices(contiguousStimOnIndices) = [];
% Find the trial number of each stimulus
stimOnTimes = timeStamps(stimOnIndices);
numStims = length(stimOnTimes);
trialNumOfEachStim = zeros(1,numStims);

for i=1:numStims
    trialNumOfEachStim(i) = find(trialStartTimes<stimOnTimes(i), 1, 'last' );
end

%%%%%%%%%%%%%%%%%%%%% Get Good trials from ML data %%%%%%%%%%%%%%%%%%%%%%%%
x=load(fullfile(folderExtract,'ML.mat'));
data = x.data;

if length(data) ~= numTrials
    error('Number of trials in ML and Digital stream do not match');
end

goodTrials = find([data.TrialError]==0);

conditionNumList = [];
goodStimTimes = [];
stimPosition = [];
for i=1:length(goodTrials)
    trialNum = goodTrials(i);
    if isfield(data(trialNum).UserVars, "Stimuli")
        conditionNumList = cat(2,conditionNumList,data(trialNum).UserVars.Stimuli);
    else
        conditionNumList = cat(2,conditionNumList,data(trialNum).Condition); % Note that this only works when there is a single stimulus per trial
    end
    goodStimTimes = cat(2,goodStimTimes,stimOnTimes(trialNumOfEachStim==trialNum)');
    stimPosition = cat(2, stimPosition, 1:length(stimOnTimes(trialNumOfEachStim==trialNum)'));
end
stimResults.stimPosition = stimPosition;
% Set up dummy variables. Condition number is assigned to orientation
numStimuli = length(conditionNumList);
try
    stimTable = x.TrialRecord.User.StimTable; % MODIFIED    
    disp("Using stimTable to assign parameterCombinations")     
    % Determine the protocol type
    paramNames = {'width1','delay','width','amp','pulses','frequency'};      % Order matters here
    protocolName = 'GRF';   
    for i=1:length(paramNames)
        if ismember(paramNames{i}, stimTable.Properties.VariableNames)
            if length(unique(stimTable.(paramNames{i})(conditionNumList))) > 1
                protocolName = paramNames{i};
                break
            end
        end
    end
    disp(['Identified Protocol: ' protocolName]) 

    % Map to grating parameters
    stimResults.spatialFrequency = stimTable.sf(conditionNumList)';
    stimResults.radius = stimTable.radii(conditionNumList)';
    stimResults.contrast = stimTable.con(conditionNumList)';        
    stimResults.orientation = stimTable.ori(conditionNumList)';
    stimResults.sigma = stimTable.radii(conditionNumList)';
    stimResults.temporalFrequency = zeros(1,numStimuli);

    switch protocolName
        case 'GRF'                
            stimResults.azimuth = stimTable.azi(conditionNumList)';
            stimResults.elevation = stimTable.ele(conditionNumList)';            
        case 'amp'        
            stimResults.azimuth = stimTable.amp(conditionNumList)';
            stimResults.elevation = stimTable.pulses(conditionNumList)';                
            stimResults.temporalFrequency = stimTable.frequency(conditionNumList)';
        case 'pulses'
            stimResults.azimuth = stimTable.amp(conditionNumList)';
            stimResults.elevation = stimTable.pulses(conditionNumList)';                
            stimResults.temporalFrequency = stimTable.frequency(conditionNumList)';
        case 'frequency'
            stimResults.azimuth = stimTable.amp(conditionNumList)';
            stimResults.elevation = stimTable.frequency(conditionNumList)';                
            stimResults.temporalFrequency = stimTable.duration(conditionNumList)';
        case 'width'
            stimResults.azimuth = stimTable.width(conditionNumList)';
            stimResults.elevation = stimTable.amp(conditionNumList)';                
            stimResults.temporalFrequency = stimTable.frequency(conditionNumList)';
        case 'width1'
            stimResults.azimuth = stimTable.width1(conditionNumList)';
            stimResults.elevation = stimTable.width2(conditionNumList)';                
            stimResults.temporalFrequency = stimTable.frequency(conditionNumList)';
        case 'delay'
            stimResults.azimuth = stimTable.amp(conditionNumList)';
            stimResults.elevation = stimTable.pulses(conditionNumList)';                
            stimResults.temporalFrequency = stimTable.frequency(conditionNumList)';
            stimResults.sigma = stimTable.delay(conditionNumList)';
    end

catch
    disp("No stimTable found. All stimuli are mapped to spatialFrequency")
    stimResults.spatialFrequency = conditionNumList;
    stimResults.azimuth = zeros(1,numStimuli);
    stimResults.elevation = zeros(1,numStimuli);
    stimResults.sigma = zeros(1,numStimuli);
    stimResults.radius = zeros(1,numStimuli);
    stimResults.contrast = zeros(1,numStimuli);
    stimResults.temporalFrequency = zeros(1,numStimuli);
    stimResults.orientation = zeros(1,numStimuli);
end

stimResults.time = goodStimTimes;
stimResults.side = 0; % dummy variable in this case

% Save in folderOut
save(fullfile(folderExtract,'stimResults.mat'),'stimResults');
save(fullfile(folderExtract,'trialResults.mat'),'trialEvents','trialResults');

end