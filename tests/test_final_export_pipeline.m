function test_final_export_pipeline()
%TEST_FINAL_EXPORT_PIPELINE Unit test for final_export_pipeline.

    root_dir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(root_dir, 'core'));
    addpath(fullfile(root_dir, 'ml'));

    runtime = task_main();
    agent = default_agent();
    sessionlog = run_session_flow(runtime, agent);

    output_dir = fullfile(root_dir, 'output');
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    output_path = fullfile(output_dir, 'test_final_export_pipeline.csv');

    if exist(output_path, 'file')
        delete(output_path);
    end

    result = final_export_pipeline(sessionlog, output_path);

    assert(isstruct(result));
    assert(isfield(result, 'table_raw'));
    assert(isfield(result, 'table_valid'));
    assert(isfield(result, 'schema'));
    assert(isfield(result, 'validation_report'));
    assert(isfield(result, 'output_path'));

    assert(istable(result.table_raw));
    assert(istable(result.table_valid));
    assert(result.validation_report.is_valid == true);

    assert(exist(output_path, 'file') == 2, 'Output CSV was not created.');
    assert(strcmp(result.output_path, output_path));

    T = readtable(output_path);
    assert(istable(T));
    assert(height(T) == sessionlog.n_trials);

    disp('test_final_export_pipeline passed');
end