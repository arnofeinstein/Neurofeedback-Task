function demo_run_session_flow()
%DEMO_RUN_SESSION_FLOW Execute a full flow-based session and print summary.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    rng(1);

    runtime = task_main();
    agent = default_agent();

    sessionlog = run_session_flow(runtime, agent);

    fprintf('\n=== Run session flow ===\n');
    fprintf('Total trials        : %d\n', sessionlog.n_trials);
    fprintf('Correct             : %d\n', sessionlog.summary.n_correct);
    fprintf('No fixation         : %d\n', sessionlog.summary.n_no_fixation);
    fprintf('Break fixation      : %d\n', sessionlog.summary.n_break_fixation);
    fprintf('No response         : %d\n', sessionlog.summary.n_no_response);
    fprintf('Wrong target        : %d\n', sessionlog.summary.n_wrong_target);
    fprintf('Broke target hold   : %d\n', sessionlog.summary.n_broke_target_hold);
    fprintf('Internal error      : %d\n', sessionlog.summary.n_internal_error);
    fprintf('Unknown             : %d\n', sessionlog.summary.n_unknown);
    fprintf('Accuracy            : %.3f\n', sessionlog.summary.accuracy);

    fprintf('\n=== Accuracy by rule ===\n');
    for i = 1:numel(sessionlog.rule_stats.unique_rules)
        fprintf('Rule %d : %.3f\n', ...
            sessionlog.rule_stats.unique_rules(i), ...
            sessionlog.rule_stats.accuracy_by_rule(i));
    end

    fprintf('\n=== First 5 trial outcomes ===\n');
    n_show = min(5, sessionlog.n_trials);
    for k = 1:n_show
        fprintf('Trial %d -> %s\n', k, sessionlog.outcomes{k});
    end
end