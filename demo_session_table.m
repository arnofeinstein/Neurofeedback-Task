function demo_session_table()
%DEMO_SESSION_TABLE Run a session and display the first rows of the table.

    project_root = fileparts(mfilename('fullpath'));

    addpath(fullfile(project_root, 'core'));
    addpath(fullfile(project_root, 'ml'));

    rng(1);

    runtime = task_main();
    agent = default_agent();

    sessionlog = run_session_flow(runtime, agent);
    T = sessionlog_to_table(sessionlog);

    fprintf('\n=== Session table demo ===\n');
    fprintf('Rows: %d\n', height(T));
    fprintf('Columns: %d\n\n', width(T));

    disp(T(1:min(10,height(T)), :));
end