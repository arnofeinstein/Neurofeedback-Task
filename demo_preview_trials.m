function demo_preview_trials()
%DEMO_PREVIEW_TRIALS Preview a few randomly generated trials.

    root_dir = fileparts(mfilename('fullpath'));

    addpath(fullfile(root_dir, 'core'));
    addpath(fullfile(root_dir, 'preview'));

    params = default_params();
    trials = build_trial_table(params);

    % Preview first few trials
    n_preview = min(3, numel(trials));

    for k = 1:n_preview
        preview_trial_layout(trials(k), params);
    end
end