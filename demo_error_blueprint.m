function demo_error_blueprint()
%DEMO_ERROR_BLUEPRINT Print the state-specific error exits.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);

    error_bp = build_error_blueprint(ml_trial);

    fprintf('\n=== Error blueprint ===\n');
    fprintf('Trial id             : %d\n', error_bp.trial_id);
    fprintf('Rule                 : %s\n', error_bp.rule_name);
    fprintf('Sample dir           : %d\n', error_bp.sample_dir);
    fprintf('Correct target angle : %d\n\n', error_bp.correct_target_angle);

    for k = 1:error_bp.n_branches
        b = error_bp.branches{k};

        fprintf('State %-16s -> %s on: %s\n', ...
            b.state_name, ...
            b.next_state, ...
            strjoin(b.outcome_labels, ', '));
    end

    fprintf('\nTerminal error state: %s -> %s\n', ...
        error_bp.terminal_error_state.name, ...
        error_bp.terminal_error_state.followed_by);
end