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
    assert(isfield(ml_trial, 'response_targets'));
    assert(isfield(ml_trial, 'display'));
    assert(isfield(ml_trial, 'monkeylogic'));

    assert(numel(ml_trial.sample_pos_deg) == 2);
    assert(numel(ml_trial.distractor_pos_deg) == 2);
    assert(numel(ml_trial.correct_target_pos_deg) == 2);
    assert(numel(ml_trial.response_targets) == numel(params.sample_dirs));
    assert(sum([ml_trial.response_targets.is_correct]) == 1);
    assert(strcmp(ml_trial.monkeylogic.timing_file, 'tf_rule_rdk.m'));
    assert(ml_trial.monkeylogic.placeholder_mode == true);
    assert(isfield(ml_trial.display, 'rule_cue'));
    assert(isfield(ml_trial.display, 'sample_placeholder'));
    assert(isfield(ml_trial.display, 'distractor_placeholder'));
    expected_shapes = struct('pro', 'square', 'anti', 'circle', 'plus90', 'triangle');
    for i = 1:numel(trials)
        rule_name = trials(i).rule_name;
        if isfield(expected_shapes, rule_name)
            rule_trial = ml_prepare_trial(trials(i), params);
            assert(strcmp(rule_trial.display.rule_cue.shape, ...
                expected_shapes.(rule_name)));
        end
    end

    disp('test_ml_prepare_trial passed');
end
