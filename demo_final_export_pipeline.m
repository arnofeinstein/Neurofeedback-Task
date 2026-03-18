function demo_final_export_pipeline()
%DEMO_FINAL_EXPORT_PIPELINE Run full session export in one command.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    rng(1);

    runtime = task_main();
    agent = default_agent();
    sessionlog = run_session_flow(runtime, agent);

    result = final_export_pipeline(sessionlog);

    fprintf('\n=== Final export pipeline ===\n');
    fprintf('Rows exported      : %d\n', height(result.table_valid));
    fprintf('Columns exported   : %d\n', width(result.table_valid));
    fprintf('Schema valid       : %d\n', result.validation_report.is_valid);
    fprintf('Output path        : %s\n', result.output_path);

    if ~isempty(result.validation_report.missing_vars)
        fprintf('\nMissing variables:\n');
        for i = 1:numel(result.validation_report.missing_vars)
            fprintf('  - %s\n', result.validation_report.missing_vars{i});
        end
    end

    if ~isempty(result.validation_report.extra_vars)
        fprintf('\nExtra variables:\n');
        for i = 1:numel(result.validation_report.extra_vars)
            fprintf('  - %s\n', result.validation_report.extra_vars{i});
        end
    end
end