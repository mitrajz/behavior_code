%% Init connection
con=pnet('tcpconnect','131.152.17.102',5000)
%con=pnet('tcpconnect','131.152.17.19',5000)
pnet(con,'setwritetimeout', 2)

%% 1Grating with LaserTrig

tBlank=1; % 3
stimID = 6;
%%% choosing window

 WindowStart=85; %in ms % starts at around 67
 WindowLength=70; %in ms

% WindowStart=1002; %in ms 
% WindowLength=70; %in ms

% WindowStart=1510; %in ms 
% WindowLength=70; %in ms 100



%%%
nrep=20;
SafeFrameStep=17; % in ms
tTrigTime=[WindowStart:SafeFrameStep:WindowStart+WindowLength];
bJitter=1;

nChannels=[0 1 2];
tFinalTimeMat=[];
for i=1:length(nChannels)
tFinalTimeMat=[tFinalTimeMat,[tTrigTime;repmat(nChannels(i),size(tTrigTime))]];
end
tFinalTimeMat=repmat([[nan;nan],tFinalTimeMat],[1,nrep]);

Order=randperm(size(tFinalTimeMat,2));
for i=1:1:length(Order)
    if ~bJitter
    cmd = sprintf('SS PRESENT %d %d 0 2 %d %d',stimID,tBlank, tFinalTimeMat(1,Order(i)),tFinalTimeMat(2,Order(i)))
    else
    cmd = sprintf('SS PRESENT %d %d 0 2 %d %d',stimID,tBlank+(randn/10), tFinalTimeMat(1,Order(i)),tFinalTimeMat(2,Order(i)))
    end
    pnet(con,'printf', '%s\n', cmd)
end
%% Grating test
cmd = 'SS PRESENT 9 2'
pnet(con,'printf', '%s\n', cmd)   
%% retino
nNumStims = 5*4*2;%numpatchesx *numpatchesy * 2
nrepretin = 8; 
tBlankRetin = 0.2;
  
vnStimIDsRand = repmat((1:nNumStims),[1 , nrepretin]);
%vnStimIDsRand = vnStimIDsRand(randperm(nrepretin*nNumStims));


for nStimIndex = (1:numel(vnStimIDsRand))
    nStimID = vnStimIDsRand(nStimIndex);
    cmd = sprintf('SS PRESENT 10 %d 1 0 %d',tBlankRetin ,nStimID)
    pnet(con,'printf', '%s\n', cmd)
end

%% Highretino
nNumStims = 12*10*2;%numpatchesx *numpatchesy * 2
nrepretin = 12;
tBlankRetin = 0.2;
  
vnStimIDsRand = repmat((1:nNumStims),[1 , nrepretin]);
vnStimIDsRand = vnStimIDsRand(randperm(nrepretin*nNumStims));


for nStimIndex = (1:numel(vnStimIDsRand))
    nStimID = vnStimIDsRand(nStimIndex);
    cmd = sprintf('SS PRESENT 11 %d 1 0 %d',tBlankRetin ,nStimID)
    pnet(con,'printf', '%s\n', cmd)
end


%%

cmd = 'SS SHUTDOWN'
pnet(con,'printf', '%s\n', cmd) 
pnet(con, 'close')

%%
% 
% cmd = 'SS FORWARD test'
% pnet(con,'printf', '%s\n', cmd)
