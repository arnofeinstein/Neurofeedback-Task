function [C, timingfile, userdefined_trialholder] = ...
        userloop_visual_taskobjects_smoke(~, TrialRecord)
%USERLOOP_VISUAL_TASKOBJECTS_SMOKE Userloop smoke test using TaskObjects.
%
% This follows the official MonkeyLogic userloop + timing-script-v2 pattern
% more closely than the adapter-only smoke test. It is intended to isolate
% whether userloop-driven TaskObjects render correctly on the target rig.

    timingfile = 'tf_visual_taskobjects_smoke.m';
    userdefined_trialholder = '';

    C = { ...
        'crc(1.000,[1.000 1.000 1.000],1,0.000,0.000)', ...
        'sqr([4.000 0.800],[1.000 0.000 0.000],1,-6.000,0.000)', ...
        'sqr([4.000 0.800],[0.000 1.000 0.000],1,6.000,0.000)'};

    if isobject(TrialRecord)
        if isprop(TrialRecord, 'NextBlock')
            TrialRecord.NextBlock = 1;
        end
        if isprop(TrialRecord, 'NextCondition')
            TrialRecord.NextCondition = 1;
        end
    end
end
