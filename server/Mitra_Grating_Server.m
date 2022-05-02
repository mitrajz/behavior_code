 

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



%% Drifting square-wave gratings

fGratingSFCPD = 0.04;
tDriftHz = 2;
nNumDirections = 8;
fComponentContrast = 1;

tFrameDuration = GetSafeFrameDurations(hWindow, 0)*1 ;%to test:2: a total of 26 times out of a total of 1291 flips during this session.

tStimulusDuration = .3; % 1.5
nNumRepeats = 1;
fCyclesPerDegree = fGratingSFCPD;
fPixelsPerDegree = fPPD;
fShiftCyclesPerSec = tDriftHz;
fRotateCyclesPerSecond = 0;
bDrawMask = false;
bInvertMask = false;
fMaskDiameterDeg = [];
vfMaskPosPix = []; % 0,0 is middle
fBarWidthDegrees = [];
fContrast = fComponentContrast;

vfDirections = linspace(0, 360, nNumDirections+1);
vfDirections = vfDirections(1:end-1);



for nDir = nNumDirections:-1:1
   vsGratings(nDir) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
                                       [], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
                                       vfDirections(nDir), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
                                       bDrawMask, bInvertMask, fMaskDiameterDeg, ...
                                       vfMaskPosPix, fContrast);
  
end

sSquareGratSeq = STIM_Sequence(nan, vsGratings);

%% Static square-wave gratings
fGratingSFCPD = 0.06;
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



for nDir = nNumDirections:-1:1
   vsGratings_static(nDir) = STIM_SquareGrating(tFrameDuration, tStimulusDuration, nNumRepeats, ...
                                       [], fCyclesPerDegree, fPixelsPerDegree, fBarWidthDegrees, ...
                                       vfDirections(nDir), fShiftCyclesPerSec, fRotateCyclesPerSecond, ...
                                       bDrawMask, bInvertMask, fMaskDiameterDeg, ...
                                       vfMaskPosPix, fContrast);

end

sSquareGratSeq_static = STIM_Sequence(nan, vsGratings_static);



%% Rough Retinotopy stimuli middle


% Generate a 3d array with one square per frame. The first prod(vnNumUnits)
% frames have a white square, the second have a black square
vnUnitSize = [20, 20]; % size of the patches in degrees
vnNumUnits = [5, 4]; % shape of the stimulus grid
nBlack = BlackIndex(hWindow);
nWhite = WhiteIndex(hWindow);
nGrey = round((nWhite + nBlack)/2);
vnSeed = [];
nNumFrames = [];

tfSparseNoiseStimulusBlack = GenerateSparseNoiseStimulus(vnUnitSize, ...
    vnNumUnits, nNumFrames, vnSeed, [nGrey nBlack]);
tfSparseNoiseStimulusWhite = GenerateSparseNoiseStimulus(vnUnitSize, ...
    vnNumUnits, nNumFrames, vnSeed, [nGrey nWhite]);
% Concatenate white and black
tfSparseNoiseStimulus = cat(3, tfSparseNoiseStimulusWhite, ...
    tfSparseNoiseStimulusBlack);
% Permute to have proper X and Y and normalise in the 0-1 range
tfImageStackDeg = permute(tfSparseNoiseStimulus, [2,1,3]) /max(tfSparseNoiseStimulus(:));
% resize in pixels (I have it in degrees)
vfDisplaySizeDeg = vnUnitSize .* vnNumUnits; %vfSizeDegrees;
vfDisplaySizePix = round(vfDisplaySizeDeg .* vfPixelsPerDegree);
tfImageStack = zeros([vfDisplaySizePix, size(tfImageStackDeg, 3)])+0.5;
for nImageID = 1:size(tfImageStackDeg, 3)
    tfImageStack(:,:,nImageID) = imresize(tfImageStackDeg(:,:,nImageID), ...
        vfDisplaySizePix, 'nearest');
end

% set arguments for presentation. Keep nan for ordering so that it is
% dynamically set by the message
tFlashDuration = 0.3;
nNumRepeats = 1;
strStackIdentifier = [];
bInvert = false;
vfCentreOffsetDeg = [0 0];
vfMaskOffsetPix = [];
vnOrdering = nan;
bDrawMask = false;
bInvertMask = false;
fMaskDiameterDeg = [];
vfMaskPosPix = [];


 fAngle = [0,0];
vtFlashDuration = 0.3;%[5 2];


[sRetinotopyR] = STIM_FlashedImageSequence(tFlashDuration, nNumRepeats, ...
    tfImageStack,strStackIdentifier, bInvert, vfDisplaySizeDeg, ...
    vfCentreOffsetDeg, vfPixelsPerDegree, bDrawMask, bInvertMask, ...
    fMaskDiameterDeg, vfMaskOffsetPix, fContrast, vnOrdering);


%% Fullfield (or masked) luminance step

% Generate a 3d array with one square per frame. The first prod(vnNumUnits)
% frames have a white square. no black squares
vnUnitSize = [20, 20]; % size of the patches in degrees
vnNumUnits = [1, 1]; % shape of the stimulus grid
nBlack = BlackIndex(hWindow);
nWhite = WhiteIndex(hWindow);
nGrey = round((nWhite + nBlack)/2);
vnSeed = [];
nNumFrames = [];

tfFlashStimulus = GenerateSparseNoiseStimulus(vnUnitSize, ...
    vnNumUnits, nNumFrames, vnSeed, [nBlack nWhite]);


% Permute to have proper X and Y and normalise in the 0-1 range
tfImageStackDeg = permute(tfFlashStimulus, [2,1]) /max(tfFlashStimulus(:));
% resize in pixels (I have it in degrees)
vfDisplaySizeDeg = vnUnitSize .* vnNumUnits; %vfSizeDegrees;
vfDisplaySizePix = round(vfDisplaySizeDeg .* vfPixelsPerDegree);
tfImageStack = zeros(vfDisplaySizePix)+0.5;
for nImageID = 1:size(tfImageStackDeg, 3)
    tfImageStack(:,:,nImageID) = imresize(tfImageStackDeg(:,:,nImageID), ...
        vfDisplaySizePix, 'nearest');
end

% set arguments for presentation. Keep nan for ordering so that it is
% dynamically set by the message
tFlashDuration = .3;
nNumRepeats = 1;
strStackIdentifier = [];
bInvert = false;
vfCentreOffsetDeg = [0 0];
vfMaskOffsetPix = [];
vnOrdering = nan;
bDrawMask = false;
bInvertMask = false;
fMaskDiameterDeg = [];
vfMaskPosPix = [];
[FFFlash] = STIM_FlashedImageSequence(tFlashDuration, nNumRepeats, ...
    tfImageStack, strStackIdentifier, bInvert, vfDisplaySizeDeg, ...
    vfCentreOffsetDeg, vfPixelsPerDegree, bDrawMask, bInvertMask, ...
    fMaskDiameterDeg, vfMaskOffsetPix, fContrast, vnOrdering);


%% Build stimulus set

vsStimuli = ...
[ vsGratings,sSquareGratSeq,sRetinotopyR ...
,FFFlash,vsGratings_static,sSquareGratSeq_static,...
];
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
