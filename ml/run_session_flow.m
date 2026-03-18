function sessionlog = run_session_flow(runtime, agent)
%RUN_SESSION_FLOW Execute a full session using flow-based trial runners.
%
% Inputs
%   runtime : struct returned by task_main()
%   agent   : struct returned by default_agent()
%
% Output
%   sessionlog : struct containing flow specs, per-trial run logs,
%                and session summary statistics

    % -------------------------
    % Validate inputs
    % -------------------------
    if ~isstruct(runtime)
        error('run_session_flow:InvalidRuntime', ...
            'runtime must be a struct.');
    end

    if ~isfield(runtime, 'trials') || ~isfield(runtime, 'params')
        error('run_session_flow:IncompleteRuntime', ...
            'runtime must contain trials and params.');
    end

    if ~isstruct(agent)
        error('run_session_flow:InvalidAgent', ...
            'agent must be a struct.');
    end

    % -------------------------
    % Prepare
    % -------------------------
    n_trials = numel(runtime.trials);

    first_ml_trial = ml_prepare_trial(runtime.trials(1), runtime.params);
    first_flow = build_trial_flow_spec(first_ml_trial);
    first_runlog = run_trial_flow(first_flow, agent);

    flows(1, n_trials) = first_flow;
    flows(1) = first_flow;

    runlogs(1, n_trials) = first_runlog;
    runlogs(1) = first_runlog;

    % -------------------------
    % Run remaining trials
    % -------------------------
    for k = 2:n_trials
        ml_trial = ml_prepare_trial(runtime.trials(k), runtime.params);
        flows(k) = build_trial_flow_spec(ml_trial);
        runlogs(k) = run_trial_flow(flows(k), agent);
    end

    % -------------------------
    % Collect outcomes
    % -------------------------
    outcomes = cell(1, n_trials);
    completed_flags = false(1, n_trials);

    for k = 1:n_trials
        outcomes{k} = normalize_outcome(runlogs(k).final_outcome);
        completed_flags(k) = logical(runlogs(k).completed);
    end

    % -------------------------
    % Summary counts
    % -------------------------
    n_correct = sum(strcmp(outcomes, 'correct'));
    n_no_fixation = sum(strcmp(outcomes, 'no_fixation'));
    n_break_fixation = sum(strcmp(outcomes, 'break_fixation'));
    n_no_response = sum(strcmp(outcomes, 'no_response'));
    n_wrong_target = sum(strcmp(outcomes, 'wrong_target'));
    n_broke_target_hold = sum(strcmp(outcomes, 'broke_target_hold'));
    n_internal_error = sum(strcmp(outcomes, 'internal_error'));

    n_known = n_correct + ...
              n_no_fixation + ...
              n_break_fixation + ...
              n_no_response + ...
              n_wrong_target + ...
              n_broke_target_hold + ...
              n_internal_error;

    n_unknown = n_trials - n_known;
    accuracy = n_correct / n_trials;

    % -------------------------
    % Accuracy by rule
    % -------------------------
    rule_ids = [runtime.trials.rule_id];
    unique_rules = unique(rule_ids);
    accuracy_by_rule = zeros(size(unique_rules));

    for i = 1:numel(unique_rules)
        mask = (rule_ids == unique_rules(i));
        accuracy_by_rule(i) = mean(strcmp(outcomes(mask), 'correct'));
    end

    % -------------------------
    % Pack output
    % -------------------------
    sessionlog = struct();
    sessionlog.n_trials = n_trials;
    sessionlog.runtime = runtime;
    sessionlog.flows = flows;
    sessionlog.runlogs = runlogs;
    sessionlog.outcomes = outcomes;
    sessionlog.completed_flags = completed_flags;

    sessionlog.summary = struct();
    sessionlog.summary.n_correct = n_correct;
    sessionlog.summary.n_no_fixation = n_no_fixation;
    sessionlog.summary.n_break_fixation = n_break_fixation;
    sessionlog.summary.n_no_response = n_no_response;
    sessionlog.summary.n_wrong_target = n_wrong_target;
    sessionlog.summary.n_broke_target_hold = n_broke_target_hold;
    sessionlog.summary.n_internal_error = n_internal_error;
    sessionlog.summary.n_unknown = n_unknown;
    sessionlog.summary.accuracy = accuracy;

    sessionlog.rule_stats = struct();
    sessionlog.rule_stats.unique_rules = unique_rules;
    sessionlog.rule_stats.accuracy_by_rule = accuracy_by_rule;
end


function out = normalize_outcome(x)
%NORMALIZE_OUTCOME Convert outcome to a row char vector.

    if isempty(x)
        out = 'internal_error';
        return;
    end

    if isstring(x)
        x = x(1);
        out = char(x);
    elseif ischar(x)
        out = x;
    else
        error('run_session_flow:InvalidOutcomeType', ...
            'Outcome must be char or string.');
    end

    out = out(:).';
end