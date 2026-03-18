function test_build_trial_flow_spec()
%TEST_BUILD_TRIAL_FLOW_SPEC Unit test for build_trial_flow_spec.

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);

    flow = build_trial_flow_spec(ml_trial);

    assert(isstruct(flow));
    assert(isfield(flow, 'nominal_states'));
    assert(isfield(flow, 'error_branches'));
    assert(isfield(flow, 'terminal_states'));
    assert(isfield(flow, 'transitions'));
    assert(isfield(flow, 'allowed_outcomes'));

    assert(iscell(flow.nominal_states));
    assert(iscell(flow.error_branches));
    assert(iscell(flow.transitions));

    assert(flow.n_nominal_states == numel(flow.nominal_states));
    assert(flow.n_error_branches == numel(flow.error_branches));

    assert(strcmp(flow.nominal_states{1}.name, 'ACQUIRE_FIX'));
    assert(strcmp(flow.nominal_states{end}.name, 'ITI'));

    assert(strcmp(flow.transitions{1}.state_name, 'ACQUIRE_FIX'));
    assert(strcmp(flow.transitions{1}.next_on_success, 'HOLD_FIX'));

    assert(strcmp(flow.terminal_states.success.name, 'REWARD'));
    assert(strcmp(flow.terminal_states.error.name, 'ERROR'));

    assert(any(strcmp(flow.allowed_outcomes, 'correct')));
    assert(any(strcmp(flow.allowed_outcomes, 'wrong_target')));

    disp('test_build_trial_flow_spec passed');
end