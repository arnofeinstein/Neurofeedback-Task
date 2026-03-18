function runtime = task_main()
%TASK_MAIN Prepare task runtime structure for future MonkeyLogic use.
%
% This function does not run MonkeyLogic itself.
% It prepares all task information that the MonkeyLogic layer will need.

    project_root = fileparts(fileparts(mfilename('fullpath')));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    params = default_params();
    trials = build_trial_table(params);

    runtime = struct();
    runtime.project_root = project_root;
    runtime.params = params;
    runtime.trials = trials;
    runtime.n_trials = numel(trials);
    runtime.current_trial_index = 1;

    fprintf('task_main initialized\n');
    fprintf('Number of trials: %d\n', runtime.n_trials);
end