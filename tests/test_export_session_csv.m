function test_export_session_csv()
%TEST_EXPORT_SESSION_CSV Unit test for export_session_csv.

    root_dir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(root_dir, 'core'));
    addpath(fullfile(root_dir, 'ml'));

    runtime = task_main();
    agent = default_agent();
    sessionlog = run_session_flow(runtime, agent);

    test_output_dir = fullfile(root_dir, 'output');
    if ~exist(test_output_dir, 'dir')
        mkdir(test_output_dir);
    end

    test_output_path = fullfile(test_output_dir, 'test_session_export.csv');

    if exist(test_output_path, 'file')
        delete(test_output_path);
    end

    returned_path = export_session_csv(sessionlog, test_output_path);

    assert(exist(test_output_path, 'file') == 2, 'CSV file was not created.');
    assert(strcmp(returned_path, test_output_path), ...
        'Returned path does not match requested output path.');

    T = readtable(test_output_path);
    assert(istable(T));
    assert(height(T) == sessionlog.n_trials);

    disp('test_export_session_csv passed');
end