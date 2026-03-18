function test_ml_taskobjects_for_trial()
%TEST_ML_TASKOBJECTS_FOR_TRIAL Unit test for placeholder TaskObject bundle.

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);

    taskobjects = ml_taskobjects_for_trial(ml_trial);

    assert(isstruct(taskobjects));
    assert(isfield(taskobjects, 'task_object_strings'));
    assert(isfield(taskobjects, 'task_object_names'));
    assert(isfield(taskobjects, 'indices'));
    assert(isfield(taskobjects, 'response_target_map'));
    assert(isfield(taskobjects, 'state_taskobjects'));
    assert(isfield(taskobjects, 'rule_cue'));

    assert(iscell(taskobjects.task_object_strings));
    assert(numel(taskobjects.task_object_strings) == 3 + numel(params.sample_dirs));
    assert(taskobjects.indices.fixation_point == 1);
    assert(taskobjects.indices.sample_placeholder == 2);
    assert(taskobjects.indices.distractor_placeholder == 3);
    assert(numel(taskobjects.indices.response_targets) == numel(params.sample_dirs));

    assert(strcmp(taskobjects.task_object_names{1}, 'fixation_point'));
    assert(strncmp(taskobjects.task_object_strings{1}, 'fix(', 4));
    assert(strncmp(taskobjects.task_object_strings{2}, 'sqr(', 4));
    assert(strncmp(taskobjects.task_object_strings{4}, 'crc(', 4));

    correct_mask = [taskobjects.response_target_map.is_correct];
    assert(sum(correct_mask) == 1);
    correct_target = taskobjects.response_target_map(correct_mask);
    assert(taskobjects.indices.correct_target == correct_target.task_object_index);

    assert(strcmp(taskobjects.timing_file, 'tf_rule_rdk.m'));
    assert(taskobjects.placeholder_mode == true);
    assert(isfield(taskobjects.state_taskobjects, 'WAIT_FOR_SACCADE'));
    assert(any(strcmp(taskobjects.rule_cue.shape, {'square', 'circle', 'triangle'})));

    disp('test_ml_taskobjects_for_trial passed');
end
