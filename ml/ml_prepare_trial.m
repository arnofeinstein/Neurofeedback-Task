function ml_trial = ml_prepare_trial(trial, params)
%ML_PREPARE_TRIAL Convert one core trial into a MonkeyLogic-facing struct.
%
% Inputs
%   trial  : one element from build_trial_table()
%   params : task parameter struct
%
% Output
%   ml_trial : struct containing derived display and response information

    if ~isstruct(trial)
        error('ml_prepare_trial:InvalidTrial', 'trial must be a struct.');
    end

    if ~isstruct(params)
        error('ml_prepare_trial:InvalidParams', 'params must be a struct.');
    end

    ml_trial = struct();

    % Copy core task information
    ml_trial.trial_id = get_field_if_exists(trial, 'trial_id', NaN);
    ml_trial.sample_dir = trial.sample_dir;
    ml_trial.sample_side = trial.sample_side;
    ml_trial.distractor_dir = trial.distractor_dir;
    ml_trial.distractor_side = trial.distractor_side;
    ml_trial.rule_id = trial.rule_id;
    ml_trial.rule_name = trial.rule_name;
    ml_trial.delay_dur_ms = trial.delay_dur_ms;
    ml_trial.correct_target_angle = trial.correct_target_angle;
    ml_trial.fix_pos_deg = [0, 0];

    % Spatial positions for sample and distractor
    ml_trial.sample_pos_deg = [trial.sample_side * params.rdk_eccentricity_deg, 0];
    ml_trial.distractor_pos_deg = [trial.distractor_side * params.rdk_eccentricity_deg, 0];

    % Correct target position on response ring
    [target_x, target_y] = angle_to_xy(trial.correct_target_angle, ...
        params.response_ring_radius_deg);
    ml_trial.correct_target_pos_deg = [target_x, target_y];

    % Response ring target set
    response_angles = params.sample_dirs;
    response_positions = zeros(numel(response_angles), 2);
    response_targets = struct( ...
        'angle_deg', cell(numel(response_angles), 1), ...
        'position_deg', cell(numel(response_angles), 1), ...
        'is_correct', cell(numel(response_angles), 1), ...
        'label', cell(numel(response_angles), 1));

    for k = 1:numel(response_angles)
        [x, y] = angle_to_xy(response_angles(k), params.response_ring_radius_deg);
        response_positions(k, :) = [x, y];
        response_targets(k).angle_deg = response_angles(k);
        response_targets(k).position_deg = [x, y];
        response_targets(k).is_correct = ...
            mod(response_angles(k), 360) == mod(trial.correct_target_angle, 360);
        response_targets(k).label = sprintf('target_%03d', response_angles(k));
    end

    ml_trial.response_angles = response_angles;
    ml_trial.response_positions_deg = response_positions;
    ml_trial.response_targets = response_targets;

    % Timing bundle
    ml_trial.timing = struct();
    ml_trial.timing.max_acquire_fix_ms = params.max_acquire_fix_ms;
    ml_trial.timing.initial_fix_ms = params.initial_fix_ms;
    ml_trial.timing.sample_dur_ms = params.sample_dur_ms;
    ml_trial.timing.delay_dur_ms = trial.delay_dur_ms;
    ml_trial.timing.distractor_dur_ms = params.distractor_dur_ms;
    ml_trial.timing.max_reaction_time_ms = params.max_reaction_time_ms;
    ml_trial.timing.target_hold_ms = params.target_hold_ms;
    ml_trial.timing.reward_ms = params.reward_ms;
    ml_trial.timing.error_timeout_ms = params.error_timeout_ms;
    ml_trial.timing.iti_ms = params.iti_ms;

    % Window bundle
    ml_trial.windows = struct();
    ml_trial.windows.fix_radius_deg = params.fix_radius_deg;
    ml_trial.windows.target_radius_deg = params.target_radius_deg;

    % MonkeyLogic display bundle
    ml_trial.display = build_display_bundle(trial, params);

    % MonkeyLogic metadata
    ml_trial.monkeylogic = struct();
    ml_trial.monkeylogic.timing_file = 'tf_rule_rdk.m';
    ml_trial.monkeylogic.placeholder_mode = true;

end


function value = get_field_if_exists(s, field_name, default_value)
%GET_FIELD_IF_EXISTS Safe field access helper.

    if isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end


function display = build_display_bundle(trial, params)
%BUILD_DISPLAY_BUNDLE Prepare ML-only placeholder display settings.

    rule_cue_map = struct();
    rule_cue_map.pro = struct('shape', 'square', 'label', 'PRO');
    rule_cue_map.anti = struct('shape', 'circle', 'label', 'ANTI');
    rule_cue_map.plus90 = struct('shape', 'triangle', 'label', '+90');

    if ~isfield(rule_cue_map, trial.rule_name)
        error('ml_prepare_trial:UnknownRuleCue', ...
            'Unsupported rule name for placeholder cue: %s', trial.rule_name);
    end

    display = struct();

    display.fixation = struct();
    display.fixation.size_deg = 0.50;
    display.fixation.edge_color_rgb = [0.95, 0.95, 0.95];
    display.fixation.face_color_rgb = [0.95, 0.95, 0.95];
    display.fixation.position_deg = [0, 0];

    display.sample_placeholder = struct();
    display.sample_placeholder.shape = 'bar';
    display.sample_placeholder.size_deg = [params.sample_size_deg, 0.45];
    display.sample_placeholder.color_rgb = [0.10, 0.70, 0.95];
    display.sample_placeholder.rotation_deg = trial.sample_dir;

    display.distractor_placeholder = struct();
    display.distractor_placeholder.shape = 'bar';
    display.distractor_placeholder.size_deg = [params.distractor_size_deg, 0.45];
    display.distractor_placeholder.color_rgb = [0.95, 0.55, 0.10];
    display.distractor_placeholder.rotation_deg = trial.distractor_dir;

    display.rule_cue = struct();
    display.rule_cue.shape = rule_cue_map.(trial.rule_name).shape;
    display.rule_cue.size_deg = 0.90;
    display.rule_cue.edge_color_rgb = [0.95, 0.95, 0.95];
    display.rule_cue.face_color_rgb = [0.95, 0.95, 0.95];
    display.rule_cue.position_deg = [0, 0];
    display.rule_cue.label = rule_cue_map.(trial.rule_name).label;

    display.response_target = struct();
    display.response_target.radius_deg = 0.45;
    display.response_target.color_rgb = [0.90, 0.90, 0.90];
    display.response_target.fill = 0;
end
