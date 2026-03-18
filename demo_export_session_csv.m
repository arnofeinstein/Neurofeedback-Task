function demo_export_session_csv()
%DEMO_EXPORT_SESSION_CSV Run a session and export its trial table as CSV.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    rng(1);

    runtime = task_main();
    agent = default_agent();

    sessionlog = run_session_flow(runtime, agent);
    output_path = export_session_csv(sessionlog);

    fprintf('\nCSV written successfully:\n%s\n', output_path);
end