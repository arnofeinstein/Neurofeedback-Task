function session = simulate_session(trials, params, agent)
%SIMULATE_SESSION Simulate a full session across many trials.
%
% Inputs
%   trials  : struct array from build_trial_table()
%   params  : task parameter struct
%   agent   : simulated agent struct
%
% Output
%   session : struct containing per-trial simulations and summary stats

    % -------------------------
    % Validate inputs
    % -------------------------
    if ~isstruct(trials) || isempty(trials)
        error('simulate_session:InvalidTrials', ...
            'trials must be a non-empty struct array.');
    end

    if ~isstruct(params)
        error('simulate_session:InvalidParams', ...
            'params must be a struct.');
    end

    if ~isstruct(agent)
        error('simulate_session:InvalidAgent', ...
            'agent must be a struct.');
    end

    % -------------------------
    % Simulate all trials
    % -------------------------
    n_trials = numel(trials);

    first_sim = simulate_trial(trials(1), params, agent);
    sims(1, n_trials) = first_sim;
    sims(1) = first_sim;

    for k = 2:n_trials
        sims(k) = simulate_trial(trials(k), params, agent);
    end

    % -------------------------
    % Normalize outcomes
    % -------------------------
    outcomes = cell(1, n_trials);
    for k = 1:n_trials
        outcomes{k} = normalize_outcome(sims(k).outcome);
    end

    % -------------------------
    % Outcome counts
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
    % Condition counts
    % -------------------------
    sample_dirs = [trials.sample_dir];
    sample_sides = [trials.sample_side];
    rule_ids = [trials.rule_id];

    unique_dirs = unique(sample_dirs);
    unique_sides = unique(sample_sides);
    unique_rules = unique(rule_ids);

    counts_by_dir = zeros(size(unique_dirs));
    counts_by_side = zeros(size(unique_sides));
    counts_by_rule = zeros(size(unique_rules));

    for i = 1:numel(unique_dirs)
        counts_by_dir(i) = sum(sample_dirs == unique_dirs(i));
    end

    for i = 1:numel(unique_sides)
        counts_by_side(i) = sum(sample_sides == unique_sides(i));
    end

    for i = 1:numel(unique_rules)
        counts_by_rule(i) = sum(rule_ids == unique_rules(i));
    end

    % -------------------------
    % Accuracy by rule
    % -------------------------
    accuracy_by_rule = zeros(size(unique_rules));

    for i = 1:numel(unique_rules)
        mask = (rule_ids == unique_rules(i));
        accuracy_by_rule(i) = mean(strcmp(outcomes(mask), 'correct'));
    end

    % -------------------------
    % Pack output
    % -------------------------
    session = struct();
    session.n_trials = n_trials;
    session.trials = trials;
    session.sims = sims;
    session.outcomes = outcomes;

    session.summary = struct();
    session.summary.n_correct = n_correct;
    session.summary.n_no_fixation = n_no_fixation;
    session.summary.n_break_fixation = n_break_fixation;
    session.summary.n_no_response = n_no_response;
    session.summary.n_wrong_target = n_wrong_target;
    session.summary.n_broke_target_hold = n_broke_target_hold;
    session.summary.n_internal_error = n_internal_error;
    session.summary.n_unknown = n_unknown;
    session.summary.accuracy = accuracy;

    session.condition_stats = struct();
    session.condition_stats.unique_dirs = unique_dirs;
    session.condition_stats.counts_by_dir = counts_by_dir;
    session.condition_stats.unique_sides = unique_sides;
    session.condition_stats.counts_by_side = counts_by_side;
    session.condition_stats.unique_rules = unique_rules;
    session.condition_stats.counts_by_rule = counts_by_rule;
    session.condition_stats.accuracy_by_rule = accuracy_by_rule;
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
        error('simulate_session:InvalidOutcomeType', ...
            'Outcome must be char or string.');
    end

    out = out(:).';
end