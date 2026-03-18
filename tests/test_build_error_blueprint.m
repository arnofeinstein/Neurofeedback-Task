function test_build_error_blueprint()
%TEST_BUILD_ERROR_BLUEPRINT Unit test for build_error_blueprint.

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);

    error_bp = build_error_blueprint(ml_trial);

    assert(isstruct(error_bp));
    assert(isfield(error_bp, 'branches'));
    assert(isfield(error_bp, 'n_branches'));
    assert(isfield(error_bp, 'terminal_error_state'));

    assert(iscell(error_bp.branches));
    assert(error_bp.n_branches == numel(error_bp.branches));
    assert(error_bp.n_branches == 7);

    first_branch = error_bp.branches{1};
    assert(strcmp(first_branch.state_name, 'ACQUIRE_FIX'));
    assert(iscell(first_branch.outcome_labels));
    assert(strcmp(first_branch.next_state, 'ERROR'));

    assert(strcmp(error_bp.terminal_error_state.name, 'ERROR'));
    assert(strcmp(error_bp.terminal_error_state.followed_by, 'ITI'));

    disp('test_build_error_blueprint passed');
end