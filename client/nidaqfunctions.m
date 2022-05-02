% 
% clear all
% sess = daq.createSession('ni');
% encder = addCounterInputChannel(sess,'Dev2','ctr0','Position'); % X1 coding, alright?
% while 1
% inputSingleScan(sess);
% end

%%
function nidaqfunctions()

clear all
global axhand


figure;

axhand = gca;
sess = daq.createSession('ni');
enc=addCounterInputChannel(sess,'Dev2','ctr0','Position'); % X1 coding, alright?
ch1=addAnalogInputChannel(sess,'Dev2','ai1','Voltage');
sess.DurationInSeconds = 5;
%sess.IsContinuous = 1;
%lh = addlistener(sess,'DataAvailable',@(src,event) plot(event.Data))
lh = addlistener(sess,'DataAvailable',@plot_counter);
sess.startBackground()
tic
%sess.wait()
%plot(enc)
delete(lh)

sess.Rate
sess.NotifyWhenDataAvailableExceeds

stop(sess)
end
function plot_counter(src,event)
global axhand
plot(axhand,event.Data(:,1));
drawnow
fprintf('%f\n',toc)
end