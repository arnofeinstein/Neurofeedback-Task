function trial_result = ml_log_trial_result(ml_trial, runtime_result)
%ML_LOG_TRIAL_RESULT Normalize MonkeyLogic trial output to schema fields.
%
% Inputs
%   ml_trial        : struct returned by ml_prepare_trial()
%   runtime_result  : struct with timing-file outcome information
%
% Output
%   trial_result : flat struct aligned to the existing behavioral schema,
%                  with extra MonkeyLogic debug fields for bhv_variable()

    if ~isstruct(ml_trial)
        error('ml_log_trial_result:InvalidTrial', ...
            'ml_trial must be a struct.');
    end

    if nargin < 2 || isempty(runtime_result)
        runtime_result = struct();
    end

    if ~isstruct(runtime_result)
        error('ml_log_trial_result:InvalidRuntimeResult', ...
            'runtime_result must be a struct.');
    end

    response_angle = get_numeric_field(runtime_result, 'response_angle', NaN);
    response_target_index = get_numeric_field(runtime_result, 'response_target_index', NaN);
    response_target_taskobject = get_numeric_field(runtime_result, ...
        'response_target_taskobject', NaN);
    reaction_time_ms = get_numeric_field(runtime_result, 'reaction_time_ms', NaN);
    n_states_visited = get_numeric_field(runtime_result, 'n_states_visited', NaN);

    response_eval = [];
    response_correct = false;
    angular_error_deg = NaN;

    if isfinite(response_angle)
        response_eval = evaluate_choice(ml_trial, response_angle, ...
            'ToleranceDeg', 22.5);
        response_correct = logical(response_eval.is_correct);
        angular_error_deg = response_eval.angular_error_deg;
    elseif isfield(runtime_result, 'response_correct')
        response_correct = logical(runtime_result.response_correct);
    end

    final_outcome = get_text_field(runtime_result, 'final_outcome', '');
    if isempty(final_outcome)
        final_outcome = default_outcome_from_response(response_eval);
    end

    terminal_state = get_text_field(runtime_result, 'terminal_state', '');
    if isempty(terminal_state)
        terminal_state = default_terminal_state(final_outcome);
    end

    completed = get_logical_field(runtime_result, 'completed', strcmp(final_outcome, 'correct'));
    last_state_name = get_text_field(runtime_result, 'last_state_name', terminal_state);

    trial_result = struct();

    % Canonical condition fields
    trial_result.trial_id = get_numeric_field(ml_trial, 'trial_id', NaN);
    trial_result.rule_id = get_numeric_field(ml_trial, 'rule_id', NaN);
    trial_result.rule_name = get_text_field(ml_trial, 'rule_name', '');
    trial_result.sample_dir = get_numeric_field(ml_trial, 'sample_dir', NaN);
    trial_result.sample_side = get_numeric_field(ml_trial, 'sample_side', NaN);
    trial_result.distractor_dir = get_numeric_field(ml_trial, 'distractor_dir', NaN);
    trial_result.distractor_side = get_numeric_field(ml_trial, 'distractor_side', NaN);
    trial_result.correct_target_angle = get_numeric_field(ml_trial, ...
        'correct_target_angle', NaN);

    % Canonical timing fields
    trial_result.max_acquire_fix_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'max_acquire_fix_ms', NaN);
    trial_result.initial_fix_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'initial_fix_ms', NaN);
    trial_result.sample_dur_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'sample_dur_ms', NaN);
    trial_result.delay_dur_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'delay_dur_ms', NaN);
    trial_result.distractor_dur_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'distractor_dur_ms', NaN);
    trial_result.max_reaction_time_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'max_reaction_time_ms', NaN);
    trial_result.target_hold_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'target_hold_ms', NaN);
    trial_result.reward_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'reward_ms', NaN);
    trial_result.error_timeout_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'error_timeout_ms', NaN);
    trial_result.iti_ms = get_nested_numeric_field(ml_trial, 'timing', ...
        'iti_ms', NaN);

    % Canonical response fields
    trial_result.response_angle = response_angle;
    trial_result.response_correct = response_correct;
    trial_result.angular_error_deg = angular_error_deg;

    % Canonical outcome fields
    trial_result.final_outcome = final_outcome;
    trial_result.terminal_state = terminal_state;
    trial_result.completed = completed;

    % Canonical execution fields
    trial_result.n_states_visited = n_states_visited;
    trial_result.last_state_name = last_state_name;

    % MonkeyLogic-specific debug fields
    trial_result.reaction_time_ms = reaction_time_ms;
    trial_result.response_target_index = response_target_index;
    trial_result.response_target_taskobject = response_target_taskobject;
    trial_result.trialerror_code = map_outcome_to_trialerror_code(final_outcome);

    trial_result.bhv_variables = build_bhv_variables(trial_result);
end


function out = default_outcome_from_response(response_eval)
%DEFAULT_OUTCOME_FROM_RESPONSE Infer outcome if the timing file did not provide one.

    if isempty(response_eval)
        out = 'internal_error';
        return;
    end

    if response_eval.is_correct
        out = 'correct';
    else
        out = response_eval.status;
    end
end


function out = default_terminal_state(final_outcome)
%DEFAULT_TERMINAL_STATE Infer terminal state from normalized outcome.

    if strcmp(final_outcome, 'correct')
        out = 'REWARD';
    else
        out = 'ERROR';
    end
end


function code = map_outcome_to_trialerror_code(final_outcome)
%MAP_OUTCOME_TO_TRIALERROR_CODE Map project outcomes to ML trialerror codes.

    switch lower(final_outcome)
        case 'correct'
            code = 0;
        case 'no_response'
            code = 1;
        case 'break_fixation'
            code = 3;
        case 'no_fixation'
            code = 4;
        case 'wrong_target'
            code = 6;
        case 'broke_target_hold'
            code = 3;
        otherwise
            code = 9;
    end
end


function bhv_variables = build_bhv_variables(trial_result)
%BUILD_BHV_VARIABLES Flatten the result struct for bhv_variable().

    bhv_variables = { ...
        'trial_id', trial_result.trial_id, ...
        'rule_id', trial_result.rule_id, ...
        'rule_name', trial_result.rule_name, ...
        'sample_dir', trial_result.sample_dir, ...
        'sample_side', trial_result.sample_side, ...
        'distractor_dir', trial_result.distractor_dir, ...
        'distractor_side', trial_result.distractor_side, ...
        'correct_target_angle', trial_result.correct_target_angle, ...
        'max_acquire_fix_ms', trial_result.max_acquire_fix_ms, ...
        'initial_fix_ms', trial_result.initial_fix_ms, ...
        'sample_dur_ms', trial_result.sample_dur_ms, ...
        'delay_dur_ms', trial_result.delay_dur_ms, ...
        'distractor_dur_ms', trial_result.distractor_dur_ms, ...
        'max_reaction_time_ms', trial_result.max_reaction_time_ms, ...
        'target_hold_ms', trial_result.target_hold_ms, ...
        'reward_ms', trial_result.reward_ms, ...
        'error_timeout_ms', trial_result.error_timeout_ms, ...
        'iti_ms', trial_result.iti_ms, ...
        'response_angle', trial_result.response_angle, ...
        'response_correct', trial_result.response_correct, ...
        'angular_error_deg', trial_result.angular_error_deg, ...
        'final_outcome', trial_result.final_outcome, ...
        'terminal_state', trial_result.terminal_state, ...
        'completed', trial_result.completed, ...
        'reaction_time_ms', trial_result.reaction_time_ms, ...
        'response_target_index', trial_result.response_target_index, ...
        'response_target_taskobject', trial_result.response_target_taskobject, ...
        'trialerror_code', trial_result.trialerror_code, ...
        'n_states_visited', trial_result.n_states_visited, ...
        'last_state_name', trial_result.last_state_name};
end


function value = get_nested_numeric_field(s, parent_field, child_field, default_value)
%GET_NESTED_NUMERIC_FIELD Safe nested numeric lookup.

    if isstruct(s) && isfield(s, parent_field) && isstruct(s.(parent_field)) ...
            && isfield(s.(parent_field), child_field)
        value = s.(parent_field).(child_field);
    else
        value = default_value;
    end
end


function value = get_numeric_field(s, field_name, default_value)
%GET_NUMERIC_FIELD Safe numeric lookup.

    if isstruct(s) && isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end


function value = get_logical_field(s, field_name, default_value)
%GET_LOGICAL_FIELD Safe logical lookup.

    if isstruct(s) && isfield(s, field_name)
        value = logical(s.(field_name));
    else
        value = logical(default_value);
    end
end


function value = get_text_field(s, field_name, default_value)
%GET_TEXT_FIELD Safe text lookup with row-char normalization.

    if isstruct(s) && isfield(s, field_name)
        value = normalize_text(s.(field_name));
    else
        value = normalize_text(default_value);
    end
end


function out = normalize_text(x)
%NORMALIZE_TEXT Convert strings/chars to row char vectors.

    if isempty(x)
        out = '';
        return;
    end

    if isstring(x)
        x = x(1);
        out = char(x);
    elseif ischar(x)
        out = x;
    else
        error('ml_log_trial_result:InvalidTextField', ...
            'Expected char or string text input.');
    end

    out = out(:).';
end
