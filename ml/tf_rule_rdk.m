function tf_rule_rdk(~, TrialRecord)
%TF_RULE_RDK First MonkeyLogic v2 timing-file scaffold for the task.
%
% This file is intentionally limited to placeholder stimuli:
%   - fixation point
%   - oriented bar for sample placeholder
%   - oriented bar for distractor placeholder
%   - shape-coded rule cue at fixation
%   - circular response-ring targets
%
% It is written as a clean porting scaffold and cannot be validated on this
% machine without the MonkeyLogic runtime.

    require_monkeylogic_runtime();

    condition_info = read_condition_info(TrialRecord);
    ml_trial = condition_info.ml_trial;
    taskobjects = condition_info.taskobjects;
    events = event_codes();
    dashboard(1, sprintf('trial=%d rule=%s sample=%d correct=%d', ...
        ml_trial.trial_id, ml_trial.rule_name, ...
        ml_trial.sample_dir, ml_trial.correct_target_angle));
    dashboard(2, 'placeholder ML timing file: bars + shape rule cue');

    acquire_fix = make_fixation_hold_adapter( ...
        eye_, ml_trial.fix_pos_deg, ml_trial.windows.fix_radius_deg);
    acquire_fix.WaitTime = ml_trial.timing.max_acquire_fix_ms;
    acquire_fix.HoldTime = 0;
    acquire_fix_scene_root = attach_fixation_graphic( ...
        acquire_fix, ml_trial.display.fixation);
    scene = create_scene(acquire_fix_scene_root);
    run_scene(scene, events.ACQUIRE_FIX);
    if ~acquire_fix.Success
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'no_fixation', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'n_states_visited', 1, ...
            'last_state_name', 'ACQUIRE_FIX'));
        return;
    end

    hold_fix = make_fixation_hold_adapter( ...
        eye_, ml_trial.fix_pos_deg, ml_trial.windows.fix_radius_deg);
    hold_fix.WaitTime = 0;
    hold_fix.HoldTime = ml_trial.timing.initial_fix_ms;
    hold_fix_scene_root = attach_fixation_graphic( ...
        hold_fix, ml_trial.display.fixation);
    scene = create_scene(hold_fix_scene_root);
    run_scene(scene, events.HOLD_FIX);
    if ~hold_fix.Success
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'break_fixation', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'n_states_visited', 2, ...
            'last_state_name', 'HOLD_FIX'));
        return;
    end

    sample_hold = make_fixation_hold_adapter( ...
        eye_, ml_trial.fix_pos_deg, ml_trial.windows.fix_radius_deg);
    sample_hold.WaitTime = 0;
    sample_hold.HoldTime = ml_trial.timing.sample_dur_ms;
    sample_scene_root = attach_fixation_graphic( ...
        sample_hold, ml_trial.display.fixation);
    sample_scene_root = attach_bar_graphic( ...
        sample_scene_root, ...
        ml_trial.display.sample_placeholder, ...
        ml_trial.sample_pos_deg);
    scene = create_scene(sample_scene_root);
    run_scene(scene, events.SHOW_SAMPLE);
    if ~sample_hold.Success
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'break_fixation', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'n_states_visited', 3, ...
            'last_state_name', 'SHOW_SAMPLE'));
        return;
    end

    delay_hold = make_fixation_hold_adapter( ...
        eye_, ml_trial.fix_pos_deg, ml_trial.windows.fix_radius_deg);
    delay_hold.WaitTime = 0;
    delay_hold.HoldTime = ml_trial.timing.delay_dur_ms;
    delay_scene_root = attach_fixation_graphic( ...
        delay_hold, ml_trial.display.fixation);
    scene = create_scene(delay_scene_root);
    run_scene(scene, events.DELAY);
    if ~delay_hold.Success
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'break_fixation', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'n_states_visited', 4, ...
            'last_state_name', 'DELAY'));
        return;
    end

    distractor_hold = make_fixation_hold_adapter( ...
        eye_, ml_trial.fix_pos_deg, ml_trial.windows.fix_radius_deg);
    distractor_hold.WaitTime = 0;
    distractor_hold.HoldTime = ml_trial.timing.distractor_dur_ms;
    distractor_scene_root = attach_fixation_graphic( ...
        distractor_hold, ml_trial.display.fixation);
    distractor_scene_root = attach_bar_graphic( ...
        distractor_scene_root, ...
        ml_trial.display.distractor_placeholder, ...
        ml_trial.distractor_pos_deg);
    scene = create_scene(distractor_scene_root);
    run_scene(scene, events.SHOW_DISTRACTOR);
    if ~distractor_hold.Success
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'break_fixation', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'n_states_visited', 5, ...
            'last_state_name', 'SHOW_DISTRACTOR'));
        return;
    end

    % SHOW_RULE remains an instantaneous logical state in this first pass.
    idle(0, [], events.SHOW_RULE);

    choice = MultiTarget(eye_);
    choice.Target = ml_trial.response_positions_deg;
    choice.Threshold = ml_trial.windows.target_radius_deg;
    choice.WaitTime = ml_trial.timing.max_reaction_time_ms;
    choice.HoldTime = 0;
    choice.AllowFixBreak = true;
    choice.TurnOffUnchosen = false;
    choice_scene_root = attach_response_ring_graphic(choice, ml_trial);
    choice_scene_root = attach_rule_cue_graphic(choice_scene_root, taskobjects.rule_cue);
    scene = create_scene(choice_scene_root);
    run_scene(scene, events.WAIT_FOR_SACCADE);

    if ~choice.Success
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'no_response', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'reaction_time_ms', choice.RT, ...
            'n_states_visited', 7, ...
            'last_state_name', 'WAIT_FOR_SACCADE'));
        return;
    end

    [response_target_index, response_angle, response_target_taskobject] = ...
        lookup_response_target(taskobjects, choice.ChosenTarget);

    choice_eval = evaluate_choice(ml_trial, response_angle, 'ToleranceDeg', 22.5);
    if ~choice_eval.is_correct
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'wrong_target', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'response_angle', response_angle, ...
            'response_target_index', response_target_index, ...
            'response_target_taskobject', response_target_taskobject, ...
            'reaction_time_ms', choice.RT, ...
            'n_states_visited', 7, ...
            'last_state_name', 'WAIT_FOR_SACCADE'));
        return;
    end

    hold_target_fix = SingleTarget(eye_);
    hold_target_fix.Target = ...
        ml_trial.response_targets(response_target_index).position_deg;
    hold_target_fix.Threshold = ml_trial.windows.target_radius_deg;

    hold_target = WaitThenHold(hold_target_fix);
    hold_target.WaitTime = 0;
    hold_target.HoldTime = ml_trial.timing.target_hold_ms;
    hold_target_scene_root = attach_response_ring_graphic(hold_target, ml_trial);
    hold_target_scene_root = attach_rule_cue_graphic( ...
        hold_target_scene_root, taskobjects.rule_cue);
    scene = create_scene(hold_target_scene_root);
    run_scene(scene, events.HOLD_TARGET);
    if ~hold_target.Success
        finish_trial(ml_trial, struct( ...
            'final_outcome', 'broke_target_hold', ...
            'terminal_state', 'ERROR', ...
            'completed', false, ...
            'response_angle', response_angle, ...
            'response_target_index', response_target_index, ...
            'response_target_taskobject', response_target_taskobject, ...
            'reaction_time_ms', choice.RT, ...
            'n_states_visited', 8, ...
            'last_state_name', 'HOLD_TARGET'));
        return;
    end

    goodmonkey(ml_trial.timing.reward_ms, 'eventmarker', events.REWARD);

    finish_trial(ml_trial, struct( ...
        'final_outcome', 'correct', ...
        'terminal_state', 'REWARD', ...
        'completed', true, ...
        'response_angle', response_angle, ...
        'response_target_index', response_target_index, ...
        'response_target_taskobject', response_target_taskobject, ...
        'reaction_time_ms', choice.RT, ...
        'n_states_visited', 10, ...
        'last_state_name', 'ITI'));
end


function hold_adapter = make_fixation_hold_adapter(tracker, fixation_position_deg, fix_radius_deg)
%MAKE_FIXATION_HOLD_ADAPTER Build a WaitThenHold chain for central fixation.

    fix_target = SingleTarget(tracker);
    fix_target.Target = fixation_position_deg;
    fix_target.Threshold = fix_radius_deg;

    hold_adapter = WaitThenHold(fix_target);
end


function scene_root = attach_fixation_graphic(child_adapter, fixation_spec)
%ATTACH_FIXATION_GRAPHIC Overlay the visible fixation point on a scene chain.

    fixation_graphic = CircleGraphic(child_adapter);
    fixation_graphic.EdgeColor = fixation_spec.edge_color_rgb;
    fixation_graphic.FaceColor = fixation_spec.face_color_rgb;
    fixation_graphic.Size = [fixation_spec.size_deg, fixation_spec.size_deg];
    fixation_graphic.Position = fixation_spec.position_deg;

    scene_root = fixation_graphic;
end


function scene_root = attach_bar_graphic(child_adapter, bar_spec, position_deg)
%ATTACH_BAR_GRAPHIC Overlay one oriented placeholder bar on a scene chain.

    bar_graphic = BoxGraphic(child_adapter);
    bar_graphic.EdgeColor = bar_spec.color_rgb;
    bar_graphic.FaceColor = bar_spec.color_rgb;
    bar_graphic.Size = bar_spec.size_deg;
    bar_graphic.Position = position_deg;
    bar_graphic.Angle = bar_spec.rotation_deg;

    scene_root = bar_graphic;
end


function scene_root = attach_response_ring_graphic(child_adapter, ml_trial)
%ATTACH_RESPONSE_RING_GRAPHIC Overlay the response ring on a scene chain.

    n_targets = numel(ml_trial.response_targets);
    target_diameter_deg = 2 * ml_trial.display.response_target.radius_deg;
    target_color = ml_trial.display.response_target.color_rgb;

    response_ring_graphic = CircleGraphic(child_adapter);
    response_ring_graphic.List = cell(n_targets, 4);

    for k = 1:n_targets
        response_ring_graphic.List(k, :) = { ...
            target_color, ...
            target_color, ...
            [target_diameter_deg, target_diameter_deg], ...
            ml_trial.response_targets(k).position_deg};
    end

    scene_root = response_ring_graphic;
end


function scene_root = attach_rule_cue_graphic(child_adapter, rule_cue)
%ATTACH_RULE_CUE_GRAPHIC Overlay the rule cue shape on a scene adapter chain.

    switch lower(rule_cue.shape)
        case 'square'
            cue = BoxGraphic(child_adapter);
            cue.List = { ...
                rule_cue.edge_color_rgb, ...
                rule_cue.face_color_rgb, ...
                [rule_cue.size_deg, rule_cue.size_deg], ...
                rule_cue.position_deg};
        case 'circle'
            cue = CircleGraphic(child_adapter);
            cue.List = { ...
                rule_cue.edge_color_rgb, ...
                rule_cue.face_color_rgb, ...
                [rule_cue.size_deg, rule_cue.size_deg], ...
                rule_cue.position_deg};
        case 'triangle'
            cue = PolygonGraphic(child_adapter);
            cue.List = { ...
                rule_cue.edge_color_rgb, ...
                rule_cue.face_color_rgb, ...
                [rule_cue.size_deg, rule_cue.size_deg], ...
                rule_cue.position_deg, ...
                [0.50 1.00; 0.05 0.10; 0.95 0.10]};
        otherwise
            error('tf_rule_rdk:UnknownRuleCueShape', ...
                'Unsupported rule cue shape: %s', rule_cue.shape);
    end

    scene_root = cue;
end


function finish_trial(ml_trial, runtime_result)
%FINISH_TRIAL Log, mark, and close out the current trial.

    events = event_codes();
    trial_result = ml_log_trial_result(ml_trial, runtime_result);

    bhv_variable(trial_result.bhv_variables{:});
    trialerror(trial_result.trialerror_code);

    dashboard(3, sprintf('outcome=%s angle=%g', ...
        trial_result.final_outcome, trial_result.response_angle));

    if strcmp(trial_result.final_outcome, 'correct')
        idle(ml_trial.timing.iti_ms, [], events.ITI);
    else
        idle(ml_trial.timing.error_timeout_ms, [], events.ERROR);
        idle(ml_trial.timing.iti_ms, [], events.ITI);
    end
end


function [response_target_index, response_angle, response_target_taskobject] = ...
        lookup_response_target(taskobjects, chosen_target_index)
%LOOKUP_RESPONSE_TARGET Convert a chosen target index to task metadata.

    if chosen_target_index < 1 || chosen_target_index > numel(taskobjects.response_target_map)
        error('tf_rule_rdk:UnknownChosenTarget', ...
            'Chosen target index %d is outside the response-ring range.', ...
            chosen_target_index);
    end

    response_target_index = chosen_target_index;
    response_angle = taskobjects.response_target_map(chosen_target_index).angle_deg;
    response_target_taskobject = ...
        taskobjects.response_target_map(chosen_target_index).task_object_index;
end


function condition_info = read_condition_info(TrialRecord)
%READ_CONDITION_INFO Read userloop-provided condition info from TrialRecord.

    condition_info = [];

    if isstruct(TrialRecord)
        if isfield(TrialRecord, 'User') && ...
                isstruct(TrialRecord.User) && isfield(TrialRecord.User, 'condition_info')
            condition_info = TrialRecord.User.condition_info;
        end
        if isempty(condition_info) && isfield(TrialRecord, 'CurrentConditionInfo')
            condition_info = TrialRecord.CurrentConditionInfo;
        end
    elseif isobject(TrialRecord)
        if isprop(TrialRecord, 'User') && ...
                isstruct(TrialRecord.User) && isfield(TrialRecord.User, 'condition_info')
            condition_info = TrialRecord.User.condition_info;
        end
        if isempty(condition_info) && isprop(TrialRecord, 'CurrentConditionInfo')
            condition_info = TrialRecord.CurrentConditionInfo;
        end
    end

    if ~isstruct(condition_info) || ...
            ~isfield(condition_info, 'ml_trial') || ...
            ~isfield(condition_info, 'taskobjects')
        error('tf_rule_rdk:IncompleteConditionInfo', ...
            'CurrentConditionInfo must contain ml_trial and taskobjects.');
    end
end


function events = event_codes()
%EVENT_CODES Static event-code map for the first timing-file scaffold.

    events = struct();
    events.ACQUIRE_FIX = 10;
    events.HOLD_FIX = 20;
    events.SHOW_SAMPLE = 30;
    events.DELAY = 40;
    events.SHOW_DISTRACTOR = 50;
    events.SHOW_RULE = 60;
    events.WAIT_FOR_SACCADE = 70;
    events.HOLD_TARGET = 80;
    events.REWARD = 90;
    events.ERROR = 95;
    events.ITI = 100;
end


function require_monkeylogic_runtime()
%REQUIRE_MONKEYLOGIC_RUNTIME Fail clearly when called outside MonkeyLogic.

    required_symbols = { ...
        'create_scene', ...
        'run_scene', ...
        'SingleTarget', ...
        'MultiTarget', ...
        'WaitThenHold', ...
        'BoxGraphic', ...
        'CircleGraphic', ...
        'PolygonGraphic', ...
        'bhv_variable', ...
        'trialerror', ...
        'goodmonkey', ...
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

    error('tf_rule_rdk:MissingMonkeyLogicRuntime', ...
        ['MonkeyLogic runtime functions are not available on this machine. ' ...
         'Missing symbols: %s'], strjoin(missing, ', '));
end
