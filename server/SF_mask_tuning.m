 % for sf/mask tuning

%% Drifting grating and plaid stimuli
close all
clear all
%% Add stim server to the path
addpath(genpath('/usr/share/matlab/site/m/psychtoolbox-3'))
sCodeRoot = '/home/javadzam/MATLAB/';
addpath(genpath(fullfile(sCodeRoot, 'stimserver')))
addpath(genpath(fullfile(sCodeRoot, 'beacon_stimuli')))
addpath(genpath(fullfile(sCodeRoot, 'PulsePal-master/MATLAB')))
load('/home/javadzam/MATLAB/beacon_stimuli/ParameterMatrix_Mitra_inhshort.mat');

%% Initialise display
InitDisplay;

%% Stimulus parameters

%% Static square-wave gratings
fGratingSFCPD = 0.04;
tDriftHz = 0; %2
nNumDirections = 8;
fComponentContrast = 1;

tFrameDuration = GetSafeFrameDurations(hWindow, 0)*1 ;%to test:2: a total of 26 times out of a total of 1291 flips during this session.

tStimulusDuration = 0.5;%1%.3; % 1.5
nNumRepeats = 1;
fCyclesPerDegree = fGratingSFCPD;
fPixelsPerDegree = fPPD;
fShiftCyclesPerSec = tDriftHz;
fRotateCyclesPerSecond = 0;
bDrawMask = true;%false
bInvertMask = false;
fMaskDiameterDeg = 40;%20 %[];
vfMaskPosPix = [0,0];%[];
fBarWidthDegrees = [];
fContrast = fComponentContrast;

vfDirections = linspace(0, 360, nNumDirections+1);
vfDirections = vfDirections(1:end-1);

fGratingSFCPD = 0.04;
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 20;
bDrawMask = true;
vsGratings_static(1) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);


fGratingSFCPD = 0.06;  
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 20;
bDrawMask = true;
vsGratings_static(2) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);


fGratingSFCPD = 0.08; 
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 20;
bDrawMask = true;
vsGratings_static(3) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);

fGratingSFCPD = 0.04;
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 40;
bDrawMask = true;
vsGratings_static(4) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);


fGratingSFCPD = 0.06;  
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 40;
bDrawMask = true;
vsGratings_static(5) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);


fGratingSFCPD = 0.08;  
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 40;
bDrawMask = true;
vsGratings_static(6) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);

fGratingSFCPD = 0.04;
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 40;
bDrawMask = false;
vsGratings_static(7) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);


fGratingSFCPD = 0.06;   
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 40;
bDrawMask = false;
vsGratings_static(8) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);


fGratingSFCPD = 0.08; 
fCyclesPerDegree = fGratingSFCPD;
fMaskDiameterDeg = 40;
bDrawMask = false;
vsGratings_static(9) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
[], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
vfDirections(2), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
bDrawMask, bInvertMask, fMaskDiameterDeg, ...
vfMaskPosPix, fContrast);


sSquareGratSeq_static = STIM_Sequence(nan, vsGratings_static);




%% Build stimulus set

vsStimuli = ...
[sSquareGratSeq_static];
% each direction a separate stimulus

 size(vsStimuli)
 

%% Manually-triggered stimuli

% InitDisplay;
% 
% for i=1:20
%  PresentArbitraryStimulus(sRetinotopyR, hWindow, .2);
% end
% PresentArbitraryStimulus(vsGratings_static(1), hWindow, 0);
% PresentArbitraryStimulus(FFFlash, hWindow, 0);
% PresentArbitraryStimulus(sRetinotopyR, hWindow, 0);
% PresentArbitraryStimulus(sRetinotopyH, hWindow, 0);

% 
% sca;
% return;



%% Start stimulus server

 strExperiment = datestr(now, 'yyyymmdd'); %#ok<UNRCH>
 StartStimulusServer(vsStimuli, 5000, hWindow, true, {}, ...
     {'131.152.17.201', 5556});
 
%  if exist('hLabJackU6', 'var')
%      hLabJackU6.close()
%  end
EndPulsePal;
 sca;
 clear all;
