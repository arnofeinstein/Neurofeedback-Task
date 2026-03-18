function test_validate_session_table()
%TEST_VALIDATE_SESSION_TABLE Unit test for validate_session_table.

    runtime = task_main();
    agent = default_agent();

    sessionlog = run_session_flow(runtime, agent);
    T = sessionlog_to_table(sessionlog);
    schema = build_behavior_schema();

    [T_valid, report] = validate_session_table(T, schema);

    assert(istable(T_valid));
    assert(isstruct(report));
    assert(isfield(report, 'is_valid'));
    assert(isfield(report, 'missing_vars'));
    assert(isfield(report, 'extra_vars'));
    assert(isfield(report, 'reordered_vars'));

    assert(report.is_valid == true);
    assert(isempty(report.missing_vars));
    assert(height(T_valid) == height(T));

    n_expected_present = numel(schema.recommended_order);
    assert(all(strcmp(T_valid.Properties.VariableNames(1:n_expected_present), ...
        schema.recommended_order)));

    % Test missing variable detection
    T_bad = removevars(T, 'response_angle');
    [~, report_bad] = validate_session_table(T_bad, schema);

    assert(report_bad.is_valid == false);
    assert(any(strcmp(report_bad.missing_vars, 'response_angle')));

    disp('test_validate_session_table passed');
end