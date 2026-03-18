function demo_trial_flow_spec()
%DEMO_TRIAL_FLOW_SPEC Print the canonical trial flow specification.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);

    flow = build_trial_flow_spec(ml_trial);

    fprintf('\n=== Trial flow spec ===\n');
    fprintf('Trial id             : %d\n', flow.trial_id);
    fprintf('Rule                 : %s\n', flow.rule_name);
    fprintf('Sample dir           : %d\n', flow.sample_dir);
    fprintf('Sample side          : %d\n', flow.sample_side);
    fprintf('Distractor dir       : %d\n', flow.distractor_dir);
    fprintf('Distractor side      : %d\n', flow.distractor_side);
    fprintf('Correct target angle : %d\n\n', flow.correct_target_angle);

    fprintf('Nominal path:\n');
    for k = 1:flow.n_nominal_states
        s = flow.nominal_states{k};
        fprintf('  %2d. %-16s | dur=%4d ms | fix=%d\n', ...
            k, s.name, s.duration_ms, s.fixation_required);
    end

    fprintf('\nNominal transitions:\n');
    for k = 1:numel(flow.transitions)
        tr = flow.transitions{k};
        fprintf('  %-16s -> %s\n', tr.state_name, tr.next_on_success);
    end

    fprintf('\nError branches:\n');
    for k = 1:flow.n_error_branches
        b = flow.error_branches{k};
        fprintf('  %-16s -> %s on [%s]\n', ...
            b.state_name, b.next_state, strjoin(b.outcome_labels, ', '));
    end

    fprintf('\nTerminal states:\n');
    fprintf('  Success: %s -> %s\n', ...
        flow.terminal_states.success.name, ...
        flow.terminal_states.success.followed_by);

    fprintf('  Error  : %s -> %s\n', ...
        flow.terminal_states.error.name, ...
        flow.terminal_states.error.followed_by);
end