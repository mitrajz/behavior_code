
function retin_drkLaser

%% Init connection
con=pnet('tcpconnect','131.152.17.102',5000)
%con=pnet('tcpconnect','131.152.17.19',5000)
pnet(con,'setwritetimeout', 2)
%% retin
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
%% laser in dark wrong
tLaserOff=timer('TimerFcn',@(src,event)outputSingleScan(sess,0),'TasksToExecute',1,'StartDelay',0.005); 
tLaser=timer('TimerFcn',@timrfunc,'TasksToExecute',1,...
    'ExecutionMode','fixedSpacing','Period',1);



sess = daq.createSession('ni');
sess.IsContinuous = false;
sess.DurationInSeconds = 1;
addDigitalChannel(sess,'Dev2','port0/line3','OutputOnly');

    

 sess.startForeground()
 sess.stop()
    
%% laser in dark wrong
waitSecondBef = 0.4;
stimLengthSecond = 0.02;%0.25
stimAmpls = 5; % 1 to 3

waitAfter = 0.4;%20
nRepeat = 40;%10

tic
for nRep = 1:nRepeat
    fprintf('Repeat %i\n', nRep)
    nStims = length(stimAmpls);
    order = randperm(nStims);
    stimAmplsRand = stimAmpls(order);
    sess = daq.createSession('ni');
    sess.IsContinuous = false;
    [ch,     idx] = sess.addAnalogOutputChannel('Dev2', 1, 'Voltage');
    sess.Rate = 50000;

    % add a wait time before
    
    for i = 1: nStims
        sess.queueOutputData(zeros(sess.Rate * waitSecondBef, 1));

        sess.queueOutputData(zeros(sess.Rate * stimLengthSecond, 1) + ...
            stimAmplsRand(i));
        
        
       sess.queueOutputData(zeros(sess.Rate * waitAfter, 1));
       
    sess.startForeground()
    sess.stop()
    end
 
    
end
toc
%%
cmd = 'SS SHUTDOWN'
pnet(con,'printf', '%s\n', cmd) 
pnet(con, 'close')

clear all
end
    function timrfunc(src,event,sess,tLaserOff)
        outputSingleScan(sess,1)
        start(tLaserOff)
    end