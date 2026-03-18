function flow = build_trial_flow_spec(ml_trial)
%BUILD_TRIAL_FLOW_SPEC Build a canonical trial flow specification.
%
% Input
%   ml_trial : struct returned by ml_prepare_trial()
%
% Output
%   flow : struct describing the full nominal and error flow of one trial

    if ~isstruct(ml_trial)
        error('build_trial_flow_spec:InvalidInput', ...
            'ml_trial must be a struct.');
    end

    timing_bp = build_timing_blueprint(ml_trial);
    error_bp = build_error_blueprint(ml_trial);

    flow = struct();

    % -------------------------
    % Trial metadata
    % -------------------------
    flow.trial_id = get_field_if_present(ml_trial, 'trial_id', NaN);
    flow.rule_id = get_field_if_present(ml_trial, 'rule_id', NaN);
    flow.rule_name = get_field_if_present(ml_trial, 'rule_name', '');
    flow.sample_dir = get_field_if_present(ml_trial, 'sample_dir', NaN);
    flow.sample_side = get_field_if_present(ml_trial, 'sample_side', NaN);
    flow.distractor_dir = get_field_if_present(ml_trial, 'distractor_dir', NaN);
    flow.distractor_side = get_field_if_present(ml_trial, 'distractor_side', NaN);
    flow.correct_target_angle = get_field_if_present(ml_trial, 'correct_target_angle', NaN);

    % -------------------------
    % Nominal path
    % -------------------------
    flow.nominal_states = timing_bp.states;
    flow.n_nominal_states = timing_bp.n_states;

    % -------------------------
    % Error branches
    % -------------------------
    flow.error_branches = error_bp.branches;
    flow.n_error_branches = error_bp.n_branches;

    % -------------------------
    % Terminal states
    % -------------------------
    flow.terminal_states = struct();
    flow.terminal_states.success = struct();
    flow.terminal_states.success.name = 'REWARD';
    flow.terminal_states.success.followed_by = 'ITI';

    flow.terminal_states.error = error_bp.terminal_error_state;

    % -------------------------
    % State transition map
    % -------------------------
    flow.transitions = build_nominal_transition_map(flow.nominal_states);

    % -------------------------
    % Allowed outcomes
    % -------------------------
    flow.allowed_outcomes = { ...
        'correct', ...
        'no_fixation', ...
        'break_fixation', ...
        'no_response', ...
        'wrong_target', ...
        'broke_target_hold'};

    % -------------------------
    % Notes
    % -------------------------
    flow.notes = { ...
        'Nominal states describe the successful path through the trial.', ...
        'Error branches describe state-specific exits to the terminal ERROR state.', ...
        'The ITI follows both successful and error terminal states.', ...
        'SHOW_RULE is modeled as an instantaneous logical state in v1.'};
end


function transitions = build_nominal_transition_map(states)
%BUILD_NOMINAL_TRANSITION_MAP Build next-state mapping for nominal path.

    n_states = numel(states);
    transitions = cell(1, n_states);

    for k = 1:n_states
        tr = struct();
        tr.state_name = states{k}.name;

        if k < n_states
            tr.next_on_success = states{k+1}.name;
        else
            tr.next_on_success = 'END_TRIAL';
        end

        transitions{k} = tr;
    end
end


function value = get_field_if_present(s, field_name, default_value)
%GET_FIELD_IF_PRESENT Safe field getter.

    if isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end