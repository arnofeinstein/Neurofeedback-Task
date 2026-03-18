function test_simulate_session()
%TEST_SIMULATE_SESSION Unit tests for simulate_session.

    params = default_params();
    trials = build_trial_table(params);

    % -------------------------
    % Generic agent
    % -------------------------
    agent = default_agent();
    session = simulate_session(trials, params, agent);

    assert(isstruct(session));
    assert(isfield(session, 'n_trials'));
    assert(isfield(session, 'sims'));
    assert(isfield(session, 'summary'));
    assert(isfield(session, 'condition_stats'));

    assert(session.n_trials == numel(trials));
    assert(numel(session.sims) == numel(trials));

    total_outcomes = ...
        session.summary.n_correct + ...
        session.summary.n_no_fixation + ...
        session.summary.n_break_fixation + ...
        session.summary.n_no_response + ...
        session.summary.n_wrong_target + ...
        session.summary.n_broke_target_hold + ...
        session.summary.n_internal_error + ...
        session.summary.n_unknown;

    assert(total_outcomes == numel(trials), ...
        'Outcome counts do not sum to total number of trials.');

    assert(session.summary.n_unknown == 0, ...
        'Unknown outcomes detected in session.');

    assert(session.summary.accuracy >= 0 && session.summary.accuracy <= 1);

    % -------------------------
    % Perfect agent
    % -------------------------
    perfect_agent = struct();
    perfect_agent.p_acquire_fix = 1.0;
    perfect_agent.p_hold_fix_initial = 1.0;
    perfect_agent.p_hold_fix_sample = 1.0;
    perfect_agent.p_hold_fix_delay = 1.0;
    perfect_agent.p_hold_fix_distractor = 1.0;
    perfect_agent.p_make_response = 1.0;
    perfect_agent.p_choose_correct = 1.0;
    perfect_agent.p_hold_target = 1.0;

    perfect_session = simulate_session(trials, params, perfect_agent);

    assert(perfect_session.summary.n_correct == numel(trials));
    assert(perfect_session.summary.accuracy == 1.0);
    assert(perfect_session.summary.n_no_fixation == 0);
    assert(perfect_session.summary.n_break_fixation == 0);
    assert(perfect_session.summary.n_no_response == 0);
    assert(perfect_session.summary.n_wrong_target == 0);
    assert(perfect_session.summary.n_broke_target_hold == 0);
    assert(perfect_session.summary.n_internal_error == 0);
    assert(perfect_session.summary.n_unknown == 0);

    disp('test_simulate_session passed');
end