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

    for k = 1:numel(response_angles)
        [x, y] = angle_to_xy(response_angles(k), params.response_ring_radius_deg);
        response_positions(k, :) = [x, y];
    end

    ml_trial.response_angles = response_angles;
    ml_trial.response_positions_deg = response_positions;

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

end


function value = get_field_if_exists(s, field_name, default_value)
%GET_FIELD_IF_EXISTS Safe field access helper.

    if isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end