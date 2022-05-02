function audio_gui()

close all
clear all

global BehCtrl
%--------------daq device number, ip, bonsai port
BehCtrl.DevNum = 'Dev2';
BehCtrl.localip = '131.152.17.82';
BehCtrl.bonsaiport = 4242;
%--------------define state object
BehCtrl.CurrState = BehState;
%--------------initialize p�arams
BehCtrl.trialnum = 0;
BehCtrl.gotrialnum = 0;
BehCtrl.nogotrialnum = 0;
BehCtrl.audiotrialnum = 0;
BehCtrl.misses = 0;
BehCtrl.falsealarms = 0;
BehCtrl.licked = 0;
BehCtrl.MSRate = [];
BehCtrl.FARate = [];

BehCtrl.SL.flag = 0;
BehCtrl.stopped = 0;
%--------------default params
BehCtrl.SS.GreyTimeAv = 3;

BehCtrl.LaserProb = 0;

BehCtrl.precision_ms = 20; % speed precision
BehCtrl.LickThresh = 1.5;
BehCtrl.ValveDuration = 0.05; % in seconds


BehCtrl.AutoRew = true;
BehCtrl.AutoRewDur = .8;
BehCtrl.AutoRewValveDuration = 0.025; 


BehCtrl.SS.Goprob = 0.5;

BehCtrl.SS.GoStimId = 13; % configure stim server accordingly
BehCtrl.SS.NoGoStimId = 15;

BehCtrl.AudioPeriod = 7;
BehCtrl.AudioPeriodJitter = 10; %insec
BehCtrl.PAudioReward = 0.2;
%stim laser delays
BehCtrl.SL.nrep=20;
BehCtrl.SL.tTrigTime=0:100:900;%100:200:700;
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
    'Position', [0.4 0.15 0.25 0.05],...
    'String',sprintf('misses = %s',num2str(BehCtrl.misses)),'FontWeight','bold','FontSize',8);

BehCtrl.handles.falsealarms = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.4 0.1 0.25 0.05],...
    'String',sprintf('falsealarms = %s',num2str(BehCtrl.misses)),'FontWeight','bold','FontSize',8);

BehCtrl.handles.trialnum = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.4 0.05 0.25 0.05],...
    'String',sprintf('numtrials = %s',num2str(BehCtrl.trialnum)),'FontWeight','bold','FontSize',8);

BehCtrl.handles.audiotrialnum = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','edit','Enable','inactive',...
    'Position', [0.4 0 0.25 0.05],...
    'String',sprintf('numtrials = %s',num2str(BehCtrl.audiotrialnum)),'FontWeight','bold','FontSize',8);

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

%--------------start and stop

BehCtrl.handles.start = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.9 0.9 0.1 0.1],...
    'String','Start','BackgroundColor', 'green','enable','on','Callback', @my_startfcn,'FontWeight','bold');


BehCtrl.handles.stop = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Style','pushbutton',...
    'Position', [0.9 0.8 0.1 0.1],...
    'String','Stop','BackgroundColor', 'red','enable','off','Callback', @my_stopfcn,'FontWeight','bold');
% -------------audioperiod
BehCtrl.handles.AudioPeriod = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.95 0.5 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.AudioPeriod)),'Callback',@changeAudioPeriod);
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.8 0.5 0.15 0.05],'Style','edit',...
    'Enable','inactive','String','audio trial length');

BehCtrl.handles.PAudioReward = uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.95 0.4 0.05 0.05],'Style','edit',...
    'String',sprintf('%s',num2str(BehCtrl.PAudioReward)),'Callback',@changePAudioReward);
uicontrol('Parent',BehCtrl.handles.f,'Units','normalized','Position',[0.8 0.4 0.15 0.05],'Style','edit',...
    'Enable','inactive','String','audio reward probability');

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
catch
    fprintf('couldnt shut stimserver down\n')
    
end
delete(gcf);
end
function initialize_everything
global BehCtrl

%---- sound object
BehCtrl.SoundObjRew = audioplayer(sin(2*pi*12000*(0:.000005:1)),200000);
BehCtrl.SoundObjNoRew = audioplayer(sin(2*pi*8000*(0:.000005:1)),200000);
%---- open a ni session and set up counter
BehCtrl.sess = daq.createSession('ni');
addCounterInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ctr0','Position'); % X1 coding, alright?
addAnalogInputChannel(BehCtrl.sess,BehCtrl.DevNum,'ai7','Voltage');
%ch.TerminalConfig = 'SingleEnded'
addAnalogOutputChannel(BehCtrl.sess,BehCtrl.DevNum,'ao0','Voltage');
addAnalogOutputChannel(BehCtrl.sess,BehCtrl.DevNum,'ao1','Voltage');
% configuring the digital session: no background, just single scans for
% opening the valve

BehCtrl.Digsess = daq.createSession('ni');
addDigitalChannel(BehCtrl.Digsess,BehCtrl.DevNum,'port0/line3:6','OutputOnly');% 3 laser, 4:5 valve, 6 audio to oe

%---- initiate bonsai udp connection and send a signal to start rec
BehCtrl.udpcon = udp(BehCtrl.localip, BehCtrl.bonsaiport);
fopen(BehCtrl.udpcon);
%---- initiate communication with stimserver
BehCtrl.SS.con=pnet('tcpconnect','131.152.17.102',5000);
%---- listening to ni input and generating output
BehCtrl.sess.IsContinuous = 1;
BehCtrl.sess.IsNotifyWhenScansQueuedBelowAuto = false;
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
%BehCtrl.tRew=timer('TimerFcn',@(src,event)triggerRewZone(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('trew stop func'));
BehCtrl.tFA=timer('TimerFcn',@(src,event)triggerFAZone(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tFA stop func'));
BehCtrl.tEnd=timer('TimerFcn',@(src,event)triggerTrialEnd(BehCtrl.CurrState),'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('tend stop func'));
BehCtrl.tAux=timer('TimerFcn',@StartTimers,'BusyMode','error','TasksToExecute',1,'StopFcn',@(src,event)disp('taux stop func'),'StartDelay',0);

BehCtrl.tNewTrialIndc=timer('TimerFcn',@(src,event)set(BehCtrl.handles.NewTrial, 'BackgroundColor','black'),'BusyMode','error','TasksToExecute',1,'StartFcn',@(src,event)set(BehCtrl.handles.NewTrial, 'BackgroundColor','yellow'),'StartDelay',.1);
BehCtrl.tValveOpen=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','yellow'),...
    'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0,0,0]),'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.ValveDuration,...
    'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));

BehCtrl.tValveOpenAutoRew=timer('StartFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','white'),...
    'TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0,0,0]),'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.AutoRewValveDuration,...
    'StopFcn',@(src,event)set(BehCtrl.handles.Valve, 'BackgroundColor','black'));

BehCtrl.tAutoRew=timer('TimerFcn',@OpenValveAutoRew,'BusyMode','error','TasksToExecute',1,'StartDelay',BehCtrl.AutoRewDur,'StopFcn',@(src,event)disp('tautorew stop func'));

%BehCtrl.tAudioRew = timer('TimerFcn',@tAudioRewFunc,'ExecutionMode','fixedDelay','Period',BehCtrl.AudioPeriod+rand*BehCtrl.AudioPeriodJitter,'StartDelay',0);
BehCtrl.tAudioRew = timer('TimerFcn',@tAudioRewFunc,'ExecutionMode','fixedDelay','Period',BehCtrl.AudioPeriod,'StartDelay',0);

BehCtrl.tLaserOff=timer('TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[0,0,0,0]),'TasksToExecute',1,'StartDelay',BehCtrl.lasergreyonduration); % 5ms laser is on: in practice 10 ms

BehCtrl.tLaser=timer('TimerFcn',@(src,event)outputSingleScan(BehCtrl.Digsess,[1,0,0,0]),'TasksToExecute',1,'StopFcn',@(src,event)start(BehCtrl.tLaserOff));

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
pnet(BehCtrl.SS.con,'printf', '%s\n','SS FORWARD auditory block started');
%----- start first trial
tic
triggerTrialStart(BehCtrl.CurrState);
start(BehCtrl.tAudioRew)
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
delete(BehCtrl.tAudioRew)
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

end
%

pnet(BehCtrl.SS.con,'printf', '%s\n', BehCtrl.SS.cmd);
%time to (potential) reward zone
BehCtrl.TimeToRZ = BehCtrl.SS.GreyTime + BehCtrl.SS.Dur1;
%time to trial end
BehCtrl.TimeToTE = BehCtrl.SS.GreyTime + BehCtrl.SS.Dur1 + BehCtrl.SS.Dur2;



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
BehCtrl.SS.GreyTime = BehCtrl.SS.GreyTimeAv% + rand;
BehCtrl.SS.Dur1 = 0; % vertical grating -- approaching corridor
BehCtrl.SS.Dur2 = 1; % angled stimulus -- either 45 or -45

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

BehCtrl.tEnd.StartDelay = BehCtrl.TimeToTE;

if BehCtrl.SS.StimId == BehCtrl.SS.GoStimId
    start(BehCtrl.tFA);
    disp('tFA timer started')
elseif BehCtrl.SS.StimId == BehCtrl.SS.NoGoStimId
    start(BehCtrl.tFA);
    disp('tFA timer started')
end
start(BehCtrl.tEnd);
disp('tEnd timer started')


end
function RewardZone(src,event)
global BehCtrl
toc
disp('Rew zone')
BehCtrl.audiotrialnum = BehCtrl.audiotrialnum +1 ;
set(BehCtrl.handles.audiotrialnum ,'String',sprintf('numaudiotrials = %s',num2str(BehCtrl.audiotrialnum)));

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
set(BehCtrl.handles.RewZone,'BackgroundColor','black')
outputSingleScan(BehCtrl.Digsess,[0,1,0,0])
stop(BehCtrl.tAutoRew)
delete(BehCtrl.licklistener)
start(BehCtrl.tValveOpen)
end
function OpenValveAutoRew(src,event)
global BehCtrl
disp('valve auto opened')
outputSingleScan(BehCtrl.Digsess,[0,1,0,0])
set(BehCtrl.handles.RewZone,'BackgroundColor','black')
delete(BehCtrl.licklistener)
BehCtrl.misses = BehCtrl.misses + 1;
set(BehCtrl.handles.misses,'String',sprintf('misses = %s',num2str(BehCtrl.misses)));
start(BehCtrl.tValveOpenAutoRew)
end
function OpenValveManual(src,event)
global BehCtrl
disp('valve manually opened')
outputSingleScan(BehCtrl.Digsess,[0,1,0,0])
start(BehCtrl.tValveOpen)
end
function CloseValveManual(src,event)
global BehCtrl
disp('valve manually closed')
outputSingleScan(BehCtrl.Digsess,[0,0,0,0])
end

function RestartTrial(src,event)
global BehCtrl
toc

if  isfield(BehCtrl,'FAlicklistener') 
    delete(BehCtrl.FAlicklistener)
    disp('FAlicklistener deleted')
end
% update FA and misses
if  BehCtrl.licked % problem: incorrectly incerements fa if the stimulus overlaps with the auditory trial
    BehCtrl.falsealarms = BehCtrl.falsealarms + 1;
    set(BehCtrl.handles.falsealarms,'String',sprintf('falsealarms = %s',num2str(BehCtrl.falsealarms)));
end
% update missrate and farate plots
BehCtrl.MSRate = [BehCtrl.MSRate , BehCtrl.misses / BehCtrl.audiotrialnum];
BehCtrl.FARate = [BehCtrl.FARate , BehCtrl.falsealarms / BehCtrl.trialnum]; % are these 2 lines better here or inside if?

if (numel(BehCtrl.MSRate) > 50) && (numel(BehCtrl.FARate) > 50)
    plot(BehCtrl.handles.MS, BehCtrl.MSRate(end-50:end),'r*-')
    plot(BehCtrl.handles.FA, BehCtrl.FARate(end-50:end),'b*-')
else
    plot(BehCtrl.handles.MS, BehCtrl.MSRate,'r*-')
    plot(BehCtrl.handles.FA, BehCtrl.FARate,'b*-')
end
drawnow
%
BehCtrl.licked = 0;

% start new trial
tic
triggerTrialStart(BehCtrl.CurrState)
end

function updateplots(src,event)
global BehCtrl
% plot speed
%BehCtrl.speed = (diff(event.Data(:,1)) * 0.0605)/(1/BehCtrl.sess.Rate);
disp('updating plots')
BehCtrl.speed = ((event.Data((BehCtrl.precision_ms+1):1:end,1) - event.Data(1:1:(end-BehCtrl.precision_ms),1)) * 0.0605)/...
    (BehCtrl.precision_ms/BehCtrl.sess.Rate); % speed calc is bad, also better to divide by the difference between the actual timestamps
plot(BehCtrl.handles.axspeed,BehCtrl.speed);
set(BehCtrl.handles.axspeed,'YLimMode','manual','Ylim',[0 200])
drawnow

%fprintf('%f\n',toc)
% plot lick
BehCtrl.lickcont = event.Data(:,2);
BehCtrl.lick = (sign(BehCtrl.lickcont - BehCtrl.LickThresh)+1)/2;
plot(BehCtrl.handles.axlick,[BehCtrl.lickcont,BehCtrl.lick]);
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
end
function changeAutoRew(src,event)
global BehCtrl
BehCtrl.AutoRew = logical(str2double(get(BehCtrl.handles.AutoRew,'String')));
end
function changeAutoRewDur(src,event)
global BehCtrl
BehCtrl.AutoRewDur = str2double(get(BehCtrl.handles.AutoRewDur,'String'));
end
function changeAutoRewValveDuration(src,event)
global BehCtrl
BehCtrl.AutoRewValveDuration = str2double(get(BehCtrl.handles.AutoRewValveDuration,'String'));
end
function changeAudioPeriod(src,event)
global BehCtrl
BehCtrl.AudioPeriod =  str2double(get(BehCtrl.handles.AudioPeriod,'String'));
stop(BehCtrl.tAudioRew)
set(BehCtrl.tAudioRew,'Period',BehCtrl.AudioPeriod);
%set(BehCtrl.tAudioRew,'Period',(BehCtrl.AudioPeriod+rand*BehCtrl.AudioPeriodJitter));
start(BehCtrl.tAudioRew)
end

function changePAudioReward(src,event)
global BehCtrl
BehCtrl.PAudioReward =  str2double(get(BehCtrl.handles.PAudioReward,'String'));
end
function changeGreyTimeAv(src,event)
global BehCtrl
BehCtrl.SS.GreyTimeAv = str2double(get(BehCtrl.handles.GreyTimeAv,'String'));
end
function changeLaserProb(src,event)
global BehCtrl
BehCtrl.LaserProb = str2double(get(BehCtrl.handles.LaserProb,'String'));
end
function tAudioRewFunc(src,event)
global BehCtrl
if rand < BehCtrl.PAudioReward
    play(BehCtrl.SoundObjRew)
    outputSingleScan(BehCtrl.Digsess,[0,0,0,1])
    outputSingleScan(BehCtrl.Digsess,[0,0,0,0])
    triggerRewZone(BehCtrl.CurrState)
    pnet(BehCtrl.SS.con,'printf', '%s\n','SS FORWARD auditory Reward');
else
    play(BehCtrl.SoundObjNoRew)
    outputSingleScan(BehCtrl.Digsess,[0,0,0,1])
    outputSingleScan(BehCtrl.Digsess,[0,0,0,0])
    pnet(BehCtrl.SS.con,'printf', '%s\n','SS FORWARD auditory NoReward');
end
    
%set(BehCtrl.tAudioRew,'Period',(BehCtrl.AudioPeriod+rand*BehCtrl.AudioPeriodJitter));

end
function my_stopfcn(src,event)
global BehCtrl

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