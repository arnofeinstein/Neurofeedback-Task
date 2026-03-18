function test_run_trial_flow()
%TEST_RUN_TRIAL_FLOW Unit test for run_trial_flow.

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);
    flow = build_trial_flow_spec(ml_trial);

    % Generic agent
    agent = default_agent();
    runlog = run_trial_flow(flow, agent);

    assert(isstruct(runlog));
    assert(isfield(runlog, 'state_logs'));
    assert(isfield(runlog, 'final_outcome'));
    assert(isfield(runlog, 'terminal_state'));
    assert(isfield(runlog, 'completed'));
    assert(iscell(runlog.state_logs));
    assert(~isempty(runlog.final_outcome));

    % Perfect agent
    perfect_agent = struct();
    perfect_agent.p_acquire_fix = 1.0;
    perfect_agent.p_hold_fix_initial = 1.0;
    perfect_agent.p_hold_fix_sample = 1.0;
    perfect_agent.p_hold_fix_delay = 1.0;
    perfect_agent.p_hold_fix_distractor = 1.0;
    perfect_agent.p_make_response = 1.0;
    perfect_agent.p_choose_correct = 1.0;
    perfect_agent.p_hold_target = 1.0;

    perfect_runlog = run_trial_flow(flow, perfect_agent);

    assert(strcmp(perfect_runlog.final_outcome, 'correct'));
    assert(strcmp(perfect_runlog.terminal_state, 'REWARD'));
    assert(perfect_runlog.completed == true);
    assert(strcmp(perfect_runlog.state_logs{end}.state_name, 'ITI'));

    disp('test_run_trial_flow passed');
end