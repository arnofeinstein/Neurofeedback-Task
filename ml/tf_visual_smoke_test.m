function tf_visual_smoke_test(~, ~)
%TF_VISUAL_SMOKE_TEST Minimal MonkeyLogic v2 rendering smoke test.
%
% Purpose:
%   1. flash the subject screen background with high-contrast colors
%   2. present large centered and lateral graphic objects
%   3. avoid all tracker/fixation/userloop task logic
%
% If this timing file does not visibly render on the subject screen, the
% problem is outside the task scaffold and should be treated as a MonkeyLogic
% display/runtime configuration issue.

    require_monkeylogic_runtime();

    dashboard(1, 'visual smoke test');
    dashboard(2, 'expect full-screen flashes, then big shapes');

    flash = BackgroundColorChanger(null_);
    flash.List = [ ...
        1.0 1.0 1.0 250; ...
        0.0 0.0 0.0 250; ...
        1.0 0.0 0.0 250; ...
        0.0 1.0 0.0 250; ...
        0.0 0.0 1.0 250];
    flash.DurationUnit = 'msec';

    scene = create_scene(flash);
    run_scene(scene);

    hold = TimeCounter(null_);
    hold.Duration = 2000;

    graphics = BoxGraphic(hold);
    graphics.List = { ...
        [1.0 1.0 1.0], [1.0 1.0 1.0], [3.0 3.0], [0.0 0.0]; ...
        [1.0 0.0 0.0], [1.0 0.0 0.0], [4.0 0.8], [-6.0 0.0]; ...
        [0.0 1.0 0.0], [0.0 1.0 0.0], [4.0 0.8], [6.0 0.0]};

    scene = create_scene(graphics);
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
        'BackgroundColorChanger', ...
        'BoxGraphic', ...
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

    error('tf_visual_smoke_test:MissingMonkeyLogicRuntime', ...
        ['MonkeyLogic runtime functions are not available on this machine. ' ...
         'Missing symbols: %s'], strjoin(missing, ', '));
end
