% Displays data from a single electrode

% In case the stimulus takes properties from both gabors (such as plaids or
% color stimuli), use sideChoice to specify which of the two side to use
% for each parameter.

% This program takes in multiple protocolNames and plots data for each.
% Useful for projects in which a particular protocol is run multiple times.
% For example, the tES stimulation project.

function displaySingleChannelGRFs(subjectName,expDate,protocolNames,folderSourceString,gridType,gridLayout,sideChoice,badTrialNameStr,useCommonBadTrialsFlag,goodLFPElectrodes)

if ~exist('folderSourceString','var');  folderSourceString='F:';        end
if ~exist('gridType','var');            gridType='Microelectrode';      end
if ~exist('gridLayout','var');          gridLayout=2;                   end
if ~exist('sideChoice','var');          sideChoice=[];                  end
if ~exist('badTrialNameStr','var');     badTrialNameStr = 'V4';         end
if ~exist('useCommonBadTrialsFlag','var'); useCommonBadTrialsFlag = 1;  end
if ~exist('goodLFPElectrodes','var');   goodLFPElectrodes = [];         end

% load LFP Information
[analogChannelsStored,~,analogInputNums] = loadLFPInfo(subjectName,expDate,protocolNames,folderSourceString,gridType);
% [neuralChannelsStored,SourceUnitIDs] = loadSpikeInfoSingleProtocol(subjectName,expDate,protocolNames{1},folderSourceString,gridType); % We take the first one since sometimes spiek data becomes unavailable for some protcols

% Get Combinations
[aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(subjectName,expDate,protocolNames,folderSourceString,gridType,sideChoice);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Panels
panelHeight = 0.34; panelStartHeight = 0.61;
staticPanelWidth = 0.25; staticStartPos = 0.025;
dynamicPanelWidth = 0.25; dynamicStartPos = 0.275;
timingPanelWidth = 0.25; timingStartPos = 0.525;
plotOptionsPanelWidth = 0.2; plotOptionsStartPos = 0.775;
backgroundColor = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dynamic panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dynamicHeight = 0.07; dynamicGap=0.015; dynamicTextWidth = 0.6;
hDynamicPanel = uipanel('Title','Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[dynamicStartPos panelStartHeight dynamicPanelWidth panelHeight]);

% Analog channel
[analogChannelStringList,analogChannelStringArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums,goodLFPElectrodes);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
    'Style','text','String','Analog Channel','FontSize',fontSizeSmall);
hAnalogChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',analogChannelStringList,'FontSize',fontSizeSmall);

% % Neural channel
% uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
%     'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
%     'Style','text','String','Neural Channel','FontSize',fontSizeSmall);
% 
% if ~isempty(neuralChannelsStored)
%     neuralChannelString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs);
%     hNeuralChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
%         'BackgroundColor', backgroundColor, 'Position', ...
%         [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
%         'Style','popup','String',neuralChannelString,'FontSize',fontSizeSmall);
% else
%     hNeuralChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
%         'Position', [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
%         'Style','text','String','Not found','FontSize',fontSizeSmall);
% end

% Azimuth
azimuthString = getStringFromValues(aValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
    'Style','text','String','Azimuth (Deg)','FontSize',fontSizeSmall);
hAzimuth = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',azimuthString,'FontSize',fontSizeSmall);

% Elevation
elevationString = getStringFromValues(eValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-4*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Elevation (Deg)','FontSize',fontSizeSmall);
hElevation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [dynamicTextWidth 1-4*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',elevationString,'FontSize',fontSizeSmall);

% Sigma
sigmaString = getStringFromValues(sValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Sigma (Deg)','FontSize',fontSizeSmall);
hSigma = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',sigmaString,'FontSize',fontSizeSmall);

% Spatial Frequency
spatialFreqString = getStringFromValues(fValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-6*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Spatial Freq (CPD)','FontSize',fontSizeSmall);
hSpatialFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-6*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',spatialFreqString,'FontSize',fontSizeSmall);

% Orientation
orientationString = getStringFromValues(oValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-7*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Orientation (Deg)','FontSize',fontSizeSmall);
hOrientation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-7*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',orientationString,'FontSize',fontSizeSmall);

% Contrast
contrastString = getStringFromValues(cValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-8*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Contrast (%)','FontSize',fontSizeSmall);
hContrast = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-8*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',contrastString,'FontSize',fontSizeSmall);

% Temporal Frequency
temporalFreqString = getStringFromValues(tValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-9*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Temporal Freq (Hz)','FontSize',fontSizeSmall);
hTemporalFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position', ...
    [dynamicTextWidth 1-9*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',temporalFreqString,'FontSize',fontSizeSmall);

% Reference scheme
referenceChannelStringList = ['None|AvgRef|' analogChannelStringList];
referenceChannelStringArray = [{'None'} {'AvgRef'} analogChannelStringArray];

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-11*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Reference','FontSize',fontSizeSmall);
hReferenceChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, 'Position',...
    [dynamicTextWidth 1-11*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',referenceChannelStringList,'FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timing panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timingHeight = 0.1; timingTextWidth = 0.5; timingBoxWidth = 0.25;
hTimingPanel = uipanel('Title','Timing','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[timingStartPos panelStartHeight timingPanelWidth panelHeight]);

stimRange = [-0.2 1];
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
    'Style','edit','String',num2str(stimRange(1)),'FontSize',fontSizeSmall);
hStimMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-3*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimRange(2)),'FontSize',fontSizeSmall);

% FFT Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-4*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','FFT Range (Hz)','FontSize',fontSizeSmall);
hFFTMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-4*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(1)),'FontSize',fontSizeSmall);
hFFTMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-4*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(fftRange(2)),'FontSize',fontSizeSmall);

% Baseline
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-5*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Basline (s)','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall);
hBaselineMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-5*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall);

% Stim Period
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-6*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Stim period (s)','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall);
hStimPeriodMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-6*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall);
% 
% % Y Range
% uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
%     'Position',[0 1-7*timingHeight timingTextWidth timingHeight], ...
%     'Style','text','String','Y Range','FontSize',fontSizeSmall);
% hYMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
%     'BackgroundColor', backgroundColor, ...
%     'Position',[timingTextWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
%     'Style','edit','String','0','FontSize',fontSizeSmall);
% hYMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
%     'BackgroundColor', backgroundColor, ...
%     'Position',[timingTextWidth+timingBoxWidth 1-7*timingHeight timingBoxWidth timingHeight], ...
%     'Style','edit','String','1','FontSize',fontSizeSmall);

% Z Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-8*timingHeight timingTextWidth timingHeight], ...
    'Style','text','String','Z Range','FontSize',fontSizeSmall);
hZMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','0','FontSize',fontSizeSmall);
hZMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[timingTextWidth+timingBoxWidth 1-8*timingHeight timingBoxWidth timingHeight], ...
    'Style','edit','String','1','FontSize',fontSizeSmall);

hNormalize = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'BackgroundColor', backgroundColor, ...
    'Position',[0 1-9*timingHeight 1 timingHeight], ...
    'Style','togglebutton','String','Normalize','FontSize',fontSizeMedium);
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
% [colorString, colorNames] = getColorString;
% uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
%     'Position',[0 1-plotOptionsHeight 0.6 plotOptionsHeight], ...
%     'Style','text','String','Color','FontSize',fontSizeSmall);
% 
% hChooseColor = uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
%     'BackgroundColor', backgroundColor, ...
%     'Position',[0.6 1-plotOptionsHeight 0.4 plotOptionsHeight], ...
%     'Style','popup','String',colorString,'FontSize',fontSizeSmall);

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

% uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
%     'Position',[0 2*plotOptionsHeight 1 plotOptionsHeight], ...
%     'Style','pushbutton','String','rescale Y','FontSize',fontSizeMedium, ...
%     'Callback',{@rescaleY_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 plotOptionsHeight 1 plotOptionsHeight], ...
    'Style','pushbutton','String','Rescale','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleData_Callback});

uicontrol('Parent',hPlotOptionsPanel,'Unit','Normalized', ...
    'Position',[0 0 1 plotOptionsHeight], ...
    'Style','pushbutton','String','plot','FontSize',fontSizeMedium, ...
    'Callback',{@plotData_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get plots and message handles

% Get electrode array information
electrodeGridPos = [staticStartPos panelStartHeight staticPanelWidth panelHeight];
hElectrodes = showElectrodeLocations(electrodeGridPos,analogChannelsStored(get(hAnalogChannel,'val')), ...
    'b',[],1,0,gridType,subjectName,gridLayout);

uicontrol('Unit','Normalized','Position',[0 0.975 1 0.025],...
    'Style','text','String',[subjectName expDate],'FontSize',fontSizeLarge);

% Plot handles
numProtocols   = length(protocolNames);
numPlots       = numProtocols+1;
hSpikePlots    = getPlotHandles(1,numPlots,[0.025 0.5 0.95 0.1],0.002);
hERPPlots      = getPlotHandles(1,numPlots,[0.025 0.4 0.95 0.1],0.002);
hTFPlots       = getPlotHandles(1,numPlots,[0.025 0.3 0.95 0.1],0.002);
hPSDPlots      = getPlotHandles(1,numPlots,[0.025 0.15 0.95 0.1],0.002);
hDeltaPSDPlots = getPlotHandles(1,numPlots,[0.025 0.05 0.95 0.1],0.002);

colorNames = jet(numProtocols);
colormap jet;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
    function plotData_Callback(~,~)
        a=get(hAzimuth,'val');
        e=get(hElevation,'val');
        s=get(hSigma,'val');
        f=get(hSpatialFreq,'val');
        o=get(hOrientation,'val');
        c=get(hContrast,'val');
        t=get(hTemporalFreq,'val');
        
        channelPos = get(hAnalogChannel,'val');
        channelString0 = analogChannelStringArray{channelPos};
        normalizeFlag = get(hNormalize,'val');
        removeERPFlag = get(hRemoveERP,'val');
        referenceChannelString = referenceChannelStringArray{get(hReferenceChannel,'val')};

        stimRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        fftRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];

        blRange = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
        stRange = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];

        % plotColor = colorNames(get(hChooseColor,'val'));
        holdOnState = get(hHoldOn,'val');
        
        % Get all Data
        if strncmpi(channelString0,'goodLFP',7) % Good LFP Electrodes
            numGoodLFPElectrodes = length(goodLFPElectrodes);

            dataOutTMP1 = cell(1,numGoodLFPElectrodes);
            for i=1:numGoodLFPElectrodes
                channelString = ['elec' num2str(goodLFPElectrodes(i))];
                disp(['Working on ' channelString ', ' num2str(i) '/' num2str(numGoodLFPElectrodes)]);

                dataOutTMP2 = cell(1,numProtocols);
                for j=1:numProtocols
                    dataIn = getSpikeLFPDataSingleChannel(subjectName,expDate,protocolNames{j},folderSourceString,channelString,0,gridType,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
                    dataOutTMP2{j} = getDataGRF(dataIn,a,e,s,f,o,c,t,blRange,stRange,removeERPFlag);
                end
                if normalizeFlag
                    dataOutTMP2 = normalizeData(dataOutTMP2);
                end
                dataOutTMP1{i} = dataOutTMP2;
            end
            dataOut = combineDataGRF(dataOutTMP1);
        else
            channelString = channelString0;
            dataOut = cell(1,numProtocols);
            for i=1:numProtocols
                dataIn = getSpikeLFPDataSingleChannel(subjectName,expDate,protocolNames{i},folderSourceString,channelString,0,gridType,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
                dataOut{i} = getDataGRF(dataIn,a,e,s,f,o,c,t,blRange,stRange,removeERPFlag);
            end
        end

        if normalizeFlag
            dataOut = normalizeData(dataOut);
        end

        % Plot Data
        for i=1:numProtocols
            plotColor = colorNames(i,:);

            % Spikes
            plot(hSpikePlots(i),dataOut{i}.frTimeVals,dataOut{i}.frVals,'color',plotColor);
            plot(hSpikePlots(numPlots),dataOut{i}.frTimeVals,dataOut{i}.frVals,'color',plotColor);
            hold(hSpikePlots(numPlots),'on');

            % ERP
            plot(hERPPlots(i),dataOut{i}.timeVals,dataOut{i}.erp,'color',plotColor);
            plot(hERPPlots(numPlots),dataOut{i}.timeVals,dataOut{i}.erp,'color',plotColor);
            hold(hERPPlots(numPlots),'on');

            % deltaTF
            pcolor(hTFPlots(i),dataOut{i}.timeTF,dataOut{i}.freqTF,dataOut{i}.deltaTF');
            shading(hTFPlots(i),'interp');

            % PSD
            plot(hPSDPlots(i),dataOut{i}.freqBL,log10(dataOut{i}.SBL),'color','k','linestyle','--');
            hold(hPSDPlots(i),'on');
            plot(hPSDPlots(i),dataOut{i}.freqST,log10(dataOut{i}.SST),'color',plotColor);
            plot(hPSDPlots(numPlots),dataOut{i}.freqBL,log10(dataOut{i}.SBL),'color','k','linestyle','--');
            hold(hPSDPlots(numPlots),'on');
            plot(hPSDPlots(numPlots),dataOut{i}.freqST,log10(dataOut{i}.SST),'color',plotColor);

            % DeltaPSD
            plot(hDeltaPSDPlots(i),dataOut{i}.freqBL,dataOut{i}.deltaPSD,'color',plotColor);
            hold(hDeltaPSDPlots(i),'on');
            plot(hDeltaPSDPlots(i),dataOut{i}.freqBL,dataOut{i}.deltaPSD - dataOut{1}.deltaPSD,'color',plotColor); % Change compared to the first protocol
            plot(hDeltaPSDPlots(i),dataOut{i}.freqBL,zeros(1,length(dataOut{i}.freqBL)),'color','k','linestyle','--');

            plot(hDeltaPSDPlots(numPlots),dataOut{i}.freqBL,dataOut{i}.deltaPSD,'color',plotColor);
            hold(hDeltaPSDPlots(numPlots),'on');
            plot(hDeltaPSDPlots(numPlots),dataOut{i}.freqBL,dataOut{i}.deltaPSD - dataOut{1}.deltaPSD,'color',plotColor); % Change compared to the first protocol
        end
        plot(hDeltaPSDPlots(numPlots),dataOut{i}.freqBL,zeros(1,length(dataOut{i}.freqBL)),'color','k','linestyle','--');

        % Rescale
        rescaleData(hSpikePlots,stimRange,getYLims(hSpikePlots));
        rescaleData(hERPPlots,stimRange,getYLims(hERPPlots));
        
        rescaleData(hTFPlots,stimRange,fftRange);
        zRange = getZLims(hTFPlots);
        set(hZMin,'String',num2str(zRange(1))); set(hZMax,'String',num2str(zRange(2)));
        rescaleZPlots(hTFPlots,zRange);

        rescaleData(hPSDPlots,fftRange,getYLims(hPSDPlots));
        rescaleData(hDeltaPSDPlots,fftRange,getYLims(hDeltaPSDPlots));

        if channelPos<=length(analogChannelsStored)
            channelNumber = analogChannelsStored(channelPos);
            showElectrodeLocations(electrodeGridPos,channelNumber,'b',hElectrodes,holdOnState,0,gridType,subjectName,gridLayout);
        elseif strncmpi(channelString0,'goodLFP',7) % Good LFP Electrodes
            showElectrodeLocations(electrodeGridPos,goodLFPElectrodes,'b',hElectrodes,holdOnState,0,gridType,subjectName,gridLayout);
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleZ_Callback(~,~)

        zRange = [str2double(get(hZMin,'String')) str2double(get(hZMax,'String'))];
        rescaleZPlots(hTFPlots,zRange);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleData_Callback(~,~)

        stimRange = [str2double(get(hStimMin,'String')) str2double(get(hStimMax,'String'))];
        fftRange = [str2double(get(hFFTMin,'String')) str2double(get(hFFTMax,'String'))];

        rescaleData(hSpikePlots,stimRange,getYLims(hSpikePlots));
        rescaleData(hERPPlots,stimRange,getYLims(hERPPlots)); 
        rescaleData(hTFPlots,stimRange,fftRange);
        rescaleData(hPSDPlots,fftRange,getYLims(hPSDPlots));
        rescaleData(hDeltaPSDPlots,fftRange,getYLims(hDeltaPSDPlots));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function holdOn_Callback(source,~)
        holdOnState = get(source,'Value');
        
        holdOnGivenPlotHandle(hSpikePlots,holdOnState);
        holdOnGivenPlotHandle(hERPPlots,holdOnState);
        holdOnGivenPlotHandle(hPSDPlots,holdOnState);
        holdOnGivenPlotHandle(hDeltaPSDPlots,holdOnState);
        
        if holdOnState
            set(hElectrodes,'Nextplot','add');
        else
            set(hElectrodes,'Nextplot','replace');
        end

        function holdOnGivenPlotHandle(plotHandles,holdOnState)
            
            [numRows,numCols] = size(plotHandles);
            if holdOnState
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','add');
                    end
                end
            else
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','replace');
                    end
                end
            end
        end 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        
        claGivenPlotHandle(hSpikePlots);
        claGivenPlotHandle(hERPPlots);
        claGivenPlotHandle(hTFPlots);
        claGivenPlotHandle(hPSDPlots);
        claGivenPlotHandle(hDeltaPSDPlots);

        function claGivenPlotHandle(plotHandles)
            [numRows,numCols] = size(plotHandles);
            for i=1:numRows
                for j=1:numCols
                    cla(plotHandles(i,j));
                end
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yLims = getYLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
yMin = inf;
yMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        tmpAxisVals = axis(plotHandles(row,column));
        if tmpAxisVals(3) < yMin
            yMin = tmpAxisVals(3);
        end
        if tmpAxisVals(4) > yMax
            yMax = tmpAxisVals(4);
        end
    end
end

yLims=[yMin yMax];
end
function zLims = getZLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
zMin = inf;
zMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        tmpAxisVals = clim(plotHandles(row,column));
        if tmpAxisVals(1) < zMin
            zMin = tmpAxisVals(1);
        end
        if tmpAxisVals(2) > zMax
            zMax = tmpAxisVals(2);
        end
    end
end

zLims=[zMin zMax];
end
function rescaleData(plotHandles,xLims,yLims)

[numRows,numCols] = size(plotHandles);
labelSize=12;
for i=1:numRows
    for j=1:numCols
        axis(plotHandles(i,j),[xLims yLims]);
        if (i==numRows && rem(j,2)==1)
            if j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        else
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        end
    end
end
end
function rescaleZPlots(plotHandles,zLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        clim(plotHandles(i,j),zLims);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outString = getStringFromValues(valsUnique,decimationFactor)

if length(valsUnique)==1
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
function [outString,outArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums,goodLFPElectrodes)
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
if ~isempty(goodLFPElectrodes)
    str = ['goodLFPElectrodes (N=' num2str(length(goodLFPElectrodes)) ')'];
    outArray{count} = str;
    outString = cat(2,outString,str);
end
end
% function outString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs)
% outString='';
% for i=1:length(neuralChannelsStored)
%     outString = cat(2,outString,[num2str(neuralChannelsStored(i)) ', SID ' num2str(SourceUnitIDs(i)) '|']);
% end 
% end
% function [colorString, colorNames] = getColorString
% 
% colorNames = 'brkgcmy';
% colorString = 'blue|red|black|green|cyan|magenta|yellow';
% 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%c%%%%%%%%%
% load Data
function [analogChannelsStored,timeVals,analogInputNums] = loadLFPInfo(subjectName,expDate,protocolNames,folderSourceString,gridType)

[analogChannelsStored,timeVals,~,analogInputNums] = loadLFPInfoSingleProtocol(subjectName,expDate,protocolNames{1},folderSourceString,gridType);

% Make sure remaining protocols have the same LFP channels
numProtocols = length(protocolNames);
if numProtocols > 1
    for i=2:numProtocols
        [analogChannelsStoredTMP,timeValsTMP,~,analogInputNumsTMP] = loadLFPInfoSingleProtocol(subjectName,expDate,protocolNames{i},folderSourceString,gridType);
        if ~isequal(analogChannelsStored,analogChannelsStoredTMP) || ~isequal(timeVals,timeValsTMP) || ~isequal(analogInputNums,analogInputNumsTMP)
            error('LFP channels do not match');
        end
    end
end
end
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadLFPInfoSingleProtocol(subjectName,expDate,protocolName,folderSourceString,gridType)
x = load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP','lfpInfo.mat'));
analogChannelsStored=x.analogChannelsStored;
goodStimPos=x.goodStimPos;
timeVals=x.timeVals;

if isfield(x,'analogInputNums')
    analogInputNums=x.analogInputNums;
else
    analogInputNums=[];
end
end
% function [neuralChannelsStored,sourceUnitID] = loadSpikeInfo(subjectName,expDate,protocolNames,folderSourceString,gridType)
% [neuralChannelsStored,sourceUnitID] = loadSpikeInfoSingleProtocol(subjectName,expDate,protocolNames{1},folderSourceString,gridType);
% 
% % Make sure remaining protocols have the same Spike channels
% numProtocols = length(protocolNames);
% if numProtocols > 1
%     for i=2:numProtocols
%         [neuralChannelsStoredTMP,sourceUnitIDTMP] = loadSpikeInfoSingleProtocol(subjectName,expDate,protocolNames{i},folderSourceString,gridType);
%         if ~isequal(neuralChannelsStored,neuralChannelsStoredTMP) || ~isequal(sourceUnitID,sourceUnitIDTMP)
%             error('Spike channels do not match');
%         end
%     end
% end
% end
% function [neuralChannelsStored,sourceUnitID] = loadSpikeInfoSingleProtocol(subjectName,expDate,protocolName,folderSourceString,gridType)
% fileName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','Spikes','spikeInfo.mat');
% if exist(fileName,'file')
%     x=load(fileName);
%     neuralChannelsStoredTMP = x.neuralChannelsStored;
%     sourceUnitIDTMP = x.SourceUnitID;
%     tmp = unique([neuralChannelsStoredTMP ; sourceUnitIDTMP]','rows');
%     neuralChannelsStored = tmp(:,1);
%     sourceUnitID = tmp(:,2);
% else
%     neuralChannelsStored=[];
%     sourceUnitID=[];
% end
% end
function [aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(subjectName,expDate,protocolNames,folderSourceString,gridType,sideChoice)

[~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinationsSingleProtocol(subjectName,expDate,protocolNames{1},folderSourceString,gridType,sideChoice);

% Make sure remaining protocols have the same parameterCombinations
numProtocols = length(protocolNames);
if numProtocols > 1
    for i=2:numProtocols
        [~,a,e,s,f,o,c,t] = loadParameterCombinationsSingleProtocol(subjectName,expDate,protocolNames{i},folderSourceString,gridType,sideChoice);

        if ~isequal(aValsUnique,a) || ~isequal(eValsUnique,e) || ~isequal(sValsUnique,s) || ~isequal(fValsUnique,f) || ~isequal(oValsUnique,o) || ~isequal(cValsUnique,c) || ~isequal(tValsUnique,t)
            error('ParameterCombinations do not match');
        end
    end
end
end
function [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinationsSingleProtocol(subjectName,expDate,protocolName,folderSourceString,gridType,sideChoice)

p = load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','parameterCombinations.mat'));

if ~isfield(p,'parameterCombinations2') % Not a plaid stimulus
    parameterCombinations=p.parameterCombinations;
    aValsUnique=p.aValsUnique;
    eValsUnique=p.eValsUnique;
    
    if ~isfield(p,'sValsUnique')
        sValsUnique = p.rValsUnique/3;
    else
        sValsUnique=p.sValsUnique;
    end
    
    fValsUnique=p.fValsUnique;
    oValsUnique=p.oValsUnique;
    
    if ~isfield(p,'cValsUnique')
        cValsUnique=100;
    else
        cValsUnique=p.cValsUnique;
    end
    
    if ~isfield(p,'tValsUnique')
        tValsUnique=0;
    else
        tValsUnique=p.tValsUnique;
    end 
else
    [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
        fValsUnique,oValsUnique,cValsUnique,tValsUnique] = makeCombinedParameterCombinations(folderExtract,sideChoice);
end
end
function dataOut = normalizeData(dataIn)

numProtocols = length(dataIn);
dataOut = dataIn;

% Normalize Firing rate
frValsMatrix = zeros(numProtocols,length(dataIn{1}.frVals));

for i=1:numProtocols
    frValsMatrix(i,:) = dataIn{i}.frVals;
end
maxFRVal = max(1,max(frValsMatrix(:))); % no normalization if max firing rate is less than 1

for i=1:numProtocols
    dataOut{i}.frVals = dataIn{i}.frVals/maxFRVal;
end
end