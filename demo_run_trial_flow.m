function demo_run_trial_flow()
%DEMO_RUN_TRIAL_FLOW Execute one flow and print the execution trace.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    rng(1);

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);
    flow = build_trial_flow_spec(ml_trial);
    agent = default_agent();

    runlog = run_trial_flow(flow, agent);

    fprintf('\n=== Run trial flow ===\n');
    fprintf('Trial id       : %d\n', runlog.trial_id);
    fprintf('Rule           : %s\n', runlog.rule_name);
    fprintf('Sample dir     : %d\n', runlog.sample_dir);
    fprintf('Correct target : %d\n\n', runlog.correct_target_angle);

    for k = 1:numel(runlog.state_logs)
        s = runlog.state_logs{k};
        fprintf('State %-16s | status=%-7s | outcome=%-24s | next=%s\n', ...
            s.state_name, s.status, s.outcome, s.next_state);
    end

    fprintf('\nFinal outcome  : %s\n', runlog.final_outcome);
    fprintf('Terminal state : %s\n', runlog.terminal_state);
    fprintf('Completed      : %d\n', runlog.completed);

    if ~isnan(runlog.response_angle)
        fprintf('Response angle : %d\n', round(runlog.response_angle));
    end
end