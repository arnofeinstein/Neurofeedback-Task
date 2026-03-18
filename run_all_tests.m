function run_all_tests()
%RUN_ALL_TESTS Run all current tests for the project.

    root_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(root_dir, 'core'));
    addpath(fullfile(root_dir, 'tests'));
    addpath(fullfile(root_dir, 'ml'));

    fprintf('Running tests...\n');

    test_transform_rule();
    test_build_trial_table();
    test_evaluate_choice();
    test_simulate_trial();
    test_simulate_session();
    test_ml_prepare_trial();
    test_build_timing_blueprint();
    test_build_error_blueprint();
    test_build_trial_flow_spec();
    test_run_trial_flow();
    test_run_session_flow();
    test_sessionlog_to_table();
    test_export_session_csv();

    fprintf('All tests passed.\n');
end