function demo_validate_session_table()
%DEMO_VALIDATE_SESSION_TABLE Validate and display a session table report.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    rng(1);

    runtime = task_main();
    agent = default_agent();

    sessionlog = run_session_flow(runtime, agent);
    T = sessionlog_to_table(sessionlog);
    schema = build_behavior_schema();

    [T_valid, report] = validate_session_table(T, schema);

    fprintf('\n=== Validate session table ===\n');
    fprintf('Rows              : %d\n', report.n_rows);
    fprintf('Input columns     : %d\n', report.n_cols_input);
    fprintf('Output columns    : %d\n', report.n_cols_output);
    fprintf('Schema valid      : %d\n', report.is_valid);
    fprintf('Missing vars      : %d\n', numel(report.missing_vars));
    fprintf('Extra vars        : %d\n', numel(report.extra_vars));

    if ~isempty(report.missing_vars)
        fprintf('\nMissing variables:\n');
        for i = 1:numel(report.missing_vars)
            fprintf('  - %s\n', report.missing_vars{i});
        end
    end

    if ~isempty(report.extra_vars)
        fprintf('\nExtra variables:\n');
        for i = 1:numel(report.extra_vars)
            fprintf('  - %s\n', report.extra_vars{i});
        end
    end

    fprintf('\nFirst variables after reordering:\n');
    n_show = min(10, width(T_valid));
    for i = 1:n_show
        fprintf('  %2d. %s\n', i, T_valid.Properties.VariableNames{i});
    end
end