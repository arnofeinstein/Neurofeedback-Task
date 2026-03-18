function T = sessionlog_to_table(sessionlog)
%SESSIONLOG_TO_TABLE Convert a session flow log into a trial-level table.
%
% Input
%   sessionlog : struct returned by run_session_flow()
%
% Output
%   T : MATLAB table with one row per trial

    % -------------------------
    % Validate input
    % -------------------------
    if ~isstruct(sessionlog)
        error('sessionlog_to_table:InvalidInput', ...
            'sessionlog must be a struct.');
    end

    required_fields = {'n_trials', 'runtime', 'flows', 'runlogs', 'outcomes'};
    for i = 1:numel(required_fields)
        if ~isfield(sessionlog, required_fields{i})
            error('sessionlog_to_table:MissingField', ...
                'Missing required field: %s', required_fields{i});
        end
    end

    n_trials = sessionlog.n_trials;
    flows = sessionlog.flows;
    runlogs = sessionlog.runlogs;

    % -------------------------
    % Preallocate columns
    % -------------------------
    trial_id = nan(n_trials, 1);
    rule_id = nan(n_trials, 1);
    rule_name = cell(n_trials, 1);
    sample_dir = nan(n_trials, 1);
    sample_side = nan(n_trials, 1);
    distractor_dir = nan(n_trials, 1);
    distractor_side = nan(n_trials, 1);
    correct_target_angle = nan(n_trials, 1);

    final_outcome = cell(n_trials, 1);
    terminal_state = cell(n_trials, 1);
    completed = false(n_trials, 1);
    response_angle = nan(n_trials, 1);
    response_correct = false(n_trials, 1);
    angular_error_deg = nan(n_trials, 1);

    n_states_visited = nan(n_trials, 1);
    last_state_name = cell(n_trials, 1);

    % -------------------------
    % Fill table row by row
    % -------------------------
    for k = 1:n_trials
        flow = flows(k);
        runlog = runlogs(k);

        trial_id(k) = get_field_if_present(flow, 'trial_id', NaN);
        rule_id(k) = get_field_if_present(flow, 'rule_id', NaN);
        rule_name{k} = to_char_row(get_field_if_present(flow, 'rule_name', ''));
        sample_dir(k) = get_field_if_present(flow, 'sample_dir', NaN);
        sample_side(k) = get_field_if_present(flow, 'sample_side', NaN);
        distractor_dir(k) = get_field_if_present(flow, 'distractor_dir', NaN);
        distractor_side(k) = get_field_if_present(flow, 'distractor_side', NaN);
        correct_target_angle(k) = get_field_if_present(flow, 'correct_target_angle', NaN);

        final_outcome{k} = to_char_row(get_field_if_present(runlog, 'final_outcome', 'internal_error'));
        terminal_state{k} = to_char_row(get_field_if_present(runlog, 'terminal_state', 'ERROR'));
        completed(k) = logical(get_field_if_present(runlog, 'completed', false));
        response_angle(k) = get_field_if_present(runlog, 'response_angle', NaN);

        if isfield(runlog, 'response_result') && ~isempty(runlog.response_result)
            rr = runlog.response_result;
            if isfield(rr, 'is_correct') && ~isempty(rr.is_correct)
                response_correct(k) = logical(rr.is_correct);
            end
            if isfield(rr, 'angular_error_deg') && ~isempty(rr.angular_error_deg)
                angular_error_deg(k) = rr.angular_error_deg;
            end
        end

        if isfield(runlog, 'state_logs') && ~isempty(runlog.state_logs)
            n_states_visited(k) = numel(runlog.state_logs);
            last_state_name{k} = to_char_row(runlog.state_logs{end}.state_name);
        else
            n_states_visited(k) = 0;
            last_state_name{k} = '';
        end
    end

    % -------------------------
    % Build table
    % -------------------------
    T = table( ...
        trial_id, ...
        rule_id, ...
        rule_name, ...
        sample_dir, ...
        sample_side, ...
        distractor_dir, ...
        distractor_side, ...
        correct_target_angle, ...
        final_outcome, ...
        terminal_state, ...
        completed, ...
        response_angle, ...
        response_correct, ...
        angular_error_deg, ...
        n_states_visited, ...
        last_state_name);

end


function value = get_field_if_present(s, field_name, default_value)
%GET_FIELD_IF_PRESENT Safe field getter.

    if isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end


function out = to_char_row(x)
%TO_CHAR_ROW Convert char/string input to row char.

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
        error('sessionlog_to_table:InvalidTextType', ...
            'Expected char or string.');
    end

    out = out(:).';
end