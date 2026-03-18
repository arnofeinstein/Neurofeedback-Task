function demo_simulate_session()
%DEMO_SIMULATE_SESSION Simulate one full session and print summary stats.

    root_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(root_dir, 'core'));
    
    rng(1);
    params = default_params();
    trials = build_trial_table(params);
    agent = default_agent();

    session = simulate_session(trials, params, agent);

    fprintf('\n=== Session summary ===\n');
    fprintf('Total trials        : %d\n', session.n_trials);
    fprintf('Correct             : %d\n', session.summary.n_correct);
    fprintf('No fixation         : %d\n', session.summary.n_no_fixation);
    fprintf('Break fixation      : %d\n', session.summary.n_break_fixation);
    fprintf('No response         : %d\n', session.summary.n_no_response);
    fprintf('Wrong target        : %d\n', session.summary.n_wrong_target);
    fprintf('Broke target hold   : %d\n', session.summary.n_broke_target_hold);
    fprintf('Accuracy            : %.3f\n', session.summary.accuracy);

    fprintf('\n=== Accuracy by rule ===\n');
    for i = 1:numel(session.condition_stats.unique_rules)
        rule_id = session.condition_stats.unique_rules(i);
        acc = session.condition_stats.accuracy_by_rule(i);
        fprintf('Rule %d : %.3f\n', rule_id, acc);
    end

    fprintf('\n=== Counts by sample direction ===\n');
    for i = 1:numel(session.condition_stats.unique_dirs)
        fprintf('%3d deg : %d\n', ...
            session.condition_stats.unique_dirs(i), ...
            session.condition_stats.counts_by_dir(i));
    end
end