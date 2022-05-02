classdef BehState < handle
    events
        RewZone
        TrialStart
        TrialEnd
        MouseLicked
        FAZone
    end
    methods
        function triggerRewZone(obj)           
            disp('BehState: entered reward zone')
            notify(obj,'RewZone')
        end
        function triggerTrialStart(obj)
            disp('BehState: trial started')
            notify(obj,'TrialStart')
        end
        function triggerTrialEnd(obj)
            disp('BehState: trial ended')
            notify(obj,'TrialEnd')
        end
        function triggerMouseLicked(obj)
            disp('BehState: mouse licked')
            notify(obj,'MouseLicked')
        end
        function triggerFAZone(obj)
            disp('BehState: entered FA zone')
            notify(obj,'FAZone')
        end
    end
end