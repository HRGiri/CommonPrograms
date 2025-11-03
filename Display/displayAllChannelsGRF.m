% Display All Channels
function displayAllChannelsGRF(subjectName,expDate,protocolName,folderSourceString,gridType,gridLayout,badTrialNameStr,useCommonBadTrialsFlag)

if ~exist('folderSourceString','var');   folderSourceString='E:';       end
if ~exist('gridType','var');             gridType='EEG';                end
if ~exist('gridLayout','var');          gridLayout=0;                   end
if ~exist('badTrialNameStr','var');     badTrialNameStr = '_v5';        end
if ~exist('useCommonBadTrialsFlag','var'); useCommonBadTrialsFlag = 1;  end

folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);

% Get folders
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
folderSpikes = fullfile(folderSegment,'Spikes');

% load LFP Information
[analogChannelsStored,~,timeVals,analogInputNums] = loadlfpInfo(folderLFP);
[neuralChannelsStored,SourceUnitID] = loadspikeInfo(folderSpikes);

% Get Combinations
[parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
    fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract);

% Get properties of the Stimulus
%stimResults = loadStimResults(folderExtract);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
panelHeight = 0.25; panelStartHeight = 0.7;
staticPanelWidth = 0.2; staticStartPos = 0.1;
dynamicPanelWidth = 0.2; dynamicStartPos = 0.3;
timingPanelWidth = 0.2; timingStartPos = 0.5;
plotOptionsPanelWidth = 0.2; plotOptionsStartPos = 0.7;
backgroundColor = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Static Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%staticTitle = [subjectName '_' expDate '_' protocolName];
% if 0 % don't plot the static panel
% hStaticPanel = uipanel('Title','Information','fontSize', fontSizeLarge, ...
%     'Unit','Normalized','Position',[staticStartPos panelStartHeight staticPanelWidth panelHeight]);
%
% staticText = [{ '   '};
%     {['Monkey Name: ' subjectName]}; ...
%     {['Date: ' expDate]}; ...
%     {['Protocol Name: ' protocolName]}; ...
%     {'   '}
%     {['Orientation  (Deg): ' num2str(stimResults.orientation)]}; ...
%     {['Spatial Freq (CPD): ' num2str(stimResults.spatialFrequency)]}; ...
%     {['Eccentricity (Deg): ' num2str(stimResults.eccentricity)]}; ...
%     {['Polar angle  (Deg): ' num2str(stimResults.polarAngle)]}; ...
%     {['Sigma        (Deg): ' num2str(stimResults.sigma)]}; ...
%     {['Radius       (Deg): ' num2str(stimResults.radius)]}; ...
%     ];
%
% tStaticText = uicontrol('Parent',hStaticPanel,'Unit','Normalized', ...
%     'Position',[0 0 1 1], 'Style','text','String',staticText,'FontSize',fontSizeSmall);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dynamic panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dynamicHeight = 0.085; dynamicGap=0.02; dynamicTextWidth = 0.6;
hDynamicPanel = uipanel('Title','Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[dynamicStartPos panelStartHeight dynamicPanelWidth panelHeight]);

% Azimuth
azimuthString = getStringFromValues(aValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
    'Style','text','String','Azimuth (Deg)','FontSize',fontSizeSmall);
hAzimuth = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',azimuthString,'FontSize',fontSizeSmall);

% Elevation
elevationString = getStringFromValues(eValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Elevation (Deg)','FontSize',fontSizeSmall);
hElevation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',elevationString,'FontSize',fontSizeSmall);

% Sigma
sigmaString = getStringFromValues(sValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Sigma (Deg)','FontSize',fontSizeSmall);
hSigma = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',sigmaString,'FontSize',fontSizeSmall);

% Spatial Frequency
spatialFreqString = getStringFromValues(fValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-4*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Spatial Freq (CPD)','FontSize',fontSizeSmall);
hSpatialFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-4*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',spatialFreqString,'FontSize',fontSizeSmall);

% Orientation
orientationString = getStringFromValues(oValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Orientation (Deg)','FontSize',fontSizeSmall);
hOrientation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',orientationString,'FontSize',fontSizeSmall);

% Contrast
if ~isempty(cValsUnique)
    contrastString = getStringFromValues(cValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-6*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Contrast (%)','FontSize',fontSizeSmall);
    hContrast = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-6*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',contrastString,'FontSize',fontSizeSmall);
end

% Temporal Freq
if ~isempty(tValsUnique)
    temporalFreqString = getStringFromValues(tValsUnique,1);
    uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-7*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
        'Style','text','String','Temporal Freq (Hz)','FontSize',fontSizeSmall);
    hTemporalFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-7*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
        'Style','popup','String',temporalFreqString,'FontSize',fontSizeSmall);
end

% Analysis Type
analysisTypeString = 'ERP|Firing Rate|FFT|delta FFT|FFT_ERP|delta FFT_ERP|TF|deltaTF';
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-8*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Analysis Type','FontSize',fontSizeSmall);
hAnalysisType = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-8*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',analysisTypeString,'FontSize',fontSizeSmall);

% Reference scheme
[analogChannelStringList,analogChannelStringArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums);
referenceChannelStringList = ['None|AvgRef|' analogChannelStringList];
referenceChannelStringArray = [{'None'} {'AvgRef'} analogChannelStringArray];

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-9*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Reference','FontSize',fontSizeSmall);
hReferenceChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [dynamicTextWidth 1-9*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',referenceChannelStringList,'FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timing panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timingHeight = 0.1; timingTextWidth = 0.5; timingBoxWidth = 0.25;
hTimingPanel = uipanel('Title','Timing','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[timingStartPos panelStartHeight timingPanelWidth panelHeight]);

signalRange = [-0.2 1];
fftRange = [0 100];
baseline = [-0.5 0];
stimPeriod = [0.25 0.75];

% Signal Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Parameter','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Min','FontSize',fontSizeMedium);

uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[timingTextWidth+timingBoxWidth 1-timingHeight timingBoxWidth timingHeight], ...
    'Style','text','String','Max','FontSize',fontSizeMedium);

% Stim Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-3*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim Range (s)','FontSize',fontSizeSmall);
hStimMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeSmall);
hStimMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeSmall);


% FFT Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','FFT Range (Hz)','FontSize',fontSizeSmall);
hFFTMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(1)),'FontSize',fontSizeSmall);
hFFTMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(2)),'FontSize',fontSizeSmall);

% Baseline
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-6*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Basline (s)','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall);
hBaselineMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall);

% Stim Period
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim period (s)','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall);
hStimPeriodMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall);

% Y Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Y Range','FontSize',fontSizeSmall);
hYMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','0','FontSize',fontSizeSmall);
hYMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','1','FontSize',fontSizeSmall);

% Z Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-9*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Z Range','FontSize',fontSizeSmall);
hZMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-9*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','0','FontSize',fontSizeSmall);
hZMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-9*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','1','FontSize',fontSizeSmall);
hRemoveERP = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0 1-10*timingHeight 1 timingHeight], ...
    'Style','togglebutton','String','remove ERP','FontSize',fontSizeMedium);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotOptionsHeight = 0.1;
hPlotOptionsPanel = uipanel('Title','Plotting Options','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[plotOptionsStartPos panelStartHeight plotOptionsPanelWidth panelHeight]);

% Button for Plotting
[colorString, colorNames] = getColorString;
uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-plotOptionsHeight 0.6 plotOptionsHeight], ...
    'Style','text','String','Color','FontSize',fontSizeSmall);
hChooseColor = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0.6 1-plotOptionsHeight 0.4 plotOptionsHeight], ...
    'Style','popup','String',colorString,'FontSize',fontSizeSmall);

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 5*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','cla','FontSize',fontSizeMedium, ...
    'Callback',{@cla_Callback});

hHoldOn = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 4*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','togglebutton','String','hold on','FontSize',fontSizeMedium, ...
    'Callback',{@holdOn_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 3*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','rescale Z','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleZ_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 2*plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','rescale Y','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleY_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','rescale X','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleData_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 0 1 plotOptionsHeight], ...
    'Style','pushbutton','String','plot','FontSize',fontSizeMedium, ...
    'Callback',{@plotData_Callback});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show electrode array and bad channels
electrodeGridPos = [staticStartPos panelStartHeight staticPanelWidth panelHeight];
[~,~,electrodeArray,electrodeGroupList,groupNameList] = electrodePositionOnGrid(1,gridType,subjectName,gridLayout);
showElectrodeGroupsFlag = ~isempty(electrodeGroupList);

if showElectrodeGroupsFlag
    numElectrodeGroups = length(electrodeGroupList);
    colorNamesElectrodeGroups = jet(numElectrodeGroups);
    for iG=1:numElectrodeGroups
        hElectrodes = showElectrodeLocations(electrodeGridPos,electrodeGroupList{iG},colorNamesElectrodeGroups(iG,:),[],1,0,gridType,subjectName,gridLayout);
        text(hElectrodes,-0.35,iG/10,groupNameList{iG},'color',colorNamesElectrodeGroups(iG,:),'unit','normalized');
    end
else
    hElectrodes = showElectrodeLocations(electrodeGridPos,[],[],[],1,0,gridType,subjectName,gridLayout);
end

% Get Bad channels from the main impedance file
if strcmp(gridType,'EEG')
    impedanceFileName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,'impedanceData.mat');
    badImpedanceCutoff = 25;
    highImpedanceCutoff = 20;
else
    impedanceFileName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,'impedanceValues.mat');
    badImpedanceCutoff = 2500;
    highImpedanceCutoff = 1500;
end
if exist(impedanceFileName,'file')
    impedanceValues = getImpedanceValues(impedanceFileName);
    badChannels = [find(impedanceValues>badImpedanceCutoff) find(isnan(impedanceValues))];
    highImpChannels = find(impedanceValues>highImpedanceCutoff);
else
    disp('Could not find impedance values');
    badChannels=[];
    highImpChannels=[];
end

% Bad electrodes are also calculated using a more involved pipeline. If
% that exists, use those bad electrodes instead
impedanceFileName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData',['badTrials' badTrialNameStr '.mat']);
if exist(impedanceFileName,'file')
    x=load(impedanceFileName);
    
    if isfield(x,'badElecs')
        badChannels = unique([x.badElecs.badImpedanceElecs; x.badElecs.noisyElecs; x.badElecs.flatPSDElecs; x.badElecs.declaredBadElectrodes]);
    else
        badChannels = [];
    end
    highImpChannels = setdiff(highImpChannels,badChannels);
    badTrials = x.badTrials;
    allBadTrials = x.allBadTrials;
    goodChannels = setdiff(1:length(x.allBadTrials),badChannels);
    saveAvgRefData(folderLFP,goodChannels);
else
    badTrials = [];
    allBadTrials = [];
end

if ~isempty(highImpChannels)
    showElectrodeLocations(electrodeGridPos,highImpChannels,'m',[],1,0,gridType,subjectName,gridLayout);
    text(hElectrodes,-0.35,0.9,'HighImpedance','color','m','unit','normalized');
end
if ~isempty(badChannels)
    showElectrodeLocations(electrodeGridPos,badChannels,'r',[],1,0,gridType,subjectName,gridLayout);
    text(hElectrodes,-0.35,1,'Bad','color','r','unit','normalized');
end

% Get main plot and message handles
[numRows,numCols] = size(electrodeArray);

if ~showElectrodeGroupsFlag
    plotHandles = getPlotHandles(numRows,numCols,[0.05 0.1 0.9 0.55]);
else
    plotHandles = getPlotHandles(numRows,numCols,[0.05 0.1 0.7 0.55]);
    plotHandles2 = getPlotHandles(numElectrodeGroups+1,1,[0.8 0.1 0.15 0.55]);
end

hMessage = uicontrol('Unit','Normalized','Position',[0 0.975 1 0.025],...
    'Style','text','String',[subjectName expDate protocolName],'FontSize',fontSizeLarge);

% Remove non EEG channels
analogChannelsStored = intersect(analogChannelsStored,unique(electrodeArray));
neuralChannelsStored = intersect(neuralChannelsStored,unique(electrodeArray));

colormap jet;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
    function plotData_Callback(~,~)
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        
        if ~isempty(tValsUnique)
            c=get(hContrast,'val');
            t=get(hTemporalFreq,'val');
            goodPos = parameterCombinations{a,e,s,f,o,c,t};
        elseif ~isempty(cValsUnique)
            c=get(hContrast,'val');
            goodPos = parameterCombinations{a,e,s,f,o,c};
        else
            goodPos = parameterCombinations{a,e,s,f,o};
        end
        
        if useCommonBadTrialsFlag
            goodPos = setdiff(goodPos,badTrials);
        else
            % Use different badTrials for different electrodes
            goodPos0 = goodPos; clear goodPos;
            numElectrodes = length(analogChannelsStored);
            goodPos = cell(1,numElectrodes);
            
            if length(allBadTrials) == numElectrodes    
                for iElec=1:numElectrodes
                    goodPos{iElec} = setdiff(goodPos0,allBadTrials{iElec});
                end
            else
                error('length of allBadTrials not equal to numElectrodes');
            end
        end
        
        analysisType = get(hAnalysisType,'val');
        referenceChannelString = referenceChannelStringArray{get(hReferenceChannel,'val')};
        plotColor = colorNames(get(hChooseColor,'val'));
        
        blRange = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
        stRange = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];
        removeERPFlag = get(hRemoveERP,'val');
        
        set(hMessage,'String',[num2str(length(goodPos)) ' stimuli found' ]);
        
        if ~isempty(goodPos)
            if analysisType == 2
                holdOnState = get(hHoldOn,'val');
                channelsStored = neuralChannelsStored;
                [baselineFiringRate,stimulusFiringRate] = plotSpikeData(plotHandles,channelsStored,goodPos,folderSpikes,...
                    timeVals,plotColor,SourceUnitID,holdOnState,blRange,stRange,gridType,subjectName);
                responsiveElectrodes = (channelsStored(stimulusFiringRate>=5));
                inhibitedElectrodes = (channelsStored(intersect(find(baselineFiringRate>=5),find(stimulusFiringRate<=5))));
%                disp(['responsive: ' num2str(responsiveElectrodes)]);
%                disp(['inhibited : ' num2str(inhibitedElectrodes)]);
                showElectrodeLocations(electrodeGridPos,responsiveElectrodes,'b',hElectrodes,1,0,gridType,subjectName,gridLayout);
                showElectrodeLocations(electrodeGridPos,inhibitedElectrodes,'g',hElectrodes,1,0,gridType,subjectName,gridLayout);
                
            else
                channelsStored = analogChannelsStored;
                [valToPlot,valToPlotBL,xValToPlot]=plotLFPData(plotHandles,channelsStored,goodPos,folderLFP,...
                    analysisType,timeVals,plotColor,blRange,stRange,gridType,subjectName,gridLayout,referenceChannelString,removeERPFlag);
            end
            
            if analysisType<=2 || analysisType>=7 % ERP or spikes, or the TF plots
                xRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
            else
                xRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
            end
            
            if analysisType>=7 % TF plots
                yRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
            else
                yRange = getYLims(plotHandles,channelsStored,gridType,subjectName,gridLayout);
            end
            
            set(hYMin,'String',num2str(yRange(1))); set(hYMax,'String',num2str(yRange(2)));
            rescaleData(plotHandles,channelsStored,[xRange yRange],gridType,subjectName,gridLayout);
            
            if analysisType>=7 % TF plots
                zRange = getZLims(plotHandles,channelsStored,gridType,subjectName,gridLayout);
                set(hZMin,'String',num2str(zRange(1))); set(hZMax,'String',num2str(zRange(2)));
                rescaleZPlots(plotHandles,zRange);
            end
            if showElectrodeGroupsFlag
                plotAvgData(plotHandles2,valToPlot,valToPlotBL,xValToPlot,electrodeGroupList,badChannels,plotColor,groupNameList,colorNamesElectrodeGroups,referenceChannelString);
                rescalePlots(plotHandles2,[xRange yRange]);
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleZ_Callback(~,~)
        
        analysisType = get(hAnalysisType,'val');

        if analysisType>=7 % TF plots
            zRange = [str2double(get(hZMin,'String')) str2double(get(hZMax,'String'))];
            rescaleZPlots(plotHandles,zRange);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleY_Callback(~,~)
        
        analysisType = get(hAnalysisType,'val');
        
        if analysisType == 2
            channelsStored = neuralChannelsStored;
        else
            channelsStored = analogChannelsStored;
        end
        
        if analysisType<=2 || analysisType>=7 % ERP or spikes, or TF plots
            xRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        else
            xRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
        end
        
        yRange = [str2double(get(hYMin,'String')) str2double(get(hYMax,'String'))];
        rescaleData(plotHandles,channelsStored,[xRange yRange],gridType,subjectName,gridLayout);
        if showElectrodeGroupsFlag
            rescalePlots(plotHandles2,[xRange yRange]);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleData_Callback(~,~)
        
        analysisType = get(hAnalysisType,'val');
        
        if analysisType == 2
            channelsStored = neuralChannelsStored;
        else
            channelsStored = analogChannelsStored;
        end
        
        if analysisType<=2 || analysisType>=7 % ERP or spikes
            xRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        else
            xRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];
        end
        
        if analysisType>=7
            yRange = [str2double(get(hYMin,'String')) str2double(get(hYMax,'String'))];
        else
            yRange = getYLims(plotHandles,channelsStored,gridType,subjectName,gridLayout);
        end
        rescaleData(plotHandles,channelsStored,[xRange yRange],gridType,subjectName,gridLayout);
        if showElectrodeGroupsFlag
            rescalePlots(plotHandles2,[xRange yRange]);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function holdOn_Callback(source,~)
        holdOnState = get(source,'Value');
        holdOnData(plotHandles,holdOnState);
        if showElectrodeGroupsFlag
            holdOnData(plotHandles2,holdOnState);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        claPlots(plotHandles);
        if showElectrodeGroupsFlag
            claPlots(plotHandles2);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function saveAvgRefData(folderData,goodChannels)

avgRefFileName = fullfile(folderData,'AvgRef.mat');

if exist(avgRefFileName,'file')
    x = load(avgRefFileName);
    
    if isequal(goodChannels,x.goodChannels)
        doAvgRef=0;
    else
        disp('Changing average reference ...');
        doAvgRef=1;
    end
else
    doAvgRef=1;
end

if doAvgRef
    disp('Generating average reference...');
    allData = [];
    for i=1:length(goodChannels)
        channelNum=goodChannels(i);
        x = load(fullfile(folderData,['elec' num2str(channelNum)]));
        analogData = x.analogData;
        allData = cat(3,allData,analogData);
    end
    analogData = squeeze(mean(allData,3));
    save(avgRefFileName,'analogData','goodChannels');
end

end
% Main function that plots the data
function [valToPlot,valToPlotBL,xValToPlot]=plotLFPData(plotHandles, channelsStored, goodPosAll, ...
    folderData, analysisType, timeVals, plotColor,blRange,stRange,gridType,subjectName,gridLayout,referenceChannelString,removeERPFlag)

if isempty(goodPosAll)
    disp('No entries for this combination..')
else
    
    Fs = round(1/(timeVals(2)-timeVals(1)));
    blPos = find(timeVals>=blRange(1),1)+ (1:diff(blRange)*Fs);
    stPos = find(timeVals>=stRange(1),1)+ (1:diff(stRange)*Fs);
    
    xsBL = 0:1/(diff(blRange)):Fs-1/(diff(blRange));
    xsST = 0:1/(diff(stRange)):Fs-1/(diff(stRange));
    
    numChannelsStored=length(channelsStored);
    valToPlot = cell(numChannelsStored,1);
    valToPlotBL = cell(numChannelsStored,1);
    
    if ~iscell(goodPosAll)
        goodPosTmp = goodPosAll; clear goodPosAll;
        goodPosAll = cell(1,numChannelsStored);
        for iElec=1:numChannelsStored
            goodPosAll{iElec} = goodPosTmp; % Same for all electrodes
        end
    end

    % Set up multitaper for TF analysis
    movingwin = [0.25 0.025];
    params.tapers   = [1 1];
    params.pad      = -1;
    params.Fs       = Fs;
    params.trialave = 1; %averaging across trials
                
    for i=1:numChannelsStored
        
        goodPos = goodPosAll{i}; % Note that for bipolar ref or avg ref, goodPos should ideally have good trials for both electrodes. To be incorporated later.
        channelNum = channelsStored(i);
        disp(['Plotting electrode ' num2str(channelNum)]);
        
        % get position
        [row,column] = electrodePositionOnGrid(channelNum,gridType,subjectName,gridLayout);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear analogData
        x = load(fullfile(folderData,['elec' num2str(channelNum)]));
        analogData = x.analogData;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%% Change Reference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmpi(referenceChannelString,'None')
            % Do nothing
        elseif strcmp(referenceChannelString,'AvgRef')
            disp('Changing to average reference');
            x = load(fullfile(folderData,'AvgRef.mat'));
            analogData = analogData - x.analogData;
        else
            disp(['Changing reference to ' referenceChannelString]);
            x = load(fullfile(folderData,referenceChannelString));
            analogData = analogData - x.analogData;
        end

        % Remove ERP if needed
        signal = analogData(goodPos,:);
        erp = mean(signal,1);
        if removeERPFlag
            signal = signal - repmat(erp,size(signal,1),1);
        end

        if analysisType == 1        % compute ERP
            
            erp = erp - mean(erp(blPos));
            
            %Plot
            plot(plotHandles(row,column),timeVals,erp,'color',plotColor);
            
            valToPlot{i} = erp;
            valToPlotBL{i} = [];
            xValToPlot = timeVals;
            
        elseif analysisType == 2    % compute Firing rates
            disp('Use plotSpikeData instead of plotLFPData...');
            
        elseif (analysisType == 3) || (analysisType == 4)
            
            fftBL = abs(fft(signal(:,blPos),[],2));
            fftST = abs(fft(signal(:,stPos),[],2));
            
            if analysisType == 3
                plot(plotHandles(row,column),xsBL,log10(mean(fftBL)),'g');
                set(plotHandles(row,column),'Nextplot','add');
                plot(plotHandles(row,column),xsST,log10(mean(fftST)),'k');
                set(plotHandles(row,column),'Nextplot','replace');
                
                valToPlot{i} = log10(mean(fftST));
                valToPlotBL{i} = log10(mean(fftBL));
                xValToPlot = xsST;
            else
                if xsBL == xsST %#ok<*BDSCI>
                    plot(plotHandles(row,column),xsBL,log10(mean(fftST))-log10(mean(fftBL)),'color',plotColor);
                    set(plotHandles(row,column),'Nextplot','add');
                    plot(plotHandles(row,column),xsBL,zeros(1,length(xsBL)),'color','k');
                    set(plotHandles(row,column),'Nextplot','replace');
                    
                    valToPlot{i} = log10(mean(fftST))-log10(mean(fftBL));
                    valToPlotBL{i} = zeros(1,length(xsBL));
                    xValToPlot = xsST;
                else
                    disp('Choose same baseline and stimulus periods..');
                end
            end
            
        elseif (analysisType == 5) || (analysisType == 6)
            
            fftERPBL = abs(fft(erp(blPos)));
            fftERPST = abs(fft(erp(stPos)));
            
            if (analysisType == 5)
                plot(plotHandles(row,column),xsBL,log10(fftERPBL),'g');
                set(plotHandles(row,column),'Nextplot','add');
                plot(plotHandles(row,column),xsST,log10(fftERPST),'k');
                set(plotHandles(row,column),'Nextplot','replace');
                
                valToPlot{i} = log10(fftERPST);
                valToPlotBL{i} = log10(fftERPBL);
                xValToPlot = xsST;
            else
                if xsBL == xsST %#ok<*BDSCI>
                    plot(plotHandles(row,column),xsBL,log10(fftERPST)-log10(fftERPBL),'color',plotColor);
                    set(plotHandles(row,column),'Nextplot','add');
                    plot(plotHandles(row,column),xsBL,zeros(1,length(xsBL)),'color','k');
                    set(plotHandles(row,column),'Nextplot','replace');
                    
                    valToPlot{i} = log10(fftERPST)-log10(fftERPBL);
                    valToPlotBL{i} = zeros(1,length(xsBL));
                    xValToPlot = xsST;
                    
                else
                    disp('Choose same baseline and stimulus periods..');
                end
            end
            
        elseif (analysisType == 7) || (analysisType == 8) % TF and deltaTF plots - use multitaper analysis using Chronux
            
            [S,timeTF,freqTF] = mtspecgramc(signal',movingwin,params);
            xValToPlot = timeTF+timeVals(1)-1/Fs;
            if (analysisType==7)
                pcolor(plotHandles(row,column),xValToPlot,freqTF,log10(S'));
                shading(plotHandles(row,column),'interp');
            else
                blPos = intersect(find(xValToPlot>=blRange(1)),find(xValToPlot<blRange(2)));
                logS = log10(S);
                blPower = mean(logS(blPos,:),1);
                logSBL = repmat(blPower,length(xValToPlot),1);
                pcolor(plotHandles(row,column),xValToPlot,freqTF,10*(logS-logSBL)');
                shading(plotHandles(row,column),'interp');
            end
        end
    end
end
end

function plotAvgData(plotHandles2,valToPlot,valToPlotBL,xValToPlot,electrodeGroupList,badChannels,plotColor,groupNameList,colorNamesElectrodeGroups,referenceChannelString)

numElectrodeGroups = length(electrodeGroupList);

valToPlot = cell2mat(valToPlot);
valToPlotBL = cell2mat(valToPlotBL);

if strcmp(referenceChannelString,'None') || strcmp(referenceChannelString,'AvgRef')
    refChannel = [];
else
    refChannel = str2double(referenceChannelString(5:end));
end

allGoodElectrodes=[];
for i=1:numElectrodeGroups
    plotPos = numElectrodeGroups-i+1;
    electrodesToUse = setdiff(electrodeGroupList{i},[badChannels; refChannel]);
    allGoodElectrodes = cat(1,allGoodElectrodes,electrodesToUse(:));
    
    plot(plotHandles2(plotPos),xValToPlot,mean(valToPlot(electrodesToUse,:),1),'color',plotColor);
    if ~isempty(valToPlotBL)
        hold(plotHandles2(plotPos),'on');
        plot(plotHandles2(plotPos),xValToPlot,mean(valToPlotBL(electrodesToUse,:),1),'color','k');
    end
    text(0.8,0.9,['N=' num2str(length(electrodesToUse))],'unit','normalized','Parent',plotHandles2(plotPos),'color','k');
    ylabel(plotHandles2(plotPos),groupNameList{i},'color',colorNamesElectrodeGroups(i,:));
    
    if i~=numElectrodeGroups
        set(plotHandles2(plotPos),'XTickLabel',[]);
    end
end

% Average of all electrodes
plotPos = numElectrodeGroups+1;
plot(plotHandles2(plotPos),xValToPlot,mean(valToPlot(allGoodElectrodes,:),1),'color',plotColor);
if ~isempty(valToPlotBL)
    hold(plotHandles2(plotPos),'on');
    plot(plotHandles2(plotPos),xValToPlot,mean(valToPlotBL(allGoodElectrodes,:),1),'color','k');
end
text(0.8,0.9,['N=' num2str(length(allGoodElectrodes))],'unit','normalized','Parent',plotHandles2(plotPos),'color','k');
ylabel(plotHandles2(plotPos),'All','color','k');

end
function [baselineFiringRate,stimulusFiringRate] = plotSpikeData(plotHandles,channelsStored,goodPos, ...
    folderData, timeVals, plotColor, SourceUnitID,holdOnState,blRange,stRange,gridType,subjectName)

unitColors = ['r','m','y','c','g'];
binWidthMS = 10;

if isempty(goodPos)
    disp('No entries for this combination..')
else
    numChannels = length(channelsStored);
    baselineFiringRate = zeros(1,numChannels);
    stimulusFiringRate = zeros(1,numChannels);
    
    for i=1:length(channelsStored)
        channelNum = channelsStored(i);
        disp(channelNum)
        
        % get position
        [row,column] = electrodePositionOnGrid(channelNum,gridType,subjectName);
        
        clear spikeData
        x = load(fullfile(folderData,['elec' num2str(channelNum) '_SID' num2str(SourceUnitID(i))]));
        spikeData = x.spikeData;
        [psthVals,xs] = getPSTH(spikeData(goodPos),binWidthMS,[timeVals(1) timeVals(end)]);
        
        % Compute the mean firing rates
        blPos = find(xs>=blRange(1),1)+ (1:(diff(blRange))/(binWidthMS/1000));
        stPos = find(xs>=stRange(1),1)+ (1:(diff(stRange))/(binWidthMS/1000));
        
        baselineFiringRate(i) = mean(psthVals(blPos));
        stimulusFiringRate(i) = mean(psthVals(stPos));
        
        if SourceUnitID(i)==0
            plot(plotHandles(row,column),xs,psthVals,'color',plotColor);
        elseif SourceUnitID(i)> 5
            disp('Only plotting upto 6 single units per electrode...')
        else
            plot(plotHandles(row,column),xs,smooth(psthVals),'color',unitColors(SourceUnitID(i)));
        end
        
        if (i<length(channelsStored))
            if channelsStored(i) == channelsStored(i+1)
                disp('hold on...')
                set(plotHandles(row,column),'Nextplot','add');
            else
                if ~holdOnState
                    set(plotHandles(row,column),'Nextplot','replace');
                end
            end
        end
        
    end
end
end
function yRange = getYLims(plotHandles,channelsStored,gridType,subjectName,gridLayout)

% Initialize
yMin = inf;
yMax = -inf;

for i=1:length(channelsStored)
    channelNum = channelsStored(i);
    % get position
    [row,column] = electrodePositionOnGrid(channelNum,gridType,subjectName,gridLayout);
    
    axis(plotHandles(row,column),'tight');
    tmpAxisVals = axis(plotHandles(row,column));
    if tmpAxisVals(3) < yMin
        yMin = tmpAxisVals(3);
    end
    if tmpAxisVals(4) > yMax
        yMax = tmpAxisVals(4);
    end
end
yRange = [yMin yMax];
end
function zRange = getZLims(plotHandles,channelsStored,gridType,subjectName,gridLayout)

% Initialize
zMin = inf;
zMax = -inf;

for i=1:length(channelsStored)
    channelNum = channelsStored(i);
    % get position
    [row,column] = electrodePositionOnGrid(channelNum,gridType,subjectName,gridLayout);
    
    tmpAxisVals = clim(plotHandles(row,column));
    if tmpAxisVals(1) < zMin
        zMin = tmpAxisVals(1);
    end
    if tmpAxisVals(2) > zMax
        zMax = tmpAxisVals(2);
    end
end
zRange = [zMin zMax];
end
function rescaleData(plotHandles,channelsStored,axisLims,gridType,subjectName,gridLayout)

[numRows,numCols] = size(plotHandles);
labelSize=12;
for i=1:length(channelsStored)
    channelNum = channelsStored(i);
    
    % get position
    [row,column] = electrodePositionOnGrid(channelNum,gridType,subjectName,gridLayout);
    
    axis(plotHandles(row,column),axisLims);
    if (row==numRows && rem(column,2)==rem(numCols+1,2))
        if column~=1
            set(plotHandles(row,column),'YTickLabel',[],'fontSize',labelSize);
        end
    elseif (rem(row,2)==0 && column==1)
        set(plotHandles(row,column),'XTickLabel',[],'fontSize',labelSize);
    else
        set(plotHandles(row,column),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
    end
end

% Remove Labels on the four corners
set(plotHandles(1,1),'XTickLabel',[],'YTickLabel',[]);
set(plotHandles(1,numCols),'XTickLabel',[],'YTickLabel',[]);
set(plotHandles(numRows,1),'XTickLabel',[],'YTickLabel',[]);
set(plotHandles(numRows,numCols),'XTickLabel',[],'YTickLabel',[]);
end
function rescalePlots(plotHandles,axisLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        axis(plotHandles(i,j),axisLims);
    end
end
end
function rescaleZPlots(plotHandles,caxisLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        clim(plotHandles(i,j),caxisLims);
    end
end
end
function holdOnData(plotHandles,holdOnState)
[numRow,numCol] = size(plotHandles);

if holdOnState
    for i=1:numRow
        for j=1:numCol
            set(plotHandles(i,j),'Nextplot','add');
        end
    end
else
    for i=1:numRow
        for j=1:numCol
            set(plotHandles(i,j),'Nextplot','replace');
        end
    end
end
end
function claPlots(plotHandles)
[numRow,numCol] = size(plotHandles);
for i=1:numRow
    for j=1:numCol
        cla(plotHandles(i,j));
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outString,outArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums)
outString='';
count=1;
for i=1:length(analogChannelsStored)
    outArray{count} = ['elec' num2str(analogChannelsStored(i))]; %#ok<AGROW>
    outString = cat(2,outString,[outArray{count} '|']);
    count=count+1;
end
if ~isempty(analogInputNums)
    for i=1:length(analogInputNums)
        outArray{count} = ['ainp' num2str(analogInputNums(i))];
        outString = cat(2,outString,[outArray{count} '|']);
        count=count+1;
    end
end
end
function outString = getStringFromValues(valsUnique,decimationFactor)

if isscalar(valsUnique)
    outString = convertNumToStr(valsUnique(1),decimationFactor);
else
    outString='';
    for i=1:length(valsUnique)
        outString = cat(2,outString,[convertNumToStr(valsUnique(i),decimationFactor) '|']);
    end
    outString = [outString 'all'];
end

    function str = convertNumToStr(num,f)
        if num > 16384
            num=num-32768;
        end
        str = num2str(num/f);
    end
end
function [colorString, colorNames] = getColorString

colorNames = 'brkgcmy';
colorString = 'blue|red|black|green|cyan|magenta|yellow';

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%c%%%%%%%%%
%%%%%%%%%%%%c%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load Data
function [analogChannelsStored,goodStimPos,timeVals,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
x=load(fullfile(folderLFP,'lfpInfo.mat'));
analogChannelsStored=x.analogChannelsStored;
goodStimPos=x.goodStimPos;
timeVals=x.timeVals;

if isfield(x,'analogInputNums')
    analogInputNums=x.analogInputNums;
else
    analogInputNums=[];
end
end
function [neuralChannelsStored,SourceUnitID] = loadspikeInfo(folderSpikes)
fileName = fullfile(folderSpikes,'spikeInfo.mat');
if exist(fileName,'file')
    x=load(fileName);
    neuralChannelsStored=x.neuralChannelsStored;
    SourceUnitID=x.SourceUnitID;
else
    neuralChannelsStored=[];
    SourceUnitID=[];
end
end
function [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract)

x=load(fullfile(folderExtract,'parameterCombinations.mat'));
parameterCombinations=x.parameterCombinations;
aValsUnique=x.aValsUnique;
eValsUnique=x.eValsUnique;

if ~isfield(x,'sValsUnique')
    sValsUnique = x.rValsUnique/3;         
else
    sValsUnique=x.sValsUnique;
end

fValsUnique=x.fValsUnique;
oValsUnique=x.oValsUnique;

if ~isfield(x,'cValsUnique')
    cValsUnique=[];
else
    cValsUnique=x.cValsUnique;
end

if ~isfield(x,'tValsUnique')
    tValsUnique=[];
else
    tValsUnique=x.tValsUnique;
end
end
function impedanceValues = getImpedanceValues(fileName)
x=load(fileName);
if isfield(x,'impedanceValues')
    impedanceValues = x.impedanceValues;
elseif isfield(x,'electrodeImpedances')
    impedanceValues = x.electrodeImpedances;
else
    disp('Impedance information is not available');
    impedanceValues = [];
end
end