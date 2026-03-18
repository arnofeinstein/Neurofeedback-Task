function test_build_timing_blueprint()
%TEST_BUILD_TIMING_BLUEPRINT Unit test for build_timing_blueprint.

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);

    blueprint = build_timing_blueprint(ml_trial);

    assert(isstruct(blueprint));
    assert(isfield(blueprint, 'states'));
    assert(isfield(blueprint, 'n_states'));
    assert(iscell(blueprint.states));
    assert(blueprint.n_states == numel(blueprint.states));
    assert(blueprint.n_states == 10);

    first_state = blueprint.states{1};
    last_state = blueprint.states{end};

    assert(strcmp(first_state.name, 'ACQUIRE_FIX'));
    assert(strcmp(last_state.name, 'ITI'));

    assert(isfield(first_state, 'duration_ms'));
    assert(isfield(first_state, 'fixation_required'));
    assert(isfield(first_state, 'stimuli'));
    assert(isfield(first_state, 'transition_rule'));

    disp('test_build_timing_blueprint passed');
end