function test_run_session_flow()
%TEST_RUN_SESSION_FLOW Unit test for run_session_flow.

    runtime = task_main();

    % Generic agent
    agent = default_agent();
    sessionlog = run_session_flow(runtime, agent);

    assert(isstruct(sessionlog));
    assert(isfield(sessionlog, 'flows'));
    assert(isfield(sessionlog, 'runlogs'));
    assert(isfield(sessionlog, 'summary'));
    assert(isfield(sessionlog, 'rule_stats'));

    assert(sessionlog.n_trials == numel(runtime.trials));
    assert(numel(sessionlog.flows) == sessionlog.n_trials);
    assert(numel(sessionlog.runlogs) == sessionlog.n_trials);
    assert(numel(sessionlog.outcomes) == sessionlog.n_trials);

    total_outcomes = ...
        sessionlog.summary.n_correct + ...
        sessionlog.summary.n_no_fixation + ...
        sessionlog.summary.n_break_fixation + ...
        sessionlog.summary.n_no_response + ...
        sessionlog.summary.n_wrong_target + ...
        sessionlog.summary.n_broke_target_hold + ...
        sessionlog.summary.n_internal_error + ...
        sessionlog.summary.n_unknown;

    assert(total_outcomes == sessionlog.n_trials, ...
        'Outcome counts do not sum to total number of trials.');

    assert(sessionlog.summary.accuracy >= 0 && sessionlog.summary.accuracy <= 1);

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

    perfect_sessionlog = run_session_flow(runtime, perfect_agent);

    assert(perfect_sessionlog.summary.n_correct == perfect_sessionlog.n_trials);
    assert(perfect_sessionlog.summary.accuracy == 1.0);
    assert(perfect_sessionlog.summary.n_no_fixation == 0);
    assert(perfect_sessionlog.summary.n_break_fixation == 0);
    assert(perfect_sessionlog.summary.n_no_response == 0);
    assert(perfect_sessionlog.summary.n_wrong_target == 0);
    assert(perfect_sessionlog.summary.n_broke_target_hold == 0);
    assert(perfect_sessionlog.summary.n_internal_error == 0);
    assert(perfect_sessionlog.summary.n_unknown == 0);

    disp('test_run_session_flow passed');
end