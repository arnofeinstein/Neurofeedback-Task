function demo_ml_skeleton()
%DEMO_ML_SKELETON Preview the future MonkeyLogic-facing trial structure.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    runtime = task_main();

    trial_index = 1;
    [ml_trial, trial_index] = userloop(runtime, trial_index);
    taskobjects = ml_taskobjects_for_trial(ml_trial);

    fprintf('\n=== ML skeleton demo ===\n');
    fprintf('Trial index            : %d\n', trial_index);
    fprintf('Trial id               : %d\n', ml_trial.trial_id);
    fprintf('Sample dir             : %d\n', ml_trial.sample_dir);
    fprintf('Sample side            : %d\n', ml_trial.sample_side);
    fprintf('Distractor dir         : %d\n', ml_trial.distractor_dir);
    fprintf('Distractor side        : %d\n', ml_trial.distractor_side);
    fprintf('Rule                   : %s\n', ml_trial.rule_name);
    fprintf('Delay                  : %d ms\n', ml_trial.delay_dur_ms);
    fprintf('Correct target angle   : %d\n', ml_trial.correct_target_angle);
    fprintf('Correct target pos     : [%.2f, %.2f]\n', ...
        ml_trial.correct_target_pos_deg(1), ...
        ml_trial.correct_target_pos_deg(2));
    fprintf('Timing file            : %s\n', ml_trial.monkeylogic.timing_file);
    fprintf('TaskObjects prepared   : %d\n', numel(taskobjects.task_object_strings));
    fprintf('Rule cue label         : %s\n', ml_trial.display.rule_cue.label);
    fprintf('Rule cue shape         : %s\n', ml_trial.display.rule_cue.shape);
end
