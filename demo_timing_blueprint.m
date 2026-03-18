function demo_timing_blueprint()
%DEMO_TIMING_BLUEPRINT Print one trial timing blueprint.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    params = default_params();
    trials = build_trial_table(params);
    ml_trial = ml_prepare_trial(trials(1), params);
    blueprint = build_timing_blueprint(ml_trial);

    fprintf('\n=== Timing blueprint ===\n');
    fprintf('Trial id             : %d\n', blueprint.trial_id);
    fprintf('Rule                 : %s\n', blueprint.rule_name);
    fprintf('Sample dir           : %d\n', blueprint.sample_dir);
    fprintf('Correct target angle : %d\n\n', blueprint.correct_target_angle);

    for k = 1:blueprint.n_states
        s = blueprint.states{k};

        fprintf('State %2d | %-16s | dur=%4d ms | fix=%d | transition=%s\n', ...
            k, s.name, s.duration_ms, s.fixation_required, s.transition_rule);

        if isempty(s.stimuli)
            fprintf('          stimuli: none\n');
        else
            fprintf('          stimuli: %s\n', strjoin(s.stimuli, ', '));
        end
    end
end