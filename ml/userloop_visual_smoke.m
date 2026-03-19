function [C, timingfile, userdefined_trialholder] = userloop_visual_smoke(~, ~)
%USERLOOP_VISUAL_SMOKE Minimal MonkeyLogic userloop for visual smoke tests.
%
% This helper is intentionally isolated from the task architecture. It is
% only meant to answer one question on the target ML machine: can a v2
% timing file render anything on the subject screen?

    persistent initialized

    timingfile = 'tf_visual_smoke_test.m';
    userdefined_trialholder = '';
    C = {};

    % Match the standard MonkeyLogic userloop probe call pattern.
    if isempty(initialized)
        initialized = true;
        return;
    end
end
