function test_build_behavior_schema()
%TEST_BUILD_BEHAVIOR_SCHEMA Unit test for build_behavior_schema.

    schema = build_behavior_schema();

    assert(isstruct(schema));
    assert(isfield(schema, 'metadata'));
    assert(isfield(schema, 'condition'));
    assert(isfield(schema, 'timing'));
    assert(isfield(schema, 'response'));
    assert(isfield(schema, 'outcome'));
    assert(isfield(schema, 'execution'));
    assert(isfield(schema, 'allowed_values'));
    assert(isfield(schema, 'recommended_order'));

    assert(iscell(schema.condition));
    assert(iscell(schema.timing));
    assert(iscell(schema.response));
    assert(iscell(schema.outcome));
    assert(iscell(schema.execution));
    assert(iscell(schema.recommended_order));

    assert(any(strcmp(schema.condition, 'sample_dir')));
    assert(any(strcmp(schema.response, 'response_angle')));
    assert(any(strcmp(schema.outcome, 'final_outcome')));
    assert(any(strcmp(schema.execution, 'last_state_name')));

    disp('test_build_behavior_schema passed');
end