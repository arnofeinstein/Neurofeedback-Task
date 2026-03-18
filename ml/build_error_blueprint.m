function error_bp = build_error_blueprint(ml_trial)
%BUILD_ERROR_BLUEPRINT Build explicit error branches for one ML trial.
%
% Input
%   ml_trial : struct returned by ml_prepare_trial()
%
% Output
%   error_bp : struct describing state-specific error exits

    if ~isstruct(ml_trial)
        error('build_error_blueprint:InvalidInput', ...
            'ml_trial must be a struct.');
    end

    error_bp = struct();

    error_bp.trial_id = get_field_if_present(ml_trial, 'trial_id', NaN);
    error_bp.rule_name = get_field_if_present(ml_trial, 'rule_name', '');
    error_bp.sample_dir = get_field_if_present(ml_trial, 'sample_dir', NaN);
    error_bp.correct_target_angle = get_field_if_present(ml_trial, 'correct_target_angle', NaN);

    branches = {};

    branches{end+1} = make_error_branch( ...
        'ACQUIRE_FIX', ...
        {'no_fixation'}, ...
        'ERROR');

    branches{end+1} = make_error_branch( ...
        'HOLD_FIX', ...
        {'break_fixation'}, ...
        'ERROR');

    branches{end+1} = make_error_branch( ...
        'SHOW_SAMPLE', ...
        {'break_fixation'}, ...
        'ERROR');

    branches{end+1} = make_error_branch( ...
        'DELAY', ...
        {'break_fixation'}, ...
        'ERROR');

    branches{end+1} = make_error_branch( ...
        'SHOW_DISTRACTOR', ...
        {'break_fixation'}, ...
        'ERROR');

    branches{end+1} = make_error_branch( ...
        'WAIT_FOR_SACCADE', ...
        {'no_response', 'wrong_target'}, ...
        'ERROR');

    branches{end+1} = make_error_branch( ...
        'HOLD_TARGET', ...
        {'broke_target_hold'}, ...
        'ERROR');

    error_bp.branches = branches;
    error_bp.n_branches = numel(branches);

    error_bp.terminal_error_state = struct();
    error_bp.terminal_error_state.name = 'ERROR';
    error_bp.terminal_error_state.followed_by = 'ITI';
end


function b = make_error_branch(state_name, outcome_labels, next_state)
%MAKE_ERROR_BRANCH Helper to create one error branch entry.

    b = struct();
    b.state_name = state_name;
    b.outcome_labels = outcome_labels;
    b.next_state = next_state;
end


function value = get_field_if_present(s, field_name, default_value)
%GET_FIELD_IF_PRESENT Safe field getter.

    if isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end