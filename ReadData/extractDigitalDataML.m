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

% Find the trial number of each stimulus
stimOnTimes = timeStamps(allDigitalCodesInDec==MLCodeList.stimStart);
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
for i=1:length(goodTrials)
    trialNum = goodTrials(i);
    if isfield(data(trialNum).UserVars, "Stimuli")
        conditionNumList = cat(2,conditionNumList,data(trialNum).UserVars.Stimuli);
    else
        conditionNumList = cat(2,conditionNumList,data(trialNum).Condition); % Note that this only works when there is a single stimulus per trial
    end
    goodStimTimes = cat(2,goodStimTimes,stimOnTimes(trialNumOfEachStim==trialNum)');
end

% Set up dummy variables. Condition number is assigned to orientation
numStimuli = length(conditionNumList);
try
    stimTable = x.TrialRecord.User.StimTable; % MODIFIED
    disp("Using stimTable to assign parameterCombinations")     
    isMicrostim = ismember('microstim', stimTable.Properties.VariableNames) || ismember('amp', stimTable.Properties.VariableNames);        

    if ~isMicrostim
        stimResults.spatialFrequency = stimTable.sf(conditionNumList)';
        stimResults.azimuth = stimTable.azi(conditionNumList)';
        stimResults.elevation = stimTable.ele(conditionNumList)';
        stimResults.sigma = stimTable.radii(conditionNumList)';
        stimResults.radius = stimTable.radii(conditionNumList)';
        stimResults.contrast = stimTable.con(conditionNumList)';
        stimResults.temporalFrequency = zeros(1,numStimuli);
        stimResults.orientation = stimTable.ori(conditionNumList)';
    else
        % Assiigning parameter combinations for microstimulation protocol
        stimResults.spatialFrequency = stimTable.sf(conditionNumList)';
        stimResults.sigma = stimTable.radii(conditionNumList)';
        stimResults.radius = stimTable.radii(conditionNumList)';
        stimResults.contrast = stimTable.con(conditionNumList)';        
        stimResults.orientation = stimTable.ori(conditionNumList)';
        stimResults.azimuth = stimTable.amp(conditionNumList)';
        if ismember('duration', stimTable.Properties.VariableNames)
            if stimTable.duration(1) ~= 0
                stimResults.elevation = stimTable.frequency(conditionNumList)';
                stimResults.temporalFrequency = stimTable.duration(conditionNumList)';
            else
                stimResults.elevation = stimTable.pulses(conditionNumList)';
                stimResults.temporalFrequency = stimTable.frequency(conditionNumList)';
            end
        else
            stimResults.elevation = stimTable.pulses(conditionNumList)';
            stimResults.temporalFrequency = stimTable.frequency(conditionNumList)';
        end
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