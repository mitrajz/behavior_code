function start_gui()


close all
clear all

global BehCtrl
%--------------daq device number, ip, bonsai port
addpath('C:\Users\Behaviour\Documents\MATLAB\Mitra\')
BehCtrl.DevNum = 'Dev1';
BehCtrl.localip = '172.24.170.140';%'131.152.17.81'
BehCtrl.bonsaiport = 4242;
BehCtrl.SS.address = '172.24.170.114';
%--------------define state object
BehCtrl.CurrState = BehState;
%--------------initialize p�arams
BehCtrl.trialnum = 0;
BehCtrl.gotrialnum = 0;
BehCtrl.nogotrialnum = 0;
BehCtrl.misses = 0;
BehCtrl.falsealarms = 0;
BehCtrl.licked = 0;
BehCtrl.MSRate = [];
BehCtrl.FARate = [];

BehCtrl.SL.flag = 0;
BehCtrl.SLS.flag = 0;
BehCtrl.stopped = 0;
%--------------default params
BehCtrl.SS.GreyTimeAv = 3;%1
BehCtrl.SS.GreyTimeCap = 15;% was 8 on 13/1

BehCtrl.LaserProb = 0;

BehCtrl.precision_ms = 20; % speed precision
BehCtrl.LickThresh = .4;
BehCtrl.ValveDuration = 0.05; % in seconds


BehCtrl.AutoRew = true;
BehCtrl.AutoRewDur = 0.6;
BehCtrl.AutoRewValveDuration = 0.05; 


BehCtrl.SS.Goprob = 0.5;
% % old style
% BehCtrl.SS.GoStimId = 10; %28 configure stim server accordingly
% BehCtrl.SS.NoGoStimId = 28; %10
% new style
BehCtrl.SS.GoStimId = 28; %28 configure stim server accordingly
BehCtrl.SS.NoGoStimId = 10; %10

BehCtrl.SS.numdivisions = 72;
BehCtrl.SS.Dur1 = 0; % vertical grating -- approaching corridor
BehCtrl.SS.Dur2 = 0.5; % angled stimulus -- either 45 or -45
BehCtrl.SS.lickonsetlag = 0.1;

%stim laser delays
% BehCtrl.SL.nrep=40;
% BehCtrl.SL.tTrigTime=0:100:600;%0:100:900;%100:200:700;
BehCtrl.SL.nrep=80;% 40 60
BehCtrl.SL.tTrigTime=5:67:500;%[0 5:67:500];%5:67:500
%stim laser short delays
BehCtrl.SLS.nrep=40;%40 60
BehCtrl.SLS.SafeFrameStep=17;
BehCtrl.SLS.tTrigTime=60:BehCtrl.SLS.SafeFrameStep:230;
% grey laser params
BehCtrl.severalgreydelays = 1;
BehCtrl.greydelays = [-2.5 -1.5 -0.5 0 0.04 0.08 0.12 0.16 0.2 0.24];
BehCtrl.lasergreyonduration = 0.05;
%--------------figures
BehCtrl.handles.f = figure('Units','normalized',...
    'Toolbar','figure','CloseRequestFcn',@my_closefcn);

BehCtrl.handles.axspeed=axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.05 0.55 0.3 0.3],'xticklabel',[],'YLimMode','manual','Ylim',[0 200]);
title('Speed - cm/s');

BehCtrl.handles.axlick=axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.05 0.15 0.3 0.3],'xticklabel',[]);
title('Licks');

BehCtrl.handles.FA=axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.7 0.135 0.275 0.05],'xticklabel',[]);
title('FA','FontSize',6);
BehCtrl.handles.MS=axes('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.7 0.025 0.275 0.05],'xticklabel',[]);
title('MS','FontSize',6);
%-------------indicator buttons
% reward zone
BehCtrl.handles.RewZone = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.4 0.55 0.15 0.05],...
    'String','reward zone','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% new trial
BehCtrl.handles.NewTrial = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.6 0.55 0.15 0.05],...
    'String','new trial','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% valve
BehCtrl.handles.Valve = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.4 0.65 0.15 0.05],...
    'String','valve','BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% stim identity
BehCtrl.handles.StimId = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit',...
    'Position', [0.6 0.65 0.15 0.05],...
    'BackgroundColor', 'black','enable','off','FontWeight','bold','FontSize',8);
% misses and false alarms
BehCtrl.handles.misses = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.4 0.1 0.25 0.05],...
    'String',sprintf('misses = %s',num2str(BehCtrl.misses)),'FontWeight','bold','FontSize',8);

BehCtrl.handles.falsealarms = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.4 0.05 0.25 0.05],...
    'String',sprintf('falsealarms = %s',num2str(BehCtrl.misses)),'FontWeight','bold','FontSize',8);

BehCtrl.handles.trialnum = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.4 0 0.25 0.05],...
    'String',sprintf('numtrials = %s',num2str(BehCtrl.trialnum)),'FontWeight','bold','FontSize',8);
%--------------set params
% lick threshold
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.05 0.05 0.25 0.05],'Style','edit','Enable','inactive',...
    'String','lick detection threshold');
BehCtrl.handles.LickThresh = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.3 0.05 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.LickThresh)),'Callback',@changelickthreshold);
% go stimulus probability
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.8 0.25 0.05],'Style','edit','Enable','inactive',...
    'String','go stimulus probability');
BehCtrl.handles.Goprob = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.5 0.75 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.SS.Goprob)),'Callback',@changeGoprob);
% grey time average
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.65 0.8 0.25 0.05],'Style','edit','Enable','inactive',...
    'String','grey time average');
BehCtrl.handles.GreyTimeAv = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.75 0.75 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.SS.GreyTimeAv)),'Callback',@changeGreyTimeAv);

% valve duration
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.4 0.2 0.05],'Style','edit','Enable','inactive',...
    'String','valve duration');
BehCtrl.handles.ValveDuration = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.6 0.4 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.ValveDuration)),'Callback',@changeValveDuration);
% auto reward
% setting on or off:
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.3 0.15 0.05],'Style','edit','Enable','inactive',...
    'String','auto reward');
BehCtrl.handles.AutoRew = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.55 0.3 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.AutoRew)),'Callback',@changeAutoRew);
% autoreward delay
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.25 0.2 0.05],'Style','edit','Enable','inactive',...
    'String','auto reward delay');
BehCtrl.handles.AutoRewDur = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.6 0.25 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.AutoRewDur)),'Callback',@changeAutoRewDur);
% autoreward valve duration
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.4 0.2 0.25 0.05],'Style','edit','Enable','inactive',...
    'String','auto reward valve duration');
BehCtrl.handles.AutoRewValveDuration  = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.65 0.2 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.AutoRewValveDuration)),'Callback',@changeAutoRewValveDuration);
%--------------manual valve opening and closing

uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
'Position', [0.8 0.6 0.1 0.05],...
'String','valve','BackgroundColor', 'cyan','enable','on','Callback', @OpenValveManual,'FontWeight','bold');

uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
'Position', [0.8 0.65 0.12 0.05],...
'String','valveClose ','BackgroundColor', 'magenta','enable','on','Callback', @CloseValveManual,'FontWeight','bold');
%-------------- rotating the stimulus
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.7 0.45 0.3 0.05],'Style','edit','Enable','inactive',...
    'String','rotate grating counter clockwise');
% counterclockwise
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
'Position', [0.8 0.4 0.1 0.05],...
'String','+1','BackgroundColor', 'yellow','enable','on','Callback', @increasegostimid,'FontWeight','bold');

% clockwise
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
'Position', [0.8 0.35 0.1 0.05],...
'String','-1','BackgroundColor', 'yellow','enable','on','Callback', @decreasegostimid,'FontWeight','bold');

% show the current go stim: direction of movement
BehCtrl.handles.goid = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.8 0.3 0.1 0.05],'Style','edit','Enable','inactive',...
 'String',num2str(BehCtrl.SS.GoStimId));%90+ 
%   'String',num2str((BehCtrl.SS.GoStimId-1)*360/BehCtrl.SS.numdivisions));%90+
 
%--------------start and stop

BehCtrl.handles.start = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.9 0.9 0.1 0.1],...
    'String','Start','BackgroundColor', 'green','enable','on','Callback', @my_startfcn,'FontWeight','bold');


BehCtrl.handles.stop = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.9 0.8 0.1 0.1],...
    'String','Stop','BackgroundColor', 'red','enable','off','Callback', @my_stopfcn,'FontWeight','bold');
%--------------laser

% laser during grey
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.6 0.9 0.25 0.05],'Style','edit','Enable','inactive',...
    'String','grey laser probability');
BehCtrl.handles.LaserProb  = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.7 0.85 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.LaserProb)),'Callback',@changeLaserProb);
% laser during stimulus
BehCtrl.handles.StimLaser = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.05 0.9 0.12 0.05],'Style','pushbutton','enable','on',...
    'String','stim laser ','BackgroundColor','white','FontWeight','bold','Callback',@setStimLaser);
BehCtrl.handles.StimLaserTrRem = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.17 0.9 0.05 0.05],'Style','edit','Enable','inactive');

% laser during stimulus short
BehCtrl.handles.StimLaserS = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.25 0.9 0.12 0.05],'Style','pushbutton','enable','on',...
    'String','stim laser S','BackgroundColor','white','FontWeight','bold','Callback',@setStimLaserS);
BehCtrl.handles.StimLaserSTrRem = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.37 0.9 0.05 0.05],'Style','edit','Enable','inactive');


%--------------initialization
initialize_everything

end

function my_closefcn(src,event)
global BehCtrl

if ~BehCtrl.stopped
    my_stopfcn(src,event);
end

cmd = 'SS SHUTDOWN';
try
    pnet(BehCtrl.SS.con,'printf', '%s\n', cmd)
    pnet(BehCtrl.SS.con, 'close')
    fprintf('stimserver shut down successfully\n')
    fprintf(BehCtrl.fmID,'%s\n\r',cmd);    
catch
    fprintf('couldnt shut stimserver down\n')
    
end
delete(gcf);
end
function initialize_everything
global BehCtrl

%---- open a ni session and set up counter
BehCtrl.sess = daq.createSession('ni');
counterch = addCounterInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ctr0','Position'); % X1 coding, alright?
counterch.EncoderType = 'X1';
lickch = addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai7','Voltage');
lickch.TerminalConfig = 'Differential';%'Differential';
addAnalogOutputChannel(BehCtrl.sess,BehCtrl.DevNum,'ao0','Voltage');
addAnalogOutputChannel(BehCtrl.sess,BehCtrl.DevNum,'ao1','Voltage');
% configuring the digital session: no background, just single scans for
% opening the valve

BehCtrl.Digsess = daq.createSession('ni');
addDigitalChannel(BehCtrl.Digsess,BehCtrl.DevNum,'port0/line3:5','OutputOnly');
% channel 4 is valveout, channel 3 was originally meant for lasergrey, but now,
% I use it as a copy of valve to send to oe (3=4)
%---- initiate bonsai udp connection and send a signal to start rec
BehCtrl.udpcon = udp(BehCtrl.localip, BehCtrl.bonsaiport);
fopen(BehCtrl.udpcon);
%---- initiate communication with stimserver
BehCtrl.SS.con=pnet('tcpconnect',BehCtrl.SS.address,5000);
%---- listening to ni input and generating output
BehCtrl.sess.IsContinuous = 1;
BehCtrl.sess.IsNotifyWhenScansQueuedBelowAuto = false;
BehCtrl.sess.NotifyWhenDataAvailableExceeds = 100;
BehCtrl.sess.NotifyWhenScansQueuedBelow = BehCtrl.sess.NotifyWhenDataAvailableExceeds;
BehCtrl.lh = addlistener(BehCtrl.sess,'DataAvailable',@updateplots);

queueOutputData(BehCtrl.sess,[zeros(2,1000),repmat(3.99,[2,1])]');
BehCtrl.lh2 = addlistener(BehCtrl.sess,'DataRequired',@(src,event)disp('DATAREQUIRED')); % this is never gonna be executed. Could be implemented better

%---- listeners to state
BehCtrl.l1 = addlistener(BehCtrl.CurrState,'TrialStart',@SendStimCmnd);
BehCtrl.l2 = addlistener(BehCtrl.CurrState,'RewZone',@RewardZone);
BehCtrl.l3 = addlistener(BehCtrl.CurrState,'TrialEnd',@RestartTrial);
BehCtrl.l4 = addlistener(BehCtrl.CurrState,'FAZone',@FalseAlarmZone);
%---- define timer
BehCtrl.tRew=timer('TimerFcn',@(src,event)triggerRewZone(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('trew stop func'));
BehCtrl.tFA=timer('TimerFcn',@(src,event)triggerFAZone(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tFA stop func'));
BehCtrl.tEnd=timer('TimerFcn',@(src,event)triggerTrialEnd(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tend stop func'));
BehCtrl.tAux=timer('TimerFcn',@StartTimers,'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('taux stop func'),'StartDelay',0);

BehCtrl.tNewTrialIndc=timer('TimerFcn',@(src,event)set(BehCtrl.handles.NewTrial, 'BackgroundColor','black'),'BusyMode','error','TasksToExecute',1,'StartFcn',@(src,event)set(BehCtrl.handles.NewTrial, 'BackgroundColor','yellow'),'StartDelay',.1);
BehCtrl.tValveOpen=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','yellow'),...
    'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0,0]),'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.ValveDuration,...
    'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));

BehCtrl.tValveOpenAutoRew=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','white'),...
    'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0,0]),'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.AutoRewValveDuration,...
    'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));

BehCtrl.tAutoRew=timer('TimerFcn',@OpenValveAutoRew,'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.AutoRewDur,'StopFcn',@(src,event)disp('tautorew stop func'));

BehCtrl.tLaserOff=timer('TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0,0]),'TasksToExecute',1,'StartDelay',BehCtrl.lasergreyonduration); % 5ms laser is on: in practice 10 ms -- 

BehCtrl.tLaser=timer('TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[1,0,0]),'TasksToExecute',1,'StopFcn',@(src,event)start(BehCtrl.tLaserOff));

%----- preparing log file to record all messages sent to oe
messagefilename = datestr(now,'dd-mm-yy-HH-MM-ss');
BehCtrl.fmID = fopen(['E:\Mitra\oemessages\',messagefilename,'.dat'],'a');


end
function my_startfcn(src,event)
global BehCtrl
%---- update ui
set(BehCtrl.handles.start, 'enable','off')
set(BehCtrl.handles.stop, 'enable','on')
cla(BehCtrl.handles.axspeed)
drawnow;
%----- start bonsai rec
oscsend(BehCtrl.udpcon,'/bonsai','i', 1);
pnet(BehCtrl.SS.con,'printf', '%s\n','SS FORWARD visual block started');
fprintf(BehCtrl.fmID,'%s\n\r','SS FORWARD visual block started');

fprintf(BehCtrl.fmID,'%s %d\n\r','Go stim id is', BehCtrl.SS.GoStimId);
fprintf(BehCtrl.fmID,'%s %d\n\r','NoGo stim is', BehCtrl.SS.NoGoStimId);
%----- start first trial
tic
triggerTrialStart(BehCtrl.CurrState);
%-----
BehCtrl.sess.startBackground()

uiwait()
delete(BehCtrl.lh)
delete(BehCtrl.lh2)
delete(BehCtrl.l1)
delete(BehCtrl.l2)
delete(BehCtrl.l3)
delete(BehCtrl.l4)
if  isfield(BehCtrl,'licklistener')
delete(BehCtrl.licklistener)
end
if  isfield(BehCtrl,'FAlicklistener')
delete(BehCtrl.FAlicklistener)
end
delete(BehCtrl.tRew)
delete(BehCtrl.tEnd)
delete(BehCtrl.tAux)
delete(BehCtrl.tNewTrialIndc)
delete(BehCtrl.tValveOpen)
delete(BehCtrl.tValveOpenAutoRew)
delete(BehCtrl.tAutoRew)
delete(BehCtrl.tFA)

end
function SendStimCmnd (src,event)
global BehCtrl
% new trial indicator and counts
start(BehCtrl.tNewTrialIndc);
BehCtrl.trialnum = BehCtrl.trialnum + 1;
set(BehCtrl.handles.trialnum ,'String',sprintf('numtrials = %s',num2str(BehCtrl.trialnum)));


GetVisStimParams

%BehCtrl.SS.cmd = sprintf('SS PRESENT %s %s 1 0 [%s,%s]',BehCtrl.SS.StimId,BehCtrl.SS.GreyTime,BehCtrl.SS.Dur1,BehCtrl.SS.Dur2);
BehCtrl.SS.cmd = sprintf('SS PRESENT %f %s 0 0',BehCtrl.SS.StimId,num2str(BehCtrl.SS.GreyTime));

% if laser during visual stimulus
if BehCtrl.SL.flag == 1
    if ~isempty(BehCtrl.SL.Order)
        BehCtrl.SS.cmd = sprintf('SS PRESENT %f %s 0 2 %d %d',BehCtrl.SS.StimId,num2str(BehCtrl.SS.GreyTime),...
           BehCtrl.SL.tFinalTimeMat(1, BehCtrl.SL.Order(end)), BehCtrl.SL.tFinalTimeMat(2, BehCtrl.SL.Order(end)));
     
        BehCtrl.SS.cmd
        
         BehCtrl.SL.Order(end) = [];
         set(BehCtrl.handles.StimLaserTrRem,'String',sprintf('%s',num2str(length(BehCtrl.SL.Order))))
    else
        BehCtrl.SL.flag = 0;
        
        set(BehCtrl.handles.StimLaser,'enable','on');
        set(BehCtrl.handles.StimLaser,'BackgroundColor','white');
        %  reactivating grey laser
        set(BehCtrl.handles.LaserProb,'Enable','on');
    end
elseif BehCtrl.SLS.flag == 1
    if ~isempty(BehCtrl.SLS.Order)
        BehCtrl.SS.cmd = sprintf('SS PRESENT %f %s 0 2 %d %d',BehCtrl.SS.StimId,num2str(BehCtrl.SS.GreyTime),...
           BehCtrl.SLS.tFinalTimeMat(1, BehCtrl.SLS.Order(end)), BehCtrl.SLS.tFinalTimeMat(2, BehCtrl.SLS.Order(end)));
     
        BehCtrl.SS.cmd
        
         BehCtrl.SLS.Order(end) = [];
         set(BehCtrl.handles.StimLaserSTrRem,'String',sprintf('%s',num2str(length(BehCtrl.SLS.Order))))
    else
        BehCtrl.SLS.flag = 0;
        
        set(BehCtrl.handles.StimLaserS,'enable','on');
        set(BehCtrl.handles.StimLaserS,'BackgroundColor','white');
        %  reactivating grey laser
        set(BehCtrl.handles.LaserProb,'Enable','on');
    end
    
end
%

pnet(BehCtrl.SS.con,'printf', '%s\n', BehCtrl.SS.cmd);
fprintf(BehCtrl.fmID,'%s\n\r',BehCtrl.SS.cmd);
%time to (potential) reward zone
BehCtrl.TimeToRZ = BehCtrl.SS.GreyTime + BehCtrl.SS.Dur1 + BehCtrl.SS.lickonsetlag;
%time to trial end
BehCtrl.TimeToTE = BehCtrl.SS.GreyTime + BehCtrl.SS.Dur1 + max(BehCtrl.SS.Dur2,BehCtrl.AutoRewDur);


stop(BehCtrl.tRew);
stop(BehCtrl.tEnd);

start(BehCtrl.tAux)

end
function GetVisStimParams
global BehCtrl

if rand < BehCtrl.SS.Goprob
    BehCtrl.SS.StimId = BehCtrl.SS.GoStimId;
    set(BehCtrl.handles.StimId,'String','Go');
    BehCtrl.gotrialnum = BehCtrl.gotrialnum + 1;
else
    BehCtrl.SS.StimId = BehCtrl.SS.NoGoStimId;
    set(BehCtrl.handles.StimId,'String','NoGo');
    BehCtrl.nogotrialnum = BehCtrl.nogotrialnum + 1;
end
% assuming these values dont depend on the stimulus type (go or nogo)
BehCtrl.SS.GreyTime = 1000;
while BehCtrl.SS.GreyTime > BehCtrl.SS.GreyTimeCap
    BehCtrl.SS.GreyTime = 0.5 + exprnd(BehCtrl.SS.GreyTimeAv-0.5);% BehCtrl.SS.GreyTimeAv;%
end

% if laser is needed
if (rand < BehCtrl.LaserProb)
    if  BehCtrl.severalgreydelays
        BehCtrl.tLaser.StartDelay = BehCtrl.SS.GreyTime + BehCtrl.greydelays(randi(length(BehCtrl.greydelays))); % in the middle of the grey period
    else
        BehCtrl.tLaser.StartDelay = BehCtrl.SS.GreyTime/2;
    end
    start(BehCtrl.tLaser)
end

end
function StartTimers(src,event)
global BehCtrl

BehCtrl.tRew.StartDelay = BehCtrl.TimeToRZ;
BehCtrl.tEnd.StartDelay = BehCtrl.TimeToTE;

BehCtrl.tFA.startDelay = BehCtrl.TimeToRZ;

if BehCtrl.SS.StimId == BehCtrl.SS.GoStimId
    start(BehCtrl.tRew);
    disp('tRew timer started')
elseif BehCtrl.SS.StimId == BehCtrl.SS.NoGoStimId
    start(BehCtrl.tFA);
    disp('tRew timer started')
end
start(BehCtrl.tEnd);
disp('tEnd timer started')


end
function RewardZone(src,event)
global BehCtrl
toc
disp('Rew zone')
BehCtrl.licklistener = addlistener(BehCtrl.CurrState,'MouseLicked',@OpenValve);
set(BehCtrl.handles.RewZone,'BackgroundColor','yellow')
if BehCtrl.AutoRew 
    start(BehCtrl.tAutoRew)
end

end
function FalseAlarmZone(src,event)
global BehCtrl
BehCtrl.FAlicklistener = addlistener(BehCtrl.CurrState,'MouseLicked',@countasFA);
end
function countasFA(src,event)
global BehCtrl
BehCtrl.licked = 1;
delete(BehCtrl.FAlicklistener)
end
function OpenValve(src,event)
global BehCtrl
disp('valve opened')
BehCtrl.licked = 1;
outputSingleScan(BehCtrl.Digsess,[1,1,0])
stop(BehCtrl.tAutoRew)
delete(BehCtrl.licklistener)
start(BehCtrl.tValveOpen)
end
function OpenValveAutoRew(src,event)
global BehCtrl
disp('valve auto opened')
outputSingleScan(BehCtrl.Digsess,[1,1,0])
delete(BehCtrl.licklistener)
start(BehCtrl.tValveOpenAutoRew)
end
function OpenValveManual(src,event)
global BehCtrl
disp('valve manually opened')
outputSingleScan(BehCtrl.Digsess,[1,1,0])
start(BehCtrl.tValveOpen)
end
function CloseValveManual(src,event)
global BehCtrl
disp('valve manually closed')
outputSingleScan(BehCtrl.Digsess,[0,0,0])
end
function RestartTrial(src,event)
global BehCtrl
toc
if  isfield(BehCtrl,'licklistener') % if the previous trial was a go and there was no reward or auto reward to delete the licklistener
    delete(BehCtrl.licklistener)
    disp('licklistener deleted')
end
if  isfield(BehCtrl,'FAlicklistener') 
    delete(BehCtrl.FAlicklistener)
    disp('FAlicklistener deleted')
end
% update FA and misses
if (BehCtrl.SS.StimId == BehCtrl.SS.GoStimId) && ~BehCtrl.licked
    BehCtrl.misses = BehCtrl.misses + 1;
    set(BehCtrl.handles.misses,'String',sprintf('misses = %s',num2str(BehCtrl.misses)));
    pnet(BehCtrl.SS.con,'printf', '%s\n','SS FORWARD visual trial: miss');   
    fprintf(BehCtrl.fmID,'%s\n\r','SS FORWARD visual trial: miss');
elseif (BehCtrl.SS.StimId == BehCtrl.SS.NoGoStimId) && BehCtrl.licked
    BehCtrl.falsealarms = BehCtrl.falsealarms + 1;
    set(BehCtrl.handles.falsealarms,'String',sprintf('falsealarms = %s',num2str(BehCtrl.falsealarms)));
    pnet(BehCtrl.SS.con,'printf', '%s\n','SS FORWARD visual trial: false alarm');  
    fprintf(BehCtrl.fmID,'%s\n\r','SS FORWARD visual trial: false alarm');
else
    pnet(BehCtrl.SS.con,'printf', '%s\n','SS FORWARD visual trial: correct');  
    fprintf(BehCtrl.fmID,'%s\n\r','SS FORWARD visual trial: correct');
end
% update missrate and farate plots
BehCtrl.MSRate = [BehCtrl.MSRate , BehCtrl.misses / BehCtrl.gotrialnum];
BehCtrl.FARate = [BehCtrl.FARate , BehCtrl.falsealarms / BehCtrl.nogotrialnum]; % are these 2 lines better here or inside if?

if (numel(BehCtrl.MSRate) > 50) && (numel(BehCtrl.FARate) > 50)
    plot(BehCtrl.handles.MS, BehCtrl.MSRate(end-50:end),'r*-')
    plot(BehCtrl.handles.FA, BehCtrl.FARate(end-50:end),'b*-')
else
    plot(BehCtrl.handles.MS, BehCtrl.MSRate,'r*-')
    plot(BehCtrl.handles.FA, BehCtrl.FARate,'b*-')
end
drawnow
%
set(BehCtrl.handles.RewZone,'BackgroundColor','black')
% reset licking flag
BehCtrl.licked = 0;
% start new trial
tic
triggerTrialStart(BehCtrl.CurrState)
end
function updateplots(src,event)
global BehCtrl
% plot speed
%BehCtrl.speed = (diff(event.Data(:,1)) * 0.0605)/(1/BehCtrl.sess.Rate);
%disp('updating plots')
BehCtrl.speed = ((event.Data((BehCtrl.precision_ms+1):1:end,1) - event.Data(1:1:(end-BehCtrl.precision_ms),1)) * pi*20/1024)/...
    (BehCtrl.precision_ms/BehCtrl.sess.Rate); % speed calc is bad, also better to divide by the difference between the actual timestamps
plot(BehCtrl.handles.axspeed,BehCtrl.speed);
set(BehCtrl.handles.axspeed,'YLimMode','manual','Ylim',[0 200])
drawnow

%fprintf('%f\n',toc)
% plot lick
BehCtrl.lickcont = event.Data(:,2);
BehCtrl.lick = (sign(BehCtrl.lickcont - BehCtrl.LickThresh)+1)/2 | (BehCtrl.lickcont<=0.05);
plot(BehCtrl.handles.axlick,[BehCtrl.lickcont,BehCtrl.lick]);
set(BehCtrl.handles.axlick,'YLimMode','manual','Ylim',[0 1])
drawnow
if sum(BehCtrl.lick) > 0
    triggerMouseLicked(BehCtrl.CurrState)
end

% send position info to output
queueOutputData(BehCtrl.sess,[mod(event.Data(:,1)* 0.0605,4) , BehCtrl.lick]) % in cms, mod 4?
%

end 
function setStimLaser(src,event)
global BehCtrl
set(BehCtrl.handles.StimLaser,'enable','off');
set(BehCtrl.handles.StimLaser,'BackgroundColor','blue');
% inactivating frey laser
set(BehCtrl.handles.LaserProb,'Enable','off');
BehCtrl.LaserProb = 0;
set(BehCtrl.handles.LaserProb,'String','0');
%
BehCtrl.SL.flag = 1;
% set delays for laser
nChannels=[0]; % no fine scale delay needed: up to 17 ms jitter 

tFinalTimeMat=[];
for i=1:length(nChannels)
tFinalTimeMat=[tFinalTimeMat,[BehCtrl.SL.tTrigTime;repmat(nChannels(i),size(BehCtrl.SL.tTrigTime))]];
end
BehCtrl.SL.tFinalTimeMat=repmat([[nan;nan],tFinalTimeMat],[1,BehCtrl.SL.nrep]);

BehCtrl.SL.Order=randperm(size(BehCtrl.SL.tFinalTimeMat,2));
set(BehCtrl.handles.StimLaserTrRem,'String',sprintf('%s',num2str(length(BehCtrl.SL.Order))))

end
function setStimLaserS(src,event)
global BehCtrl
set(BehCtrl.handles.StimLaserS,'enable','off');
set(BehCtrl.handles.StimLaserS,'BackgroundColor','blue');
% inactivating frey laser
set(BehCtrl.handles.LaserProb,'Enable','off');
BehCtrl.LaserProb = 0;
set(BehCtrl.handles.LaserProb,'String','0');
%
BehCtrl.SLS.flag = 1;
% set delays for laser
nChannels=[0 1 2]; % no fine scale delay needed: up to 17 ms jitter 

tFinalTimeMat=[];
for i=1:length(nChannels)
tFinalTimeMat=[tFinalTimeMat,[BehCtrl.SLS.tTrigTime;repmat(nChannels(i),size(BehCtrl.SLS.tTrigTime))]];
end
BehCtrl.SLS.tFinalTimeMat=repmat([[nan;nan],tFinalTimeMat],[1,BehCtrl.SLS.nrep]);

BehCtrl.SLS.Order=randperm(size(BehCtrl.SLS.tFinalTimeMat,2));
set(BehCtrl.handles.StimLaserSTrRem,'String',sprintf('%s',num2str(length(BehCtrl.SLS.Order))))

end

function increasegostimid (src,event)
global BehCtrl
desiredgo = mod(BehCtrl.SS.GoStimId+1,BehCtrl.SS.numdivisions/2);
desirednogo =  mod(BehCtrl.SS.NoGoStimId+1,BehCtrl.SS.numdivisions/2);
if desiredgo == 0; desiredgo=BehCtrl.SS.numdivisions/2;end
if desirednogo == 0; desirednogo=BehCtrl.SS.numdivisions/2;end
BehCtrl.SS.GoStimId = desiredgo;
BehCtrl.SS.NoGoStimId = desirednogo;

fprintf(BehCtrl.fmID,'%s %d\n\r','Go stim id changed to', BehCtrl.SS.GoStimId);
fprintf(BehCtrl.fmID,'%s %d\n\r','NoGo stim id changed to', BehCtrl.SS.NoGoStimId);

% update gui indicator
%set(BehCtrl.handles.goid,'String',num2str(90+BehCtrl.SS.GoStimId*360/BehCtrl.SS.numdivisions))
set(BehCtrl.handles.goid,'String',num2str(BehCtrl.SS.GoStimId))

end

function decreasegostimid (src,event)
global BehCtrl
desiredgo = mod(BehCtrl.SS.GoStimId-1,BehCtrl.SS.numdivisions/2);
desirednogo =  mod(BehCtrl.SS.NoGoStimId-1,BehCtrl.SS.numdivisions/2);
if desiredgo == 0; desiredgo=BehCtrl.SS.numdivisions/2;end
if desirednogo == 0; desirednogo=BehCtrl.SS.numdivisions/2;end
BehCtrl.SS.GoStimId = desiredgo;
BehCtrl.SS.NoGoStimId = desirednogo;

fprintf(BehCtrl.fmID,'%s %d\n\r','Go stim id changed to', BehCtrl.SS.GoStimId);
fprintf(BehCtrl.fmID,'%s %d\n\r','NoGo stim id changed to', BehCtrl.SS.NoGoStimId);

% update gui indicator
%set(BehCtrl.handles.goid,'String',num2str(90+BehCtrl.SS.GoStimId*360/BehCtrl.SS.numdivisions))
set(BehCtrl.handles.goid,'String',num2str(BehCtrl.SS.GoStimId))

end

function changelickthreshold(src,event)
global BehCtrl
BehCtrl.LickThresh = str2double(get(BehCtrl.handles.LickThresh,'String'));
str2double(get(BehCtrl.handles.LickThresh,'String'))
end
function changeGoprob(src,event)
global BehCtrl
BehCtrl.SS.Goprob = str2double(get(BehCtrl.handles.Goprob,'String'));

end
function changeValveDuration(src,event)
global BehCtrl
BehCtrl.ValveDuration = str2double(get(BehCtrl.handles.ValveDuration,'String'));
set(BehCtrl.tValveOpen,'StartDelay',BehCtrl.ValveDuration);
end
function changeAutoRew(src,event)
global BehCtrl
BehCtrl.AutoRew = logical(str2double(get(BehCtrl.handles.AutoRew,'String')));
end
function changeAutoRewDur(src,event)
global BehCtrl
BehCtrl.AutoRewDur = str2double(get(BehCtrl.handles.AutoRewDur,'String'));
set(BehCtrl.tAutoRew,'StartDelay',BehCtrl.AutoRewDur);
end
function changeAutoRewValveDuration(src,event)
global BehCtrl
BehCtrl.AutoRewValveDuration = str2double(get(BehCtrl.handles.AutoRewValveDuration,'String'));
set(BehCtrl.tValveOpenAutoRew,'StartDelay',BehCtrl.AutoRewValveDuration);
end
function changeGreyTimeAv(src,event)
global BehCtrl
BehCtrl.SS.GreyTimeAv = str2double(get(BehCtrl.handles.GreyTimeAv,'String'));
end
function changeLaserProb(src,event)
global BehCtrl
BehCtrl.LaserProb = str2double(get(BehCtrl.handles.LaserProb,'String'));
end
function my_stopfcn(src,event)
global BehCtrl

% close oe message file
fclose(BehCtrl.fmID);

if  isfield(BehCtrl,'licklistener')
delete(BehCtrl.licklistener)
end

stop(timerfind)
delete(timerfind)

set(BehCtrl.handles.stop, 'enable','off')
stop(BehCtrl.sess); % how to properly close it?
stop(BehCtrl.Digsess);
BehCtrl = rmfield(BehCtrl,'sess');
BehCtrl = rmfield(BehCtrl,'Digsess');

% stop bonsai recording
oscsend(BehCtrl.udpcon,'/bonsai','i', 0);
fclose(BehCtrl.udpcon);
% enable on?
fprintf('stopped\n')
% what else needs cleaning?
BehCtrl.stopped = 1;
end