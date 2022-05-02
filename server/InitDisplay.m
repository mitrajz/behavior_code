% Initialise display
%oldPriority=Priority(50); %default 0

headBefore=Screen('Preference','ScreenToHead', 1, 0,1); % 1 0 0 % change last number to match

Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'Verbosity',10); % 10 or 1

vnScreens = Screen('Screens');
nStimScreen = max(vnScreens);


% - Get black / white colours
nBlack = BlackIndex(nStimScreen);
nWhite = WhiteIndex(nStimScreen);
nGrey = round((nWhite + nBlack)/2);

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');

% - Open a window
% hWindow = Screen('OpenWindow', 0, nGrey, [0 0 400 100]);
% hWindow = Screen('OpenWindow', 0, nGrey, [0 0 2500 1500]);
%hWindow = Screen('OpenWindow', nStimScreen, nGrey]);
% hWindow = PsychImaging('OpenWindow', nStimScreen, nGrey);
% hWindow = Screen('OpenWindow', 0, nGrey, [-800 0 0 480]);
[hWindow, vnScreenRect]=Screen('OpenWindow',nStimScreen, nGrey);

tIFI = Screen('GetFlipInterval', hWindow); 
% --------------------- labjack, frame marker flip
% % Create a handle to labjack
% hLabJackU6 = labJack('deviceID', 6, 'verbose', true);
% fFrameMarkerFunction = @() hLabJackU6.timedTTL(3, 0.2);
% %fSendLaserTrig = @() hLabJackU6.timedTTL(2, 500);
% Usage: (hWindow, vnMarkerSize, bShowStimulusMarker, bShowFrameMarker, 
%         bSynchToFrames, bInvertStimMarker, bMarkerStartsBlack, ..
%         fFunctionPerFrame)
% FrameMarkerFlip(hWindow, [150 150],    true,               false,   ... % 50 50
%               false,          false,             false, ... %  bsynchtoframe: default false
%               fFrameMarkerFunction);
FrameMarkerFlip(hWindow, [150 150],    true,               false,   ... % 50 50
              false,          false,             false );
%           
% if exist('hLabJackU6', 'var') && hLabJackU6.isOpen
%      hLabJackU6.close()
% end          

% --------------------- Load gamma table
load(fullfile(sCodeRoot, 'beacon_stimuli', 'gamma_table', ...
    'GammaTable_ephyssetup2_bigmonitor_0luminance'))
oldGamma = Screen('LoadNormalizedGammaTable', hWindow, gammaTable*[1 1 1]);

% [vfPixelsPerDegree, vfDegreesPerMetre, vfPixelsPerMetre] = CalibrateMacBook;
% [vfPixelsPerDegree, vfDegreesPerMetre, vfPixelsPerMetre] = CalibrateXenarc7(0.09, [800 480]);
% [vfPixelsPerDegree, vfDegreesPerMetre, vfPixelsPerMetre, vfSizeDegrees] = ...
%    CalibrateDisplay([0.475 0.30], [1280 800], 0.18);
screenSizePixels =vnScreenRect(3:4);
screenSizeMeters= [0.6 0.35];
[vfPixelsPerDegree, vfDegreesPerMetre, vfPixelsPerMetre, vfSizeDegrees] = ...
   CalibrateDisplay(screenSizeMeters, screenSizePixels, 0.24 ); % Change last parameter!!!!

fPPD = mean(vfPixelsPerDegree);
fDPM = mean(vfDegreesPerMetre);
fPPM = mean(vfPixelsPerMetre);

% to restore the original gamma table do:
% Screen('LoadNormalizedGammaTable', hWindow, oldGamma);
% --------------------- PulsePal initialization

PulsePal; % no port specified. Make sure it is the right device
pulsepalwaves;
