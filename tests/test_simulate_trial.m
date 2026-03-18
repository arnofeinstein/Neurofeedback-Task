function test_simulate_trial()
%TEST_SIMULATE_TRIAL Unit tests for simulate_trial.

    params = default_params();
    trials = build_trial_table(params);
    trial = trials(1);

    % -------------------------
    % Generic simulated agent
    % -------------------------
    agent = default_agent();
    sim = simulate_trial(trial, params, agent);

    assert(isstruct(sim));
    assert(isfield(sim, 'state_history'));
    assert(isfield(sim, 'outcome'));
    assert(isfield(sim, 'completed'));
    assert(iscell(sim.state_history));
    assert(ischar(sim.outcome) || isstring(sim.outcome));

    % -------------------------
    % Perfect agent should always succeed
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

    sim2 = simulate_trial(trial, params, perfect_agent);

    assert(strcmp(sim2.outcome, 'correct'));
    assert(sim2.completed == true);
    assert(strcmp(sim2.state_history{end}, 'REWARD'));

    disp('test_simulate_trial passed');
end