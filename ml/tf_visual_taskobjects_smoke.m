%TF_VISUAL_TASKOBJECTS_SMOKE Minimal v2 smoke test using TaskObjects only.
%
% This is intentionally a MonkeyLogic timing script, not a MATLAB function.

require_monkeylogic_runtime();

dashboard(1, 'visual taskobjects smoke');
dashboard(2, 'expect white center circle + red/green bars for 5 s');

fix = SingleTarget(eye_);
fix.Target = 1;  % TaskObject #1
fix.Threshold = 3;

wth = WaitThenHold(fix);
wth.WaitTime = 5000;
wth.HoldTime = 0;

scene = create_scene(wth, [1 2 3]);
run_scene(scene);

trialerror(0);
idle(500);


function require_monkeylogic_runtime()
%REQUIRE_MONKEYLOGIC_RUNTIME Fail clearly when called outside MonkeyLogic.

    required_symbols = { ...
        'create_scene', ...
        'run_scene', ...
        'SingleTarget', ...
        'WaitThenHold', ...
        'trialerror', ...
        'idle', ...
        'dashboard'};

    missing = {};

    for i = 1:numel(required_symbols)
        if exist(required_symbols{i}, 'file') == 0 && ...
                exist(required_symbols{i}, 'builtin') == 0 && ...
                exist(required_symbols{i}, 'class') == 0
            missing{end+1} = required_symbols{i}; %#ok<AGROW>
        end
    end

    if isempty(missing)
        return;
    end

    error('tf_visual_taskobjects_smoke:MissingMonkeyLogicRuntime', ...
        ['MonkeyLogic runtime functions are not available on this machine. ' ...
         'Missing symbols: %s'], strjoin(missing, ', '));
end
