%% Init connection
con=pnet('tcpconnect','172.24.170.114',5000)
%con=pnet('tcpconnect','131.152.17.19',5000)
pnet(con,'setwritetimeout', 2)

%% ordered retino - online
nNumStims = 5*4*2;%numpatchesx *numpatchesy * 2
nrepretin = 6; 
tBlankRetin = 0.2;
  
vnStimIDsRand = repmat((1:nNumStims),[1 , nrepretin]);
%vnStimIDsRand = vnStimIDsRand(randperm(nrepretin*nNumStims));


for nStimIndex = (1:numel(vnStimIDsRand))
    nStimID = vnStimIDsRand(nStimIndex);
    cmd = sprintf('SS PRESENT 73 %d 1 0 %d',tBlankRetin ,nStimID)
    pnet(con,'printf', '%s\n', cmd)
end

%% retino

retinofilename = datestr(now,'dd-mm-yy-HH-MM-ss');
frID = fopen(['C:\Users\visstim\Documents\MATLAB\Mitra\oemessages\retino_',retinofilename,'.txt'],'a');


nNumStims = 5*4*2;%numpatchesx *numpatchesy * 2
nrepretin = 8; 
tBlankRetin = 0.2;
  
vnStimIDsRand = repmat((1:nNumStims),[1 , nrepretin]);
vnStimIDsRand = vnStimIDsRand(randperm(nrepretin*nNumStims));


for nStimIndex = (1:numel(vnStimIDsRand))
    nStimID = vnStimIDsRand(nStimIndex);
    cmd = sprintf('SS PRESENT 10 %d 1 0 %d',tBlankRetin ,nStimID)
    fprintf(frID,'%s\n',cmd);
    pnet(con,'printf', '%s\n', cmd)
end

fclose(frID);
%%

cmd = 'SS SHUTDOWN'
pnet(con,'printf', '%s\n', cmd) 
pnet(con, 'close')

%%
% 
% cmd = 'SS FORWARD test'
% pnet(con,'printf', '%s\n', cmd)
