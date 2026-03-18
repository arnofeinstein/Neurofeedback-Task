function test_ml_prepare_trial()
%TEST_ML_PREPARE_TRIAL Unit test for ml_prepare_trial.

    params = default_params();
    trials = build_trial_table(params);

    ml_trial = ml_prepare_trial(trials(1), params);

    assert(isstruct(ml_trial));
    assert(isfield(ml_trial, 'sample_dir'));
    assert(isfield(ml_trial, 'sample_pos_deg'));
    assert(isfield(ml_trial, 'distractor_pos_deg'));
    assert(isfield(ml_trial, 'correct_target_angle'));
    assert(isfield(ml_trial, 'correct_target_pos_deg'));
    assert(isfield(ml_trial, 'timing'));
    assert(isfield(ml_trial, 'windows'));

    assert(numel(ml_trial.sample_pos_deg) == 2);
    assert(numel(ml_trial.distractor_pos_deg) == 2);
    assert(numel(ml_trial.correct_target_pos_deg) == 2);

    disp('test_ml_prepare_trial passed');
end