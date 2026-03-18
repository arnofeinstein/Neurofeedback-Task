function demo_simulate_trials()
%DEMO_SIMULATE_TRIALS Simulate several trials and print their outcomes.

    root_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(root_dir, 'core'));

    params = default_params();
    trials = build_trial_table(params);
    agent = default_agent();

    n_show = min(15, numel(trials));

    fprintf('Simulating %d trials...\n\n', n_show);

    for k = 1:n_show
        sim = simulate_trial(trials(k), params, agent);

        fprintf(['trial %2d | sample=%3d | side=%2d | rule=%-6s | ' ...
                 'correct=%3d | response=%6s | outcome=%s\n'], ...
                 trials(k).trial_id, ...
                 trials(k).sample_dir, ...
                 trials(k).sample_side, ...
                 trials(k).rule_name, ...
                 trials(k).correct_target_angle, ...
                 format_angle(sim.response_angle), ...
                 sim.outcome);
    end
end


function txt = format_angle(a)
%FORMAT_ANGLE Helper for display.

    if isnan(a)
        txt = 'NaN';
    else
        txt = sprintf('%3d', round(a));
    end
end