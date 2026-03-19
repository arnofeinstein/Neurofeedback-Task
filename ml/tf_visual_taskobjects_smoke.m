function tf_visual_taskobjects_smoke(~, ~)
%TF_VISUAL_TASKOBJECTS_SMOKE Minimal v2 smoke test using TaskObjects only.

    require_monkeylogic_runtime();

    dashboard(1, 'visual taskobjects smoke');
    dashboard(2, 'expect white center circle + red/green bars');

    hold = TimeCounter(null_);
    hold.Duration = 2000;
    scene = create_scene(hold, [1 2 3]);
    run_scene(scene);

    trialerror(0);
    idle(500);
end


function require_monkeylogic_runtime()
%REQUIRE_MONKEYLOGIC_RUNTIME Fail clearly when called outside MonkeyLogic.

    required_symbols = { ...
        'create_scene', ...
        'run_scene', ...
        'TimeCounter', ...
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
