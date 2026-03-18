function trials = build_trial_table(params)
%BUILD_TRIAL_TABLE Build a balanced randomized trial table.
%
% Inputs
%   params : struct returned by default_params()
%
% Output
%   trials : struct array with one element per trial
%
% Each trial contains:
%   trial_id
%   sample_dir
%   sample_side
%   distractor_dir
%   distractor_side
%   rule_id
%   rule_name
%   delay_dur_ms
%   correct_target_angle

    % -------------------------
    % Validate required fields
    % -------------------------
    required_fields = { ...
        'sample_dirs', ...
        'sample_sides', ...
        'rules', ...
        'rule_names', ...
        'distractor_dir', ...
        'delay_min_ms', ...
        'delay_max_ms', ...
        'n_repeats_per_condition'};

    for i = 1:numel(required_fields)
        if ~isfield(params, required_fields{i})
            error('build_trial_table:MissingField', ...
                'Missing required params field: %s', required_fields{i});
        end
    end

    if numel(params.rule_names) ~= numel(params.rules)
        error('build_trial_table:RuleNameMismatch', ...
            'params.rule_names and params.rules must have same length.');
    end

    % -------------------------
    % Build all condition combinations
    % -------------------------
    sample_dirs = params.sample_dirs;
    sample_sides = params.sample_sides;
    rules = params.rules;

    n_dirs = numel(sample_dirs);
    n_sides = numel(sample_sides);
    n_rules = numel(rules);
    n_repeats = params.n_repeats_per_condition;

    n_conditions = n_dirs * n_sides * n_rules;
    n_trials = n_conditions * n_repeats;

    base_conditions = struct( ...
        'sample_dir', cell(n_conditions,1), ...
        'sample_side', cell(n_conditions,1), ...
        'rule_id', cell(n_conditions,1), ...
        'rule_name', cell(n_conditions,1));

    idx = 0;
    for i_dir = 1:n_dirs
        for i_side = 1:n_sides
            for i_rule = 1:n_rules
                idx = idx + 1;
                base_conditions(idx).sample_dir = sample_dirs(i_dir);
                base_conditions(idx).sample_side = sample_sides(i_side);
                base_conditions(idx).rule_id = rules(i_rule);
                base_conditions(idx).rule_name = params.rule_names{i_rule};
            end
        end
    end

    % -------------------------
    % Repeat conditions
    % -------------------------
    all_conditions = repmat(base_conditions, n_repeats, 1);
    all_conditions = all_conditions(:);

    % -------------------------
    % Randomize trial order
    % -------------------------
    perm = randperm(n_trials);
    all_conditions = all_conditions(perm);

    % -------------------------
    % Fill derived trial fields
    % -------------------------
    trials = struct( ...
        'trial_id', cell(n_trials,1), ...
        'sample_dir', cell(n_trials,1), ...
        'sample_side', cell(n_trials,1), ...
        'distractor_dir', cell(n_trials,1), ...
        'distractor_side', cell(n_trials,1), ...
        'rule_id', cell(n_trials,1), ...
        'rule_name', cell(n_trials,1), ...
        'delay_dur_ms', cell(n_trials,1), ...
        'correct_target_angle', cell(n_trials,1));

    for k = 1:n_trials
        sample_dir = all_conditions(k).sample_dir;
        sample_side = all_conditions(k).sample_side;
        rule_id = all_conditions(k).rule_id;

        delay_dur_ms = randi([params.delay_min_ms, params.delay_max_ms], 1, 1);
        correct_target_angle = transform_rule(sample_dir, rule_id);

        trials(k).trial_id = k;
        trials(k).sample_dir = sample_dir;
        trials(k).sample_side = sample_side;
        trials(k).distractor_dir = params.distractor_dir;
        trials(k).distractor_side = -sample_side;
        trials(k).rule_id = rule_id;
        trials(k).rule_name = all_conditions(k).rule_name;
        trials(k).delay_dur_ms = delay_dur_ms;
        trials(k).correct_target_angle = correct_target_angle;
    end
end