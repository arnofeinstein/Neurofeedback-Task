function debug_session_outcomes()
%DEBUG_SESSION_OUTCOMES Print unique outcomes and their counts.

    root_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(root_dir, 'core'));

    params = default_params();
    trials = build_trial_table(params);
    agent = default_agent();

    session = simulate_session(trials, params, agent);

    outcomes = session.outcomes;
    u = unique(outcomes);

    fprintf('\nUnique outcomes found:\n');
    for i = 1:numel(u)
        fprintf('  %s : %d\n', u{i}, sum(strcmp(outcomes, u{i})));
    end
end