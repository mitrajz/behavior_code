waitSecondBef = 0.4;
stimLengthSecond = 0.02;%0.25
stimAmpls = 5; % 1 to 3
visStim =zeros(size(stimAmpls));%[1,0,1];
waitAfter = 0.4;%20
nRepeat = 40;%10

tic
for nRep = 1:nRepeat
    fprintf('Repeat %i\n', nRep)
    nStims = length(stimAmpls);
    order = randperm(nStims);
    stimAmplsRand = stimAmpls(order);
    stimVisRand = visStim(order);
    sess = daq.createSession('ni');
    sess.IsContinuous = false;
    [ch,     idx] = sess.addAnalogOutputChannel('Dev2', 1, 'Voltage');
    sess.Rate = 50000;

    % add a wait time before
    
    for i = 1: nStims
        sess.queueOutputData(zeros(sess.Rate * waitSecondBef, 1));
        if stimVisRand(i)
            cmd = sprintf('SS PRESENT 9 1 1 0 %i', randi(8))
            pnet(con,'printf', '%s\n', cmd) 
        end
        sess.queueOutputData(zeros(sess.Rate * stimLengthSecond, 1) + ...
            stimAmplsRand(i));
        sess.queueOutputData(zeros(sess.Rate * waitAfter, 1));
    sess.startForeground()
    sess.stop()
    end
 
    
end
toc